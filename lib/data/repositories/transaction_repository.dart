import 'package:dio/dio.dart';

import '../api/endpoints.dart';
import '../../domain/models/chat_action.dart';
import '../../domain/models/dispute.dart';
import '../../domain/models/transaction.dart';

class TransactionRepository {
  TransactionRepository(this._dio);

  final Dio _dio;

  Future<Transaction?> getByConversation(String conversationId) async {
    final res =
        await _dio.get(ApiEndpoints.transactionByConversation(conversationId));
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
    final res =
        await _dio.post(ApiEndpoints.transactionStatus(transactionId), data: {
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

  Future<TransactionActionCreateResult> createAction({
    required String transactionId,
    required String conversationId,
    required String actionType,
    required String createdByUserId,
    required String createdByName,
    required String createdByRole,
    String? targetRole,
    String? content,
    Map<String, dynamic>? payload,
    String? expiresAt,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.transactionActions(transactionId),
        data: {
          'conversationId': conversationId,
          'actionType': actionType,
          if (targetRole != null && targetRole.trim().isNotEmpty)
            'targetRole': targetRole.trim(),
          'createdByUserId': createdByUserId,
          'createdByName': createdByName,
          if (createdByRole.trim().isNotEmpty) 'createdByRole': createdByRole,
          if (content != null && content.trim().isNotEmpty)
            'content': content.trim(),
          if (payload != null) 'payload': payload,
          if (expiresAt != null && expiresAt.trim().isNotEmpty)
            'expiresAt': expiresAt.trim(),
        },
      );

      final raw = res.data;
      final map =
          raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      final actionRaw =
          map['action'] is Map ? map['action'] as Map : raw as Map?;
      if (actionRaw == null) {
        throw Exception('Invalid action response from server.');
      }

      final action = ChatAction.fromJson(Map<String, dynamic>.from(actionRaw));
      final warnings = (map['warnings'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const <String>[];

      return TransactionActionCreateResult(action: action, warnings: warnings);
    } on DioException catch (e) {
      throw Exception(
          _formatApiError(e, fallback: 'Failed to create transaction action.'));
    }
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
    final res =
        await _dio.post(ApiEndpoints.transactionDisputes(transactionId), data: {
      'conversationId': conversationId,
      'reason': reason,
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
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
      if (resolutionTargetStatus != null)
        'resolutionTargetStatus': resolutionTargetStatus,
      'resolvedByUserId': resolvedByUserId,
      'resolvedByRole': resolvedByRole,
    });
    return Dispute.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<PayoutClaimResult> claimPayout({
    required String transactionId,
    required String idempotencyKey,
    required double amount,
    required String ledgerType,
    String? currency,
    String? recipientUserId,
    String? reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.transactionPayoutClaim(transactionId),
        data: {
          'idempotencyKey': idempotencyKey,
          'amount': amount,
          'ledgerType': ledgerType,
          if (currency != null && currency.trim().isNotEmpty)
            'currency': currency.trim(),
          if (recipientUserId != null && recipientUserId.trim().isNotEmpty)
            'recipientUserId': recipientUserId.trim(),
          if (reference != null && reference.trim().isNotEmpty)
            'reference': reference.trim(),
          if (metadata != null) 'metadata': metadata,
        },
      );

      final map = res.data is Map
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};
      return PayoutClaimResult(
        claimed: map['claimed'] == true,
        idempotencyKey: (map['idempotencyKey'] ?? '').toString(),
        entryId: (map['entryId'] ?? '').toString(),
      );
    } on DioException catch (e) {
      throw Exception(
          _formatApiError(e, fallback: 'Failed to claim payout ledger entry.'));
    }
  }

  Future<TransactionRatingResult> submitRating({
    required String transactionId,
    required String raterUserId,
    required int stars,
    String? review,
    String? ratedUserId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.transactionRatings(transactionId),
        data: {
          'raterUserId': raterUserId,
          'stars': stars,
          if (review != null && review.trim().isNotEmpty)
            'review': review.trim(),
          if (ratedUserId != null && ratedUserId.trim().isNotEmpty)
            'ratedUserId': ratedUserId.trim(),
        },
      );

      final map = res.data is Map
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};
      return TransactionRatingResult(
        created: map['created'] == true,
        ratingId: (map['ratingId'] ?? '').toString(),
        editableUntil: (map['editableUntil'] ?? '').toString().trim().isEmpty
            ? null
            : (map['editableUntil']).toString(),
      );
    } on DioException catch (e) {
      throw Exception(
          _formatApiError(e, fallback: 'Failed to submit transaction rating.'));
    }
  }

  String _formatApiError(DioException error, {required String fallback}) {
    final response = error.response;
    final status = response?.statusCode;
    final payload = response?.data;

    String? serverMessage;
    if (payload is Map && payload['message'] != null) {
      serverMessage = payload['message'].toString().trim();
    } else {
      final raw = payload?.toString().trim();
      if (raw != null && raw.isNotEmpty) {
        serverMessage = raw;
      }
    }

    final effective = (serverMessage?.isNotEmpty ?? false)
        ? serverMessage!
        : (error.message?.trim().isNotEmpty ?? false)
            ? error.message!.trim()
            : fallback;

    if (status == null) return effective;
    return '$status: $effective';
  }
}

class TransactionActionCreateResult {
  TransactionActionCreateResult({
    required this.action,
    required this.warnings,
  });

  final ChatAction action;
  final List<String> warnings;
}

class PayoutClaimResult {
  PayoutClaimResult({
    required this.claimed,
    required this.idempotencyKey,
    required this.entryId,
  });

  final bool claimed;
  final String idempotencyKey;
  final String entryId;
}

class TransactionRatingResult {
  TransactionRatingResult({
    required this.created,
    required this.ratingId,
    this.editableUntil,
  });

  final bool created;
  final String ratingId;
  final String? editableUntil;
}
