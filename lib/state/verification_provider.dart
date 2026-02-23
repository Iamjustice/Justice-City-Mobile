import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/verification_status.dart';
import 'session_provider.dart';
import 'repositories_providers.dart';

/// Holds the latest verification status for the signed-in user.
///
/// Uses the backend endpoint: GET /api/verification/status/:userId
final verificationStatusProvider =
    AsyncNotifierProvider<VerificationStatusNotifier, VerificationStatus?>(VerificationStatusNotifier.new);

class VerificationStatusNotifier extends AsyncNotifier<VerificationStatus?> {
  @override
  Future<VerificationStatus?> build() async {
    final session = ref.watch(sessionProvider);
    if (session == null) return null;

    final repo = ref.read(verificationRepositoryProvider);
    final status = await repo.fetchStatus(userId: session.userId);
    return status;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// Convenience boolean: whether current user is verified.
/// Defaults to false when unknown/unavailable.
final isVerifiedProvider = Provider<bool>((ref) {
  final status = ref.watch(verificationStatusProvider);
  return status.maybeWhen(data: (s) => s?.isVerified == true, orElse: () => false);
});
