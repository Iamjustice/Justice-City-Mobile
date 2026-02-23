// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListingImpl _$$ListingImplFromJson(Map<String, dynamic> json) =>
    _$ListingImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String?,
      listingType: _asString(json['listingType']),
      location: _asString(json['location']),
      price: _asString(json['price']),
      priceSuffix: _asString(json['price_suffix']),
      views: _asInt(json['views']),
      inquiries: _asInt(json['inquiries']),
      coverImageUrl: _asString(json['coverImageUrl']),
      createdAt: _asDate(json['createdAt']),
    );

Map<String, dynamic> _$$ListingImplToJson(_$ListingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'listingType': instance.listingType,
      'location': instance.location,
      'price': instance.price,
      'price_suffix': instance.priceSuffix,
      'views': instance.views,
      'inquiries': instance.inquiries,
      'coverImageUrl': instance.coverImageUrl,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
