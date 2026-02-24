import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/chat_conversation.dart';
import '../../data/repositories/chat_repository.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';

final chatInboxProvider = FutureProvider<ChatInboxData>((ref) async {
  final session = ref.watch(sessionProvider);
  final viewerId = session?.userId;
  if (viewerId == null) {
    return const ChatInboxData(
      conversations: <ChatConversation>[],
      cards: <UserChatCard>[],
    );
  }

  final viewerName = session?.email ?? '';
  final repo = ref.read(chatRepositoryProvider);
  final conversations = await repo.listConversations(
    viewerId: viewerId,
    viewerName: viewerName,
  );
  final cards = await repo.listChatCards(userId: viewerId);
  return ChatInboxData(conversations: conversations, cards: cards);
});

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(chatInboxProvider);
    await ref.read(chatInboxProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(chatInboxProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: inbox.when(
        data: (data) {
          if (data.cards.isEmpty && data.conversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(
                      child:
                          Text('No conversations or issue notifications yet.')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (data.cards.isNotEmpty) ...[
                  const Text(
                    'Issue Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ...data.cards.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChatCardTile(card: card),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Conversations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (data.conversations.isEmpty)
                  const Text(
                    'No conversations yet.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ...data.conversations.map(
                  (c) {
                    final title = (c.subject?.trim().isNotEmpty ?? false)
                        ? c.subject!.trim()
                        : (c.participants.isNotEmpty
                            ? c.participants.map((p) => p.name).join(', ')
                            : 'Conversation');
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(c.lastMessage ?? ''),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/chat/${c.id}', extra: c),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed: $e')),
      ),
    );
  }
}

class ChatInboxData {
  const ChatInboxData({
    required this.conversations,
    required this.cards,
  });

  final List<ChatConversation> conversations;
  final List<UserChatCard> cards;
}

class _ChatCardTile extends StatelessWidget {
  const _ChatCardTile({required this.card});

  final UserChatCard card;

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(card.createdAt);
    final unread = card.isUnread;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (card.conversationId != null && card.conversationId!.isNotEmpty) {
            if (card.transactionId != null && card.transactionId!.isNotEmpty) {
              context.push('/transaction/${card.conversationId!}');
              return;
            }
            context.go('/chat/${card.conversationId!}');
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('No linked conversation for this notification yet.')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(card.problemTag)),
                  Chip(
                    label: Text(unread ? 'unread' : 'read'),
                    backgroundColor:
                        unread ? Colors.amber.shade100 : Colors.green.shade100,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                card.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(card.message),
              if (dateLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  dateLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDate(String raw) {
    if (raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
}
