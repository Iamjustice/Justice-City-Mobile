// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_offering.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceOffering _$ServiceOfferingFromJson(Map<String, dynamic> json) {
  return _ServiceOffering.fromJson(json);
}

/// @nodoc
mixin _$ServiceOffering {
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get price => throw _privateConstructorUsedError;
  String get turnaround => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ServiceOffering to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServiceOffering
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServiceOfferingCopyWith<ServiceOffering> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceOfferingCopyWith<$Res> {
  factory $ServiceOfferingCopyWith(
          ServiceOffering value, $Res Function(ServiceOffering) then) =
      _$ServiceOfferingCopyWithImpl<$Res, ServiceOffering>;
  @useResult
  $Res call(
      {String code,
      String name,
      String description,
      String icon,
      String price,
      String turnaround,
      String updatedAt});
}

/// @nodoc
class _$ServiceOfferingCopyWithImpl<$Res, $Val extends ServiceOffering>
    implements $ServiceOfferingCopyWith<$Res> {
  _$ServiceOfferingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServiceOffering
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? description = null,
    Object? icon = null,
    Object? price = null,
    Object? turnaround = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      turnaround: null == turnaround
          ? _value.turnaround
          : turnaround // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceOfferingImplCopyWith<$Res>
    implements $ServiceOfferingCopyWith<$Res> {
  factory _$$ServiceOfferingImplCopyWith(_$ServiceOfferingImpl value,
          $Res Function(_$ServiceOfferingImpl) then) =
      __$$ServiceOfferingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String name,
      String description,
      String icon,
      String price,
      String turnaround,
      String updatedAt});
}

/// @nodoc
class __$$ServiceOfferingImplCopyWithImpl<$Res>
    extends _$ServiceOfferingCopyWithImpl<$Res, _$ServiceOfferingImpl>
    implements _$$ServiceOfferingImplCopyWith<$Res> {
  __$$ServiceOfferingImplCopyWithImpl(
      _$ServiceOfferingImpl _value, $Res Function(_$ServiceOfferingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ServiceOffering
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? description = null,
    Object? icon = null,
    Object? price = null,
    Object? turnaround = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ServiceOfferingImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String,
      turnaround: null == turnaround
          ? _value.turnaround
          : turnaround // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceOfferingImpl implements _ServiceOffering {
  const _$ServiceOfferingImpl(
      {required this.code,
      required this.name,
      required this.description,
      required this.icon,
      required this.price,
      required this.turnaround,
      required this.updatedAt});

  factory _$ServiceOfferingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceOfferingImplFromJson(json);

  @override
  final String code;
  @override
  final String name;
  @override
  final String description;
  @override
  final String icon;
  @override
  final String price;
  @override
  final String turnaround;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'ServiceOffering(code: $code, name: $name, description: $description, icon: $icon, price: $price, turnaround: $turnaround, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceOfferingImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.turnaround, turnaround) ||
                other.turnaround == turnaround) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, code, name, description, icon, price, turnaround, updatedAt);

  /// Create a copy of ServiceOffering
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceOfferingImplCopyWith<_$ServiceOfferingImpl> get copyWith =>
      __$$ServiceOfferingImplCopyWithImpl<_$ServiceOfferingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceOfferingImplToJson(
      this,
    );
  }
}

abstract class _ServiceOffering implements ServiceOffering {
  const factory _ServiceOffering(
      {required final String code,
      required final String name,
      required final String description,
      required final String icon,
      required final String price,
      required final String turnaround,
      required final String updatedAt}) = _$ServiceOfferingImpl;

  factory _ServiceOffering.fromJson(Map<String, dynamic> json) =
      _$ServiceOfferingImpl.fromJson;

  @override
  String get code;
  @override
  String get name;
  @override
  String get description;
  @override
  String get icon;
  @override
  String get price;
  @override
  String get turnaround;
  @override
  String get updatedAt;

  /// Create a copy of ServiceOffering
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServiceOfferingImplCopyWith<_$ServiceOfferingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
