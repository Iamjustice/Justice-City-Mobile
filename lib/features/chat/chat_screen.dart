import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/chat_conversation.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';

final conversationsProvider = FutureProvider<List<ChatConversation>>((ref) async {
  final session = ref.watch(sessionProvider);
  final viewerId = session?.userId;
  if (viewerId == null) return const [];
  final viewerName = session?.email ?? '';
  return ref.read(chatRepositoryProvider).listConversations(
        viewerId: viewerId,
        viewerName: viewerName,
      );
});

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(conversationsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: conversations.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (_, i) {
              final c = items[i];
              final title = (c.subject?.trim().isNotEmpty ?? false)
                  ? c.subject!.trim()
                  : (c.participants.isNotEmpty ? c.participants.map((p) => p.name).join(', ') : 'Conversation');

              return ListTile(
                title: Text(title),
                subtitle: Text(c.lastMessage ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/chat/${c.id}', extra: c),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed: $e')),
      ),
    );
  }
}
