// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatActionImpl _$$ChatActionImplFromJson(Map<String, dynamic> json) =>
    _$ChatActionImpl(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      conversationId: json['conversationId'] as String,
      actionType: json['actionType'] as String,
      targetRole: json['targetRole'] as String,
      status: json['status'] as String,
      payload: json['payload'] as Map<String, dynamic>? ?? const {},
      createdByUserId: json['createdByUserId'] as String?,
      resolvedByUserId: json['resolvedByUserId'] as String?,
      expiresAt: json['expiresAt'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$ChatActionImplToJson(_$ChatActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'conversationId': instance.conversationId,
      'actionType': instance.actionType,
      'targetRole': instance.targetRole,
      'status': instance.status,
      'payload': instance.payload,
      'createdByUserId': instance.createdByUserId,
      'resolvedByUserId': instance.resolvedByUserId,
      'expiresAt': instance.expiresAt,
      'resolvedAt': instance.resolvedAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
