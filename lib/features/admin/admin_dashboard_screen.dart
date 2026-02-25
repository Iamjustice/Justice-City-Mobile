import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/services_repository.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';
import '../../state/me_provider.dart';

final adminDashboardProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getDashboard();
});

final adminHiringProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.listHiringApplications(actorRole: 'admin');
});

final adminConversationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final session = ref.watch(sessionProvider);
  if (session == null) return <dynamic>[];
  return repo.listAdminConversations(
    viewerId: session.userId,
    viewerRole: 'admin',
    viewerName: session.email ?? 'Admin',
  );
});

final adminOpenDisputesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.listOpenDisputes(actorRole: 'admin', limit: 100);
});

final adminServicePdfJobsProvider =
    FutureProvider<List<ServicePdfJobRecord>>((ref) async {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.listServicePdfJobs(limit: 50);
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(
          child: Text('You do not have admin access.'),
        ),
      );
    }

    final dashboardAsync = ref.watch(adminDashboardProvider);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Verifications'),
              Tab(text: 'Flagged'),
              Tab(text: 'Hiring'),
              Tab(text: 'Ops'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(adminDashboardProvider);
                ref.invalidate(adminHiringProvider);
                ref.invalidate(adminConversationsProvider);
                ref.invalidate(adminOpenDisputesProvider);
                ref.invalidate(adminServicePdfJobsProvider);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _OverviewTab(dashboardAsync: dashboardAsync),
            _VerificationsTab(dashboardAsync: dashboardAsync),
            _FlaggedTab(dashboardAsync: dashboardAsync),
            _HiringTab(),
            const _OpsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAdminConversations(context, ref),
          icon: const Icon(Icons.forum),
          label: const Text('Conversations'),
        ),
      ),
    );
  }

  Future<void> _openAdminConversations(
      BuildContext context, WidgetRef ref) async {
    final convoAsync = ref.read(adminConversationsProvider);
    final data = await convoAsync.when(
      data: (d) async => d,
      loading: () async => <dynamic>[],
      error: (_, __) async => <dynamic>[],
    );

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('All Conversations (Admin)',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.invalidate(adminConversationsProvider);
                      Navigator.of(context).pop();
                      _openAdminConversations(context, ref);
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = data[i];
                    final m = item is Map ? item : <String, dynamic>{};
                    final title = (m['subject'] ?? m['title'] ?? 'Conversation')
                        .toString();
                    final last = (m['lastMessage'] ?? m['last_message'] ?? '')
                        .toString();
                    final id =
                        (m['id'] ?? m['conversationId'] ?? '').toString();
                    return ListTile(
                      title: Text(title),
                      subtitle: last.isEmpty
                          ? null
                          : Text(last,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing:
                          id.isEmpty ? null : const Icon(Icons.chevron_right),
                      onTap: id.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              // Open regular chat thread screen in the app (admin can read it if backend allows).
                              GoRouter.of(context).go('/chat/$id');
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.dashboardAsync});

  final AsyncValue<Map<String, dynamic>> dashboardAsync;

  @override
  Widget build(BuildContext context) {
    return dashboardAsync.when(
      data: (data) {
        final overview =
            (data['overview'] is Map) ? (data['overview'] as Map) : const {};
        final totalUsers =
            overview['totalUsers'] ?? overview['total_users'] ?? '-';
        final pending = overview['pendingVerifications'] ??
            overview['pending_verifications'] ??
            '-';
        final flagged =
            overview['flaggedListings'] ?? overview['flagged_listings'] ?? '-';
        final commissionRate =
            overview['commissionRate'] ?? overview['commission_rate'] ?? '-';
        final revenueLabel =
            overview['revenueJanLabel'] ?? overview['revenue_jan_label'] ?? '';

        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(title: 'Total Users', value: '$totalUsers'),
                _StatCard(title: 'Pending Verifications', value: '$pending'),
                _StatCard(title: 'Flagged Listings', value: '$flagged'),
                _StatCard(title: 'Commission Rate', value: '$commissionRate'),
              ],
            ),
            if (revenueLabel.toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Revenue label: $revenueLabel'),
            ],
            const SizedBox(height: 16),
            Text('Raw (debug)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(const JsonEncoder.withIndent('  ').convert(data)),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Failed to load admin dashboard: $e')),
    );
  }
}

class _VerificationsTab extends ConsumerWidget {
  const _VerificationsTab({required this.dashboardAsync});

