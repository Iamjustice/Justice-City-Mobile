// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatParticipantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$ChatParticipantImplToJson(
        _$ChatParticipantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

_$ChatConversationImpl _$$ChatConversationImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatConversationImpl(
      id: json['id'] as String,
      subject: json['subject'] as String?,
      listingId: json['listingId'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ChatParticipant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ChatParticipant>[],
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ChatConversationImplToJson(
        _$ChatConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'listingId': instance.listingId,
      'participants': instance.participants,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
