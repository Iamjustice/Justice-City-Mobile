import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/transaction.dart';
import '../domain/models/chat_action.dart';
import '../domain/models/dispute.dart';
import 'repositories_providers.dart';
import '../data/repositories/transaction_repository.dart';
import 'me_provider.dart';
import 'session_provider.dart';

final transactionByConversationProvider =
    FutureProvider.family<Transaction?, String>((ref, conversationId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getByConversation(conversationId);
});

final transactionActionsProvider =
    FutureProvider.family<List<ChatAction>, String>((ref, transactionId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.listActions(transactionId);
});

final transactionDisputesProvider =
    FutureProvider.family<List<Dispute>, String>((ref, transactionId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.listDisputes(transactionId);
});

final transactionControllerProvider = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final session = ref.watch(sessionProvider);
  final me = ref.watch(meProvider);
  final userRole = me.maybeWhen(
    data: (u) => (u?.role ?? '').trim().toLowerCase(),
    orElse: () => 'buyer',
  );
  return _TransactionController(
    ref,
    repo,
    session?.userId ?? '',
    session?.email ?? 'User',
    userRole.isEmpty ? 'buyer' : userRole,
  );
});

class _TransactionController {
  final Ref ref;
  final TransactionRepository repo;
  final String userId;
  final String userName;
  final String userRole;

  _TransactionController(
    this.ref,
    this.repo,
    this.userId,
    this.userName,
    this.userRole,
  );

  Future<Transaction> upsertForConversation(String conversationId) async {
    final tx = await repo.upsert(conversationId: conversationId);
    ref.invalidate(transactionByConversationProvider(conversationId));
    return tx;
  }

  Future<Transaction> changeStatus(
      String conversationId, String txId, String toStatus,
      {String? reason}) async {
    final updated = await repo.changeStatus(
      transactionId: txId,
      toStatus: toStatus,
      actorUserId: userId,
      reason: reason,
    );
    ref.invalidate(transactionByConversationProvider(conversationId));
    ref.invalidate(transactionActionsProvider(txId));
    return updated;
  }

  Future<void> openDispute(String conversationId, String txId, String reason,
      {String? details}) async {
    await repo.openDispute(
      transactionId: txId,
      conversationId: conversationId,
      reason: reason,
      details: details,
      openedByUserId: userId,
      openedByName: userName,
      openedByRole: userRole,
    );
    ref.invalidate(transactionDisputesProvider(txId));
  }

  Future<TransactionActionCreateResult> createAction(
    String conversationId,
    String txId, {
    required String actionType,
    String? targetRole,
    String? content,
    Map<String, dynamic>? payload,
    String? expiresAt,
  }) async {
    final created = await repo.createAction(
      transactionId: txId,
      conversationId: conversationId,
      actionType: actionType,
      targetRole: targetRole,
      createdByUserId: userId,
      createdByName: userName,
      createdByRole: userRole,
      content: content,
      payload: payload,
      expiresAt: expiresAt,
    );
    ref.invalidate(transactionActionsProvider(txId));
    return created;
  }

  Future<PayoutClaimResult> claimPayout(
    String conversationId,
    String txId, {
    required double amount,
    required String ledgerType,
    String? currency,
    String? recipientUserId,
    String? reference,
  }) async {
    final idempotencyKey =
        '$txId:${DateTime.now().millisecondsSinceEpoch}:$userId';
    final result = await repo.claimPayout(
      transactionId: txId,
      idempotencyKey: idempotencyKey,
      amount: amount,
      ledgerType: ledgerType,
      currency: currency,
      recipientUserId: recipientUserId,
      reference: reference,
      metadata: {
        'requestedByUserId': userId,
        'requestedByRole': userRole,
      },
    );
    ref.invalidate(transactionByConversationProvider(conversationId));
    return result;
  }

  Future<TransactionActionResolveResult> resolveAction(
    String conversationId,
    String txId, {
    required String actionId,
    required String decision,
    Map<String, dynamic>? payload,
  }) async {
    final result = await repo.resolveAction(
      actionId: actionId,
      actorUserId: userId,
      actorRole: userRole,
      actorName: userName,
      decision: decision,
      payload: payload,
    );
    ref.invalidate(transactionActionsProvider(txId));
    ref.invalidate(transactionByConversationProvider(conversationId));
    return result;
  }

  Future<TransactionRatingResult> submitRating(
    String conversationId,
    String txId, {
    required int stars,
    String? review,
    String? ratedUserId,
  }) async {
    final result = await repo.submitRating(
      transactionId: txId,
      raterUserId: userId,
      stars: stars,
      review: review,
      ratedUserId: ratedUserId,
    );
    ref.invalidate(transactionByConversationProvider(conversationId));
    return result;
  }
}
