// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispute.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisputeImpl _$$DisputeImplFromJson(Map<String, dynamic> json) =>
    _$DisputeImpl(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String,
      conversationId: json['conversationId'] as String,
      openedByUserId: json['openedByUserId'] as String?,
      againstUserId: json['againstUserId'] as String?,
      reason: json['reason'] as String,
      details: json['details'] as String?,
      status: json['status'] as String,
      resolution: json['resolution'] as String?,
      resolutionTargetStatus: json['resolutionTargetStatus'] as String?,
      resolvedByUserId: json['resolvedByUserId'] as String?,
      resolvedAt: json['resolvedAt'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$DisputeImplToJson(_$DisputeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'conversationId': instance.conversationId,
      'openedByUserId': instance.openedByUserId,
      'againstUserId': instance.againstUserId,
      'reason': instance.reason,
      'details': instance.details,
      'status': instance.status,
      'resolution': instance.resolution,
      'resolutionTargetStatus': instance.resolutionTargetStatus,
      'resolvedByUserId': instance.resolvedByUserId,
      'resolvedAt': instance.resolvedAt,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
