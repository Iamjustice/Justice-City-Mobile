import 'package:dio/dio.dart';

import '../../domain/models/service_offering.dart';
import '../../domain/models/provider_package.dart';
import '../api/endpoints.dart';

class ServicesRepository {
  ServicesRepository(this._dio);

  final Dio _dio;

  Future<List<ServiceOffering>> listOfferings() async {
    final res = await _dio.get(ApiEndpoints.serviceOfferings);
    final data = res.data;
    if (data is List) {
      return data
          .map((e) => ServiceOffering.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    // some servers may wrap
    if (data is Map && data['offerings'] is List) {
      final list = List<Map<String, dynamic>>.from(data['offerings'] as List);
      return list.map(ServiceOffering.fromJson).toList();
    }
    throw StateError('Unexpected service offerings response');
  }

  Future<ProviderPackage> loadProviderPackage(String token) async {
    final res = await _dio.get(ApiEndpoints.providerPackage(token));
    return ProviderPackage.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<ServicePdfJobRecord>> listServicePdfJobs({
    String? conversationId,
    String status = 'all',
    int? limit,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.servicePdfJobs,
        queryParameters: {
          if (conversationId != null && conversationId.trim().isNotEmpty)
            'conversationId': conversationId.trim(),
          if (status.trim().isNotEmpty) 'status': status.trim().toLowerCase(),
          if (limit != null) 'limit': limit,
        },
      );
      final raw = (res.data as List?) ?? const [];
      return raw
          .whereType<Map>()
          .map(
              (e) => ServicePdfJobRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _formatApiError(e, fallback: 'Failed to load service PDF jobs.'),
      );
    }
  }

  Future<ServicePdfJobRecord> queueServicePdfJob({
    String? conversationId,
    String? transactionId,
    String? serviceRequestId,
    String? createdByUserId,
    required String actorRole,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.servicePdfJobs,
        data: {
          if (conversationId != null && conversationId.trim().isNotEmpty)
            'conversationId': conversationId.trim(),
          if (transactionId != null && transactionId.trim().isNotEmpty)
            'transactionId': transactionId.trim(),
          if (serviceRequestId != null && serviceRequestId.trim().isNotEmpty)
            'serviceRequestId': serviceRequestId.trim(),
          if (createdByUserId != null && createdByUserId.trim().isNotEmpty)
            'createdByUserId': createdByUserId.trim(),
          'actorRole': actorRole,
          if (payload != null) 'payload': payload,
        },
      );
      return ServicePdfJobRecord.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        _formatApiError(e, fallback: 'Failed to queue service PDF job.'),
      );
    }
  }

  Future<List<ServiceProviderLinkRecord>> listProviderLinksByConversation(
    String conversationId, {
    int? limit,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.providerLinksByConversation(
            Uri.encodeComponent(conversationId)),
        queryParameters: {
          if (limit != null) 'limit': limit,
        },
      );
      final raw = (res.data as List?) ?? const [];
      return raw
          .whereType<Map>()
          .map(
            (e) => ServiceProviderLinkRecord.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(
        _formatApiError(e, fallback: 'Failed to load provider links.'),
      );
    }
  }

  Future<ProviderLinkCreateResult> createProviderLink({
    required String conversationId,
    String? providerUserId,
    String? serviceRequestId,
    String? createdByUserId,
    required String createdByRole,
    String? expiresAt,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.providerLinks,
        data: {
          'conversationId': conversationId,
          if (providerUserId != null && providerUserId.trim().isNotEmpty)
            'providerUserId': providerUserId.trim(),
          if (serviceRequestId != null && serviceRequestId.trim().isNotEmpty)
            'serviceRequestId': serviceRequestId.trim(),
          if (createdByUserId != null && createdByUserId.trim().isNotEmpty)
            'createdByUserId': createdByUserId.trim(),
          'createdByRole': createdByRole,
          if (expiresAt != null && expiresAt.trim().isNotEmpty)
            'expiresAt': expiresAt.trim(),
          if (payload != null) 'payload': payload,
        },
      );

      final map = Map<String, dynamic>.from(res.data as Map);
      final linkRaw = map['link'] is Map
          ? Map<String, dynamic>.from(map['link'] as Map)
          : <String, dynamic>{};
      return ProviderLinkCreateResult(
        link: ServiceProviderLinkRecord.fromJson(linkRaw),
        token: (map['token'] ?? '').toString(),
        packageUrl: (map['packageUrl'] ?? map['package_url'] ?? '').toString(),
      );
    } on DioException catch (e) {
      throw Exception(
        _formatApiError(e, fallback: 'Failed to create provider link.'),
      );
    }
  }

  Future<ServiceProviderLinkRecord> revokeProviderLink({
    required String linkId,
    required String actorRole,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.revokeProviderLink(Uri.encodeComponent(linkId)),
        data: {'actorRole': actorRole},
      );
      return ServiceProviderLinkRecord.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        _formatApiError(e, fallback: 'Failed to revoke provider link.'),
      );
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

