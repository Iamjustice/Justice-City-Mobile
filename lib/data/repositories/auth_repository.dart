import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/endpoints.dart';
import '../../domain/models/app_user.dart';

class AuthRepository {
  AuthRepository(this._dio, this._supabase);

  final Dio _dio;
  final SupabaseClient _supabase;

  /// Supabase email+password sign-in
  Future<void> signInWithEmailPassword({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmailPassword({required String email, required String password}) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async => _supabase.auth.signOut();

  Future<AppUser?> fetchMe() async {
    final res = await _dio.get(ApiEndpoints.me);
    final data = res.data;
    if (data is Map<String, dynamic>) {
      // Try common shapes: {user:{...}} or direct.
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        return AppUser.fromJson(user);
      }
      return AppUser.fromJson(data);
    }
    return null;
  }

  /// Optional Node API signup endpoint (if you use it to initialize profile rows / roles).
  Future<Map<String, dynamic>> nodeSignup({required Map<String, dynamic> payload}) async {
    final res = await _dio.post(ApiEndpoints.signup, data: payload);
    if (res.data is Map<String, dynamic>) {
      return res.data as Map<String, dynamic>;
    }
    return <String, dynamic>{'raw': res.data};
  }

  Future<AppUser?> patchProfile({
    String? fullName,
    String? dateOfBirth,
    String? homeAddress,
    String? officeAddress,
  }) async {
    final res = await _dio.patch(
      ApiEndpoints.patchProfile,
      data: {
        if (fullName != null) 'fullName': fullName,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (homeAddress != null) 'homeAddress': homeAddress,
        if (officeAddress != null) 'officeAddress': officeAddress,
      },
    );
    if (res.data is Map<String, dynamic>) {
      return AppUser.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }
}
