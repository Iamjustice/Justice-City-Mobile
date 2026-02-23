import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/session_provider.dart';
import '../data/api/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/listings_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/verification_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/services_repository.dart';
import '../data/repositories/admin_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(supabaseProvider));
});

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  return ListingsRepository(ref.watch(dioProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ref.watch(dioProvider));
});


final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TransactionRepository(dio);
});


final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository(ref.watch(dioProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(dioProvider));
});
