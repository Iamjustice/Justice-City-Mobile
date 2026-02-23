import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispute.freezed.dart';
part 'dispute.g.dart';

String? _asString(dynamic v) => v == null ? null : v.toString();

@freezed
class Dispute with _$Dispute {
  const factory Dispute({
    required String id,
    required String transactionId,
    required String conversationId,
    String? openedByUserId,
    String? againstUserId,
    required String reason,
    String? details,
    required String status,
    String? resolution,
    String? resolutionTargetStatus,
    String? resolvedByUserId,
    String? resolvedAt,
    @Default({}) Map<String, dynamic> metadata,
    required String createdAt,
    required String updatedAt,
  }) = _Dispute;

  factory Dispute.fromJson(Map<String, dynamic> json) => _$DisputeFromJson({
        'id': _asString(json['id']) ?? '',
        'transactionId': _asString(json['transactionId'] ?? json['transaction_id']) ?? '',
        'conversationId': _asString(json['conversationId'] ?? json['conversation_id']) ?? '',
        'openedByUserId': _asString(json['openedByUserId'] ?? json['opened_by_user_id']),
        'againstUserId': _asString(json['againstUserId'] ?? json['against_user_id']),
        'reason': _asString(json['reason']) ?? '',
        'details': _asString(json['details']),
        'status': _asString(json['status']) ?? 'open',
        'resolution': _asString(json['resolution']),
        'resolutionTargetStatus': _asString(json['resolutionTargetStatus'] ?? json['resolution_target_status']),
        'resolvedByUserId': _asString(json['resolvedByUserId'] ?? json['resolved_by_user_id']),
        'resolvedAt': _asString(json['resolvedAt'] ?? json['resolved_at']),
        'metadata': (json['metadata'] is Map) ? Map<String, dynamic>.from(json['metadata']) : <String, dynamic>{},
        'createdAt': _asString(json['createdAt'] ?? json['created_at']) ?? '',
        'updatedAt': _asString(json['updatedAt'] ?? json['updated_at']) ?? '',
      });
}
