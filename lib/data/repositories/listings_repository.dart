import 'package:dio/dio.dart';

import '../api/endpoints.dart';
import '../../domain/models/listing.dart';

class ListingsRepository {
  ListingsRepository(this._dio);
  final Dio _dio;

  Future<List<Listing>> fetchAgentListings() async {
    final res = await _dio.get(ApiEndpoints.agentListings);
    final data = res.data;
    if (data is List) {
      return data.map((e) => Listing.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    // server may wrap in { items: [] }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .map((e) => Listing.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  Future<Listing> updateListingStatus({
    required String listingId,
    required String status,
  }) async {
    final res = await _dio.patch(
      ApiEndpoints.patchListingStatus(listingId),
      data: {'status': status},
    );
    final data = res.data;
    if (data is Map) {
      return Listing.fromJson(Map<String, dynamic>.from(data));
    }
    throw StateError('Unexpected response from server while updating status.');
  }
}
