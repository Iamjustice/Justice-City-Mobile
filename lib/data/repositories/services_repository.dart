import 'package:dio/dio.dart';
import '../../domain/models/service_offering.dart';
import '../../domain/models/provider_package.dart';
import '../api/endpoints.dart';

class ServicesRepository {
  final Dio _dio;
  ServicesRepository(this._dio);

  Future<List<ServiceOffering>> listOfferings() async {
    final res = await _dio.get(ApiEndpoints.serviceOfferings);
    final data = res.data;
    if (data is List) {
      return data.map((e) => ServiceOffering.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    // some servers may wrap
    if (data is Map && data['offerings'] is List) {
      final list = List<Map<String, dynamic>>.from(data['offerings'] as List);
      return list.map(ServiceOffering.fromJson).toList();
    }
    throw StateError('Unexpected service offerings response');
  }

  Future<ProviderPackage> loadProviderPackage(String token) async {
    final res = await _dio.get(ApiEndpoints.providerPackage(token));
    return ProviderPackage.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
