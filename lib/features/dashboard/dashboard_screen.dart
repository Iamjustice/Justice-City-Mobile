import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);

final dashboardListingsProvider = FutureProvider<List<Listing>>((ref) async {
  final me = await ref.watch(meProvider.future);
  final role = (me?.role ?? '').toLowerCase();
  final isOperator =
      role == 'admin' || role == 'agent' || role == 'seller' || role == 'owner';
  if (!isOperator) return const [];

  try {
    return await ref.read(listingsRepositoryProvider).fetchAgentListings();
  } catch (_) {
    return const [];
  }
});

final dashboardAdminOverviewProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: Center(child: Text('Failed to load profile: $error')),
      ),
      data: (me) {
        final role = (me?.role ?? 'buyer').toLowerCase();
        final displayName = (me?.fullName?.trim().isNotEmpty ?? false)
            ? me!.fullName!.trim()
            : (me?.email ?? 'User');

        switch (role) {
          case 'admin':
            return _AdminDashboard(displayName: displayName);
          case 'agent':
            return _AgentDashboard(displayName: displayName);
          case 'seller':
            return _SellerDashboard(displayName: displayName);
          case 'owner':
            return _OwnerDashboard(displayName: displayName);
          case 'renter':
            return _RenterDashboard(displayName: displayName);
          default:
            return _BuyerDashboard(displayName: displayName);
        }
      },
    );
  }
}

