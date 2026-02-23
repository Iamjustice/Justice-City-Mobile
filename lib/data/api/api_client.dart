import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../env.dart';
import '../../state/session_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(sessionProvider);

  final dio = Dio(BaseOptions(
    baseUrl: Env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final jwt = session?.accessToken;
        if (jwt != null && jwt.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $jwt';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
    ),
  );

  return dio;
});
