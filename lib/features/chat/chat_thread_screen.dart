import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_conversation.dart';
import '../../domain/models/chat_message.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);

final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, conversationId) async {
  final session = ref.watch(sessionProvider);
  final viewerId = session?.userId;
  if (viewerId == null) return const [];
  return ref.read(chatRepositoryProvider).getMessages(conversationId: conversationId, viewerId: viewerId);
});

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  final String conversationId;
  final ChatConversation? conversation;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  final List<PlatformFile> _pendingFiles = [];
  bool _sending = false;

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
    setState(() => _pendingFiles.addAll(result.files.take(5 - _pendingFiles.length)));
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
        final payload = <LocalFilePayload>[];
        for (final file in _pendingFiles) {
          final bytes = file.bytes;
          if (bytes == null || bytes.isEmpty) continue;
          payload.add(
            LocalFilePayload.fromBytes(
              fileName: file.name,
              bytes: bytes,
              mimeType: lookupMimeType(file.name, headerBytes: bytes),
            ),
          );
        }
        if (payload.isNotEmpty) {
          uploaded = await repo.uploadAttachments(
            conversationId: widget.conversationId,
            senderId: senderId,
            files: payload,
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
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.conversationId));
    final session = ref.watch(sessionProvider);
    final meId = session?.userId ?? '';
    final title = (widget.conversation?.subject?.trim().isNotEmpty ?? false)
        ? widget.conversation!.subject!.trim()
        : 'Conversation';

    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: _jcHeading,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Transaction Center',
            onPressed: () => context.push('/transaction/${widget.conversationId}'),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(chatMessagesProvider(widget.conversationId)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _jcPanelBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        border: Border(
                          bottom: BorderSide(color: _jcPanelBorder),
                        ),
                      ),
                      child: const Text(
                        'Use this thread for listing support, transaction updates, and file exchange.',
                        style: TextStyle(fontSize: 14, color: _jcMuted),
                      ),
                    ),
                    Expanded(
                      child: messages.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const Center(
                              child: Text(
                                'No messages yet.',
                                style: TextStyle(color: _jcMuted),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final msg = items[i];
                              final isMe = msg.senderId != null && msg.senderId == meId;
                              return _Bubble(
                                message: msg,
                                isMe: isMe,
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Failed to load messages: $e')),
                      ),
                    ),
                    if (_pendingFiles.isNotEmpty)
                      SizedBox(
                        height: 52,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _pendingFiles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (_, i) => Chip(
                            side: const BorderSide(color: _jcPanelBorder),
                            label: Text(_pendingFiles[i].name, overflow: TextOverflow.ellipsis),
                            onDeleted: () => setState(() => _pendingFiles.removeAt(i)),
                          ),
                        ),
                      ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: _jcPanelBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.attach_file),
                              onPressed: _sending ? null : _pickFiles,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Type message...',
                                  hintStyle: TextStyle(color: _jcMuted),
                                  fillColor: Color(0xFFF8FAFC),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: _jcPanelBorder),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _sending ? null : _send,
                              child: _sending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Send'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMe});
  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? const Color(0xFF2563EB) : Colors.white;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            border: Border.all(color: isMe ? const Color(0xFF2563EB) : _jcPanelBorder),
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              if (message.messageType != 'text')
                Text(
                  message.messageType,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? const Color(0xFFDBEAFE) : _jcMuted,
                  ),
                ),
              if (message.content.isNotEmpty)
                Text(
                  message.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: isMe ? Colors.white : _jcHeading,
                  ),
                ),
              for (final attachment in message.attachments)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          attachment.fileName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? const Color(0xFFDBEAFE) : _jcMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
