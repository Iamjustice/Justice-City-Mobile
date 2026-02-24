// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      nickname: json['nickname'] as String?,
      role: json['role'] as String?,
      isVerified: json['isVerified'] as bool?,
      emailVerified: json['emailVerified'] as bool?,
      phoneVerified: json['phoneVerified'] as bool?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      homeAddress: json['homeAddress'] as String?,
      officeAddress: json['officeAddress'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'nickname': instance.nickname,
      'role': instance.role,
      'isVerified': instance.isVerified,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'phone': instance.phone,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth,
      'homeAddress': instance.homeAddress,
      'officeAddress': instance.officeAddress,
      'avatar': instance.avatar,
    };
