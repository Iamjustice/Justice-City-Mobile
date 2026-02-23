import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final sessionProvider = StateNotifierProvider<SessionNotifier, Session?>((ref) {
  final client = ref.watch(supabaseProvider);
  return SessionNotifier(client);
});

class SessionNotifier extends StateNotifier<Session?> {
  SessionNotifier(this._client) : super(_client.auth.currentSession) {
    _sub = _client.auth.onAuthStateChange.listen((data) {
      state = data.session;
    });
  }

  final SupabaseClient _client;
  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}


extension SessionX on Session {
  String get userId => user.id;
  String? get email => user.email;
}
