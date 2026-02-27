import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/listings_repository.dart';
import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';
import 'listings_screen.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);
const _jcRadius = 12.0;

final listingByIdProvider = Provider.family<Listing?, String>((ref, id) {
  final asyncListings = ref.watch(listingsProvider);
  return asyncListings.maybeWhen(
    data: (items) => items.where((e) => e.id == id).cast<Listing?>().firstOrNull,
    orElse: () => null,
  );
});

final listingDetailRecordProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, listingId) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return null;
  final me = ref.watch(meProvider).valueOrNull;
  final actor = ListingActor(
    actorId: session.userId,
    actorRole: me?.role,
    actorName:
        (me?.fullName ?? '').trim().isNotEmpty ? me!.fullName : session.email,
  );
  return ref
      .read(listingsRepositoryProvider)
      .fetchListingRecord(listingId: listingId, actor: actor);
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class ListingDetailsScreen extends ConsumerStatefulWidget {
  const ListingDetailsScreen({
    super.key,
    required this.listingId,
    this.initial,
    this.showVerificationOnOpen = false,
  });
  final String listingId;
  final Listing? initial;
  final bool showVerificationOnOpen;

  @override
  ConsumerState<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends ConsumerState<ListingDetailsScreen> {
  String? _statusDraft;
  bool _statusBusy = false;
  bool _openedVerification = false;

  bool get _isAdmin => (ref.read(meProvider).valueOrNull?.role ?? '').toLowerCase() == 'admin';

  bool _canManage(Listing listing) {
    if (_isAdmin) return true;
    final role = (ref.read(meProvider).valueOrNull?.role ?? '').toLowerCase();
    if (!(role == 'agent' || role == 'seller' || role == 'owner')) return false;
    final meId = (ref.read(meProvider).valueOrNull?.id ?? '').trim();
    return meId.isNotEmpty && meId == (listing.agentId ?? '').trim();
  }

  ListingActor? _actor() {
    final session = ref.read(sessionProvider);
    if (session == null) return null;
    final me = ref.read(meProvider).valueOrNull;
    return ListingActor(
      actorId: session.userId,
      actorRole: me?.role,
      actorName: (me?.fullName ?? '').trim().isNotEmpty ? me!.fullName : session.email,
    );
  }

  Future<void> _applyStatus(Listing listing) async {
    final status = _statusDraft;
    final actor = _actor();
    if (status == null || actor == null) return;
    setState(() => _statusBusy = true);
    try {
      await ref.read(listingsRepositoryProvider).updateListingStatus(
            listingId: listing.id,
            status: status,
            actor: actor,
          );
      ref.invalidate(listingsProvider);
      ref.invalidate(listingDetailRecordProvider(widget.listingId));
      if (mounted) {
        setState(() => _statusDraft = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _statusBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.initial ?? ref.watch(listingByIdProvider(widget.listingId));
    final record = ref.watch(listingDetailRecordProvider(widget.listingId)).valueOrNull;
    final steps = _parseSteps(record);
    final progress = _progress(steps);

    if (listing != null && widget.showVerificationOnOpen && !_openedVerification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _openedVerification) return;
        _openedVerification = true;
        unawaited(_openVerificationDialog(listing, steps));
      });
    }

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: Text('Listing not found.')),
      );
    }

    final canManage = _canManage(listing);
    final completed = steps.where((s) => s.status == 'completed').length;
    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        title: const Text(
          'Property Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 30,
            color: _jcHeading,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(listingsProvider);
              ref.invalidate(listingDetailRecordProvider(widget.listingId));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                listing.title,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: _jcHeading,
                ),
              ),
              const SizedBox(height: 4),
              Text('${listing.location ?? '-'} - ${listing.listingType ?? '-'}',
                  style: const TextStyle(fontSize: 14, color: _jcMuted)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: Text(
                    'Price: ${[listing.price, listing.priceSuffix].whereType<String>().join(' ')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _jcHeading,
                    ),
                  ),
                ),
                _StatusChip(status: listing.status ?? '-'),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          _Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(
                  child: Text(
                    'Verification Progress',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: _jcHeading,
                    ),
                  ),
                ),
                Text(
                  '$progress%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _jcHeading,
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: steps.isEmpty ? 0 : progress / 100),
              const SizedBox(height: 6),
              Text(
                steps.isEmpty
                    ? 'Verification details are being prepared.'
                    : '$completed/${steps.length} checks completed.',
                style: const TextStyle(fontSize: 14, color: _jcMuted),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () => _openVerificationDialog(listing, steps),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('View Verification Progress'),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          _Card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Listing Status', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (canManage)
                DropdownButtonFormField<String>(
                  initialValue: _statusDraft ?? listing.status,
                  items: const [
                    DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'Pending Review', child: Text('Pending Review')),
                    DropdownMenuItem(value: 'Published', child: Text('Published')),
                    DropdownMenuItem(value: 'Archived', child: Text('Archived')),
                    DropdownMenuItem(value: 'Sold', child: Text('Sold')),
                    DropdownMenuItem(value: 'Rented', child: Text('Rented')),
                  ],
                  onChanged: (value) => setState(() => _statusDraft = value),
                )
              else
                const Text('Read-only for this listing.'),
              const SizedBox(height: 8),
              if (canManage)
                FilledButton.icon(
                  onPressed: _statusBusy || _statusDraft == null ? null : () => _applyStatus(listing),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Status'),
                ),
            ]),
          ),
          const SizedBox(height: 10),
          _Card(
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/request-callback'),
                icon: const Icon(Icons.call_outlined),
                label: const Text('Request Callback'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/schedule-tour'),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Schedule Tour'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/chat'),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Message Support'),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _openVerificationDialog(Listing listing, List<_StepVm> seed) async {
    final actor = _actor();
    final canEdit = _isAdmin;
    var steps = List<_StepVm>.from(seed);
    var busy = false;

    Future<void> refreshSteps() async {
      final latest = await ref.read(listingDetailRecordProvider(widget.listingId).future);
      final fromServer = _parseSteps(latest);
      if (fromServer.isNotEmpty) {
        steps = fromServer;
      }
    }

    Future<void> updateStep(StateSetter setModalState, String stepKey, String status) async {
      if (!canEdit || actor == null) return;
      setModalState(() => busy = true);
      try {
        await ref.read(listingsRepositoryProvider).updateListingVerificationStepStatus(
              listingId: listing.id,
              stepKey: stepKey,
              status: status,
              actor: actor,
            );
        ref.invalidate(listingsProvider);
        ref.invalidate(listingDetailRecordProvider(widget.listingId));
        await refreshSteps();
        setModalState(() {});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update verification step: $e')),
          );
        }
      } finally {
        if (mounted) setModalState(() => busy = false);
      }
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final completed = steps.where((s) => s.status == 'completed').length;
          final progress = _progress(steps);
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920, maxHeight: 760),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pending Property Verification Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _jcHeading,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${listing.title} - $completed/${steps.length} checks completed.',
                                style: const TextStyle(fontSize: 14, color: _jcMuted),
                              ),
                              if (!canEdit)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Read-only for this role. Only admins can complete verification checks or publish listings.',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                      children: [
                        _Card(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Overall Verification Progress',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _jcHeading,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$progress%',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: _jcHeading,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: steps.isEmpty ? 0 : progress / 100,
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (steps.isEmpty)
                          const _Card(
                            child: Text(
                              'Verification details are being prepared.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          )
                        else
                          ...steps.map((step) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            step.label,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _jcHeading,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            step.description,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: _jcMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _stepStatusBg(step.status),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            _stepStatusLabel(step.status),
                                            style: TextStyle(
                                              color: _stepStatusFg(step.status),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (canEdit) ...[
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: 155,
                                            child: DropdownButtonFormField<String>(
                                              initialValue: step.status,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: _jcHeading,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              decoration: const InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                                border: OutlineInputBorder(),
                                              ),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'pending',
                                                  child: Text('Pending'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'in_progress',
                                                  child: Text('In Progress'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'completed',
                                                  child: Text('Completed'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'blocked',
                                                  child: Text('Blocked'),
                                                ),
                                              ],
                                              onChanged: busy
                                                  ? null
                                                  : (value) {
                                                      if (value == null || value == step.status) {
                                                        return;
                                                      }
                                                      unawaited(
                                                        updateStep(
                                                          setModalState,
                                                          step.key,
                                                          value,
                                                        ),
                                                      );
                                                    },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Close'),
                        ),
                        const Spacer(),
                        if (canEdit)
                          OutlinedButton(
                            onPressed: busy || steps.isEmpty
                                ? null
                                : () async {
                                    for (final step in steps) {
                                      if (step.status != 'completed') {
                                        await updateStep(setModalState, step.key, 'completed');
                                      }
                                    }
                                  },
                            child: busy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Complete All Checks'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _jcPanelBorder),
          borderRadius: BorderRadius.circular(_jcRadius),
        ),
        child: child,
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    var bg = const Color(0xFFF1F5F9);
    var fg = const Color(0xFF334155);
    if (normalized.contains('pending')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else if (normalized == 'published' || normalized == 'approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (normalized == 'sold' || normalized == 'rented') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else if (normalized == 'rejected' || normalized == 'blocked') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StepVm {
  const _StepVm({required this.key, required this.label, required this.description, required this.status});
  final String key;
  final String label;
  final String description;
  final String status;
}

List<_StepVm> _parseSteps(Map<String, dynamic>? raw) {
  final source = raw == null ? null : (raw['verificationSteps'] ?? raw['verification_steps']);
  if (source is! List || source.isEmpty) return const [];
  final parsed = <_StepVm>[];
  for (final item in source) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final key = '${map['key'] ?? map['step_key'] ?? ''}'.trim();
    if (key.isEmpty) continue;
    final status = _normalizeStatus('${map['status'] ?? 'pending'}');
    final meta = _stepMeta[key] ??
        const _StepVm(
          key: 'unknown',
          label: 'Verification Check',
          description: 'Verification check',
          status: 'pending',
        );
    parsed.add(
      _StepVm(
        key: key,
        label: '${map['label'] ?? meta.label}',
        description: '${map['description'] ?? meta.description}',
        status: status,
      ),
    );
  }
  parsed.sort((a, b) => (_stepOrder[a.key] ?? 99).compareTo(_stepOrder[b.key] ?? 99));
  return parsed;
}

String _normalizeStatus(String raw) {
  final s = raw.trim().toLowerCase();
  if (s == 'completed') return 'completed';
  if (s == 'in_progress') return 'in_progress';
  if (s == 'blocked') return 'blocked';
  return 'pending';
}

int _progress(List<_StepVm> steps) {
  if (steps.isEmpty) return 0;
  final done = steps.fold<double>(0, (acc, step) {
    if (step.status == 'completed') return acc + 1;
    if (step.status == 'in_progress') return acc + 0.5;
    return acc;
  });
  return ((done / steps.length) * 100).round();
}

String _stepStatusLabel(String status) {
  if (status == 'completed') return 'Completed';
  if (status == 'in_progress') return 'In Progress';
  if (status == 'blocked') return 'Blocked';
  return 'Pending';
}

Color _stepStatusBg(String status) {
  if (status == 'completed') return const Color(0xFFDCFCE7);
  if (status == 'in_progress') return const Color(0xFFDBEAFE);
  if (status == 'blocked') return const Color(0xFFFEE2E2);
  return const Color(0xFFF1F5F9);
}

Color _stepStatusFg(String status) {
  if (status == 'completed') return const Color(0xFF15803D);
  if (status == 'in_progress') return const Color(0xFF1D4ED8);
  if (status == 'blocked') return const Color(0xFFB91C1C);
  return const Color(0xFF334155);
}

const Map<String, int> _stepOrder = {
  'ownership': 0,
  'ownership_authorization': 1,
  'survey': 2,
  'right_of_way': 3,
  'ministerial_charting': 4,
  'legal_verification': 5,
  'property_document_verification': 6,
};

const Map<String, _StepVm> _stepMeta = {
  'ownership': _StepVm(
    key: 'ownership',
    label: 'Ownership Verification',
    description: 'Validate ownership records against title registry entries.',
    status: 'pending',
  ),
  'ownership_authorization': _StepVm(
    key: 'ownership_authorization',
    label: 'Ownership Authorization',
    description: 'Confirm owner-issued authorization to list and market the property.',
    status: 'pending',
  ),
  'survey': _StepVm(
    key: 'survey',
    label: 'Survey Verification',
    description: 'Review survey plan details and boundary coordinates.',
    status: 'pending',
  ),
  'right_of_way': _StepVm(
    key: 'right_of_way',
    label: 'Right of Way Verification',
    description: 'Confirm legal access roads and easement compliance.',
    status: 'pending',
  ),
  'ministerial_charting': _StepVm(
    key: 'ministerial_charting',
    label: 'Ministerial Charting',
    description: 'Check government acquisition status and charting records.',
    status: 'pending',
  ),
  'legal_verification': _StepVm(
    key: 'legal_verification',
    label: 'Legal Verification',
    description: 'Validate legal standing and applicable encumbrances.',
    status: 'pending',
  ),
  'property_document_verification': _StepVm(
    key: 'property_document_verification',
    label: 'Property Document Verification',
    description: 'Audit title documents (C of O, deed, survey, supporting files).',
    status: 'pending',
  ),
};
