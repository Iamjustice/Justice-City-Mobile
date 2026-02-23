// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatAction _$ChatActionFromJson(Map<String, dynamic> json) {
  return _ChatAction.fromJson(json);
}

/// @nodoc
mixin _$ChatAction {
  String get id => throw _privateConstructorUsedError;
  String get transactionId => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get actionType => throw _privateConstructorUsedError;
  String get targetRole => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  String? get createdByUserId => throw _privateConstructorUsedError;
  String? get resolvedByUserId => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;
  String? get resolvedAt => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChatAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatActionCopyWith<ChatAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatActionCopyWith<$Res> {
  factory $ChatActionCopyWith(
          ChatAction value, $Res Function(ChatAction) then) =
      _$ChatActionCopyWithImpl<$Res, ChatAction>;
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String conversationId,
      String actionType,
      String targetRole,
      String status,
      Map<String, dynamic> payload,
      String? createdByUserId,
      String? resolvedByUserId,
      String? expiresAt,
      String? resolvedAt,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$ChatActionCopyWithImpl<$Res, $Val extends ChatAction>
    implements $ChatActionCopyWith<$Res> {
  _$ChatActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? conversationId = null,
    Object? actionType = null,
    Object? targetRole = null,
    Object? status = null,
    Object? payload = null,
    Object? createdByUserId = freezed,
    Object? resolvedByUserId = freezed,
    Object? expiresAt = freezed,
    Object? resolvedAt = freezed,
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
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      targetRole: null == targetRole
          ? _value.targetRole
          : targetRole // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdByUserId: freezed == createdByUserId
          ? _value.createdByUserId
          : createdByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedByUserId: freezed == resolvedByUserId
          ? _value.resolvedByUserId
          : resolvedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$ChatActionImplCopyWith<$Res>
    implements $ChatActionCopyWith<$Res> {
  factory _$$ChatActionImplCopyWith(
          _$ChatActionImpl value, $Res Function(_$ChatActionImpl) then) =
      __$$ChatActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String transactionId,
      String conversationId,
      String actionType,
      String targetRole,
      String status,
      Map<String, dynamic> payload,
      String? createdByUserId,
      String? resolvedByUserId,
      String? expiresAt,
      String? resolvedAt,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$ChatActionImplCopyWithImpl<$Res>
    extends _$ChatActionCopyWithImpl<$Res, _$ChatActionImpl>
    implements _$$ChatActionImplCopyWith<$Res> {
  __$$ChatActionImplCopyWithImpl(
      _$ChatActionImpl _value, $Res Function(_$ChatActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? conversationId = null,
    Object? actionType = null,
    Object? targetRole = null,
    Object? status = null,
    Object? payload = null,
    Object? createdByUserId = freezed,
    Object? resolvedByUserId = freezed,
    Object? expiresAt = freezed,
    Object? resolvedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ChatActionImpl(
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
      actionType: null == actionType
          ? _value.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as String,
      targetRole: null == targetRole
          ? _value.targetRole
          : targetRole // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdByUserId: freezed == createdByUserId
          ? _value.createdByUserId
          : createdByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedByUserId: freezed == resolvedByUserId
          ? _value.resolvedByUserId
          : resolvedByUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$ChatActionImpl implements _ChatAction {
  const _$ChatActionImpl(
      {required this.id,
      required this.transactionId,
      required this.conversationId,
      required this.actionType,
      required this.targetRole,
      required this.status,
      final Map<String, dynamic> payload = const {},
      this.createdByUserId,
      this.resolvedByUserId,
      this.expiresAt,
      this.resolvedAt,
      required this.createdAt,
      required this.updatedAt})
      : _payload = payload;

  factory _$ChatActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatActionImplFromJson(json);

  @override
  final String id;
  @override
  final String transactionId;
  @override
  final String conversationId;
  @override
  final String actionType;
  @override
  final String targetRole;
  @override
  final String status;
  final Map<String, dynamic> _payload;
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  final String? createdByUserId;
  @override
  final String? resolvedByUserId;
  @override
  final String? expiresAt;
  @override
  final String? resolvedAt;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'ChatAction(id: $id, transactionId: $transactionId, conversationId: $conversationId, actionType: $actionType, targetRole: $targetRole, status: $status, payload: $payload, createdByUserId: $createdByUserId, resolvedByUserId: $resolvedByUserId, expiresAt: $expiresAt, resolvedAt: $resolvedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.targetRole, targetRole) ||
                other.targetRole == targetRole) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.resolvedByUserId, resolvedByUserId) ||
                other.resolvedByUserId == resolvedByUserId) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
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
      actionType,
      targetRole,
      status,
      const DeepCollectionEquality().hash(_payload),
      createdByUserId,
      resolvedByUserId,
      expiresAt,
      resolvedAt,
      createdAt,
      updatedAt);

  /// Create a copy of ChatAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatActionImplCopyWith<_$ChatActionImpl> get copyWith =>
      __$$ChatActionImplCopyWithImpl<_$ChatActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatActionImplToJson(
      this,
    );
  }
}

abstract class _ChatAction implements ChatAction {
  const factory _ChatAction(
      {required final String id,
      required final String transactionId,
      required final String conversationId,
      required final String actionType,
      required final String targetRole,
      required final String status,
      final Map<String, dynamic> payload,
      final String? createdByUserId,
      final String? resolvedByUserId,
      final String? expiresAt,
      final String? resolvedAt,
      required final String createdAt,
      required final String updatedAt}) = _$ChatActionImpl;

  factory _ChatAction.fromJson(Map<String, dynamic> json) =
      _$ChatActionImpl.fromJson;

  @override
  String get id;
  @override
  String get transactionId;
  @override
  String get conversationId;
  @override
  String get actionType;
  @override
  String get targetRole;
  @override
  String get status;
  @override
  Map<String, dynamic> get payload;
  @override
  String? get createdByUserId;
  @override
  String? get resolvedByUserId;
  @override
  String? get expiresAt;
  @override
  String? get resolvedAt;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of ChatAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatActionImplCopyWith<_$ChatActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
