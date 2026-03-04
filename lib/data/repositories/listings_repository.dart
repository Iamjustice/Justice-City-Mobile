import 'dart:convert';

import 'package:dio/dio.dart';

import '../api/endpoints.dart';
import '../../domain/models/listing.dart';

class ListingActor {
  ListingActor({
    required this.actorId,
    this.actorRole,
    this.actorName,
  });

  final String actorId;
  final String? actorRole;
  final String? actorName;
}

class ListingUpsertInput {
  ListingUpsertInput({
    required this.title,
    required this.listingType,
    required this.location,
    required this.price,
    this.description,
    this.status,
  });

  final String title;
  final String listingType; // Sale | Rent
  final String location;
  final String price;
  final String? description;
  final String? status;
}

class ListingUploadFilePayload {
  ListingUploadFilePayload({
    required this.fileName,
    required this.contentBase64,
    this.mimeType,
    this.fileSizeBytes,
  });

  final String fileName;
  final String contentBase64;
  final String? mimeType;
  final int? fileSizeBytes;

  Map<String, dynamic> toJson() => {
        'fileName': fileName,
        'contentBase64': contentBase64,
        if (mimeType != null) 'mimeType': mimeType,
        if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      };

  static ListingUploadFilePayload fromBytes({
    required String fileName,
    required List<int> bytes,
    String? mimeType,
  }) {
    return ListingUploadFilePayload(
      fileName: fileName,
      contentBase64: base64Encode(bytes),
      mimeType: mimeType,
      fileSizeBytes: bytes.length,
    );
  }
}

class ListingAssetsUploadInput {
  ListingAssetsUploadInput({
    this.propertyDocuments = const [],
    this.ownershipAuthorizationDocuments = const [],
    this.images = const [],
  });

  final List<ListingUploadFilePayload> propertyDocuments;
  final List<ListingUploadFilePayload> ownershipAuthorizationDocuments;
  final List<ListingUploadFilePayload> images;
}

class ListingAssetsUploadResult {
  ListingAssetsUploadResult({
    required this.listingId,
    required this.propertyDocumentsUploaded,
    required this.ownershipAuthorizationUploaded,
    required this.imagesUploaded,
  });

  final String listingId;
  final int propertyDocumentsUploaded;
  final int ownershipAuthorizationUploaded;
  final int imagesUploaded;

