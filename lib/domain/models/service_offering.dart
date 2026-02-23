import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_offering.freezed.dart';
part 'service_offering.g.dart';

@freezed
class ServiceOffering with _$ServiceOffering {
  const factory ServiceOffering({
    required String code,
    required String name,
    required String description,
    required String icon,
    required String price,
    required String turnaround,
    required String updatedAt,
  }) = _ServiceOffering;

  factory ServiceOffering.fromJson(Map<String, dynamic> json) => _$ServiceOfferingFromJson(json);
}
