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
        title: const SizedBox(
          height: 32,
          child: _BrandWordmark(),
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
              _InboxQuickRail(
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
                                  child: _ConversationTile(
                                      conversation: conversation),
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
  const _InboxHeader(
      {required this.totalConversations, required this.totalIssues});
  final int totalConversations;
  final int totalIssues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat Workspace',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Track issue cards, listing discussions, and support threads.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _pill('Threads', '$totalConversations'),
              const SizedBox(height: 8),
              _pill('Issues', '$totalIssues'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFFE2E8F0),
          ),
        ),
      );
}

class _InboxQuickRail extends StatelessWidget {
  const _InboxQuickRail({
    required this.totalConversations,
    required this.totalIssues,
  });

  final int totalConversations;
  final int totalIssues;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniInboxMetric(
            label: 'Open threads',
            value: '$totalConversations',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniInboxMetric(
            label: 'Issue cards',
            value: '$totalIssues',
          ),
        ),
      ],
    );
  }
}

class _MiniInboxMetric extends StatelessWidget {
  const _MiniInboxMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _jcMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
            ),
          ),
        ],
      ),
    );
  }
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.forum_outlined,
                    color: _jcHeading, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: _jcHeading,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
      borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _jcPanelBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnread
                    ? const Color(0xFFFEF3C7)
                    : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isUnread ? 'Unread' : 'Read',
                style: TextStyle(
                  color: isUnread
                      ? const Color(0xFFB45309)
                      : const Color(0xFF15803D),
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
                  Text(
                    card.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _jcHeading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.message,
                    style:
                        const TextStyle(fontSize: 14, color: Color(0xFF475569)),
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
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.go('/chat/${conversation.id}', extra: conversation),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
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
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'JUSTICE CITY',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _jcHeading,
          ),
        ),
      ),
    );
  }
}
