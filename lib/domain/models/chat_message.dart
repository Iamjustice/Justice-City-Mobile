import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
class ChatAttachment with _$ChatAttachment {
  const factory ChatAttachment({
    String? bucketId,
    required String storagePath,
    required String fileName,
    String? mimeType,
    int? fileSizeBytes,
    String? previewUrl,
  }) = _ChatAttachment;

  factory ChatAttachment.fromJson(Map<String, dynamic> json) => _$ChatAttachmentFromJson(json);
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String sender, // me | them | system
    required String content,
    String? time,
    DateTime? createdAt,
    String? senderId,
    required String messageType, // text | system | issue_card
    Map<String, dynamic>? metadata,
    @Default(<ChatAttachment>[]) List<ChatAttachment> attachments,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
}
