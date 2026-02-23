// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s);
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString().trim();
  return DateTime.tryParse(s);
}

@freezed
class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String title,
    String? description,
    String? status,

    /// "Sale" | "Rent"
    @JsonKey(name: 'listingType', fromJson: _asString) String? listingType,

    @JsonKey(fromJson: _asString) String? location,

    /// Server often returns price as string (e.g. "25000000")
    @JsonKey(fromJson: _asString) String? price,

    @JsonKey(name: 'price_suffix', fromJson: _asString) String? priceSuffix,

    @JsonKey(fromJson: _asInt) int? views,

    @JsonKey(fromJson: _asInt) int? inquiries,

    @JsonKey(name: 'coverImageUrl', fromJson: _asString) String? coverImageUrl,

    @JsonKey(fromJson: _asDate) DateTime? createdAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);
}
