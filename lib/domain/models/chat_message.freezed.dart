// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatAttachment _$ChatAttachmentFromJson(Map<String, dynamic> json) {
  return _ChatAttachment.fromJson(json);
}

/// @nodoc
mixin _$ChatAttachment {
  String? get bucketId => throw _privateConstructorUsedError;
  String get storagePath => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  int? get fileSizeBytes => throw _privateConstructorUsedError;
  String? get previewUrl => throw _privateConstructorUsedError;

  /// Serializes this ChatAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatAttachmentCopyWith<ChatAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatAttachmentCopyWith<$Res> {
  factory $ChatAttachmentCopyWith(
          ChatAttachment value, $Res Function(ChatAttachment) then) =
      _$ChatAttachmentCopyWithImpl<$Res, ChatAttachment>;
  @useResult
  $Res call(
      {String? bucketId,
      String storagePath,
      String fileName,
      String? mimeType,
      int? fileSizeBytes,
      String? previewUrl});
}

/// @nodoc
class _$ChatAttachmentCopyWithImpl<$Res, $Val extends ChatAttachment>
    implements $ChatAttachmentCopyWith<$Res> {
  _$ChatAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bucketId = freezed,
    Object? storagePath = null,
    Object? fileName = null,
    Object? mimeType = freezed,
    Object? fileSizeBytes = freezed,
    Object? previewUrl = freezed,
  }) {
    return _then(_value.copyWith(
      bucketId: freezed == bucketId
          ? _value.bucketId
          : bucketId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      fileSizeBytes: freezed == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int?,
      previewUrl: freezed == previewUrl
          ? _value.previewUrl
          : previewUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatAttachmentImplCopyWith<$Res>
    implements $ChatAttachmentCopyWith<$Res> {
  factory _$$ChatAttachmentImplCopyWith(_$ChatAttachmentImpl value,
          $Res Function(_$ChatAttachmentImpl) then) =
      __$$ChatAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? bucketId,
      String storagePath,
      String fileName,
      String? mimeType,
      int? fileSizeBytes,
      String? previewUrl});
}

/// @nodoc
class __$$ChatAttachmentImplCopyWithImpl<$Res>
    extends _$ChatAttachmentCopyWithImpl<$Res, _$ChatAttachmentImpl>
    implements _$$ChatAttachmentImplCopyWith<$Res> {
  __$$ChatAttachmentImplCopyWithImpl(
      _$ChatAttachmentImpl _value, $Res Function(_$ChatAttachmentImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bucketId = freezed,
    Object? storagePath = null,
    Object? fileName = null,
    Object? mimeType = freezed,
    Object? fileSizeBytes = freezed,
    Object? previewUrl = freezed,
  }) {
    return _then(_$ChatAttachmentImpl(
      bucketId: freezed == bucketId
          ? _value.bucketId
          : bucketId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      fileSizeBytes: freezed == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int?,
      previewUrl: freezed == previewUrl
          ? _value.previewUrl
          : previewUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatAttachmentImpl implements _ChatAttachment {
  const _$ChatAttachmentImpl(
      {this.bucketId,
      required this.storagePath,
      required this.fileName,
      this.mimeType,
      this.fileSizeBytes,
      this.previewUrl});

  factory _$ChatAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatAttachmentImplFromJson(json);

  @override
  final String? bucketId;
  @override
  final String storagePath;
  @override
  final String fileName;
  @override
  final String? mimeType;
  @override
  final int? fileSizeBytes;
  @override
  final String? previewUrl;

  @override
  String toString() {
    return 'ChatAttachment(bucketId: $bucketId, storagePath: $storagePath, fileName: $fileName, mimeType: $mimeType, fileSizeBytes: $fileSizeBytes, previewUrl: $previewUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatAttachmentImpl &&
            (identical(other.bucketId, bucketId) ||
                other.bucketId == bucketId) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.previewUrl, previewUrl) ||
                other.previewUrl == previewUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bucketId, storagePath, fileName,
      mimeType, fileSizeBytes, previewUrl);

  /// Create a copy of ChatAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatAttachmentImplCopyWith<_$ChatAttachmentImpl> get copyWith =>
      __$$ChatAttachmentImplCopyWithImpl<_$ChatAttachmentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatAttachmentImplToJson(
      this,
    );
  }
}

abstract class _ChatAttachment implements ChatAttachment {
  const factory _ChatAttachment(
      {final String? bucketId,
      required final String storagePath,
      required final String fileName,
      final String? mimeType,
      final int? fileSizeBytes,
      final String? previewUrl}) = _$ChatAttachmentImpl;

  factory _ChatAttachment.fromJson(Map<String, dynamic> json) =
      _$ChatAttachmentImpl.fromJson;

  @override
  String? get bucketId;
  @override
  String get storagePath;
  @override
  String get fileName;
  @override
  String? get mimeType;
  @override
  int? get fileSizeBytes;
  @override
  String? get previewUrl;

  /// Create a copy of ChatAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatAttachmentImplCopyWith<_$ChatAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get sender => throw _privateConstructorUsedError; // me | them | system
  String get content => throw _privateConstructorUsedError;
  String? get time => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get senderId => throw _privateConstructorUsedError;
  String get messageType =>
      throw _privateConstructorUsedError; // text | system | issue_card
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<ChatAttachment> get attachments => throw _privateConstructorUsedError;

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {String id,
      String sender,
      String content,
      String? time,
      DateTime? createdAt,
      String? senderId,
      String messageType,
      Map<String, dynamic>? metadata,
      List<ChatAttachment> attachments});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? content = null,
    Object? time = freezed,
    Object? createdAt = freezed,
    Object? senderId = freezed,
    Object? messageType = null,
    Object? metadata = freezed,
    Object? attachments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      time: freezed == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<ChatAttachment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sender,
      String content,
      String? time,
      DateTime? createdAt,
      String? senderId,
      String messageType,
      Map<String, dynamic>? metadata,
      List<ChatAttachment> attachments});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = null,
    Object? content = null,
    Object? time = freezed,
    Object? createdAt = freezed,
    Object? senderId = freezed,
    Object? messageType = null,
    Object? metadata = freezed,
    Object? attachments = null,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: null == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      time: freezed == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      senderId: freezed == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String?,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<ChatAttachment>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.id,
      required this.sender,
      required this.content,
      this.time,
      this.createdAt,
      this.senderId,
      required this.messageType,
      final Map<String, dynamic>? metadata,
      final List<ChatAttachment> attachments = const <ChatAttachment>[]})
      : _metadata = metadata,
        _attachments = attachments;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String sender;
// me | them | system
  @override
  final String content;
  @override
  final String? time;
  @override
  final DateTime? createdAt;
  @override
  final String? senderId;
  @override
  final String messageType;
// text | system | issue_card
  final Map<String, dynamic>? _metadata;
// text | system | issue_card
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<ChatAttachment> _attachments;
  @override
  @JsonKey()
  List<ChatAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, sender: $sender, content: $content, time: $time, createdAt: $createdAt, senderId: $senderId, messageType: $messageType, metadata: $metadata, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sender,
      content,
      time,
      createdAt,
      senderId,
      messageType,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_attachments));

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String id,
      required final String sender,
      required final String content,
      final String? time,
      final DateTime? createdAt,
      final String? senderId,
      required final String messageType,
      final Map<String, dynamic>? metadata,
      final List<ChatAttachment> attachments}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get sender; // me | them | system
  @override
  String get content;
  @override
  String? get time;
  @override
  DateTime? get createdAt;
  @override
  String? get senderId;
  @override
  String get messageType; // text | system | issue_card
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<ChatAttachment> get attachments;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