  final AsyncValue<Map<String, dynamic>> dashboardAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return dashboardAsync.when(
      data: (data) {
        final list = (data['verifications'] is List)
            ? (data['verifications'] as List)
            : <dynamic>[];
        if (list.isEmpty) {
          return const Center(child: Text('No verification records'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = list[i] is Map ? list[i] as Map : <String, dynamic>{};
            final id = (m['id'] ?? '').toString();
            final user = (m['user'] ?? m['userName'] ?? '').toString();
            final type = (m['type'] ?? '').toString();
            final status = (m['status'] ?? '').toString();
            final createdAt =
                (m['createdAt'] ?? m['created_at'] ?? '').toString();
            final docs = (m['documents'] is List)
                ? (m['documents'] as List)
                : <dynamic>[];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text('$user - $type',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600))),
                        Text(status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (createdAt.isNotEmpty) Text('Created: $createdAt'),
                    const SizedBox(height: 8),
                    if (docs.isNotEmpty) ...[
                      const Text('Documents:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      ...docs.take(4).map((d) {
                        final dm = d is Map
                            ? Map<String, dynamic>.from(d)
                            : <String, dynamic>{};
                        return Text(
                            '- ${(dm['name'] ?? '').toString()}  ${(dm['url'] ?? '').toString()}');
                      }),
                      if (docs.length > 4) const Text('...'),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _normalizeAdminVerificationStatus(
                              status,
                            ),
                            decoration:
                                const InputDecoration(labelText: 'Set status'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Awaiting Review',
                                  child: Text('Awaiting Review')),
                              DropdownMenuItem(
                                  value: 'Approved', child: Text('Approved')),
                              DropdownMenuItem(
                                  value: 'Rejected', child: Text('Rejected')),
                            ],
                            onChanged: (v) async {
                              if (v == null || id.isEmpty) return;
                              try {
                                await ref
                                    .read(adminRepositoryProvider)
                                    .setVerificationStatus(id: id, status: v);
                                ref.invalidate(adminDashboardProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Verification updated')));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed: $e')));
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
    );
  }

  String _normalizeAdminVerificationStatus(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'approved') return 'Approved';
    if (s == 'rejected') return 'Rejected';
    return 'Awaiting Review';
  }
}

class _FlaggedTab extends ConsumerWidget {
  const _FlaggedTab({required this.dashboardAsync});