class ServicePdfJobRecord {
  ServicePdfJobRecord({
    required this.id,
    required this.conversationId,
    this.serviceRequestId,
    this.transactionId,
    required this.status,
    required this.attemptCount,
    required this.maxAttempts,
    required this.outputBucket,
    this.outputPath,
    this.errorMessage,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String conversationId;
  final String? serviceRequestId;
  final String? transactionId;
  final String status;
  final int attemptCount;
  final int maxAttempts;
  final String outputBucket;
  final String? outputPath;
  final String? errorMessage;
  final String? processedAt;
  final String createdAt;
  final String updatedAt;

  factory ServicePdfJobRecord.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic value, int fallback) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    String? readString(dynamic value) {
      final parsed = value?.toString().trim();
      if (parsed == null || parsed.isEmpty) return null;
      return parsed;
    }

    return ServicePdfJobRecord(
      id: readString(json['id']) ?? '',
      conversationId:
          readString(json['conversationId'] ?? json['conversation_id']) ?? '',
      serviceRequestId:
          readString(json['serviceRequestId'] ?? json['service_request_id']),
      transactionId:
          readString(json['transactionId'] ?? json['transaction_id']),
      status: readString(json['status']) ?? 'queued',
      attemptCount: readInt(json['attemptCount'] ?? json['attempt_count'], 0),
      maxAttempts: readInt(json['maxAttempts'] ?? json['max_attempts'], 0),
      outputBucket:
          readString(json['outputBucket'] ?? json['output_bucket']) ?? '',
      outputPath: readString(json['outputPath'] ?? json['output_path']),
      errorMessage: readString(json['errorMessage'] ?? json['error_message']),
      processedAt: readString(json['processedAt'] ?? json['processed_at']),
      createdAt: readString(json['createdAt'] ?? json['created_at']) ?? '',
      updatedAt: readString(json['updatedAt'] ?? json['updated_at']) ?? '',
    );
  }
}

class ServiceProviderLinkRecord {
  ServiceProviderLinkRecord({
    required this.id,
    required this.conversationId,
    this.serviceRequestId,
    this.providerUserId,
    this.tokenHint,
    required this.expiresAt,
    required this.status,
    this.openedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String conversationId;
  final String? serviceRequestId;
  final String? providerUserId;
  final String? tokenHint;
  final String expiresAt;
  final String status;
  final String? openedAt;
  final String createdAt;
  final String updatedAt;

  factory ServiceProviderLinkRecord.fromJson(Map<String, dynamic> json) {
    String? readString(dynamic value) {
      final parsed = value?.toString().trim();
      if (parsed == null || parsed.isEmpty) return null;
      return parsed;
    }

    return ServiceProviderLinkRecord(
      id: readString(json['id']) ?? '',
      conversationId:
          readString(json['conversationId'] ?? json['conversation_id']) ?? '',
      serviceRequestId:
          readString(json['serviceRequestId'] ?? json['service_request_id']),
      providerUserId:
          readString(json['providerUserId'] ?? json['provider_user_id']),
      tokenHint: readString(json['tokenHint'] ?? json['token_hint']),
      expiresAt: readString(json['expiresAt'] ?? json['expires_at']) ?? '',
      status: readString(json['status']) ?? 'active',
      openedAt: readString(json['openedAt'] ?? json['opened_at']),
      createdAt: readString(json['createdAt'] ?? json['created_at']) ?? '',
      updatedAt: readString(json['updatedAt'] ?? json['updated_at']) ?? '',
    );
  }
}

class ProviderLinkCreateResult {
  ProviderLinkCreateResult({
    required this.link,
    required this.token,
    required this.packageUrl,
  });

  final ServiceProviderLinkRecord link;
  final String token;
  final String packageUrl;
}
