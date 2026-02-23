// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      transactionKind: json['transactionKind'] as String,
      closingMode: json['closingMode'] as String,
      status: json['status'] as String,
      buyerUserId: json['buyerUserId'] as String?,
      sellerUserId: json['sellerUserId'] as String?,
      agentUserId: json['agentUserId'] as String?,
      providerUserId: json['providerUserId'] as String?,
      currency: json['currency'] as String,
      principalAmount: (json['principalAmount'] as num?)?.toDouble(),
      inspectionFeeAmount: (json['inspectionFeeAmount'] as num).toDouble(),
      inspectionFeeRefundable: json['inspectionFeeRefundable'] as bool,
      inspectionFeeStatus: json['inspectionFeeStatus'] as String,
      escrowReference: json['escrowReference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'transactionKind': instance.transactionKind,
      'closingMode': instance.closingMode,
      'status': instance.status,
      'buyerUserId': instance.buyerUserId,
      'sellerUserId': instance.sellerUserId,
      'agentUserId': instance.agentUserId,
      'providerUserId': instance.providerUserId,
      'currency': instance.currency,
      'principalAmount': instance.principalAmount,
      'inspectionFeeAmount': instance.inspectionFeeAmount,
      'inspectionFeeRefundable': instance.inspectionFeeRefundable,
      'inspectionFeeStatus': instance.inspectionFeeStatus,
      'escrowReference': instance.escrowReference,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