  final AsyncValue<Map<String, dynamic>> dashboardAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return dashboardAsync.when(
      data: (data) {
        final list = (data['flaggedListings'] is List)
            ? (data['flaggedListings'] as List)
            : <dynamic>[];
        if (list.isEmpty) {
          return const Center(child: Text('No flagged listings'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = list[i] is Map ? list[i] as Map : <String, dynamic>{};
            final id = (m['id'] ?? '').toString();
            final title = (m['title'] ?? '').toString();
            final location = (m['location'] ?? '').toString();
            final reason = (m['reason'] ?? '').toString();
            final status = (m['status'] ?? '').toString();
            final updatedAt =
                (m['updatedAt'] ?? m['updated_at'] ?? '').toString();
            final comments =
                (m['comments'] is List) ? (m['comments'] as List) : <dynamic>[];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (location.isNotEmpty) Text(location),
                    const SizedBox(height: 6),
                    if (reason.isNotEmpty) Text('Reason: $reason'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: Text('Status: $status')),
                        if (updatedAt.isNotEmpty)
                          Text(updatedAt,
                              style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: _normalizeFlaggedStatus(status),
                      decoration:
                          const InputDecoration(labelText: 'Set status'),
                      items: const [
                        DropdownMenuItem(value: 'Open', child: Text('Open')),
                        DropdownMenuItem(
                            value: 'Under Review', child: Text('Under Review')),
                        DropdownMenuItem(
                            value: 'Cleared', child: Text('Cleared')),
                      ],
                      onChanged: (v) async {
                        if (v == null || id.isEmpty) return;
                        try {
                          await ref
                              .read(adminRepositoryProvider)
                              .setFlaggedListingStatus(id: id, status: v);
                          ref.invalidate(adminDashboardProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Flag status updated')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _AddCommentBox(listingId: id),
                    if (comments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text('Comments',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      ...comments.take(3).map((c) {
                        final cm = c is Map
                            ? Map<String, dynamic>.from(c)
                            : <String, dynamic>{};
                        return Text(
                            '- ${(cm['problemTag'] ?? '').toString()}: ${(cm['comment'] ?? '').toString()}');
                      }),
                      if (comments.length > 3) const Text('...'),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
    );
  }

  String _normalizeFlaggedStatus(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'under review' || s == 'under_review') return 'Under Review';
    if (s == 'cleared') return 'Cleared';
    return 'Open';
  }
}

class _AddCommentBox extends ConsumerStatefulWidget {
  const _AddCommentBox({required this.listingId});

  final String listingId;

  @override
  ConsumerState<_AddCommentBox> createState() => _AddCommentBoxState();
}

class _AddCommentBoxState extends ConsumerState<_AddCommentBox> {
  final _comment = TextEditingController();
  final _tag = TextEditingController(text: 'policy');

  bool _saving = false;

  @override
  void dispose() {
    _comment.dispose();
    _tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider).valueOrNull;
    final createdBy = (me?.fullName?.isNotEmpty == true
        ? me!.fullName!
        : (me?.email ?? 'Admin'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _comment,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Add moderator comment (sent to user chat)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tag,
                decoration: const InputDecoration(
                  labelText: 'Problem tag',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _saving
                  ? null
                  : () async {
                      final comment = _comment.text.trim();
                      final tag = _tag.text.trim();
                      if (comment.isEmpty || tag.isEmpty) return;
                      setState(() => _saving = true);
                      try {
                        await ref
                            .read(adminRepositoryProvider)
                            .addFlaggedListingComment(
                              id: widget.listingId,
                              comment: comment,
                              problemTag: tag,
                              createdBy: createdBy,
                              createdById: me?.id,
                            );
                        _comment.clear();
                        ref.invalidate(adminDashboardProvider);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Comment sent')));
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HiringTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminHiringProvider);
    return async.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text('No hiring applications'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final m = list[i] is Map ? list[i] as Map : <String, dynamic>{};
            final id = (m['id'] ?? '').toString();
            final name =
                (m['fullName'] ?? m['full_name'] ?? 'Applicant').toString();
            final track =
                (m['serviceTrack'] ?? m['service_track'] ?? '').toString();
            final status = (m['status'] ?? '').toString();
            final email = (m['email'] ?? '').toString();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (email.isNotEmpty) Text(email),
                    if (track.isNotEmpty) Text('Track: $track'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: status.isEmpty ? 'submitted' : status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(
                            value: 'submitted', child: Text('submitted')),
                        DropdownMenuItem(
                            value: 'under_review', child: Text('under_review')),
                        DropdownMenuItem(
                            value: 'approved', child: Text('approved')),
                        DropdownMenuItem(
                            value: 'rejected', child: Text('rejected')),
                      ],
                      onChanged: (v) async {
                        if (v == null || id.isEmpty) return;
                        try {
                          await ref
                              .read(adminRepositoryProvider)
                              .updateHiringStatus(
                                id: id,
                                status: v,
                                actorRole: 'admin',
                              );
                          ref.invalidate(adminHiringProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Hiring status updated')));
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed: $e')),
    );
  }
}

class _OpsTab extends ConsumerStatefulWidget {
  const _OpsTab();

  @override
  ConsumerState<_OpsTab> createState() => _OpsTabState();
}

class _OpsTabState extends ConsumerState<_OpsTab> {
  bool _processingNextJob = false;

  Future<void> _processNextJob(BuildContext context) async {
    if (_processingNextJob) return;
    setState(() => _processingNextJob = true);
    try {
      final result = await ref
          .read(adminRepositoryProvider)
          .processNextServicePdfJob(actorRole: 'admin');
      ref.invalidate(adminServicePdfJobsProvider);
      if (!context.mounted) return;
      final jobRaw = result['job'];
      final jobMap = jobRaw is Map ? Map<String, dynamic>.from(jobRaw) : null;
      final jobId = (jobMap?['id'] ?? '').toString();
      final jobStatus = (jobMap?['status'] ?? '').toString();
      final message = jobId.isEmpty
          ? 'Process-next completed.'
          : 'Processed job $jobId ($jobStatus).';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Process-next failed: ${_adminReadableError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _processingNextJob = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disputesAsync = ref.watch(adminOpenDisputesProvider);
    final jobsAsync = ref.watch(adminServicePdfJobsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminOpenDisputesProvider);
        ref.invalidate(adminServicePdfJobsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service PDF Job Runner',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manual trigger for /api/service-pdf-jobs/process-next',
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _processingNextJob
                        ? null
                        : () => _processNextJob(context),
                    icon: _processingNextJob
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: const Text('Process Next'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Open Disputes Queue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          disputesAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Card(
                  child: ListTile(
                    title: Text('No open disputes.'),
                  ),
                );
              }
              return Column(
                children: items
                    .map(
                      (item) => _DisputeResolveCard(
                        dispute: item,
                        onResolved: () {
                          ref.invalidate(adminOpenDisputesProvider);
                        },
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Card(
              child: ListTile(
                title: const Text('Failed to load open disputes'),
                subtitle: Text(_adminReadableError(e)),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(adminOpenDisputesProvider),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Recent Service PDF Jobs',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          jobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return const Card(
                  child: ListTile(title: Text('No service PDF jobs yet.')),
                );
              }
              return Card(
                child: Column(
                  children: jobs
                      .take(10)
                      .map(
                        (job) => ListTile(
                          title:
                              Text('${job.status.toUpperCase()} - ${job.id}'),
                          subtitle: Text(
                            'Conv: ${job.conversationId}\nAttempts: ${job.attemptCount}/${job.maxAttempts}',
                          ),
                          isThreeLine: true,
                        ),
                      )
                      .toList(),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Card(
              child: ListTile(
                title: const Text('Failed to load service PDF jobs'),
                subtitle: Text(_adminReadableError(e)),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(adminServicePdfJobsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisputeResolveCard extends ConsumerStatefulWidget {
  const _DisputeResolveCard({
    required this.dispute,
    required this.onResolved,
  });

  final Map<String, dynamic> dispute;
  final VoidCallback onResolved;

  @override
  ConsumerState<_DisputeResolveCard> createState() =>
      _DisputeResolveCardState();
}

class _DisputeResolveCardState extends ConsumerState<_DisputeResolveCard> {
  static const _resolutionStatuses = <String>[
    'resolved',
    'rejected',
    'cancelled',
  ];

  static const _targetStatuses = <String>[
    '',
    'initiated',
    'inspection_pending',
    'inspection_passed',
    'inspection_failed',
    'escrow_funded',
    'escrow_released',
    'completed',
    'cancelled',
    'disputed',
  ];

  final _resolutionCtrl = TextEditingController();
  String _nextStatus = 'resolved';
  String _targetStatus = '';
  bool _unfreezeEscrow = true;
  bool _saving = false;

  @override
  void dispose() {
    _resolutionCtrl.dispose();
    super.dispose();
  }

  String _readField(String key, [String fallbackKey = '']) {
    final value = widget.dispute[key] ??
        (fallbackKey.isEmpty ? null : widget.dispute[fallbackKey]);
    return (value ?? '').toString();
  }

  Future<void> _submit(BuildContext context) async {
    if (_saving) return;
    final disputeId = _readField('id').trim();
    if (disputeId.isEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      final me = ref.read(meProvider).valueOrNull;
      final result = await ref.read(adminRepositoryProvider).resolveDispute(
            disputeId: disputeId,
            resolvedByRole: 'admin',
            status: _nextStatus,
            resolution: _resolutionCtrl.text.trim().isEmpty
                ? null
                : _resolutionCtrl.text.trim(),
            resolutionTargetStatus:
                _targetStatus.isEmpty ? null : _targetStatus,
            resolvedByUserId: me?.id,
            resolvedByName: (me?.fullName?.isNotEmpty == true)
                ? me!.fullName
                : (me?.email ?? 'Admin'),
            unfreezeEscrow: _unfreezeEscrow,
          );
      widget.onResolved();
      if (!context.mounted) return;
      final warnings = (result['warnings'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const <String>[];
      final warningText =
          warnings.isNotEmpty ? ' Warning: ${warnings.first}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dispute resolved.$warningText')),
      );
      _resolutionCtrl.clear();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resolve failed: ${_adminReadableError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = _readField('reason');
    final details = _readField('details');
    final status = _readField('status');
    final transactionId = _readField('transactionId', 'transaction_id');
    final conversationId = _readField('conversationId', 'conversation_id');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispute ${_readField('id')}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text('Status: $status'),
            if (transactionId.isNotEmpty) Text('Transaction: $transactionId'),
            if (conversationId.isNotEmpty)
              Text('Conversation: $conversationId'),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Reason: $reason'),
            ],
            if (details.isNotEmpty) Text('Details: $details'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _nextStatus,
              items: _resolutionStatuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _nextStatus = v ?? 'resolved'),
              decoration: const InputDecoration(labelText: 'Dispute status'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _targetStatus,
              items: _targetStatuses
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.isEmpty ? '(no target status)' : s),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _targetStatus = v ?? ''),
              decoration:
                  const InputDecoration(labelText: 'Transaction target status'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _resolutionCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Resolution note (optional)',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _unfreezeEscrow,
              onChanged: (v) => setState(() => _unfreezeEscrow = v),
              title: const Text('Unfreeze escrow'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _saving ? null : () => _submit(context),
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.gavel),
              label: const Text('Resolve Dispute'),
            ),
          ],
        ),
      ),
    );
  }
}

String _adminReadableError(Object error) {
  var message = error.toString().trim();
  if (message.startsWith('Exception:')) {
    message = message.substring('Exception:'.length).trim();
  }
  final statusMatch = RegExp(r'^(\d{3})\s*:\s*(.+)$').firstMatch(message);
  if (statusMatch == null) return message;

  final status = statusMatch.group(1) ?? '';
  final detail = statusMatch.group(2) ?? message;
  if (status == '403') return '403 Forbidden: $detail';
  if (status == '422') return '422 Validation failed: $detail';
  if (status == '502') return '502 Service error: $detail';
  return '$status: $detail';
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
