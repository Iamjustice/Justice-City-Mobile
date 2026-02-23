// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProviderPackageFileImpl _$$ProviderPackageFileImplFromJson(
        Map<String, dynamic> json) =>
    _$ProviderPackageFileImpl(
      bucketId: json['bucketId'] as String,
      storagePath: json['storagePath'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String?,
      createdAt: json['createdAt'] as String?,
      signedUrl: json['signedUrl'] as String?,
    );

Map<String, dynamic> _$$ProviderPackageFileImplToJson(
        _$ProviderPackageFileImpl instance) =>
    <String, dynamic>{
      'bucketId': instance.bucketId,
      'storagePath': instance.storagePath,
      'fileName': instance.fileName,
      'mimeType': instance.mimeType,
      'createdAt': instance.createdAt,
      'signedUrl': instance.signedUrl,
    };

_$ProviderPackageImpl _$$ProviderPackageImplFromJson(
        Map<String, dynamic> json) =>
    _$ProviderPackageImpl(
      linkId: json['linkId'] as String,
      conversationId: json['conversationId'] as String,
      serviceRequestId: json['serviceRequestId'] as String?,
      providerUserId: json['providerUserId'] as String?,
      status: json['status'] as String,
      expiresAt: json['expiresAt'] as String,
      openedAt: json['openedAt'] as String?,
      payload: json['payload'] as Map<String, dynamic>,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => ProviderPackageFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      transcript: json['transcript'] == null
          ? null
          : ProviderPackageFile.fromJson(
              json['transcript'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProviderPackageImplToJson(
        _$ProviderPackageImpl instance) =>
    <String, dynamic>{
      'linkId': instance.linkId,
      'conversationId': instance.conversationId,
      'serviceRequestId': instance.serviceRequestId,
      'providerUserId': instance.providerUserId,
      'status': instance.status,
      'expiresAt': instance.expiresAt,
      'openedAt': instance.openedAt,
      'payload': instance.payload,
      'attachments': instance.attachments,
      'transcript': instance.transcript,
    };
