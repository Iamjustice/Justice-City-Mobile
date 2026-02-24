import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/listing.dart';
import '../../state/repositories_providers.dart';

final listingsProvider = FutureProvider<List<Listing>>((ref) {
  return ref.read(listingsRepositoryProvider).fetchAgentListings();
});

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(listingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listings'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(listingsProvider),
          ),
        ],
      ),
      body: listings.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No listings yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 20),
            itemBuilder: (_, i) {
              final l = items[i];
              final subtitle = <String>[
                if (l.location != null) l.location!,
                if (l.status != null) l.status!,
              ].join(' - ');

              return ListTile(
                leading: const Icon(Icons.home_work_outlined),
                title: Text(l.title),
                subtitle: Text(subtitle.isEmpty ? '-' : subtitle),
                trailing: Text(l.price ?? ''),
                onTap: () => context.go('/property/${l.id}', extra: l),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed: $e')),
      ),
    );
  }
}
