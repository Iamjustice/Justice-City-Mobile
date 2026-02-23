// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatAttachmentImpl _$$ChatAttachmentImplFromJson(Map<String, dynamic> json) =>
    _$ChatAttachmentImpl(
      bucketId: json['bucketId'] as String?,
      storagePath: json['storagePath'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String?,
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
      previewUrl: json['previewUrl'] as String?,
    );

Map<String, dynamic> _$$ChatAttachmentImplToJson(
        _$ChatAttachmentImpl instance) =>
    <String, dynamic>{
      'bucketId': instance.bucketId,
      'storagePath': instance.storagePath,
      'fileName': instance.fileName,
      'mimeType': instance.mimeType,
      'fileSizeBytes': instance.fileSizeBytes,
      'previewUrl': instance.previewUrl,
    };

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      sender: json['sender'] as String,
      content: json['content'] as String,
      time: json['time'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      senderId: json['senderId'] as String?,
      messageType: json['messageType'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => ChatAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ChatAttachment>[],
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'content': instance.content,
      'time': instance.time,
      'createdAt': instance.createdAt?.toIso8601String(),
      'senderId': instance.senderId,
      'messageType': instance.messageType,
      'metadata': instance.metadata,
      'attachments': instance.attachments,
    };
