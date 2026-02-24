import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';

final dashboardListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final me = await ref.watch(meProvider.future);
  final role = (me?.role ?? '').toLowerCase();
  final isOperator = role == 'admin' || role == 'agent' || role == 'seller' || role == 'owner';
  if (!isOperator) return const [];

  try {
    return await ref.read(listingsRepositoryProvider).fetchAgentListings();
  } catch (_) {
    return const [];
  }
});

final dashboardAdminOverviewProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final me = await ref.watch(meProvider.future);
  if ((me?.role ?? '').toLowerCase() != 'admin') return null;

  try {
    return await ref.read(adminRepositoryProvider).getDashboard();
  } catch (_) {
    return null;
  }
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load profile: $error'),
          ),
        ),
      ),
      data: (me) {
        final role = (me?.role ?? 'buyer').toLowerCase();
        final displayName = (me?.fullName?.trim().isNotEmpty ?? false)
            ? me!.fullName!.trim()
            : (me?.email ?? 'User');

        if (role == 'admin') {
          return _AdminDashboardShell(role: role, displayName: displayName);
        }

        if (role == 'agent' || role == 'seller' || role == 'owner') {
          return _OperatorDashboardShell(role: role, displayName: displayName);
        }

        return _BuyerDashboardShell(role: role, displayName: displayName);
      },
    );
  }
}

class _AdminDashboardShell extends ConsumerWidget {
  const _AdminDashboardShell({
    required this.role,
    required this.displayName,
  });

  final String role;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);
    final adminAsync = ref.watch(dashboardAdminOverviewProvider);

    final overview = adminAsync.maybeWhen(
      data: (data) => (data?['overview'] is Map<String, dynamic>)
          ? data!['overview'] as Map<String, dynamic>
          : <String, dynamic>{},
      orElse: () => <String, dynamic>{},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(dashboardListingsProvider);
              ref.invalidate(dashboardAdminOverviewProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RoleHeader(displayName: displayName, role: role),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: '${overview['totalUsers'] ?? overview['total_users'] ?? '-'}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Pending Verifications',
                  value:
                      '${overview['pendingVerifications'] ?? overview['pending_verifications'] ?? '-'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Flagged Listings',
                  value: '${overview['flaggedListings'] ?? overview['flagged_listings'] ?? '-'}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Commission Rate',
                  value: '${overview['commissionRate'] ?? overview['commission_rate'] ?? '-'}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => context.go('/admin'),
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text('Open Admin Console'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.go('/listings'),
                icon: const Icon(Icons.home_work_outlined),
                label: const Text('Listings Console'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/chat'),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Support Chat'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Recent Listings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          listingsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('Failed to load listings: $error'),
            data: (items) {
              if (items.isEmpty) return const Text('No listings yet.');
              return Column(
                children: items.take(5).map((listing) => _ListingTile(listing: listing)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OperatorDashboardShell extends ConsumerWidget {
  const _OperatorDashboardShell({
    required this.role,
    required this.displayName,
  });

  final String role;
  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardListingsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load listings: $error')),
        data: (items) {
          final draft = items.where((e) => (e.status ?? '').toLowerCase() == 'draft').length;
          final pending = items
              .where((e) => (e.status ?? '').toLowerCase().contains('pending'))
              .length;
          final published = items
              .where((e) => (e.status ?? '').toLowerCase().contains('published'))
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RoleHeader(displayName: displayName, role: role),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Total Listings', value: '${items.length}')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Draft', value: '$draft')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Pending Review', value: '$pending')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Published', value: '$published')),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/listings'),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Manage Listings'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => context.go('/chat'),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Leads & Chats'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/services'),
                    icon: const Icon(Icons.work_outline),
                    label: const Text('Professional Services'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Recent Listings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (items.isEmpty)
                const Text('No listings yet.')
              else
                ...items.take(8).map((listing) => _ListingTile(listing: listing)),
            ],
          );
        },
      ),
    );
  }
}

class _BuyerDashboardShell extends StatelessWidget {
  const _BuyerDashboardShell({
    required this.role,
    required this.displayName,
  });

  final String role;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RoleHeader(displayName: displayName, role: role),
          const SizedBox(height: 16),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.phone_forwarded_outlined),
            title: const Text('Request Callback'),
            subtitle: const Text('Contact support about a property'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/request-callback'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Professional Services'),
            subtitle: const Text('Survey, valuation, verification, snagging'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/services'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chats'),
            subtitle: const Text('Track conversations with support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/chat'),
          ),
        ],
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader({
    required this.displayName,
    required this.role,
  });

  final String displayName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text('Role: ${role.isEmpty ? 'buyer' : role}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingTile extends StatelessWidget {
  const _ListingTile({
    required this.listing,
  });

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final status = listing.status ?? 'unknown';
    final location = listing.location ?? 'No location';
    final price = listing.price ?? '-';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.home_work_outlined),
        title: Text(listing.title),
        subtitle: Text('$location - $status'),
        trailing: Text(price),
        onTap: () => context.go('/property/${listing.id}', extra: listing),
      ),
    );
  }
}
