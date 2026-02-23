import 'package:dio/dio.dart';
import '../api/endpoints.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/chat_action.dart';
import '../../domain/models/dispute.dart';

class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  Future<Transaction?> getByConversation(String conversationId) async {
    final res = await _dio.get(ApiEndpoints.transactionByConversation(conversationId));
    if (res.data == null || res.data is! Map) return null;
    final data = Map<String, dynamic>.from(res.data as Map);
    if ((data['id'] ?? '').toString().isEmpty) return null;
    return Transaction.fromJson(data);
  }

  Future<Transaction> upsert({
    required String conversationId,
    String transactionKind = 'sale',
    String closingMode = 'direct',
    String status = 'initiated',
    Map<String, dynamic>? metadata,
  }) async {
    final res = await _dio.post(ApiEndpoints.transactionsUpsert, data: {
      'conversationId': conversationId,
      'transactionKind': transactionKind,
      'closingMode': closingMode,
      'status': status,
      if (metadata != null) 'metadata': metadata,
    });
    return Transaction.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Transaction> changeStatus({
    required String transactionId,
    required String toStatus,
    required String actorUserId,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    final res = await _dio.post(ApiEndpoints.transactionStatus(transactionId), data: {
      'toStatus': toStatus,
      'actorUserId': actorUserId,
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      if (metadata != null) 'metadata': metadata,
    });
    return Transaction.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<ChatAction>> listActions(String transactionId) async {
    final res = await _dio.get(ApiEndpoints.transactionActions(transactionId));
    final raw = (res.data as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => ChatAction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Dispute>> listDisputes(String transactionId) async {
    final res = await _dio.get(ApiEndpoints.transactionDisputes(transactionId));
    final raw = (res.data as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((e) => Dispute.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Dispute> openDispute({
    required String transactionId,
    required String conversationId,
    required String reason,
    String? details,
    required String openedByUserId,
    required String openedByName,
    required String openedByRole,
  }) async {
    final res = await _dio.post(ApiEndpoints.transactionDisputes(transactionId), data: {
      'conversationId': conversationId,
      'reason': reason,
      if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
      'openedByUserId': openedByUserId,
      'openedByName': openedByName,
      'openedByRole': openedByRole,
    });
    return Dispute.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<Dispute> resolveDispute({
    required String disputeId,
    required String status,
    required String resolution,
    String? resolutionTargetStatus,
    required String resolvedByUserId,
    required String resolvedByRole,
  }) async {
    final res = await _dio.post(ApiEndpoints.resolveDispute(disputeId), data: {
      'status': status,
      'resolution': resolution,
      if (resolutionTargetStatus != null) 'resolutionTargetStatus': resolutionTargetStatus,
      'resolvedByUserId': resolvedByUserId,
      'resolvedByRole': resolvedByRole,
    });
    return Dispute.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