  factory ListingAssetsUploadResult.fromJson(Map<String, dynamic> json) {
    int readInt(String key) {
      final v = json[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    return ListingAssetsUploadResult(
      listingId: '${json['listingId'] ?? ''}',
      propertyDocumentsUploaded: readInt('propertyDocumentsUploaded'),
      ownershipAuthorizationUploaded: readInt('ownershipAuthorizationUploaded'),
      imagesUploaded: readInt('imagesUploaded'),
    );
  }
}

class ListingsRepository {
  ListingsRepository(this._dio);
  final Dio _dio;

  Future<List<Listing>> fetchAgentListings({
    ListingActor? actor,
  }) async {
    final query = <String, dynamic>{};
    if (actor != null) {
      query['actorId'] = actor.actorId;
      if ((actor.actorRole ?? '').trim().isNotEmpty) {
        query['actorRole'] = actor.actorRole;
      }
      if ((actor.actorName ?? '').trim().isNotEmpty) {
        query['actorName'] = actor.actorName;
      }
    }

    final res = await _dio.get(
      ApiEndpoints.agentListings,
      queryParameters: query.isEmpty ? null : query,
    );

    final rows = _extractRows(res.data);
    return rows.map(Listing.fromJson).toList();
  }

  Future<Map<String, dynamic>?> fetchListingRecord({
    required String listingId,
    ListingActor? actor,
  }) async {
    final query = <String, dynamic>{};
    if (actor != null) {
      query['actorId'] = actor.actorId;
      if ((actor.actorRole ?? '').trim().isNotEmpty) {
        query['actorRole'] = actor.actorRole;
      }
      if ((actor.actorName ?? '').trim().isNotEmpty) {
        query['actorName'] = actor.actorName;
      }
    }

    try {
      final res = await _dio.get(
        ApiEndpoints.agentListing(listingId),
        queryParameters: query.isEmpty ? null : query,
      );
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      if (res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<Listing> createListing({
    required ListingUpsertInput input,
    required ListingActor actor,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.agentListings,
      data: _withActor(actor, {
        'title': input.title,
        'listingType': input.listingType,
        'location': input.location,
        'description': input.description,
        'price': input.price,
        'status': input.status ?? 'Pending Review',
      }),
    );
    return _readListing(
        res.data, 'Unexpected response while creating listing.');
  }

  Future<Listing> updateListing({
    required String listingId,
    required ListingUpsertInput input,
    required ListingActor actor,
  }) async {
    final res = await _dio.patch(
      ApiEndpoints.patchListing(listingId),
      data: _withActor(actor, {
        'title': input.title,
        'listingType': input.listingType,
        'location': input.location,
        'description': input.description,
        'price': input.price,
        'status': input.status ?? 'Draft',
      }),
    );
    return _readListing(
        res.data, 'Unexpected response while updating listing.');
  }

  Future<void> deleteListing({
    required String listingId,
    required ListingActor actor,
  }) async {
    await _dio.delete(
      ApiEndpoints.deleteListing(listingId),
      data: _withActor(actor, const {}),
    );
  }

  Future<Listing> updateListingStatus({
    required String listingId,
    required String status,
    ListingActor? actor,
  }) async {
    final res = await _dio.patch(
      ApiEndpoints.patchListingStatus(listingId),
      data: actor == null
          ? {'status': status}
          : _withActor(actor, {'status': status}),
    );
    return _readListing(
        res.data, 'Unexpected response from server while updating status.');
  }

  Future<void> updateListingVerificationStepStatus({
    required String listingId,
    required String stepKey,
    required String status,
    required ListingActor actor,
  }) async {
    await _dio.patch(
      ApiEndpoints.patchListingVerificationStepStatus(listingId, stepKey),
      data: _withActor(actor, {'status': status}),
    );
  }

  Future<Listing> updateListingPayoutStatus({
    required String listingId,
    required String payoutStatus,
    required ListingActor actor,
  }) async {
    final res = await _dio.patch(
      ApiEndpoints.patchListingPayout(listingId),
      data: _withActor(actor, {'payoutStatus': payoutStatus}),
    );
    return _readListing(
        res.data, 'Unexpected response while updating payout status.');
  }

  Future<ListingAssetsUploadResult> uploadListingAssets({
    required String listingId,
    required ListingAssetsUploadInput input,
    required ListingActor actor,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.listingAssets(listingId),
      data: _withActor(actor, {
        'propertyDocuments':
            input.propertyDocuments.map((e) => e.toJson()).toList(),
        'ownershipAuthorizationDocuments': input.ownershipAuthorizationDocuments
            .map((e) => e.toJson())
            .toList(),
        'images': input.images.map((e) => e.toJson()).toList(),
      }),
    );
    final data = res.data;
    if (data is Map) {
      return ListingAssetsUploadResult.fromJson(
          Map<String, dynamic>.from(data));
    }
    throw StateError('Unexpected response while uploading listing assets.');
  }

  Map<String, dynamic> _withActor(
      ListingActor actor, Map<String, dynamic> payload) {
    final data = <String, dynamic>{
      ...payload,
      'actorId': actor.actorId,
    };
    if ((actor.actorRole ?? '').trim().isNotEmpty) {
      data['actorRole'] = actor.actorRole;
    }
    if ((actor.actorName ?? '').trim().isNotEmpty) {
      data['actorName'] = actor.actorName;
    }
    return data;
  }

  Listing _readListing(dynamic data, String fallbackError) {
    if (data is Map) {
      return Listing.fromJson(Map<String, dynamic>.from(data));
    }
    throw StateError(fallbackError);
  }

  List<Map<String, dynamic>> _extractRows(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    return const [];
  }
}
