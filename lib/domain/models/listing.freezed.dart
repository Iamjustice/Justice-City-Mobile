// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Listing _$ListingFromJson(Map<String, dynamic> json) {
  return _Listing.fromJson(json);
}

/// @nodoc
mixin _$Listing {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// "Sale" | "Rent"
  @JsonKey(name: 'listingType', fromJson: _asString)
  String? get listingType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _asString)
  String? get location => throw _privateConstructorUsedError;

  /// Server often returns price as string (e.g. "25000000")
  @JsonKey(fromJson: _asString)
  String? get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'price_suffix', fromJson: _asString)
  String? get priceSuffix => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _asInt)
  int? get views => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _asInt)
  int? get inquiries => throw _privateConstructorUsedError;
  @JsonKey(name: 'coverImageUrl', fromJson: _asString)
  String? get coverImageUrl => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _asDate)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingCopyWith<Listing> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingCopyWith<$Res> {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) then) =
      _$ListingCopyWithImpl<$Res, Listing>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String? status,
      @JsonKey(name: 'listingType', fromJson: _asString) String? listingType,
      @JsonKey(fromJson: _asString) String? location,
      @JsonKey(fromJson: _asString) String? price,
      @JsonKey(name: 'price_suffix', fromJson: _asString) String? priceSuffix,
      @JsonKey(fromJson: _asInt) int? views,
      @JsonKey(fromJson: _asInt) int? inquiries,
      @JsonKey(name: 'coverImageUrl', fromJson: _asString)
      String? coverImageUrl,
      @JsonKey(fromJson: _asDate) DateTime? createdAt});
}

/// @nodoc
class _$ListingCopyWithImpl<$Res, $Val extends Listing>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = freezed,
    Object? listingType = freezed,
    Object? location = freezed,
    Object? price = freezed,
    Object? priceSuffix = freezed,
    Object? views = freezed,
    Object? inquiries = freezed,
    Object? coverImageUrl = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      listingType: freezed == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      priceSuffix: freezed == priceSuffix
          ? _value.priceSuffix
          : priceSuffix // ignore: cast_nullable_to_non_nullable
              as String?,
      views: freezed == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int?,
      inquiries: freezed == inquiries
          ? _value.inquiries
          : inquiries // ignore: cast_nullable_to_non_nullable
              as int?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingImplCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$$ListingImplCopyWith(
          _$ListingImpl value, $Res Function(_$ListingImpl) then) =
      __$$ListingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String? status,
      @JsonKey(name: 'listingType', fromJson: _asString) String? listingType,
      @JsonKey(fromJson: _asString) String? location,
      @JsonKey(fromJson: _asString) String? price,
      @JsonKey(name: 'price_suffix', fromJson: _asString) String? priceSuffix,
      @JsonKey(fromJson: _asInt) int? views,
      @JsonKey(fromJson: _asInt) int? inquiries,
      @JsonKey(name: 'coverImageUrl', fromJson: _asString)
      String? coverImageUrl,
      @JsonKey(fromJson: _asDate) DateTime? createdAt});
}

