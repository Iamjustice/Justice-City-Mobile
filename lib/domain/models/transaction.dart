import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

String? _asString(dynamic v) => v?.toString();
double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
bool _asBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return fallback;
}

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String conversationId,
    required String transactionKind,
    required String closingMode,
    required String status,
    String? buyerUserId,
    String? sellerUserId,
    String? agentUserId,
    String? providerUserId,
    required String currency,
    double? principalAmount,
    required double inspectionFeeAmount,
    required bool inspectionFeeRefundable,
    required String inspectionFeeStatus,
    String? escrowReference,
    @Default({}) Map<String, dynamic> metadata,
    required String createdAt,
    required String updatedAt,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson({
        'id': _asString(json['id']) ?? '',
        'conversationId': _asString(json['conversationId'] ?? json['conversation_id']) ?? '',
        'transactionKind': _asString(json['transactionKind'] ?? json['transaction_kind']) ?? 'sale',
        'closingMode': _asString(json['closingMode'] ?? json['closing_mode']) ?? 'direct',
        'status': _asString(json['status']) ?? 'initiated',
        'buyerUserId': _asString(json['buyerUserId'] ?? json['buyer_user_id']),
        'sellerUserId': _asString(json['sellerUserId'] ?? json['seller_user_id']),
        'agentUserId': _asString(json['agentUserId'] ?? json['agent_user_id']),
        'providerUserId': _asString(json['providerUserId'] ?? json['provider_user_id']),
        'currency': _asString(json['currency']) ?? 'NGN',
        'principalAmount': _asDouble(json['principalAmount'] ?? json['principal_amount']),
        'inspectionFeeAmount': _asDouble(json['inspectionFeeAmount'] ?? json['inspection_fee_amount']) ?? 0,
        'inspectionFeeRefundable': _asBool(json['inspectionFeeRefundable'] ?? json['inspection_fee_refundable'], fallback: true),
        'inspectionFeeStatus': _asString(json['inspectionFeeStatus'] ?? json['inspection_fee_status']) ?? 'not_applicable',
        'escrowReference': _asString(json['escrowReference'] ?? json['escrow_reference']),
        'metadata': (json['metadata'] is Map) ? Map<String, dynamic>.from(json['metadata']) : <String, dynamic>{},
        'createdAt': _asString(json['createdAt'] ?? json['created_at']) ?? '',
        'updatedAt': _asString(json['updatedAt'] ?? json['updated_at']) ?? '',
      });
}
