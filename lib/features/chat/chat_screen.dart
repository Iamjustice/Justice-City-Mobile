import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_conversation.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);

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
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chat Inbox',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 30,
            color: _jcHeading,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: inbox.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _InboxHeader(
                totalConversations: data.conversations.length,
                totalIssues: data.cards.length,
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Issue Notifications',
                subtitle: 'System-generated cards that need attention.',
                child: data.cards.isEmpty
                    ? const Text(
                        'No issue notifications.',
                        style: TextStyle(fontSize: 14, color: _jcMuted),
                      )
                    : Column(
                        children: data.cards
                            .map((card) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _IssueCard(card: card),
                                ))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Conversations',
                subtitle: 'Open listing/service/support threads.',
                child: data.conversations.isEmpty
                    ? const Text(
                        'No conversations yet.',
                        style: TextStyle(fontSize: 14, color: _jcMuted),
                      )
                    : Column(
                        children: data.conversations
                            .map((conversation) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _ConversationTile(conversation: conversation),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load chat inbox: $e')),
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

class _InboxHeader extends StatelessWidget {
  const _InboxHeader({required this.totalConversations, required this.totalIssues});
  final int totalConversations;
  final int totalIssues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Chat Workspace',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _jcHeading,
              ),
            ),
          ),
          _pill('Threads', '$totalConversations'),
          const SizedBox(width: 8),
          _pill('Issues', '$totalIssues'),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: _jcPanelBorder),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: _jcHeading,
          ),
        ),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _jcHeading,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: _jcMuted),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.card});
  final UserChatCard card;

  @override
  Widget build(BuildContext context) {
    final isUnread = card.isUnread;
    return InkWell(
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
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _jcPanelBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnread ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isUnread ? 'Unread' : 'Read',
                style: TextStyle(
                  color: isUnread ? const Color(0xFFB45309) : const Color(0xFF15803D),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    card.message,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.problemTag,
                    style: const TextStyle(fontSize: 12, color: _jcMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});
  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    final title = (conversation.subject?.trim().isNotEmpty ?? false)
        ? conversation.subject!.trim()
        : (conversation.participants.isNotEmpty
            ? conversation.participants.map((p) => p.name).join(', ')
            : 'Conversation');
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.go('/chat/${conversation.id}', extra: conversation),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _jcPanelBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if ((conversation.lastMessage ?? '').trim().isNotEmpty)
                    Text(
                      conversation.lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: _jcMuted),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
