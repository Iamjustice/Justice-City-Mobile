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
}
