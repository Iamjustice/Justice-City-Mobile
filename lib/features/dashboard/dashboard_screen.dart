import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/chat_conversation.dart';
import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../shell/justice_city_shell.dart';

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

final dashboardConversationsProvider =
    FutureProvider<List<ChatConversation>>((ref) async {
  final me = await ref.watch(meProvider.future);
  final viewerId = me?.id.trim();
  if (viewerId == null || viewerId.isEmpty) return const [];

  try {
    return await ref.read(chatRepositoryProvider).listConversations(
          viewerId: viewerId,
          viewerRole: me?.role,
          viewerName: me?.email,
        );
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
      loading: () => const JusticeCityShell(
        currentPath: '/dashboard',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => JusticeCityShell(
        currentPath: '/dashboard',
        child: Center(child: Text('Failed to load profile: $error')),
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
      child: JusticeCityShell(
        currentPath: '/dashboard',
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
        child: listingsAsync.when(
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
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.symmetric(horizontal: 18),
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
      child: JusticeCityShell(
        currentPath: '/dashboard',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardListingsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
        child: listingsAsync.when(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'My Listings',
                          value: '${listings.length}',
                          icon: Icons.apartment_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Pending Review',
                          value: '${stats.pending}',
                          icon: Icons.hourglass_top_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Published',
                          value: '${stats.published}',
                          icon: Icons.verified_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Pending Agent Payouts',
                          value: stats.closed == 0 ? 'NO' : '${stats.closed}',
                          icon: Icons.schedule_rounded,
                          accentColor: const Color(0xFFD97706),
                        ),
                      ),
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
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.symmetric(horizontal: 18),
                      padding: EdgeInsets.all(4),
                      labelColor: Color(0xFF0F172A),
                      unselectedLabelColor: Color(0xFF64748B),
                      indicatorColor: Color(0xFF2563EB),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.apartment_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Listings'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Chats'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Pending Verifications'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      _AgentListingsPane(listings: listings),
                      const _AgentChatsPane(),
                      _AgentVerificationPane(listings: listings),
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

    return DefaultTabController(
      length: 3,
      child: JusticeCityShell(
        currentPath: '/dashboard',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardListingsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
        child: listingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load listings: $e')),
          data: (listings) {
            final stats = _listingStats(listings);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _ConsoleHeader(
                    title: 'Seller Dashboard',
                    subtitle:
                        'Publish inventory, manage buyer conversations, and track verification progress.',
                    displayName: displayName,
                    role: 'seller',
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Inventory',
                          value: '${listings.length}',
                          icon: Icons.home_work_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Pending Review',
                          value: '${stats.pending}',
                          icon: Icons.hourglass_top_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Published',
                          value: '${stats.published}',
                          icon: Icons.verified_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AgentSummaryCard(
                          title: 'Closed Deals',
                          value: '${stats.closed}',
                          icon: Icons.task_alt_outlined,
                          accentColor: const Color(0xFF16A34A),
                        ),
                      ),
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
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.symmetric(horizontal: 18),
                      padding: EdgeInsets.all(4),
                      labelColor: Color(0xFF0F172A),
                      unselectedLabelColor: Color(0xFF64748B),
                      indicatorColor: Color(0xFF2563EB),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.apartment_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Listings'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Chats'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.schedule_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Pending Verifications'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      _SellerListingsPane(listings: listings),
                      const _SellerChatsPane(),
                      _SellerVerificationPane(listings: listings),
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
class _OwnerDashboard extends ConsumerWidget {
  const _OwnerDashboard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(dashboardListingsProvider);

    return DefaultTabController(
      length: 3,
      child: JusticeCityShell(
        currentPath: '/dashboard',
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardListingsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
        child: listingsAsync.when(
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
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: EdgeInsets.symmetric(horizontal: 18),
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
    return JusticeCityShell(
      currentPath: '/dashboard',
      child: ListView(
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
            onTap: () => context.go('/home'),
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
          const SizedBox(height: 12),
          const JusticeCityFooter(),
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
    return JusticeCityShell(
      currentPath: '/dashboard',
      child: ListView(
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
            onTap: () => context.go('/home'),
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
          const SizedBox(height: 12),
          const JusticeCityFooter(),
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
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: _jcMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _jcPanelBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                  ],
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

class _AgentSummaryCard extends StatelessWidget {
  const _AgentSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor = const Color(0xFF2563EB),
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 6),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: _jcMuted),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
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

class _AgentListingsPane extends StatelessWidget {
  const _AgentListingsPane({required this.listings});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Listings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _jcHeading,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Create, edit, and manage listings with verification workflow actions.',
                          style: TextStyle(color: _jcMuted, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: Text(
                      'All payouts calculated at 5% commission rate.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _jcMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: () => context.go('/listings'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Open Console'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (listings.isEmpty)
          const _EmptyState(message: 'No listings yet.')
        else
          ...listings.take(6).map((listing) => _AgentListingCard(listing: listing)),
        const JusticeCityFooter(),
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

class _AgentChatsPane extends ConsumerWidget {
  const _AgentChatsPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(dashboardConversationsProvider);

    return conversationsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: const [
          _AgentConversationHeader(conversationCountLabel: 'Loading'),
          SizedBox(height: 10),
          _EmptyState(message: 'Loading inbox...'),
          JusticeCityFooter(),
        ],
      ),
      error: (error, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          const _AgentConversationHeader(conversationCountLabel: 'Inbox unavailable'),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            title: 'Open Inbox',
            subtitle: 'Continue in the full chat workspace while the dashboard feed reloads.',
            onTap: () => context.go('/chat'),
          ),
          const SizedBox(height: 10),
          _EmptyState(message: 'Could not load recent conversations: $error'),
          const JusticeCityFooter(),
        ],
      ),
      data: (conversations) {
        final recent = conversations.take(5).toList();
        final countLabel = conversations.isEmpty
            ? 'No open threads'
            : '${conversations.length} open';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            _AgentConversationHeader(conversationCountLabel: countLabel),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              const _EmptyState(
                message: 'No buyer or support conversations yet.',
              )
            else
              ...recent.map(
                (conversation) => _AgentConversationCard(
                  conversation: conversation,
                ),
              ),
            const JusticeCityFooter(),
          ],
        );
      },
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

class _AgentVerificationPane extends StatelessWidget {
  const _AgentVerificationPane({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    final pending = listings.where((l) {
      final s = (l.status ?? '').toLowerCase();
      return s.contains('pending') || s == 'draft' || s == 'archived';
    }).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Property Verifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _jcHeading,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Track the status of your listed properties currently being verified by our professionals.',
                          style: TextStyle(color: _jcMuted, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AgentSectionCountBadge(label: '${pending.length} open'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          const _EmptyState(message: 'No pending verification records.')
        else
          ...pending
              .take(6)
              .map((listing) => _AgentVerificationCard(listing: listing)),
        const JusticeCityFooter(),
      ],
    );
  }
}

class _SellerListingsPane extends StatelessWidget {
  const _SellerListingsPane({required this.listings});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Listings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _jcHeading,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Review your latest properties, keep them moving through approval, and jump back into the listings console when you need full controls.',
                          style: TextStyle(color: _jcMuted, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: Text(
                      'All payouts calculated at 5% commission rate.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: _jcMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 220,
                child: FilledButton.icon(
                  onPressed: () => context.go('/listings'),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Open Console'),
                ),
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
              .map((listing) => _AgentListingCard(listing: listing)),
        const JusticeCityFooter(),
      ],
    );
  }
}

class _SellerChatsPane extends ConsumerWidget {
  const _SellerChatsPane();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(dashboardConversationsProvider);

    return conversationsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: const [
          _SellerConversationHeader(conversationCountLabel: 'Loading'),
          SizedBox(height: 10),
          _EmptyState(message: 'Loading inbox...'),
          JusticeCityFooter(),
        ],
      ),
      error: (error, _) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          const _SellerConversationHeader(
            conversationCountLabel: 'Inbox unavailable',
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.chat_bubble_outline,
            title: 'Open Inbox',
            subtitle: 'Continue in the full chat workspace while the dashboard feed reloads.',
            onTap: () => context.go('/chat'),
          ),
          const SizedBox(height: 10),
          _EmptyState(message: 'Could not load recent conversations: $error'),
          const JusticeCityFooter(),
        ],
      ),
      data: (conversations) {
        final recent = conversations.take(5).toList();
        final countLabel = conversations.isEmpty
            ? 'No open threads'
            : '${conversations.length} open';

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            _SellerConversationHeader(conversationCountLabel: countLabel),
            const SizedBox(height: 10),
            if (recent.isEmpty)
              const _EmptyState(
                message: 'No buyer or support conversations yet.',
              )
            else
              ...recent.map(
                (conversation) => _AgentConversationCard(
                  conversation: conversation,
                ),
              ),
            const JusticeCityFooter(),
          ],
        );
      },
    );
  }
}

class _SellerConversationHeader extends StatelessWidget {
  const _SellerConversationHeader({required this.conversationCountLabel});

  final String conversationCountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Conversations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Track live buyer inquiries, support follow-ups, and transaction chats without leaving the dashboard.',
                      style: TextStyle(color: _jcMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AgentSectionCountBadge(label: conversationCountLabel),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 220,
            child: FilledButton.icon(
              onPressed: () => context.go('/chat'),
              icon: const Icon(Icons.forum_outlined),
              label: const Text('Open Inbox'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerVerificationPane extends StatelessWidget {
  const _SellerVerificationPane({required this.listings});

  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    final pending = listings.where((l) {
      final s = (l.status ?? '').toLowerCase();
      return s.contains('pending') || s == 'draft' || s == 'archived';
    }).toList();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Property Verifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _jcHeading,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Review the properties still moving through title, legal, and survey checks before they can go fully live.',
                          style: TextStyle(color: _jcMuted, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _AgentSectionCountBadge(label: '${pending.length} open'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (pending.isEmpty)
          const _EmptyState(message: 'No pending verification records.')
        else
          ...pending
              .take(6)
              .map((listing) => _AgentVerificationCard(listing: listing)),
        const JusticeCityFooter(),
      ],
    );
  }
}
class _AgentConversationHeader extends StatelessWidget {
  const _AgentConversationHeader({required this.conversationCountLabel});

  final String conversationCountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Conversations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chat with potential buyers and keep transaction updates in one place.',
                      style: TextStyle(color: _jcMuted, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _AgentSectionCountBadge(label: conversationCountLabel),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 220,
            child: FilledButton.icon(
              onPressed: () => context.go('/chat'),
              icon: const Icon(Icons.forum_outlined),
              label: const Text('Open Inbox'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentConversationCard extends StatelessWidget {
  const _AgentConversationCard({required this.conversation});

  final ChatConversation conversation;

  @override
  Widget build(BuildContext context) {
    final title = _conversationPreviewTitle(conversation);
    final preview = (conversation.lastMessage ?? '').trim();
    final secondaryLabel = (conversation.listingId?.trim().isNotEmpty ?? false)
        ? 'Listing thread'
        : '${conversation.participants.length} participant${conversation.participants.length == 1 ? '' : 's'}';
    final updatedLabel = _formatConversationUpdatedAt(
      conversation.lastMessageAt ?? conversation.updatedAt,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go('/chat/${conversation.id}', extra: conversation),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: _jcHeading,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _jcHeading,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preview.isEmpty
                            ? 'Open the thread to review the latest inquiry and attachments.'
                            : preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _jcMuted, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _AgentMetaPill(
                    icon: Icons.schedule_outlined,
                    label: updatedLabel,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _AgentMetaPill(
                    icon: (conversation.listingId?.trim().isNotEmpty ?? false)
                        ? Icons.home_work_outlined
                        : Icons.people_outline,
                    label: secondaryLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AgentSectionCountBadge extends StatelessWidget {
  const _AgentSectionCountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _jcHeading,
          fontWeight: FontWeight.w700,
        ),
      ),
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

class _AgentListingCard extends StatelessWidget {
  const _AgentListingCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home_work_outlined, color: _jcHeading),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.location ?? '-',
                      style: const TextStyle(color: _jcMuted),
                    ),
                    const SizedBox(height: 6),
                    _StatusBadge(status: listing.status ?? '-'),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Open listing',
                onPressed: () => context.go('/property/${listing.id}', extra: listing),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AgentMetaPill(
                  icon: Icons.payments_outlined,
                  label: _formatAgentPrice(listing),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AgentMetaPill(
                  icon: Icons.visibility_outlined,
                  label: '${listing.views ?? 0} views',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AgentMetaPill(
                  icon: Icons.mail_outline,
                  label: '${listing.inquiries ?? 0} leads',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AgentMetaPill(
                  icon: Icons.event_outlined,
                  label: _formatListingDate(listing.createdAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentVerificationCard extends StatelessWidget {
  const _AgentVerificationCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final progress = _dashboardVerificationProgress(listing);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.shield_outlined, color: _jcHeading),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusBadge(status: listing.status ?? '-'),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formatSubmittedAgo(listing.createdAt),
                            style: const TextStyle(color: _jcMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go(
                '/property/${listing.id}?view=verification',
                extra: listing,
              ),
              child: const Text('View Progress'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Verification progress',
                  style: TextStyle(color: _jcMuted),
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: _jcMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFD9E7FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentMetaPill extends StatelessWidget {
  const _AgentMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _jcMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _jcHeading,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatAgentPrice(Listing listing) {
  final cleaned = (listing.price ?? '').replaceAll(',', '').trim();
  if (cleaned.isEmpty) return 'Price on request';
  final amount = int.tryParse(cleaned);
  final suffix = (listing.priceSuffix ?? '').trim();
  if (amount == null) {
    return suffix.isEmpty ? cleaned : '$cleaned $suffix';
  }
  final digits = amount.toString();
  final buffer = StringBuffer('\u20A6');
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  return suffix.isEmpty ? buffer.toString() : '${buffer.toString()} $suffix';
}

String _conversationPreviewTitle(ChatConversation conversation) {
  if (conversation.subject?.trim().isNotEmpty ?? false) {
    return conversation.subject!.trim();
  }
  if (conversation.participants.isNotEmpty) {
    return conversation.participants.map((p) => p.name).join(', ');
  }
  return 'Conversation';
}

String _formatConversationUpdatedAt(DateTime? date) {
  if (date == null) return 'Updated recently';
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 1) {
    return 'Updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inHours >= 1) {
    return 'Updated ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  return 'Updated today';
}

String _formatListingDate(DateTime? date) {
  if (date == null) return 'Date pending';
  final local = date.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

String _formatSubmittedAgo(DateTime? date) {
  if (date == null) return 'Submitted recently';
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays >= 1) {
    return 'Submitted ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inHours >= 1) {
    return 'Submitted ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  return 'Submitted today';
}

int _dashboardVerificationProgress(Listing listing) {
  final status = (listing.status ?? '').trim().toLowerCase();
  if (status.contains('published') || status == 'sold' || status == 'rented') {
    return 100;
  }
  if (status.contains('pending')) return 21;
  if (status == 'draft') return 7;
  return 0;
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





