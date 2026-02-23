import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/transaction.dart';
import '../domain/models/chat_action.dart';
import '../domain/models/dispute.dart';
import 'repositories_providers.dart';
import '../data/repositories/transaction_repository.dart';
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
  return _TransactionController(ref, repo, session?.userId ?? '', session?.email ?? 'User');
});

class _TransactionController {
  final Ref ref;
  final TransactionRepository repo;
  final String userId;
  final String userName;

  _TransactionController(this.ref, this.repo, this.userId, this.userName);

  Future<Transaction> upsertForConversation(String conversationId) async {
    final tx = await repo.upsert(conversationId: conversationId);
    ref.invalidate(transactionByConversationProvider(conversationId));
    return tx;
  }

  Future<Transaction> changeStatus(String conversationId, String txId, String toStatus, {String? reason}) async {
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

  Future<void> openDispute(String conversationId, String txId, String reason, {String? details}) async {
    await repo.openDispute(
      transactionId: txId,
      conversationId: conversationId,
      reason: reason,
      details: details,
      openedByUserId: userId,
      openedByName: userName,
      openedByRole: 'buyer',
    );
    ref.invalidate(transactionDisputesProvider(txId));
  }
}
