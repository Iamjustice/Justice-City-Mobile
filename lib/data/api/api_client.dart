import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../env.dart';
import '../../state/session_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final session = ref.watch(sessionProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

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
      onError: (error, handler) async {
        if (!_shouldRetryWithFallback(error)) {
          return handler.next(error);
        }

        final fallbackUri = Env.apiFallbackUri;
        if (fallbackUri == null) {
          return handler.next(error);
        }

        final retryOptions = error.requestOptions.copyWith(
          baseUrl: '${fallbackUri.scheme}://${fallbackUri.authority}',
          extra: <String, dynamic>{
            ...error.requestOptions.extra,
            'failoverTried': true,
          },
        );

        try {
          final response = await dio.fetch<dynamic>(retryOptions);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    ),
  );

  return dio;
});

bool _shouldRetryWithFallback(DioException error) {
  final fallbackUri = Env.apiFallbackUri;
  if (fallbackUri == null) {
    return false;
  }

  if (error.requestOptions.extra['failoverTried'] == true) {
    return false;
  }

  final primaryHost = Env.apiBaseUri.host.toLowerCase();
  final requestHost = error.requestOptions.uri.host.toLowerCase();
  if (requestHost != primaryHost) {
    return false;
  }

  if (error.error is SocketException) {
    return true;
  }

  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return true;
    case DioExceptionType.badCertificate:
    case DioExceptionType.badResponse:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      break;
  }

  final details = '${error.message ?? ''} ${error.error ?? ''}'.toLowerCase();
  return details.contains('failed host lookup') ||
      details.contains('socketexception') ||
      details.contains('connection error') ||
      details.contains('timed out');
}
