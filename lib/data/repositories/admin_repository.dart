import 'package:dio/dio.dart';

import '../api/endpoints.dart';

class AdminRepository {
  AdminRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get(ApiEndpoints.adminDashboard);
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return {'raw': data};
  }

  Future<List<dynamic>> listHiringApplications(
      {required String actorRole}) async {
    final res =
        await _dio.get(ApiEndpoints.adminHiringApplications, queryParameters: {
      'actorRole': actorRole,
    });
    return (res.data is List) ? (res.data as List) : <dynamic>[];
  }

  Future<Map<String, dynamic>> updateHiringStatus({
    required String id,
    required String status, // submitted|under_review|approved|rejected
    String? reviewerNotes,
    String? reviewerId,
    String? reviewerName,
    String? actorRole,
  }) async {
    final res = await _dio.patch(ApiEndpoints.adminHiringStatus(id), data: {
      'status': status,
      if (reviewerNotes != null) 'reviewerNotes': reviewerNotes,
      if (reviewerId != null) 'reviewerId': reviewerId,
      if (reviewerName != null) 'reviewerName': reviewerName,
      if (actorRole != null) 'actorRole': actorRole,
    });
    return (res.data is Map<String, dynamic>)
        ? (res.data as Map<String, dynamic>)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> patchServiceOffering({
    required String code,
    String? price,
    String? turnaround,
    required String actorRole,
  }) async {
    final res =
        await _dio.patch(ApiEndpoints.adminServiceOffering(code), data: {
      if (price != null) 'price': price,
      if (turnaround != null) 'turnaround': turnaround,
      'actorRole': actorRole,
    });
    return (res.data is Map<String, dynamic>)
        ? (res.data as Map<String, dynamic>)
        : <String, dynamic>{};
  }

  Future<List<dynamic>> listAdminConversations({
    required String viewerId,
    String? viewerRole,
    String? viewerName,
  }) async {
    final res =
        await _dio.get(ApiEndpoints.adminChatConversations, queryParameters: {
      'viewerId': viewerId,
      if (viewerRole != null) 'viewerRole': viewerRole,
      if (viewerName != null) 'viewerName': viewerName,
    });
    return (res.data is List) ? (res.data as List) : <dynamic>[];
  }

  Future<void> setVerificationStatus(
      {required String id, required String status}) async {
    await _dio
        .patch(ApiEndpoints.adminVerification(id), data: {'status': status});
  }

  Future<void> setFlaggedListingStatus(
      {required String id, required String status}) async {
    await _dio.patch(ApiEndpoints.adminFlaggedListingStatus(id),
        data: {'status': status});
  }

  Future<Map<String, dynamic>> addFlaggedListingComment({
    required String id,
    required String comment,
    required String problemTag,
    required String createdBy,
    String? createdById,
  }) async {
    final res =
        await _dio.post(ApiEndpoints.adminFlaggedListingComments(id), data: {
      'comment': comment,
      'problemTag': problemTag,
      'createdBy': createdBy,
      if (createdById != null) 'createdById': createdById,
    });
    return (res.data is Map<String, dynamic>)
        ? (res.data as Map<String, dynamic>)
        : <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> listOpenDisputes({
    required String actorRole,
    int? limit,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.openDisputes,
      queryParameters: {
        'actorRole': actorRole,
        if (limit != null) 'limit': limit,
      },
    );
    final raw = (res.data as List?) ?? const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> resolveDispute({
    required String disputeId,
    required String resolvedByRole,
    String? status,
    String? resolution,
    String? resolutionTargetStatus,
    String? resolvedByUserId,
    String? resolvedByName,
    bool? unfreezeEscrow,
    Map<String, dynamic>? metadata,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.resolveDispute(disputeId),
      data: {
        'resolvedByRole': resolvedByRole,
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        if (resolution != null && resolution.trim().isNotEmpty)
          'resolution': resolution.trim(),
        if (resolutionTargetStatus != null &&
            resolutionTargetStatus.trim().isNotEmpty)
          'resolutionTargetStatus': resolutionTargetStatus.trim(),
        if (resolvedByUserId != null && resolvedByUserId.trim().isNotEmpty)
          'resolvedByUserId': resolvedByUserId.trim(),
        if (resolvedByName != null && resolvedByName.trim().isNotEmpty)
          'resolvedByName': resolvedByName.trim(),
        if (unfreezeEscrow != null) 'unfreezeEscrow': unfreezeEscrow,
        if (metadata != null) 'metadata': metadata,
      },
    );
    return (res.data is Map<String, dynamic>)
        ? (res.data as Map<String, dynamic>)
        : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> processNextServicePdfJob({
    required String actorRole,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.servicePdfJobsProcessNext,
      data: {'actorRole': actorRole},
    );
    return (res.data is Map<String, dynamic>)
        ? (res.data as Map<String, dynamic>)
        : <String, dynamic>{};
  }
}
