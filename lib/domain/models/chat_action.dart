import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_action.freezed.dart';
part 'chat_action.g.dart';

String? _asString(dynamic v) => v?.toString();

@freezed
class ChatAction with _$ChatAction {
  const factory ChatAction({
    required String id,
    required String transactionId,
    required String conversationId,
    required String actionType,
    required String targetRole,
    required String status,
    @Default({}) Map<String, dynamic> payload,
    String? createdByUserId,
    String? resolvedByUserId,
    String? expiresAt,
    String? resolvedAt,
    required String createdAt,
    required String updatedAt,
  }) = _ChatAction;

  factory ChatAction.fromJson(Map<String, dynamic> json) => _$ChatActionFromJson({
        'id': _asString(json['id']) ?? '',
        'transactionId': _asString(json['transactionId'] ?? json['transaction_id']) ?? '',
        'conversationId': _asString(json['conversationId'] ?? json['conversation_id']) ?? '',
        'actionType': _asString(json['actionType'] ?? json['action_type']) ?? '',
        'targetRole': _asString(json['targetRole'] ?? json['target_role']) ?? '',
        'status': _asString(json['status']) ?? '',
        'payload': (json['payload'] is Map) ? Map<String, dynamic>.from(json['payload']) : <String, dynamic>{},
        'createdByUserId': _asString(json['createdByUserId'] ?? json['created_by_user_id']),
        'resolvedByUserId': _asString(json['resolvedByUserId'] ?? json['resolved_by_user_id']),
        'expiresAt': _asString(json['expiresAt'] ?? json['expires_at']),
        'resolvedAt': _asString(json['resolvedAt'] ?? json['resolved_at']),
        'createdAt': _asString(json['createdAt'] ?? json['created_at']) ?? '',
        'updatedAt': _asString(json['updatedAt'] ?? json['updated_at']) ?? '',
      });
}
