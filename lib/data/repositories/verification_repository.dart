import 'package:dio/dio.dart';

import '../api/endpoints.dart';
import '../../domain/models/verification_status.dart';

class VerificationRepository {
  final Dio _dio;
  VerificationRepository(this._dio);

  Future<VerificationStatus> fetchStatus({required String userId}) async {
    final res = await _dio.get('${ApiEndpoints.verificationStatus}/$userId');
    final data = (res.data is Map) ? Map<String, dynamic>.from(res.data) : <String, dynamic>{};
    return VerificationStatus.fromJson(data);
  }

  Future<void> sendEmailOtp({required String email}) async {
    await _dio.post(ApiEndpoints.emailOtpSend, data: {'email': email});
  }

  Future<void> checkEmailOtp({required String email, required String code, required String userId}) async {
    await _dio.post(ApiEndpoints.emailOtpCheck, data: {'email': email, 'code': code, 'userId': userId});
  }

  Future<void> sendPhoneOtp({required String phone}) async {
    await _dio.post(ApiEndpoints.phoneOtpSend, data: {'phone': phone});
  }

  Future<void> checkPhoneOtp({required String phone, required String code, required String userId}) async {
    await _dio.post(ApiEndpoints.phoneOtpCheck, data: {'phone': phone, 'code': code, 'userId': userId});
  }

  Future<void> submitSmileId({required String userId, String mode = 'kyc'}) async {
    await _dio.post(ApiEndpoints.smileIdSubmit, data: {'userId': userId, 'mode': mode});
  }

  Future<Map<String, dynamic>> uploadDocument({
    required String userId,
    required String documentType,
    required String fileName,
    required String contentBase64,
    String? mimeType,
    int? fileSizeBytes,
    String? verificationId,
    String? homeAddress,
    String? officeAddress,
    String? dateOfBirth,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.verificationDocumentsUpload,
      data: {
        'userId': userId,
        'documentType': documentType,
        'fileName': fileName,
        'contentBase64': contentBase64,
        if (mimeType != null && mimeType.isNotEmpty) 'mimeType': mimeType,
        if (fileSizeBytes != null && fileSizeBytes >= 0) 'fileSizeBytes': fileSizeBytes,
        if (verificationId != null && verificationId.isNotEmpty) 'verificationId': verificationId,
        if (homeAddress != null && homeAddress.isNotEmpty) 'homeAddress': homeAddress,
        if (officeAddress != null && officeAddress.isNotEmpty) 'officeAddress': officeAddress,
        if (dateOfBirth != null && dateOfBirth.isNotEmpty) 'dateOfBirth': dateOfBirth,
      },
    );

    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    return <String, dynamic>{'raw': res.data};
  }
}