/// @nodoc
class __$$ListingImplCopyWithImpl<$Res>
    extends _$ListingCopyWithImpl<$Res, _$ListingImpl>
    implements _$$ListingImplCopyWith<$Res> {
  __$$ListingImplCopyWithImpl(
      _$ListingImpl _value, $Res Function(_$ListingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = freezed,
    Object? listingType = freezed,
    Object? location = freezed,
    Object? price = freezed,
    Object? priceSuffix = freezed,
    Object? views = freezed,
    Object? inquiries = freezed,
    Object? coverImageUrl = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$ListingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      listingType: freezed == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      priceSuffix: freezed == priceSuffix
          ? _value.priceSuffix
          : priceSuffix // ignore: cast_nullable_to_non_nullable
              as String?,
      views: freezed == views
          ? _value.views
          : views // ignore: cast_nullable_to_non_nullable
              as int?,
      inquiries: freezed == inquiries
          ? _value.inquiries
          : inquiries // ignore: cast_nullable_to_non_nullable
              as int?,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingImpl implements _Listing {
  const _$ListingImpl(
      {required this.id,
      required this.title,
      this.description,
      this.status,
      @JsonKey(name: 'listingType', fromJson: _asString) this.listingType,
      @JsonKey(fromJson: _asString) this.location,
      @JsonKey(fromJson: _asString) this.price,
      @JsonKey(name: 'price_suffix', fromJson: _asString) this.priceSuffix,
      @JsonKey(fromJson: _asInt) this.views,
      @JsonKey(fromJson: _asInt) this.inquiries,
      @JsonKey(name: 'coverImageUrl', fromJson: _asString) this.coverImageUrl,
      @JsonKey(fromJson: _asDate) this.createdAt});

  factory _$ListingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? status;

  /// "Sale" | "Rent"
  @override
  @JsonKey(name: 'listingType', fromJson: _asString)
  final String? listingType;
  @override
  @JsonKey(fromJson: _asString)
  final String? location;

  /// Server often returns price as string (e.g. "25000000")
  @override
  @JsonKey(fromJson: _asString)
  final String? price;
  @override
  @JsonKey(name: 'price_suffix', fromJson: _asString)
  final String? priceSuffix;
  @override
  @JsonKey(fromJson: _asInt)
  final int? views;
  @override
  @JsonKey(fromJson: _asInt)
  final int? inquiries;
  @override
  @JsonKey(name: 'coverImageUrl', fromJson: _asString)
  final String? coverImageUrl;
  @override
  @JsonKey(fromJson: _asDate)
  final DateTime? createdAt;

  @override
  String toString() {
    return 'Listing(id: $id, title: $title, description: $description, status: $status, listingType: $listingType, location: $location, price: $price, priceSuffix: $priceSuffix, views: $views, inquiries: $inquiries, coverImageUrl: $coverImageUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.listingType, listingType) ||
                other.listingType == listingType) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceSuffix, priceSuffix) ||
                other.priceSuffix == priceSuffix) &&
            (identical(other.views, views) || other.views == views) &&
            (identical(other.inquiries, inquiries) ||
                other.inquiries == inquiries) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      status,
      listingType,
      location,
      price,
      priceSuffix,
      views,
      inquiries,
      coverImageUrl,
      createdAt);

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingImplCopyWith<_$ListingImpl> get copyWith =>
      __$$ListingImplCopyWithImpl<_$ListingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingImplToJson(
      this,
    );
  }
}

abstract class _Listing implements Listing {
  const factory _Listing(
      {required final String id,
      required final String title,
      final String? description,
      final String? status,
      @JsonKey(name: 'listingType', fromJson: _asString)
      final String? listingType,
      @JsonKey(fromJson: _asString) final String? location,
      @JsonKey(fromJson: _asString) final String? price,
      @JsonKey(name: 'price_suffix', fromJson: _asString)
      final String? priceSuffix,
      @JsonKey(fromJson: _asInt) final int? views,
      @JsonKey(fromJson: _asInt) final int? inquiries,
      @JsonKey(name: 'coverImageUrl', fromJson: _asString)
      final String? coverImageUrl,
      @JsonKey(fromJson: _asDate) final DateTime? createdAt}) = _$ListingImpl;

  factory _Listing.fromJson(Map<String, dynamic> json) = _$ListingImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get status;

  /// "Sale" | "Rent"
  @override
  @JsonKey(name: 'listingType', fromJson: _asString)
  String? get listingType;
  @override
  @JsonKey(fromJson: _asString)
  String? get location;

  /// Server often returns price as string (e.g. "25000000")
  @override
  @JsonKey(fromJson: _asString)
  String? get price;
  @override
  @JsonKey(name: 'price_suffix', fromJson: _asString)
  String? get priceSuffix;
  @override
  @JsonKey(fromJson: _asInt)
  int? get views;
  @override
  @JsonKey(fromJson: _asInt)
  int? get inquiries;
  @override
  @JsonKey(name: 'coverImageUrl', fromJson: _asString)
  String? get coverImageUrl;
  @override
  @JsonKey(fromJson: _asDate)
  DateTime? get createdAt;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingImplCopyWith<_$ListingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
