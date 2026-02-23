import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_package.freezed.dart';
part 'provider_package.g.dart';

@freezed
class ProviderPackageFile with _$ProviderPackageFile {
  const factory ProviderPackageFile({
    required String bucketId,
    required String storagePath,
    required String fileName,
    String? mimeType,
    String? createdAt,
    String? signedUrl,
  }) = _ProviderPackageFile;

  factory ProviderPackageFile.fromJson(Map<String, dynamic> json) =>
      _$ProviderPackageFileFromJson(json);
}

@freezed
class ProviderPackage with _$ProviderPackage {
  const factory ProviderPackage({
    required String linkId,
    required String conversationId,
    String? serviceRequestId,
    String? providerUserId,
    required String status,
    required String expiresAt,
    String? openedAt,
    required Map<String, dynamic> payload,
    required List<ProviderPackageFile> attachments,
    ProviderPackageFile? transcript,
  }) = _ProviderPackage;

  factory ProviderPackage.fromJson(Map<String, dynamic> json) => _$ProviderPackageFromJson(json);
}
