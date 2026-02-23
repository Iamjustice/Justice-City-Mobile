// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String get transactionKind => throw _privateConstructorUsedError;
  String get closingMode => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get buyerUserId => throw _privateConstructorUsedError;
  String? get sellerUserId => throw _privateConstructorUsedError;
  String? get agentUserId => throw _privateConstructorUsedError;
  String? get providerUserId => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  double? get principalAmount => throw _privateConstructorUsedError;
  double get inspectionFeeAmount => throw _privateConstructorUsedError;
  bool get inspectionFeeRefundable => throw _privateConstructorUsedError;
  String get inspectionFeeStatus => throw _privateConstructorUsedError;
  String? get escrowReference => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String transactionKind,
      String closingMode,
      String status,
      String? buyerUserId,
      String? sellerUserId,
      String? agentUserId,
      String? providerUserId,
      String currency,
      double? principalAmount,
      double inspectionFeeAmount,
      bool inspectionFeeRefundable,
      String inspectionFeeStatus,
      String? escrowReference,
      Map<String, dynamic> metadata,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? transactionKind = null,
    Object? closingMode = null,
    Object? status = null,
    Object? buyerUserId = freezed,
    Object? sellerUserId = freezed,
    Object? agentUserId = freezed,
    Object? providerUserId = freezed,
    Object? currency = null,
    Object? principalAmount = freezed,
    Object? inspectionFeeAmount = null,
    Object? inspectionFeeRefundable = null,
    Object? inspectionFeeStatus = null,
    Object? escrowReference = freezed,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionKind: null == transactionKind
          ? _value.transactionKind
          : transactionKind // ignore: cast_nullable_to_non_nullable
              as String,
      closingMode: null == closingMode
          ? _value.closingMode
          : closingMode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      buyerUserId: freezed == buyerUserId
          ? _value.buyerUserId
          : buyerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerUserId: freezed == sellerUserId
          ? _value.sellerUserId
          : sellerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      agentUserId: freezed == agentUserId
          ? _value.agentUserId
          : agentUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      providerUserId: freezed == providerUserId
          ? _value.providerUserId
          : providerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      principalAmount: freezed == principalAmount
          ? _value.principalAmount
          : principalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      inspectionFeeAmount: null == inspectionFeeAmount
          ? _value.inspectionFeeAmount
          : inspectionFeeAmount // ignore: cast_nullable_to_non_nullable
              as double,
      inspectionFeeRefundable: null == inspectionFeeRefundable
          ? _value.inspectionFeeRefundable
          : inspectionFeeRefundable // ignore: cast_nullable_to_non_nullable
              as bool,
      inspectionFeeStatus: null == inspectionFeeStatus
          ? _value.inspectionFeeStatus
          : inspectionFeeStatus // ignore: cast_nullable_to_non_nullable
              as String,
      escrowReference: freezed == escrowReference
          ? _value.escrowReference
          : escrowReference // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String conversationId,
      String transactionKind,
      String closingMode,
      String status,
      String? buyerUserId,
      String? sellerUserId,
      String? agentUserId,
      String? providerUserId,
      String currency,
      double? principalAmount,
      double inspectionFeeAmount,
      bool inspectionFeeRefundable,
      String inspectionFeeStatus,
      String? escrowReference,
      Map<String, dynamic> metadata,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? transactionKind = null,
    Object? closingMode = null,
    Object? status = null,
    Object? buyerUserId = freezed,
    Object? sellerUserId = freezed,
    Object? agentUserId = freezed,
    Object? providerUserId = freezed,
    Object? currency = null,
    Object? principalAmount = freezed,
    Object? inspectionFeeAmount = null,
    Object? inspectionFeeRefundable = null,
    Object? inspectionFeeStatus = null,
    Object? escrowReference = freezed,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      transactionKind: null == transactionKind
          ? _value.transactionKind
          : transactionKind // ignore: cast_nullable_to_non_nullable
              as String,
      closingMode: null == closingMode
          ? _value.closingMode
          : closingMode // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      buyerUserId: freezed == buyerUserId
          ? _value.buyerUserId
          : buyerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      sellerUserId: freezed == sellerUserId
          ? _value.sellerUserId
          : sellerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      agentUserId: freezed == agentUserId
          ? _value.agentUserId
          : agentUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      providerUserId: freezed == providerUserId
          ? _value.providerUserId
          : providerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      principalAmount: freezed == principalAmount
          ? _value.principalAmount
          : principalAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      inspectionFeeAmount: null == inspectionFeeAmount
          ? _value.inspectionFeeAmount
          : inspectionFeeAmount // ignore: cast_nullable_to_non_nullable
              as double,
      inspectionFeeRefundable: null == inspectionFeeRefundable
          ? _value.inspectionFeeRefundable
          : inspectionFeeRefundable // ignore: cast_nullable_to_non_nullable
              as bool,
      inspectionFeeStatus: null == inspectionFeeStatus
          ? _value.inspectionFeeStatus
          : inspectionFeeStatus // ignore: cast_nullable_to_non_nullable
              as String,
      escrowReference: freezed == escrowReference
          ? _value.escrowReference
          : escrowReference // ignore: cast_nullable_to_non_nullable
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
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.conversationId,
      required this.transactionKind,
      required this.closingMode,
      required this.status,
      this.buyerUserId,
      this.sellerUserId,
      this.agentUserId,
      this.providerUserId,
      required this.currency,
      this.principalAmount,
      required this.inspectionFeeAmount,
      required this.inspectionFeeRefundable,
      required this.inspectionFeeStatus,
      this.escrowReference,
      final Map<String, dynamic> metadata = const {},
      required this.createdAt,
      required this.updatedAt})
      : _metadata = metadata;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String conversationId;
  @override
  final String transactionKind;
  @override
  final String closingMode;
  @override
  final String status;
  @override
  final String? buyerUserId;
  @override
  final String? sellerUserId;
  @override
  final String? agentUserId;
  @override
  final String? providerUserId;
  @override
  final String currency;
  @override
  final double? principalAmount;
  @override
  final double inspectionFeeAmount;
  @override
  final bool inspectionFeeRefundable;
  @override
  final String inspectionFeeStatus;
  @override
  final String? escrowReference;
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
    return 'Transaction(id: $id, conversationId: $conversationId, transactionKind: $transactionKind, closingMode: $closingMode, status: $status, buyerUserId: $buyerUserId, sellerUserId: $sellerUserId, agentUserId: $agentUserId, providerUserId: $providerUserId, currency: $currency, principalAmount: $principalAmount, inspectionFeeAmount: $inspectionFeeAmount, inspectionFeeRefundable: $inspectionFeeRefundable, inspectionFeeStatus: $inspectionFeeStatus, escrowReference: $escrowReference, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.transactionKind, transactionKind) ||
                other.transactionKind == transactionKind) &&
            (identical(other.closingMode, closingMode) ||
                other.closingMode == closingMode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.buyerUserId, buyerUserId) ||
                other.buyerUserId == buyerUserId) &&
            (identical(other.sellerUserId, sellerUserId) ||
                other.sellerUserId == sellerUserId) &&
            (identical(other.agentUserId, agentUserId) ||
                other.agentUserId == agentUserId) &&
            (identical(other.providerUserId, providerUserId) ||
                other.providerUserId == providerUserId) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.principalAmount, principalAmount) ||
                other.principalAmount == principalAmount) &&
            (identical(other.inspectionFeeAmount, inspectionFeeAmount) ||
                other.inspectionFeeAmount == inspectionFeeAmount) &&
            (identical(
                    other.inspectionFeeRefundable, inspectionFeeRefundable) ||
                other.inspectionFeeRefundable == inspectionFeeRefundable) &&
            (identical(other.inspectionFeeStatus, inspectionFeeStatus) ||
                other.inspectionFeeStatus == inspectionFeeStatus) &&
            (identical(other.escrowReference, escrowReference) ||
                other.escrowReference == escrowReference) &&
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
      conversationId,
      transactionKind,
      closingMode,
      status,
      buyerUserId,
      sellerUserId,
      agentUserId,
      providerUserId,
      currency,
      principalAmount,
      inspectionFeeAmount,
      inspectionFeeRefundable,
      inspectionFeeStatus,
      escrowReference,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      required final String conversationId,
      required final String transactionKind,
      required final String closingMode,
      required final String status,
      final String? buyerUserId,
      final String? sellerUserId,
      final String? agentUserId,
      final String? providerUserId,
      required final String currency,
      final double? principalAmount,
      required final double inspectionFeeAmount,
      required final bool inspectionFeeRefundable,
      required final String inspectionFeeStatus,
      final String? escrowReference,
      final Map<String, dynamic> metadata,
      required final String createdAt,
      required final String updatedAt}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get conversationId;
  @override
  String get transactionKind;
  @override
  String get closingMode;
  @override
  String get status;
  @override
  String? get buyerUserId;
  @override
  String? get sellerUserId;
  @override
  String? get agentUserId;
  @override
  String? get providerUserId;
  @override
  String get currency;
  @override
  double? get principalAmount;
  @override
  double get inspectionFeeAmount;
  @override
  bool get inspectionFeeRefundable;
  @override
  String get inspectionFeeStatus;
  @override
  String? get escrowReference;
  @override
  Map<String, dynamic> get metadata;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
