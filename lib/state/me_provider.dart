import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/app_user.dart';
import 'repositories_providers.dart';
import 'session_provider.dart';

/// Loads the current user's profile from the Node API (/api/auth/me).
/// Used for role-based routing (admin dashboard).
final meProvider = FutureProvider<AppUser?>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return null;
  final repo = ref.watch(authRepositoryProvider);
  try {
    return await repo.fetchMe();
  } catch (_) {
    // Fallback: basic session user
    return AppUser(id: session.userId, email: session.email);
  }
});

final isAdminProvider = Provider<bool>((ref) {
  final me = ref.watch(meProvider);
  return me.maybeWhen(
    data: (u) => (u?.role ?? '').toLowerCase() == 'admin',
    orElse: () => false,
  );
});
