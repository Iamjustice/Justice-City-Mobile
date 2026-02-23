// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_offering.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceOfferingImpl _$$ServiceOfferingImplFromJson(
        Map<String, dynamic> json) =>
    _$ServiceOfferingImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      price: json['price'] as String,
      turnaround: json['turnaround'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$ServiceOfferingImplToJson(
        _$ServiceOfferingImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'price': instance.price,
      'turnaround': instance.turnaround,
      'updatedAt': instance.updatedAt,
    };
