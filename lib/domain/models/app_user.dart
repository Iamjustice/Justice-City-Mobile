import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

Map<String, dynamic> _normalizeAppUserJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);

  normalized.putIfAbsent('fullName', () => normalized['name'] ?? normalized['full_name']);
  normalized.putIfAbsent('isVerified', () => normalized['is_verified']);
  normalized.putIfAbsent('emailVerified', () => normalized['email_verified']);
  normalized.putIfAbsent('phoneVerified', () => normalized['phone_verified']);
  normalized.putIfAbsent('dateOfBirth', () => normalized['date_of_birth']);
  normalized.putIfAbsent('homeAddress', () => normalized['home_address']);
  normalized.putIfAbsent('officeAddress', () => normalized['office_address']);
  normalized.putIfAbsent('avatar', () => normalized['avatar_url']);

  return normalized;
}

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    String? email,
    String? fullName,
    String? nickname,
    String? role,
    bool? isVerified,
    bool? emailVerified,
    bool? phoneVerified,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? homeAddress,
    String? officeAddress,
    String? avatar,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(_normalizeAppUserJson(json));
}
