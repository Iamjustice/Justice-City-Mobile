// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  return double.tryParse(s);
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

Map<String, dynamic> _normalizeListingJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);

  normalized.putIfAbsent('agentId', () => normalized['agent_id']);
  normalized.putIfAbsent('listingType', () => normalized['listing_type']);
  normalized.putIfAbsent('priceSuffix', () => normalized['price_suffix']);
  normalized.putIfAbsent('views', () => normalized['views_count']);
  normalized.putIfAbsent('inquiries', () => normalized['leads_count']);
  normalized.putIfAbsent('createdAt', () => normalized['created_at']);
  normalized.putIfAbsent('coverImageUrl', () => normalized['cover_image_url']);
  normalized.putIfAbsent(
      'agentPayoutStatus', () => normalized['agent_payout_status']);
  normalized.putIfAbsent('dealAmount', () => normalized['deal_amount']);
  normalized.putIfAbsent(
      'totalCommission', () => normalized['total_commission']);
  normalized.putIfAbsent(
      'agentCommission', () => normalized['agent_commission']);
  normalized.putIfAbsent(
      'companyCommission', () => normalized['company_commission']);
  normalized.putIfAbsent('closedAt', () => normalized['closed_at']);

  return normalized;
}

@freezed
class Listing with _$Listing {
  const factory Listing({
    required String id,
    @JsonKey(fromJson: _asString) String? agentId,
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
    @JsonKey(fromJson: _asString) String? date,
    @JsonKey(fromJson: _asDouble) double? dealAmount,
    @JsonKey(fromJson: _asDouble) double? totalCommission,
    @JsonKey(fromJson: _asDouble) double? agentCommission,
    @JsonKey(fromJson: _asDouble) double? companyCommission,
    @JsonKey(fromJson: _asString) String? agentPayoutStatus,
    @JsonKey(fromJson: _asString) String? closedAt,
    @JsonKey(fromJson: _asDate) DateTime? createdAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(_normalizeListingJson(json));
}
