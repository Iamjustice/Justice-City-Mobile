import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';
import '../../data/repositories/chat_repository.dart';

final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  final session = ref.watch(sessionProvider);
  final viewerId = session?.userId;
  if (viewerId == null) return const [];
  return ref.read(chatRepositoryProvider).getMessages(conversationId: conversationId, viewerId: viewerId);
});

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.conversationId, this.conversation});

  final String conversationId;
  final ChatConversation? conversation;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  bool _sending = false;
  final List<PlatformFile> _pendingFiles = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );
    if (result == null) return;

    setState(() {
      _pendingFiles.addAll(result.files.take(5 - _pendingFiles.length));
    });
  }

  void _removePending(int i) {
    setState(() => _pendingFiles.removeAt(i));
  }

  Future<void> _send() async {
    final session = ref.read(sessionProvider);
    final senderId = session?.userId;
    if (senderId == null) return;

    final text = _controller.text.trim();
    if (text.isEmpty && _pendingFiles.isEmpty) return;

    setState(() => _sending = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final senderName = session?.email ?? 'User';

      List<Map<String, dynamic>>? uploaded;

      if (_pendingFiles.isNotEmpty) {
        final localPayloads = <LocalFilePayload>[];
        for (final f in _pendingFiles) {
          final bytes = f.bytes;
          if (bytes == null || bytes.isEmpty) continue;
          final mime = lookupMimeType(f.name, headerBytes: bytes);
          localPayloads.add(LocalFilePayload.fromBytes(fileName: f.name, bytes: bytes, mimeType: mime));
        }
        if (localPayloads.isNotEmpty) {
          uploaded = await repo.uploadAttachments(
            conversationId: widget.conversationId,
            senderId: senderId,
            files: localPayloads,
          );
        }
      }

      await repo.sendMessage(
        conversationId: widget.conversationId,
        senderId: senderId,
        senderName: senderName,
        content: text,
        attachments: uploaded,
      );

      _controller.clear();
      setState(() => _pendingFiles.clear());
      ref.invalidate(chatMessagesProvider(widget.conversationId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.conversationId));

    final title = (widget.conversation?.subject?.trim().isNotEmpty ?? false)
        ? widget.conversation!.subject!.trim()
        : 'Conversation';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Transaction & Escrow',
            onPressed: () {
              context.push('/transaction/${widget.conversationId}');
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(chatMessagesProvider(widget.conversationId)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final m = items[items.length - 1 - i];
                    final isMe = m.sender == 'me';
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (m.messageType != 'text' && m.messageType != 'system')
                                  Text(m.messageType, style: const TextStyle(fontSize: 12)),
                                if (m.content.isNotEmpty) Text(m.content),
                                if (m.attachments.isNotEmpty) const SizedBox(height: 8),
                                for (final a in m.attachments)
                                  _AttachmentTile(attachment: a),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed: $e')),
            ),
          ),
          if (_pendingFiles.isNotEmpty)
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _pendingFiles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _pendingFiles[i];
                  return Chip(
                    label: Text(f.name, overflow: TextOverflow.ellipsis),
                    onDeleted: () => _removePending(i),
                  );
                },
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Attach',
                    onPressed: _sending ? null : _pickFiles,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    final label = attachment.fileName;
    final subtitle = attachment.previewUrl ?? attachment.storagePath;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
