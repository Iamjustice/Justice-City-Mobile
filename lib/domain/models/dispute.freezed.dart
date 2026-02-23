// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dispute.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Dispute _$DisputeFromJson(Map<String, dynamic> json) {
  return _Dispute.fromJson(json);
}

/// @nodoc
mixin _$Dispute {
  String get id => throw _privateConstructorUsedError;
  String get transactionId => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String? get openedByUserId => throw _privateConstructorUsedError;
  String? get againstUserId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get resolution => throw _privateConstructorUsedError;
  String? get resolutionTargetStatus => throw _privateConstructorUsedError;
  String? get resolvedByUserId => throw _privateConstructorUsedError;
  String? get resolvedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Dispute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisputeCopyWith<Dispute> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisputeCopyWith<$Res> {
  factory $DisputeCopyWith(Dispute value, $Res Function(Dispute) then) =
      _$DisputeCopyWithImpl<$Res, Dispute>;
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String conversationId,
      String? openedByUserId,
      String? againstUserId,
      String reason,
      String? details,
      String status,
      String? resolution,
      String? resolutionTargetStatus,
      String? resolvedByUserId,
      String? resolvedAt,
      Map<String, dynamic> metadata,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$DisputeCopyWithImpl<$Res, $Val extends Dispute>
    implements $DisputeCopyWith<$Res> {
  _$DisputeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? conversationId = null,
    Object? openedByUserId = freezed,
    Object? againstUserId = freezed,
    Object? reason = null,
    Object? details = freezed,
    Object? status = null,
    Object? resolution = freezed,
    Object? resolutionTargetStatus = freezed,
    Object? resolvedByUserId = freezed,
    Object? resolvedAt = freezed,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      openedByUserId: freezed == openedByUserId
          ? _value.openedByUserId
          : openedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      againstUserId: freezed == againstUserId
          ? _value.againstUserId
          : againstUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      resolutionTargetStatus: freezed == resolutionTargetStatus
          ? _value.resolutionTargetStatus
          : resolutionTargetStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedByUserId: freezed == resolvedByUserId
          ? _value.resolvedByUserId
          : resolvedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DisputeImplCopyWith<$Res> implements $DisputeCopyWith<$Res> {
  factory _$$DisputeImplCopyWith(
          _$DisputeImpl value, $Res Function(_$DisputeImpl) then) =
      __$$DisputeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String conversationId,
      String? openedByUserId,
      String? againstUserId,
      String reason,
      String? details,
      String status,
      String? resolution,
      String? resolutionTargetStatus,
      String? resolvedByUserId,
      String? resolvedAt,
      Map<String, dynamic> metadata,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$DisputeImplCopyWithImpl<$Res>
    extends _$DisputeCopyWithImpl<$Res, _$DisputeImpl>
    implements _$$DisputeImplCopyWith<$Res> {
  __$$DisputeImplCopyWithImpl(
      _$DisputeImpl _value, $Res Function(_$DisputeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? conversationId = null,
    Object? openedByUserId = freezed,
    Object? againstUserId = freezed,
    Object? reason = null,
    Object? details = freezed,
    Object? status = null,
    Object? resolution = freezed,
    Object? resolutionTargetStatus = freezed,
    Object? resolvedByUserId = freezed,
    Object? resolvedAt = freezed,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$DisputeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      openedByUserId: freezed == openedByUserId
          ? _value.openedByUserId
          : openedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      againstUserId: freezed == againstUserId
          ? _value.againstUserId
          : againstUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      details: freezed == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      resolution: freezed == resolution
          ? _value.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      resolutionTargetStatus: freezed == resolutionTargetStatus
          ? _value.resolutionTargetStatus
          : resolutionTargetStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedByUserId: freezed == resolvedByUserId
          ? _value.resolvedByUserId
          : resolvedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
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
class _$DisputeImpl implements _Dispute {
  const _$DisputeImpl(
      {required this.id,
      required this.transactionId,
      required this.conversationId,
      this.openedByUserId,
      this.againstUserId,
      required this.reason,
      this.details,
      required this.status,
      this.resolution,
      this.resolutionTargetStatus,
      this.resolvedByUserId,
      this.resolvedAt,
      final Map<String, dynamic> metadata = const {},
      required this.createdAt,
      required this.updatedAt})
      : _metadata = metadata;

  factory _$DisputeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisputeImplFromJson(json);

  @override
  final String id;
  @override
  final String transactionId;
  @override
  final String conversationId;
  @override
  final String? openedByUserId;
  @override
  final String? againstUserId;
  @override
  final String reason;
  @override
  final String? details;
  @override
  final String status;
  @override
  final String? resolution;
  @override
  final String? resolutionTargetStatus;
  @override
  final String? resolvedByUserId;
  @override
  final String? resolvedAt;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'Dispute(id: $id, transactionId: $transactionId, conversationId: $conversationId, openedByUserId: $openedByUserId, againstUserId: $againstUserId, reason: $reason, details: $details, status: $status, resolution: $resolution, resolutionTargetStatus: $resolutionTargetStatus, resolvedByUserId: $resolvedByUserId, resolvedAt: $resolvedAt, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisputeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.openedByUserId, openedByUserId) ||
                other.openedByUserId == openedByUserId) &&
            (identical(other.againstUserId, againstUserId) ||
                other.againstUserId == againstUserId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            (identical(other.resolutionTargetStatus, resolutionTargetStatus) ||
                other.resolutionTargetStatus == resolutionTargetStatus) &&
            (identical(other.resolvedByUserId, resolvedByUserId) ||
                other.resolvedByUserId == resolvedByUserId) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      transactionId,
      conversationId,
      openedByUserId,
      againstUserId,
      reason,
      details,
      status,
      resolution,
      resolutionTargetStatus,
      resolvedByUserId,
      resolvedAt,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      __$$DisputeImplCopyWithImpl<_$DisputeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisputeImplToJson(
      this,
    );
  }
}

abstract class _Dispute implements Dispute {
  const factory _Dispute(
      {required final String id,
      required final String transactionId,
      required final String conversationId,
      final String? openedByUserId,
      final String? againstUserId,
      required final String reason,
      final String? details,
      required final String status,
      final String? resolution,
      final String? resolutionTargetStatus,
      final String? resolvedByUserId,
      final String? resolvedAt,
      final Map<String, dynamic> metadata,
      required final String createdAt,
      required final String updatedAt}) = _$DisputeImpl;

  factory _Dispute.fromJson(Map<String, dynamic> json) = _$DisputeImpl.fromJson;

  @override
  String get id;
  @override
  String get transactionId;
  @override
  String get conversationId;
  @override
  String? get openedByUserId;
  @override
  String? get againstUserId;
  @override
  String get reason;
  @override
  String? get details;
  @override
  String get status;
  @override
  String? get resolution;
  @override
  String? get resolutionTargetStatus;
  @override
  String? get resolvedByUserId;
  @override
  String? get resolvedAt;
  @override
  Map<String, dynamic> get metadata;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of Dispute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisputeImplCopyWith<_$DisputeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
