import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/service_offering.dart';
import '../domain/models/provider_package.dart';
import 'repositories_providers.dart';
import '../data/repositories/services_repository.dart';

final serviceOfferingsProvider =
    FutureProvider<List<ServiceOffering>>((ref) async {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.listOfferings();
});

final providerPackageProvider =
    FutureProvider.family<ProviderPackage, String>((ref, token) async {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.loadProviderPackage(token);
});

final servicePdfJobsByConversationProvider =
    FutureProvider.family<List<ServicePdfJobRecord>, String>(
        (ref, conversationId) async {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.listServicePdfJobs(conversationId: conversationId);
});

final providerLinksByConversationProvider =
    FutureProvider.family<List<ServiceProviderLinkRecord>, String>(
        (ref, conversationId) async {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.listProviderLinksByConversation(conversationId);
});
