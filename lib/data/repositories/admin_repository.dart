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

  Future<List<dynamic>> listHiringApplications({required String actorRole}) async {
    final res = await _dio.get(ApiEndpoints.adminHiringApplications, queryParameters: {
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
    return (res.data is Map<String, dynamic>) ? (res.data as Map<String, dynamic>) : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> patchServiceOffering({
    required String code,
    String? price,
    String? turnaround,
    required String actorRole,
  }) async {
    final res = await _dio.patch(ApiEndpoints.adminServiceOffering(code), data: {
      if (price != null) 'price': price,
      if (turnaround != null) 'turnaround': turnaround,
      'actorRole': actorRole,
    });
    return (res.data is Map<String, dynamic>) ? (res.data as Map<String, dynamic>) : <String, dynamic>{};
  }

  Future<List<dynamic>> listAdminConversations({
    required String viewerId,
    String? viewerRole,
    String? viewerName,
  }) async {
    final res = await _dio.get(ApiEndpoints.adminChatConversations, queryParameters: {
      'viewerId': viewerId,
      if (viewerRole != null) 'viewerRole': viewerRole,
      if (viewerName != null) 'viewerName': viewerName,
    });
    return (res.data is List) ? (res.data as List) : <dynamic>[];
  }

  Future<void> setVerificationStatus({required String id, required String status}) async {
    await _dio.patch(ApiEndpoints.adminVerification(id), data: {'status': status});
  }

  Future<void> setFlaggedListingStatus({required String id, required String status}) async {
    await _dio.patch(ApiEndpoints.adminFlaggedListingStatus(id), data: {'status': status});
  }

  Future<Map<String, dynamic>> addFlaggedListingComment({
    required String id,
    required String comment,
    required String problemTag,
    required String createdBy,
    String? createdById,
  }) async {
    final res = await _dio.post(ApiEndpoints.adminFlaggedListingComments(id), data: {
      'comment': comment,
      'problemTag': problemTag,
      'createdBy': createdBy,
      if (createdById != null) 'createdById': createdById,
    });
    return (res.data is Map<String, dynamic>) ? (res.data as Map<String, dynamic>) : <String, dynamic>{};
  }
}