class _AdminDashboard extends ConsumerWidget {
  const _AdminDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);
    final adminAsync = ref.watch(dashboardAdminOverviewProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: _jcPageBg,
        appBar: AppBar(
          backgroundColor: _jcPageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const SizedBox(height: 34, child: _BrandWordmark()),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () {
                ref.invalidate(dashboardListingsProvider);
                ref.invalidate(dashboardAdminOverviewProvider);
              },
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'Open Admin Panel',
              onPressed: () => context.go('/admin'),
              icon: const Icon(Icons.admin_panel_settings_outlined),
            ),
          ],
        ),
        body: listingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load listings: $e')),
          data: (listings) {
            final stats = _listingStats(listings);
            final overview = adminAsync.maybeWhen(
              data: (data) => (data?['overview'] is Map<String, dynamic>)
                  ? data!['overview'] as Map<String, dynamic>
                  : <String, dynamic>{},
              orElse: () => <String, dynamic>{},
            );
            final adminUsers =
                '${overview['totalUsers'] ?? overview['total_users'] ?? '-'}';
            final adminFlagged =
                '${overview['flaggedListings'] ?? overview['flagged_listings'] ?? '-'}';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _ConsoleHeader(
                    title: 'Admin Listings Console',
                    subtitle:
                        'Create, edit, and moderate listings across all platform roles.',
                    displayName: displayName,
                    role: 'admin',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _KpiCard(
                          title: 'Total Listings', value: '${listings.length}'),
                      _KpiCard(
                          title: 'Pending Review', value: '${stats.pending}'),
                      _KpiCard(title: 'Closed Deals', value: '${stats.closed}'),
                      _KpiCard(title: 'Total Users', value: adminUsers),
                      _KpiCard(title: 'Flagged Listings', value: adminFlagged),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _jcPanelBorder),
                    ),
                    child: const TabBar(
                      padding: EdgeInsets.all(4),
                      labelColor: Color(0xFF0F172A),
                      unselectedLabelColor: Color(0xFF64748B),
                      indicatorColor: Color(0xFF2563EB),
                      tabs: [
                        Tab(text: 'Listings'),
                        Tab(text: 'Verifications'),
                        Tab(text: 'Chats'),
                        Tab(text: 'Admin Ops'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ListingsPane(listings: listings),
                      _VerificationPane(listings: listings),
                      const _ChatsPane(isAdmin: true),
                      const _AdminOpsPane(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AgentDashboard extends ConsumerWidget {
  const _AgentDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _jcPageBg,
        appBar: AppBar(
          backgroundColor: _jcPageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const SizedBox(height: 34, child: _BrandWordmark()),
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
          error: (e, _) => Center(child: Text('Failed to load listings: $e')),
          data: (listings) {
            final stats = _listingStats(listings);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _ConsoleHeader(
                    title: 'Agent Dashboard',
                    subtitle:
                        'Manage listings, convert leads, and track verification progress.',
                    displayName: displayName,
                    role: 'agent',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _KpiCard(
                          title: 'My Listings', value: '${listings.length}'),
                      _KpiCard(
                          title: 'Pending Review', value: '${stats.pending}'),
                      _KpiCard(title: 'Published', value: '${stats.published}'),
                      _KpiCard(title: 'Closed Deals', value: '${stats.closed}'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/listings'),
                          icon: const Icon(Icons.add_business_outlined),
                          label: const Text('Open Listings Console'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _jcPanelBorder),
                    ),
                    child: const TabBar(
                      padding: EdgeInsets.all(4),
                      labelColor: Color(0xFF0F172A),
                      unselectedLabelColor: Color(0xFF64748B),
                      indicatorColor: Color(0xFF2563EB),
                      tabs: [
                        Tab(text: 'Listings'),
                        Tab(text: 'Leads'),
                        Tab(text: 'Verification'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ListingsPane(listings: listings),
                      const _ChatsPane(isAdmin: false),
                      _VerificationPane(listings: listings),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SellerDashboard extends ConsumerWidget {
  const _SellerDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);

    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox(height: 34, child: _BrandWordmark()),
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
        error: (e, _) => Center(child: Text('Failed to load listings: $e')),
        data: (listings) {
          final stats = _listingStats(listings);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _ConsoleHeader(
                title: 'Seller Listings Console',
                subtitle:
                    'Publish inventory, track negotiations, and close buyer requests.',
                displayName: displayName,
                role: 'seller',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _KpiCard(
                          title: 'Inventory', value: '${listings.length}')),
                  Expanded(
                      child: _KpiCard(
                          title: 'Pending Review', value: '${stats.pending}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _KpiCard(
                          title: 'Published', value: '${stats.published}')),
                  Expanded(
                      child:
                          _KpiCard(title: 'Closed', value: '${stats.closed}')),
                ],
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.home_work_outlined,
                title: 'Manage Listings',
                subtitle:
                    'Create, edit, duplicate, archive, and unarchive listings',
                onTap: () => context.go('/listings'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.chat_bubble_outline,
                title: 'Buyer & Support Chats',
                subtitle:
                    'Respond to inquiries and progress transaction actions',
                onTap: () => context.go('/chat'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.shield_outlined,
                title: 'Verification Progress',
                subtitle:
                    'Review pending verification checks for your listings',
                onTap: () => context.go('/listings'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OwnerDashboard extends ConsumerWidget {
  const _OwnerDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _jcPageBg,
        appBar: AppBar(
          backgroundColor: _jcPageBg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const SizedBox(height: 34, child: _BrandWordmark()),
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
          error: (e, _) => Center(child: Text('Failed to load listings: $e')),
          data: (listings) {
            final stats = _listingStats(listings);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _ConsoleHeader(
                    title: 'Owner Console',
                    subtitle:
                        'Track property performance, costs, and tenant/buyer requests.',
                    displayName: displayName,
                    role: 'owner',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _KpiCard(
                          title: 'Properties', value: '${listings.length}'),
                      _KpiCard(title: 'Active', value: '${stats.published}'),
                      _KpiCard(title: 'Pending', value: '${stats.pending}'),
                      _KpiCard(title: 'Closed', value: '${stats.closed}'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _jcPanelBorder),
                    ),
                    child: const TabBar(
                      padding: EdgeInsets.all(4),
                      labelColor: Color(0xFF0F172A),
                      unselectedLabelColor: Color(0xFF64748B),
                      indicatorColor: Color(0xFF2563EB),
                      tabs: [
                        Tab(text: 'Properties'),
                        Tab(text: 'Verification'),
                        Tab(text: 'Conversations'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ListingsPane(listings: listings),
                      _VerificationPane(listings: listings),
                      const _ChatsPane(isAdmin: false),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BuyerDashboard extends StatelessWidget {
  const _BuyerDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox(height: 34, child: _BrandWordmark()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _ConsoleHeader(
            title: 'Buyer Dashboard',
            subtitle:
                'Browse properties, schedule tours, and manage ongoing inquiries.',
            displayName: displayName,
            role: 'buyer',
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.search_outlined,
            title: 'Browse Listings',
            subtitle: 'Open marketplace inventory and property details',
            onTap: () => context.go('/listings'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.calendar_month_outlined,
            title: 'Schedule Tour',
            subtitle: 'Book a property visit with support',
            onTap: () => context.go('/schedule-tour'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.phone_forwarded_outlined,
            title: 'Request Callback',
            subtitle: 'Contact support about a listing',
            onTap: () => context.go('/request-callback'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            title: 'In-App Chats',
            subtitle: 'Continue existing support and transaction conversations',
            onTap: () => context.go('/chat'),
          ),
        ],
      ),
    );
  }
}

class _RenterDashboard extends StatelessWidget {
  const _RenterDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox(height: 34, child: _BrandWordmark()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _ConsoleHeader(
            title: 'Renter Dashboard',
            subtitle:
                'Track rental conversations, utility requests, and support tasks.',
            displayName: displayName,
            role: 'renter',
          ),
          const SizedBox(height: 14),
          _ActionTile(
            icon: Icons.home_work_outlined,
            title: 'Rental Listings',
            subtitle: 'Open available properties and compare rent options',
            onTap: () => context.go('/listings'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.work_outline,
            title: 'Professional Services',
            subtitle: 'Survey, valuation, verification, and snagging support',
            onTap: () => context.go('/services'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            title: 'Support Conversations',
            subtitle: 'Manage current chats with agents and support',
            onTap: () => context.go('/chat'),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.person_outline,
            title: 'Profile & Verification',
            subtitle: 'Update account profile and verification details',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
}

class _AdminOpsPane extends StatelessWidget {
  const _AdminOpsPane();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _ActionTile(
          icon: Icons.gavel_outlined,
          title: 'Open Disputes Queue',
          subtitle: 'Review and resolve disputes from transactions and support',
          onTap: () => context.go('/admin'),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.upload_file_outlined,
          title: 'Service PDF Jobs',
          subtitle: 'Monitor and manually process pending transcript/PDF jobs',
          onTap: () => context.go('/admin'),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.shield_outlined,
          title: 'Moderation Actions',
          subtitle: 'Resolve flagged listings and verification escalations',
          onTap: () => context.go('/admin'),
        ),
      ],
    );
  }
}

_ListingStats _listingStats(List<Listing> listings) {
  final draft =
      listings.where((e) => (e.status ?? '').toLowerCase() == 'draft').length;
  final pending = listings
      .where((e) => (e.status ?? '').toLowerCase().contains('pending'))
      .length;
  final published = listings
      .where((e) => (e.status ?? '').toLowerCase().contains('published'))
      .length;
  final closed = listings.where((e) {
    final s = (e.status ?? '').toLowerCase();
    return s == 'sold' || s == 'rented';
  }).length;
  return _ListingStats(
    draft: draft,
    pending: pending,
    published: published,
    closed: closed,
  );
}

class _ListingStats {
  const _ListingStats({
    required this.draft,
    required this.pending,
    required this.published,
    required this.closed,
  });

  final int draft;
  final int pending;
  final int published;
  final int closed;
}

class _ConsoleHeader extends StatelessWidget {
  const _ConsoleHeader({
    required this.title,
    required this.subtitle,
    required this.displayName,
    required this.role,
  });

  final String title;
  final String subtitle;
  final String displayName;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: _jcMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  displayName.isEmpty ? 'U' : displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$displayName - ${role[0].toUpperCase()}${role.substring(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: _jcMuted),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingsPane extends StatelessWidget {
  const _ListingsPane({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _jcPanelBorder),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Listings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _jcHeading,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/listings'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Open Console'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (listings.isEmpty)
          const _EmptyState(message: 'No listings yet.')
        else
          ...listings
              .take(6)
              .map((listing) => _ListingPreviewTile(listing: listing)),
      ],
    );
  }
}

class _ChatsPane extends StatelessWidget {
  const _ChatsPane({required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _ActionTile(
          icon: Icons.chat_bubble_outline,
          title: isAdmin ? 'Support Inbox' : 'Leads & Conversations',
          subtitle: isAdmin
              ? 'Moderate platform conversations and issue cards'
              : 'Reply to inquiries, track attachments, and manage actions',
          onTap: () => context.go('/chat'),
        ),
        const SizedBox(height: 10),
        if (isAdmin)
          _ActionTile(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admin Console',
            subtitle: 'Open moderation, disputes, and PDF job operations',
            onTap: () => context.go('/admin'),
          ),
      ],
    );
  }
}

class _VerificationPane extends StatelessWidget {
  const _VerificationPane({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    final pending = listings.where((l) {
      final s = (l.status ?? '').toLowerCase();
      return s == 'pending review' || s == 'draft' || s == 'archived';
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Text(
            'Pending Property Verifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          const _EmptyState(message: 'No pending verification records.')
        else
          ...pending.map(
            (listing) => _ActionTile(
              icon: Icons.shield_outlined,
              title: listing.title,
              subtitle: '${listing.location ?? '-'} - ${listing.status ?? '-'}',
              onTap: () =>
                  context.go('/property/${listing.id}', extra: listing),
            ),
          ),
      ],
    );
  }
}

class _ListingPreviewTile extends StatelessWidget {
  const _ListingPreviewTile({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () => context.go('/property/${listing.id}', extra: listing),
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.home_work_outlined),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    listing.location ?? '-',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: listing.status ?? '-'),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFE2E8F0),
              ),
              child: Icon(icon, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final color = s.contains('published')
        ? const Color(0xFF16A34A)
        : s.contains('pending')
            ? const Color(0xFFD97706)
            : s.contains('archived')
                ? const Color(0xFF475569)
                : const Color(0xFF334155);

    final bg = s.contains('published')
        ? const Color(0xFFDCFCE7)
        : s.contains('pending')
            ? const Color(0xFFFEF3C7)
            : s.contains('archived')
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'JUSTICE CITY',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
