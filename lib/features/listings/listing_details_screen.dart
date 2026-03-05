import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/listings_repository.dart';
import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/saved_properties_provider.dart';
import '../../state/session_provider.dart';
import '../marketplace/marketplace_mock_data.dart';
import '../marketplace/public_agent_profile_screen.dart';
import '../shell/justice_city_shell.dart';
import 'listings_screen.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);
const _jcRadius = 12.0;
const _galleryFallbackUrls = <String>[
  'https://images.unsplash.com/photo-1600585154526-990dcea4db0d?auto=format&fit=crop&q=80&w=1400',
  'https://images.unsplash.com/photo-1600566752355-35792bedcfea?auto=format&fit=crop&q=80&w=1400',
  'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?auto=format&fit=crop&q=80&w=1400',
  'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80&w=1400',
];

final listingByIdProvider = Provider.family<Listing?, String>((ref, id) {
  final asyncListings = ref.watch(listingsProvider);
  return asyncListings.maybeWhen(
    data: (items) =>
        items.where((e) => e.id == id).cast<Listing?>().firstOrNull,
    orElse: () => null,
  );
});

final listingDetailRecordProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
        (ref, listingId) async {
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
  ConsumerState<ListingDetailsScreen> createState() =>
      _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends ConsumerState<ListingDetailsScreen> {
  String? _statusDraft;
  bool _statusBusy = false;
  bool _openedVerification = false;
  late final PageController _heroController;
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    _heroController = PageController();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  bool get _isAdmin =>
      (ref.read(meProvider).valueOrNull?.role ?? '').toLowerCase() == 'admin';

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
      actorName:
          (me?.fullName ?? '').trim().isNotEmpty ? me!.fullName : session.email,
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
    final listing =
        widget.initial ?? ref.watch(listingByIdProvider(widget.listingId));
    final record =
        ref.watch(listingDetailRecordProvider(widget.listingId)).valueOrNull;
    final steps = _parseSteps(record);
    final progress = _progress(steps);
    final listingId = listing?.id ?? '';
    final isSaved = listingId.isNotEmpty
        ? ref.watch(isListingSavedProvider(listingId))
        : false;

    if (listing != null &&
        widget.showVerificationOnOpen &&
        !_openedVerification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _openedVerification) return;
        _openedVerification = true;
        unawaited(_openVerificationDialog(listing, steps));
      });
    }

    if (listing == null) {
      return JusticeCityShell(
        currentPath: '/home',
        backgroundColor: _jcPageBg,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded, color: _jcHeading),
        ),
        leadingWidth: 56,
        child: const Center(
          child: Text(
            'Listing not found.',
            style: TextStyle(
              color: _jcHeading,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final canManage = _canManage(listing);
    final completed = steps.where((s) => s.status == 'completed').length;
    final me = ref.watch(meProvider).valueOrNull;
    final isVerifiedUser = me?.isVerified == true;
    final galleryItems = _buildGalleryItems(listing, record, progress);
    final statCards = _buildStatCards(listing, record);
    final documents = _buildDocumentCards(steps);
    final priceText = _formatListingPrice(listing.price, listing.priceSuffix);
    final recordAgentName = _recordString(record, const ['agentName', 'agent_name']) ?? '';
    final agentName =
        recordAgentName.trim().isEmpty ? 'Justice City Agent' : recordAgentName;
    final agentRoleLabel = isVerifiedUser ? 'Verified Agent' : 'Property Agent';

    return JusticeCityShell(
      currentPath: '/home',
      backgroundColor: _jcPageBg,
      leading: IconButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        icon: const Icon(Icons.arrow_back_rounded, color: _jcHeading),
      ),
      leadingWidth: 56,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: _jcHeading),
          onPressed: () {
            ref.invalidate(listingsProvider);
            ref.invalidate(listingDetailRecordProvider(widget.listingId));
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x220F172A),
                  blurRadius: 28,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _heroController,
                  itemCount: galleryItems.length,
                  onPageChanged: (index) => setState(() => _heroIndex = index),
                  itemBuilder: (context, index) =>
                      _HeroGalleryPanel(item: galleryItems[index]),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  right: 18,
                  child: Row(
                    children: [
                      _HeroBadge(
                        icon: Icons.sell_outlined,
                        label: listing.listingType ?? 'Property',
                        background: const Color(0xFF2563EB),
                        foreground: Colors.white,
                      ),
                      const Spacer(),
                      const _HeroBadge(
                        icon: Icons.verified_user_outlined,
                        label: 'Verified Title',
                        background: Color(0xFF16A34A),
                        foreground: Colors.white,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xCC000000),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0x33FFFFFF)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                priceText,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_heroIndex + 1} / ${galleryItems.length}',
                                style: const TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _jcHeading,
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () => ref
                                .read(savedListingIdsProvider.notifier)
                                .toggle(listing.id),
                            icon: Icon(
                              isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border_outlined,
                              color: isSaved ? Colors.red : _jcHeading,
                            ),
                            label: Text(isSaved ? 'Saved' : 'Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              '${_heroIndex + 1} / ${galleryItems.length}',
              style: const TextStyle(
                color: _jcMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Color(0xFF2563EB), size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  (listing.location ?? '-').trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: _jcMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _jcPanelBorder),
            ),
            child: Row(
              children: [
                Expanded(child: _DetailStatCard(item: statCards[0])),
                _statDivider(),
                Expanded(child: _DetailStatCard(item: statCards[1])),
                _statDivider(),
                Expanded(child: _DetailStatCard(item: statCards[2])),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'About this property',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _jcHeading,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                (listing.description ?? '').trim().isEmpty
                    ? 'No description has been provided for this listing yet.'
                    : listing.description!.trim(),
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.7,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 18),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FeatureChip(label: '24/7 Power'),
                  _FeatureChip(label: 'Gated Security'),
                  _FeatureChip(label: 'Treated Water'),
                  _FeatureChip(label: 'Parking Space'),
                ],
              ),
            ]),
          ),
          const SizedBox(height: 18),
          _DarkSectionCard(
            title: 'Verified Documentation',
            subtitle: isVerifiedUser
                ? 'Document previews follow the verification workflow for this property.'
                : 'Full document access is restricted to verified users only.',
            children: [
              ...documents,
              if (!isVerifiedUser) ...[
                const SizedBox(height: 12),
                const _LockNotice(
                  message:
                      'Full document access is restricted to verified users only.',
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          _Card(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              const SizedBox(height: 8),
              LinearProgressIndicator(value: steps.isEmpty ? 0 : progress / 100),
              const SizedBox(height: 10),
              Text(
                steps.isEmpty
                    ? 'Verification details are being prepared.'
                    : '$completed/${steps.length} checks completed.',
                style: const TextStyle(fontSize: 14, color: _jcMuted),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _openVerificationDialog(listing, steps),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('View Verification Progress'),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go(
                    '/agents/${marketplaceAgentSlug(agentName)}',
                    extra: PublicAgentRouteArgs(
                      name: agentName,
                      imageUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=${Uri.encodeComponent(agentName)}',
                      verified: isVerifiedUser,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _jcPanelBorder),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _leadingInitial(agentName),
                            style: const TextStyle(
                              color: _jcHeading,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                agentName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _jcHeading,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                agentRoleLabel,
                                style: const TextStyle(color: _jcMuted),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tap to view public profile',
                                style: TextStyle(color: Color(0xFF2563EB), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isVerifiedUser)
                          const Icon(Icons.verified_user_outlined,
                              color: Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => context.go('/chat'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Chat with Agent'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.go('/request-callback'),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Request Callback'),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/schedule-tour'),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Schedule Tour'),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your identity is protected. Contact details are only shared once mutual verification is complete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _jcMuted, fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
          if (canManage) ...[
            const SizedBox(height: 18),
            _Card(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Listing Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: _jcHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _statusDraft ?? listing.status,
                      items: const [
                        DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                        DropdownMenuItem(
                            value: 'Pending Review',
                            child: Text('Pending Review')),
                        DropdownMenuItem(
                            value: 'Published', child: Text('Published')),
                        DropdownMenuItem(
                            value: 'Archived', child: Text('Archived')),
                        DropdownMenuItem(value: 'Sold', child: Text('Sold')),
                        DropdownMenuItem(value: 'Rented', child: Text('Rented')),
                      ],
                      onChanged: (value) => setState(() => _statusDraft = value),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _statusBusy || _statusDraft == null
                          ? null
                          : () => _applyStatus(listing),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Status'),
                    ),
                  ]),
            ),
          ],
          const SizedBox(height: 8),
          const JusticeCityFooter(),
        ],
      ),
    );
  }

  Future<void> _openVerificationDialog(
      Listing listing, List<_StepVm> seed) async {
    final canEdit = _isAdmin;
    final steps = List<_StepVm>.from(seed);

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final visibleSteps = steps;
          final completed =
              visibleSteps.where((s) => s.status == 'completed').length;
          final progress = _progress(visibleSteps);
          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                                '${listing.title} - $completed/${visibleSteps.length} checks completed.',
                                style: const TextStyle(
                                    fontSize: 14, color: _jcMuted),
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
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView(
                      shrinkWrap: true,
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
                                value: visibleSteps.isEmpty ? 0 : progress / 100,
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (visibleSteps.isEmpty)
                          const _Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verification checks pending setup',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _jcHeading,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'No verification steps have been published for this listing yet. Progress will appear here once the verification workflow starts.',
                                  style: TextStyle(color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          )
                        else
                          ...visibleSteps.map((step) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _Card(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _stepStatusBg(step.status),
                                            borderRadius:
                                                BorderRadius.circular(999),
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

  List<_HeroPanelItem> _buildGalleryItems(
    Listing listing,
    Map<String, dynamic>? record,
    int progress,
  ) {
    final imageUrls = {
      if ((listing.coverImageUrl ?? '').trim().isNotEmpty)
        listing.coverImageUrl!.trim(),
      ..._recordStringList(record, const ['imageUrls', 'images', 'listingImages']),
    }.toList();

    if (imageUrls.isEmpty) {
      return const [
        _HeroPanelItem.panel(
          title: 'Property Showcase',
          subtitle: 'Official media is being prepared for this listing.',
          icon: Icons.home_work_outlined,
        ),
      ];
    }

    for (final fallback in _galleryFallbackUrls) {
      if (imageUrls.length >= 4) break;
      if (!imageUrls.contains(fallback)) {
        imageUrls.add(fallback);
      }
    }

    return imageUrls.map(_HeroPanelItem.image).toList();
  }


  List<_DetailStatItem> _buildStatCards(
      Listing listing, Map<String, dynamic>? record) {
    final bedrooms = _recordInt(record, const ['bedrooms']);
    final bathrooms = _recordInt(record, const ['bathrooms']);
    final sizeSqm =
        _recordString(record, const ['property_size_sqm', 'propertySizeSqm']);

    return [
      _DetailStatItem(
        label: 'Bedrooms',
        value: bedrooms?.toString() ?? '--',
        icon: Icons.bed_outlined,
      ),
      _DetailStatItem(
        label: 'Bathrooms',
        value: bathrooms?.toString() ?? '--',
        icon: Icons.bathtub_outlined,
      ),
      _DetailStatItem(
        label: 'Square Ft',
        value: (sizeSqm ?? '').trim().isEmpty ? '--' : sizeSqm!,
        icon: Icons.open_in_full_outlined,
      ),
    ];
  }

  List<Widget> _buildDocumentCards(List<_StepVm> steps) {
    final statusByKey = {
      for (final step in steps) step.key: step.status,
    };
    return [
      _DocumentPreviewTile(
        title: 'Title Document',
        status: statusByKey['ownership'] ?? 'pending',
      ),
      const SizedBox(height: 10),
      _DocumentPreviewTile(
        title: 'Ownership Authorization',
        status: statusByKey['ownership_authorization'] ?? 'pending',
      ),
      const SizedBox(height: 10),
      _DocumentPreviewTile(
        title: 'Survey Plan',
        status: statusByKey['survey'] ?? 'pending',
      ),
    ];
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

class _HeroPanelItem {
  const _HeroPanelItem._({
    this.imageUrl,
    this.title,
    this.subtitle,
    this.icon,
  });

  const _HeroPanelItem.image(String imageUrl)
      : this._(
          imageUrl: imageUrl,
        );

  const _HeroPanelItem.panel({
    required String title,
    required String subtitle,
    required IconData icon,
  }) : this._(
          title: title,
          subtitle: subtitle,
          icon: icon,
        );

  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final IconData? icon;
}

class _HeroGalleryPanel extends StatelessWidget {
  const _HeroGalleryPanel({required this.item});

  final _HeroPanelItem item;

  @override
  Widget build(BuildContext context) {
    if ((item.imageUrl ?? '').trim().isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _HeroGradientFallback(item: item),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x22000000),
                  Color(0xAA000000),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return _HeroGradientFallback(item: item);
  }
}

class _HeroGradientFallback extends StatelessWidget {
  const _HeroGradientFallback({required this.item});

  final _HeroPanelItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1D4ED8),
            Color(0xFF0B1120),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 92),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon ?? Icons.home_work_outlined,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            item.title ?? 'Justice City',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle ?? '',
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStatItem {
  const _DetailStatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _DetailStatCard extends StatelessWidget {
  const _DetailStatCard({required this.item});

  final _DetailStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          item.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                item.value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _jcHeading,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 14, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkSectionCard extends StatelessWidget {
  const _DarkSectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_outlined, color: Color(0xFF4ADE80)),
              SizedBox(width: 10),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class _DocumentPreviewTile extends StatelessWidget {
  const _DocumentPreviewTile({
    required this.title,
    required this.status,
  });

  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final fg = _stepStatusFg(status);
    final bg = _stepStatusBg(status).withValues(alpha: 0.18);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x1A60A5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.description_outlined,
                color: Color(0xFF60A5FA)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verified by Justice City workflow',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _stepStatusLabel(status),
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockNotice extends StatelessWidget {
  const _LockNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x1AF59E0B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33F59E0B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFFFCD34D)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFDE68A), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _statDivider() => Container(width: 1, height: 54, color: _jcPanelBorder);

String _leadingInitial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'J';
  return trimmed.substring(0, 1).toUpperCase();
}

String _formatListingPrice(String? rawPrice, String? suffix) {
  final cleaned = (rawPrice ?? '').replaceAll(',', '').trim();
  if (cleaned.isEmpty) return 'Price on request';

  final amount = int.tryParse(cleaned);
  if (amount == null) {
    final label = (rawPrice ?? '').trim();
    final extra = (suffix ?? '').trim();
    return extra.isEmpty ? label : '$label $extra';
  }

  const naira = '\u20A6';
  final digits = amount.toString();
  final buffer = StringBuffer(naira);
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  final extra = (suffix ?? '').trim();
  return extra.isEmpty ? buffer.toString() : '${buffer.toString()} $extra';
}

String? _recordString(Map<String, dynamic>? raw, List<String> keys) {
  if (raw == null) return null;
  for (final key in keys) {
    final value = raw[key];
    if (value == null) continue;
    final text = '$value'.trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

int? _recordInt(Map<String, dynamic>? raw, List<String> keys) {
  if (raw == null) return null;
  for (final key in keys) {
    final value = raw[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse('${value ?? ''}'.trim());
    if (parsed != null) return parsed;
  }
  return null;
}

List<String> _recordStringList(Map<String, dynamic>? raw, List<String> keys) {
  if (raw == null) return const [];
  for (final key in keys) {
    final value = raw[key];
    if (value is List) {
      return value
          .map((item) => '$item'.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
  }
  return const [];
}

class _StepVm {
  const _StepVm(
      {required this.key,
      required this.label,
      required this.description,
      required this.status});
  final String key;
  final String label;
  final String description;
  final String status;
}

List<_StepVm> _parseSteps(Map<String, dynamic>? raw) {
  final source = raw == null
      ? null
      : (raw['verificationSteps'] ?? raw['verification_steps']);
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
  parsed.sort(
      (a, b) => (_stepOrder[a.key] ?? 99).compareTo(_stepOrder[b.key] ?? 99));
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
    description:
        'Confirm owner-issued authorization to list and market the property.',
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
    description:
        'Audit title documents (C of O, deed, survey, supporting files).',
    status: 'pending',
  ),
};
