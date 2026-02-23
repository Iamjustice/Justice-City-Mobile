// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProviderPackageFile _$ProviderPackageFileFromJson(Map<String, dynamic> json) {
  return _ProviderPackageFile.fromJson(json);
}

/// @nodoc
mixin _$ProviderPackageFile {
  String get bucketId => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get signedUrl => throw _privateConstructorUsedError;

  /// Serializes this ProviderPackageFile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderPackageFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderPackageFileCopyWith<ProviderPackageFile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderPackageFileCopyWith<$Res> {
  factory $ProviderPackageFileCopyWith(
          ProviderPackageFile value, $Res Function(ProviderPackageFile) then) =
      _$ProviderPackageFileCopyWithImpl<$Res, ProviderPackageFile>;
  @useResult
  $Res call(
      {String bucketId,
      String storagePath,
      String fileName,
      String? mimeType,
      String? createdAt,
      String? signedUrl});
}

/// @nodoc
class _$ProviderPackageFileCopyWithImpl<$Res, $Val extends ProviderPackageFile>
    implements $ProviderPackageFileCopyWith<$Res> {
  _$ProviderPackageFileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderPackageFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bucketId = null,
    Object? storagePath = null,
    Object? fileName = null,
    Object? mimeType = freezed,
    Object? createdAt = freezed,
    Object? signedUrl = freezed,
  }) {
    return _then(_value.copyWith(
      bucketId: null == bucketId
          ? _value.bucketId
          : bucketId // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      signedUrl: freezed == signedUrl
          ? _value.signedUrl
          : signedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProviderPackageFileImplCopyWith<$Res>
    implements $ProviderPackageFileCopyWith<$Res> {
  factory _$$ProviderPackageFileImplCopyWith(_$ProviderPackageFileImpl value,
          $Res Function(_$ProviderPackageFileImpl) then) =
      __$$ProviderPackageFileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String bucketId,
      String storagePath,
      String fileName,
      String? mimeType,
      String? createdAt,
      String? signedUrl});
}

/// @nodoc
class __$$ProviderPackageFileImplCopyWithImpl<$Res>
    extends _$ProviderPackageFileCopyWithImpl<$Res, _$ProviderPackageFileImpl>
    implements _$$ProviderPackageFileImplCopyWith<$Res> {
  __$$ProviderPackageFileImplCopyWithImpl(_$ProviderPackageFileImpl _value,
      $Res Function(_$ProviderPackageFileImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProviderPackageFile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bucketId = null,
    Object? storagePath = null,
    Object? fileName = null,
    Object? mimeType = freezed,
    Object? createdAt = freezed,
    Object? signedUrl = freezed,
  }) {
    return _then(_$ProviderPackageFileImpl(
      bucketId: null == bucketId
          ? _value.bucketId
          : bucketId // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _value.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      mimeType: freezed == mimeType
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      signedUrl: freezed == signedUrl
          ? _value.signedUrl
          : signedUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderPackageFileImpl implements _ProviderPackageFile {
  const _$ProviderPackageFileImpl(
      {required this.bucketId,
      required this.storagePath,
      required this.fileName,
      this.mimeType,
      this.createdAt,
      this.signedUrl});

  factory _$ProviderPackageFileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderPackageFileImplFromJson(json);

  @override
  final String bucketId;
  @override
  final String storagePath;
  @override
  final String fileName;
  @override
  final String? mimeType;
  @override
  final String? createdAt;
  @override
  final String? signedUrl;

  @override
  String toString() {
    return 'ProviderPackageFile(bucketId: $bucketId, storagePath: $storagePath, fileName: $fileName, mimeType: $mimeType, createdAt: $createdAt, signedUrl: $signedUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderPackageFileImpl &&
            (identical(other.bucketId, bucketId) ||
                other.bucketId == bucketId) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.signedUrl, signedUrl) ||
                other.signedUrl == signedUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bucketId, storagePath, fileName,
      mimeType, createdAt, signedUrl);

  /// Create a copy of ProviderPackageFile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderPackageFileImplCopyWith<_$ProviderPackageFileImpl> get copyWith =>
      __$$ProviderPackageFileImplCopyWithImpl<_$ProviderPackageFileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderPackageFileImplToJson(
      this,
    );
  }
}

abstract class _ProviderPackageFile implements ProviderPackageFile {
  const factory _ProviderPackageFile(
      {required final String bucketId,
      required final String storagePath,
      required final String fileName,
      final String? mimeType,
      final String? createdAt,
      final String? signedUrl}) = _$ProviderPackageFileImpl;

  factory _ProviderPackageFile.fromJson(Map<String, dynamic> json) =
      _$ProviderPackageFileImpl.fromJson;

  @override
  String get bucketId;
  @override
  String get storagePath;
  @override
  String get fileName;
  @override
  String? get mimeType;
  @override
  String? get createdAt;
  @override
  String? get signedUrl;

  /// Create a copy of ProviderPackageFile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderPackageFileImplCopyWith<_$ProviderPackageFileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProviderPackage _$ProviderPackageFromJson(Map<String, dynamic> json) {
  return _ProviderPackage.fromJson(json);
}

/// @nodoc
mixin _$ProviderPackage {
  String get linkId => throw _privateConstructorUsedError;
  String get conversationId => throw _privateConstructorUsedError;
  String? get serviceRequestId => throw _privateConstructorUsedError;
  String? get providerUserId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  String? get openedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;
  List<ProviderPackageFile> get attachments =>
      throw _privateConstructorUsedError;
  ProviderPackageFile? get transcript => throw _privateConstructorUsedError;

  /// Serializes this ProviderPackage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderPackageCopyWith<ProviderPackage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderPackageCopyWith<$Res> {
  factory $ProviderPackageCopyWith(
          ProviderPackage value, $Res Function(ProviderPackage) then) =
      _$ProviderPackageCopyWithImpl<$Res, ProviderPackage>;
  @useResult
  $Res call(
      {String linkId,
      String conversationId,
      String? serviceRequestId,
      String? providerUserId,
      String status,
      String expiresAt,
      String? openedAt,
      Map<String, dynamic> payload,
      List<ProviderPackageFile> attachments,
      ProviderPackageFile? transcript});

  $ProviderPackageFileCopyWith<$Res>? get transcript;
}

/// @nodoc
class _$ProviderPackageCopyWithImpl<$Res, $Val extends ProviderPackage>
    implements $ProviderPackageCopyWith<$Res> {
  _$ProviderPackageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linkId = null,
    Object? conversationId = null,
    Object? serviceRequestId = freezed,
    Object? providerUserId = freezed,
    Object? status = null,
    Object? expiresAt = null,
    Object? openedAt = freezed,
    Object? payload = null,
    Object? attachments = null,
    Object? transcript = freezed,
  }) {
    return _then(_value.copyWith(
      linkId: null == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceRequestId: freezed == serviceRequestId
          ? _value.serviceRequestId
          : serviceRequestId // ignore: cast_nullable_to_non_nullable
              as String?,
      providerUserId: freezed == providerUserId
          ? _value.providerUserId
          : providerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      openedAt: freezed == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<ProviderPackageFile>,
      transcript: freezed == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as ProviderPackageFile?,
    ) as $Val);
  }

  /// Create a copy of ProviderPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProviderPackageFileCopyWith<$Res>? get transcript {
    if (_value.transcript == null) {
      return null;
    }

    return $ProviderPackageFileCopyWith<$Res>(_value.transcript!, (value) {
      return _then(_value.copyWith(transcript: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProviderPackageImplCopyWith<$Res>
    implements $ProviderPackageCopyWith<$Res> {
  factory _$$ProviderPackageImplCopyWith(_$ProviderPackageImpl value,
          $Res Function(_$ProviderPackageImpl) then) =
      __$$ProviderPackageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String linkId,
      String conversationId,
      String? serviceRequestId,
      String? providerUserId,
      String status,
      String expiresAt,
      String? openedAt,
      Map<String, dynamic> payload,
      List<ProviderPackageFile> attachments,
      ProviderPackageFile? transcript});

  @override
  $ProviderPackageFileCopyWith<$Res>? get transcript;
}

/// @nodoc
class __$$ProviderPackageImplCopyWithImpl<$Res>
    extends _$ProviderPackageCopyWithImpl<$Res, _$ProviderPackageImpl>
    implements _$$ProviderPackageImplCopyWith<$Res> {
  __$$ProviderPackageImplCopyWithImpl(
      _$ProviderPackageImpl _value, $Res Function(_$ProviderPackageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProviderPackage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? linkId = null,
    Object? conversationId = null,
    Object? serviceRequestId = freezed,
    Object? providerUserId = freezed,
    Object? status = null,
    Object? expiresAt = null,
    Object? openedAt = freezed,
    Object? payload = null,
    Object? attachments = null,
    Object? transcript = freezed,
  }) {
    return _then(_$ProviderPackageImpl(
      linkId: null == linkId
          ? _value.linkId
          : linkId // ignore: cast_nullable_to_non_nullable
              as String,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String,
      serviceRequestId: freezed == serviceRequestId
          ? _value.serviceRequestId
          : serviceRequestId // ignore: cast_nullable_to_non_nullable
              as String?,
      providerUserId: freezed == providerUserId
          ? _value.providerUserId
          : providerUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String,
      openedAt: freezed == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<ProviderPackageFile>,
      transcript: freezed == transcript
          ? _value.transcript
          : transcript // ignore: cast_nullable_to_non_nullable
              as ProviderPackageFile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderPackageImpl implements _ProviderPackage {
  const _$ProviderPackageImpl(
      {required this.linkId,
      required this.conversationId,
      this.serviceRequestId,
      this.providerUserId,
      required this.status,
      required this.expiresAt,
      this.openedAt,
      required final Map<String, dynamic> payload,
      required final List<ProviderPackageFile> attachments,
      this.transcript})
      : _payload = payload,
        _attachments = attachments;

  factory _$ProviderPackageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderPackageImplFromJson(json);

  @override
  final String linkId;
  @override
  final String conversationId;
  @override
  final String? serviceRequestId;
  @override
  final String? providerUserId;
  @override
  final String status;
  @override
  final String expiresAt;
  @override
  final String? openedAt;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  final List<ProviderPackageFile> _attachments;
  @override
  List<ProviderPackageFile> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final ProviderPackageFile? transcript;

  @override
  String toString() {
    return 'ProviderPackage(linkId: $linkId, conversationId: $conversationId, serviceRequestId: $serviceRequestId, providerUserId: $providerUserId, status: $status, expiresAt: $expiresAt, openedAt: $openedAt, payload: $payload, attachments: $attachments, transcript: $transcript)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderPackageImpl &&
            (identical(other.linkId, linkId) || other.linkId == linkId) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.serviceRequestId, serviceRequestId) ||
                other.serviceRequestId == serviceRequestId) &&
            (identical(other.providerUserId, providerUserId) ||
                other.providerUserId == providerUserId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.transcript, transcript) ||
                other.transcript == transcript));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      linkId,
      conversationId,
      serviceRequestId,
      providerUserId,
      status,
      expiresAt,
      openedAt,
      const DeepCollectionEquality().hash(_payload),
      const DeepCollectionEquality().hash(_attachments),
      transcript);

  /// Create a copy of ProviderPackage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderPackageImplCopyWith<_$ProviderPackageImpl> get copyWith =>
      __$$ProviderPackageImplCopyWithImpl<_$ProviderPackageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderPackageImplToJson(
      this,
    );
  }
}

abstract class _ProviderPackage implements ProviderPackage {
  const factory _ProviderPackage(
      {required final String linkId,
      required final String conversationId,
      final String? serviceRequestId,
      final String? providerUserId,
      required final String status,
      required final String expiresAt,
      final String? openedAt,
      required final Map<String, dynamic> payload,
      required final List<ProviderPackageFile> attachments,
      final ProviderPackageFile? transcript}) = _$ProviderPackageImpl;

  factory _ProviderPackage.fromJson(Map<String, dynamic> json) =
      _$ProviderPackageImpl.fromJson;

  @override
  String get linkId;
  @override
  String get conversationId;
  @override
  String? get serviceRequestId;
  @override
  String? get providerUserId;
  @override
  String get status;
  @override
  String get expiresAt;
  @override
  String? get openedAt;
  @override
  Map<String, dynamic> get payload;
  @override
  List<ProviderPackageFile> get attachments;
  @override
  ProviderPackageFile? get transcript;

  /// Create a copy of ProviderPackage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderPackageImplCopyWith<_$ProviderPackageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
