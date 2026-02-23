import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';
part 'chat_conversation.g.dart';

@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String id,
    required String name,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);
}

@freezed
class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String id,
    String? subject,
    String? listingId,
    @Default(<ChatParticipant>[]) List<ChatParticipant> participants,
    String? lastMessage,
    DateTime? lastMessageAt,
    DateTime? updatedAt,
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);
}
