import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import '../../domain/models/app_user.dart';
import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';
import '../../data/repositories/listings_repository.dart';

final listingsProvider = FutureProvider<List<Listing>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return const [];

  final me = ref.watch(meProvider).valueOrNull;
  final actor = ListingActor(
    actorId: session.userId,
    actorRole: me?.role,
    actorName:
        (me?.fullName ?? '').trim().isNotEmpty ? me!.fullName : session.email,
  );

  return ref.read(listingsRepositoryProvider).fetchAgentListings(actor: actor);
});

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);
const _jcRadius = 12.0;

class ListingsScreen extends ConsumerStatefulWidget {
  const ListingsScreen({super.key});

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  String? _actionListingId;

  bool _isAdmin(AppUser? me) =>
      (me?.role ?? '').trim().toLowerCase() == 'admin';

  bool _isOperatorRole(AppUser? me) {
    final role = (me?.role ?? '').trim().toLowerCase();
    return role == 'admin' ||
        role == 'agent' ||
        role == 'seller' ||
        role == 'owner';
  }

  bool _canManageListing(Listing listing, AppUser? me) {
    if (_isAdmin(me)) return true;
    final meId = (me?.id ?? '').trim();
    if (meId.isEmpty) return false;
    final ownerId = (listing.agentId ?? '').trim();
    if (ownerId.isEmpty) return true;
    return ownerId == meId;
  }

  ListingActor? _actorFromState() {
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

  bool _isBusy(String listingId) => _actionListingId == listingId;

  void _setBusy(String? listingId) {
    if (!mounted) return;
    setState(() => _actionListingId = listingId);
  }

  Future<void> _refreshListings() async {
    ref.invalidate(listingsProvider);
    await ref.read(listingsProvider.future);
  }

  void _showMessage(String message, {bool destructive = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: destructive ? Colors.red : null,
      ),
    );
  }

  bool _isClosedStatus(String status) => status == 'Sold' || status == 'Rented';

  Future<void> _openCreateDialog() async {
    final me = ref.read(meProvider).valueOrNull;
    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    final form = await showDialog<_ListingFormValue>(
      context: context,
      builder: (ctx) => _ListingFormDialog(
        title: 'Create Listing',
        submitLabel: 'Create',
        initial: null,
        isAdmin: _isAdmin(me),
      ),
    );
    if (form == null) return;

    _setBusy('create');
    try {
      await ref.read(listingsRepositoryProvider).createListing(
            actor: actor,
            input: ListingUpsertInput(
              title: form.title,
              listingType: form.listingType,
              location: form.location,
              description: form.description,
              price: form.price,
              status: form.status,
            ),
          );
      await _refreshListings();
      _showMessage('Listing created.');
    } catch (e) {
      _showMessage('Failed to create listing: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  Future<void> _openEditDialog(Listing listing) async {
    final me = ref.read(meProvider).valueOrNull;
    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    if (!_canManageListing(listing, me)) {
      _showMessage('You can only edit listings you own.', destructive: true);
      return;
    }

    final form = await showDialog<_ListingFormValue>(
      context: context,
      builder: (ctx) => _ListingFormDialog(
        title: 'Edit Listing',
        submitLabel: 'Save',
        initial: listing,
        isAdmin: _isAdmin(me),
      ),
    );
    if (form == null) return;

    _setBusy(listing.id);
    try {
      await ref.read(listingsRepositoryProvider).updateListing(
            listingId: listing.id,
            actor: actor,
            input: ListingUpsertInput(
              title: form.title,
              listingType: form.listingType,
              location: form.location,
              description: form.description,
              price: form.price,
              status: form.status,
            ),
          );
      await _refreshListings();
      _showMessage('Listing updated.');
    } catch (e) {
      _showMessage('Failed to update listing: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  Future<void> _duplicateListing(Listing listing) async {
    final me = ref.read(meProvider).valueOrNull;
    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    if (!_canManageListing(listing, me)) {
      _showMessage('You can only duplicate listings you own.',
          destructive: true);
      return;
    }

    final listingType = (listing.listingType ?? 'Sale').trim();
    final location = (listing.location ?? '').trim();
    final price = (listing.price ?? '').trim();
    if (location.isEmpty || price.isEmpty) {
      _showMessage(
          'Listing is missing location or price and cannot be duplicated.',
          destructive: true);
      return;
    }

    _setBusy(listing.id);
    try {
      await ref.read(listingsRepositoryProvider).createListing(
            actor: actor,
            input: ListingUpsertInput(
              title: '${listing.title} (Copy)',
              listingType: listingType == 'Rent' ? 'Rent' : 'Sale',
              location: location,
              description: listing.description ?? '',
              price: price,
              status: 'Draft',
            ),
          );
      await _refreshListings();
      _showMessage('Listing duplicated as draft.');
    } catch (e) {
      _showMessage('Failed to duplicate listing: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    final me = ref.read(meProvider).valueOrNull;
    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    if (!_canManageListing(listing, me)) {
      _showMessage('You can only delete listings you own.', destructive: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing'),
        content: Text('Delete "${listing.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _setBusy(listing.id);
    try {
      await ref.read(listingsRepositoryProvider).deleteListing(
            listingId: listing.id,
            actor: actor,
          );
      await _refreshListings();
      _showMessage('Listing deleted.');
    } catch (e) {
      _showMessage('Failed to delete listing: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  Future<void> _updateStatus(Listing listing, String status) async {
    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    _setBusy(listing.id);
    try {
      await ref.read(listingsRepositoryProvider).updateListingStatus(
            listingId: listing.id,
            status: status,
            actor: actor,
          );
      await _refreshListings();
      _showMessage('${listing.title} is now $status.');
    } catch (e) {
      _showMessage('Failed to update status: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  Future<void> _updatePayoutToPaid(Listing listing) async {
    final me = ref.read(meProvider).valueOrNull;
    if (!_isAdmin(me)) {
      _showMessage('Only admins can mark payouts as paid.', destructive: true);
      return;
    }

    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    _setBusy(listing.id);
    try {
      await ref.read(listingsRepositoryProvider).updateListingPayoutStatus(
            listingId: listing.id,
            payoutStatus: 'Paid',
            actor: actor,
          );
      await _refreshListings();
      _showMessage('${listing.title}: payout marked Paid.');
    } catch (e) {
      _showMessage('Failed to update payout: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  Future<void> _uploadAssets(Listing listing) async {
    final me = ref.read(meProvider).valueOrNull;
    final actor = _actorFromState();
    if (actor == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    if (!_canManageListing(listing, me)) {
      _showMessage('You can only upload assets for listings you own.',
          destructive: true);
      return;
    }

    final picked = await showDialog<_UploadAssetsSelection>(
      context: context,
      builder: (ctx) => const _UploadAssetsDialog(),
    );
    if (picked == null || picked.totalFiles == 0) return;

    _setBusy(listing.id);
    try {
      List<ListingUploadFilePayload> toPayload(List<PlatformFile> files) {
        return files
            .where((f) => f.bytes != null && f.bytes!.isNotEmpty)
            .map(
              (f) => ListingUploadFilePayload.fromBytes(
                fileName: f.name,
                bytes: f.bytes!,
                mimeType: lookupMimeType(f.name, headerBytes: f.bytes!),
              ),
            )
            .toList();
      }

      final result =
          await ref.read(listingsRepositoryProvider).uploadListingAssets(
                listingId: listing.id,
                actor: actor,
                input: ListingAssetsUploadInput(
                  propertyDocuments: toPayload(picked.propertyDocuments),
                  ownershipAuthorizationDocuments:
                      toPayload(picked.ownershipAuthorizationDocuments),
                  images: toPayload(picked.images),
                ),
              );

      await _refreshListings();
      _showMessage(
        'Assets uploaded: ${result.propertyDocumentsUploaded} property docs, '
        '${result.ownershipAuthorizationUploaded} authorization docs, '
        '${result.imagesUploaded} images.',
      );
    } catch (e) {
      _showMessage('Failed to upload assets: $e', destructive: true);
    } finally {
      _setBusy(null);
    }
  }

  List<PopupMenuEntry<_ListingRowAction>> _buildActionMenuItems({
    required Listing listing,
    required AppUser? me,
  }) {
    final status = (listing.status ?? '').trim();
    final isAdmin = _isAdmin(me);
    final canManage = _canManageListing(listing, me);
    final isClosed = _isClosedStatus(status);
    final canSubmitForReview =
        !isAdmin && (status == 'Draft' || status == 'Archived');
    final canArchive = status != 'Archived';
    final canUnarchive = status == 'Archived';
    final payoutPaid =
        (listing.agentPayoutStatus ?? '').trim().toLowerCase() == 'paid';

    final items = <PopupMenuEntry<_ListingRowAction>>[
      const PopupMenuItem<_ListingRowAction>(
        value: _ListingRowAction.view,
        child: Text('View Listing'),
      ),
      const PopupMenuItem<_ListingRowAction>(
        value: _ListingRowAction.verification,
        child: Text('View Verification Progress'),
      ),
    ];

    if (!canManage) {
      items.add(
        const PopupMenuItem<_ListingRowAction>(
          enabled: false,
          child: Text('Read-only listing'),
        ),
      );
      return items;
    }

    items.add(const PopupMenuDivider());
    items.addAll(const [
      PopupMenuItem<_ListingRowAction>(
        value: _ListingRowAction.edit,
        child: Text('Edit Listing'),
      ),
      PopupMenuItem<_ListingRowAction>(
        value: _ListingRowAction.uploadAssets,
        child: Text('Upload Assets'),
      ),
      PopupMenuItem<_ListingRowAction>(
        value: _ListingRowAction.duplicate,
        child: Text('Duplicate Listing'),
      ),
    ]);

    if (canSubmitForReview) {
      items.add(
        const PopupMenuItem<_ListingRowAction>(
          value: _ListingRowAction.submitForReview,
          child: Text('Submit for Review'),
        ),
      );
    }

    if (canUnarchive) {
      items.add(
        const PopupMenuItem<_ListingRowAction>(
          value: _ListingRowAction.unarchive,
          child: Text('Unarchive Listing'),
        ),
      );
    } else if (canArchive) {
      items.add(
        const PopupMenuItem<_ListingRowAction>(
          value: _ListingRowAction.archive,
          child: Text('Archive Listing'),
        ),
      );
    }

    if (status == 'Published') {
      items.add(
        PopupMenuItem<_ListingRowAction>(
          value: _ListingRowAction.markClosed,
          child: Text(
            (listing.listingType ?? '').toLowerCase() == 'rent'
                ? 'Mark Closed Deal (Rented)'
                : 'Mark Closed Deal (Sold)',
          ),
        ),
      );
    }

    if (isAdmin && isClosed) {
      items.add(
        const PopupMenuItem<_ListingRowAction>(
          value: _ListingRowAction.reopen,
          child: Text('Reopen Listing'),
        ),
      );
      if (!payoutPaid) {
        items.add(
          const PopupMenuItem<_ListingRowAction>(
            value: _ListingRowAction.markPayoutPaid,
            child: Text('Mark Agent Payout Paid'),
          ),
        );
      }
    }

    items.add(const PopupMenuDivider());
    items.add(
      const PopupMenuItem<_ListingRowAction>(
        value: _ListingRowAction.delete,
        child: Text('Delete Listing'),
      ),
    );

    return items;
  }

  Future<void> _onActionSelected(
      _ListingRowAction action, Listing listing) async {
    switch (action) {
      case _ListingRowAction.view:
        if (!mounted) return;
        context.go('/property/${listing.id}', extra: listing);
        return;
      case _ListingRowAction.verification:
        if (!mounted) return;
        context.go(
          '/property/${listing.id}?view=verification',
          extra: listing,
        );
        return;
      case _ListingRowAction.edit:
        await _openEditDialog(listing);
        return;
      case _ListingRowAction.uploadAssets:
        await _uploadAssets(listing);
        return;
      case _ListingRowAction.duplicate:
        await _duplicateListing(listing);
        return;
      case _ListingRowAction.submitForReview:
        await _updateStatus(listing, 'Pending Review');
        return;
      case _ListingRowAction.archive:
        await _updateStatus(listing, 'Archived');
        return;
      case _ListingRowAction.unarchive:
        await _updateStatus(listing, 'Draft');
        return;
      case _ListingRowAction.markClosed:
        final target = (listing.listingType ?? '').toLowerCase() == 'rent'
            ? 'Rented'
            : 'Sold';
        await _updateStatus(listing, target);
        return;
      case _ListingRowAction.reopen:
        await _updateStatus(listing, 'Published');
        return;
      case _ListingRowAction.markPayoutPaid:
        await _updatePayoutToPaid(listing);
        return;
      case _ListingRowAction.delete:
        await _deleteListing(listing);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(listingsProvider);
    final me = ref.watch(meProvider).valueOrNull;
    final canCreate = _isOperatorRole(me);

    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Listings Console',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 30,
            color: _jcHeading,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(listingsProvider),
          ),
          IconButton(
            tooltip: 'Create listing',
            icon: const Icon(Icons.add),
            onPressed: canCreate ? _openCreateDialog : null,
          ),
        ],
      ),
      body: listings.when(
        data: (items) {
          final pending = items
              .where((e) => (e.status ?? '').toLowerCase().contains('pending'))
              .length;
          final draft =
              items.where((e) => (e.status ?? '').toLowerCase() == 'draft').length;
          final published = items
              .where((e) => (e.status ?? '').toLowerCase() == 'published')
              .length;

          if (items.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _ListingsHeaderCard(
                  canCreate: canCreate,
                  onCreate: _openCreateDialog,
                ),
                const SizedBox(height: 14),
                const _EmptyStateCard(
                  message:
                      'No listings yet. Create your first listing to start verification and publication workflow.',
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _ListingsHeaderCard(
                canCreate: canCreate,
                onCreate: _openCreateDialog,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _MiniKpiCard(title: 'Total', value: '${items.length}'),
                    _MiniKpiCard(title: 'Pending', value: '$pending'),
                    _MiniKpiCard(title: 'Draft', value: '$draft'),
                    _MiniKpiCard(title: 'Published', value: '$published'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_jcRadius),
                  border: Border.all(color: _jcPanelBorder),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              'Property',
                              style: TextStyle(
                                color: _jcMuted,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Status',
                              style: TextStyle(
                                color: _jcMuted,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Price',
                              style: TextStyle(
                                color: _jcMuted,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Date',
                              style: TextStyle(
                                color: _jcMuted,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(width: 38),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ...items.map((l) {
                      return InkWell(
                        onTap: () => context.go('/property/${l.id}', extra: l),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                      child: const Icon(Icons.home_work_outlined),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: _jcHeading,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'ID: ${l.id}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: _jcMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: _ListingStatusChip(status: l.status ?? '-'),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  l.price ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _jcHeading,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  _formatRowDate(l),
                                  style: const TextStyle(
                                    color: _jcMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (_isBusy(l.id))
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                PopupMenuButton<_ListingRowAction>(
                                  onSelected: (value) => _onActionSelected(value, l),
                                  itemBuilder: (_) =>
                                      _buildActionMenuItems(listing: l, me: me),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load listings: $e'),
          ),
        ),
      ),
    );
  }

  String _formatRowDate(Listing listing) {
    if (listing.createdAt != null) {
      final d = listing.createdAt!.toLocal();
      return '${_monthShort(d.month)} ${d.day}, ${d.year}';
    }
    final raw = (listing.date ?? '').trim();
    if (raw.isNotEmpty) return raw;
    return '-';
  }

  String _monthShort(int month) {
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
      'Dec'
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}

class _ListingsHeaderCard extends StatelessWidget {
  const _ListingsHeaderCard({
    required this.canCreate,
    required this.onCreate,
  });

  final bool canCreate;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_jcRadius),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Listings',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: _jcHeading,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Create, edit, and manage listings with verification workflow actions.',
                  style: TextStyle(fontSize: 16, color: _jcMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: canCreate ? onCreate : null,
            icon: const Icon(Icons.add),
            label: const Text('Create New Listing'),
          ),
        ],
      ),
    );
  }
}

class _MiniKpiCard extends StatelessWidget {
  const _MiniKpiCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 182,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_jcRadius),
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

class _ListingStatusChip extends StatelessWidget {
  const _ListingStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg = const Color(0xFFE2E8F0);
    Color fg = const Color(0xFF475569);

    if (s.contains('pending')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
    } else if (s.contains('published')) {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (s == 'draft') {
      bg = const Color(0xFFE2E8F0);
      fg = const Color(0xFF475569);
    } else if (s == 'archived') {
      bg = const Color(0xFFE2E8F0);
      fg = const Color(0xFF334155);
    } else if (s == 'sold' || s == 'rented') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bg.withValues(alpha: 0.9)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }
}

enum _ListingRowAction {
  view,
  verification,
  edit,
  uploadAssets,
  duplicate,
  submitForReview,
  archive,
  unarchive,
  markClosed,
  reopen,
  markPayoutPaid,
  delete,
}

class _ListingFormValue {
  _ListingFormValue({
    required this.title,
    required this.listingType,
    required this.location,
    required this.price,
    required this.description,
    required this.status,
  });

  final String title;
  final String listingType;
  final String location;
  final String price;
  final String description;
  final String status;
}

class _ListingFormDialog extends StatefulWidget {
  const _ListingFormDialog({
    required this.title,
    required this.submitLabel,
    required this.initial,
    required this.isAdmin,
  });

  final String title;
  final String submitLabel;
  final Listing? initial;
  final bool isAdmin;

  @override
  State<_ListingFormDialog> createState() => _ListingFormDialogState();
}

class _ListingFormDialogState extends State<_ListingFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _price;
  late final TextEditingController _description;
  late String _listingType;
  late String _status;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _title = TextEditingController(text: initial?.title ?? '');
    _location = TextEditingController(text: initial?.location ?? '');
    _price = TextEditingController(text: initial?.price ?? '');
    _description = TextEditingController(text: initial?.description ?? '');
    _listingType =
        (initial?.listingType ?? 'Sale').trim() == 'Rent' ? 'Rent' : 'Sale';
    _status = _initialStatus(initial, widget.isAdmin);
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  String _initialStatus(Listing? listing, bool isAdmin) {
    final current = (listing?.status ?? '').trim();
    if (current.isNotEmpty) return current;
    return isAdmin ? 'Pending Review' : 'Draft';
  }

  List<String> _statusOptions() {
    if (widget.isAdmin) {
      return const [
        'Draft',
        'Pending Review',
        'Published',
        'Archived',
        'Sold',
        'Rented'
      ];
    }
    final base = <String>['Draft', 'Pending Review', 'Archived'];
    if (_status == 'Published') base.add('Published');
    if (_status == 'Sold' || _status == 'Rented') {
      base.addAll(['Sold', 'Rented']);
    }
    return base.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final statusOptions = _statusOptions();
    if (!statusOptions.contains(_status)) {
      _status = statusOptions.first;
    }

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _listingType,
                decoration: const InputDecoration(labelText: 'Listing Type'),
                items: const [
                  DropdownMenuItem(value: 'Sale', child: Text('Sale')),
                  DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _listingType = v);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: statusOptions
                    .map((s) =>
                        DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _status = v);
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _description,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            final location = _location.text.trim();
            final price = _price.text.trim();
            final description = _description.text.trim();
            if (title.isEmpty || location.isEmpty || price.isEmpty) return;

            Navigator.of(context).pop(
              _ListingFormValue(
                title: title,
                listingType: _listingType,
                location: location,
                price: price,
                description: description,
                status: _status,
              ),
            );
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}

class _UploadAssetsSelection {
  const _UploadAssetsSelection({
    required this.propertyDocuments,
    required this.ownershipAuthorizationDocuments,
    required this.images,
  });

  final List<PlatformFile> propertyDocuments;
  final List<PlatformFile> ownershipAuthorizationDocuments;
  final List<PlatformFile> images;

  int get totalFiles =>
      propertyDocuments.length +
      ownershipAuthorizationDocuments.length +
      images.length;
}

class _UploadAssetsDialog extends StatefulWidget {
  const _UploadAssetsDialog();

  @override
  State<_UploadAssetsDialog> createState() => _UploadAssetsDialogState();
}

class _UploadAssetsDialogState extends State<_UploadAssetsDialog> {
  final List<PlatformFile> _propertyDocs = [];
  final List<PlatformFile> _ownerAuthDocs = [];
  final List<PlatformFile> _images = [];

  Future<void> _pickInto(List<PlatformFile> target, {int? maxFiles}) async {
    final remaining = maxFiles == null ? null : (maxFiles - target.length);
    if (remaining != null && remaining <= 0) return;

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.any,
    );
    if (result == null) return;

    setState(() {
      for (final file in result.files) {
        if (file.bytes == null || file.bytes!.isEmpty) continue;
        if (remaining != null && target.length >= maxFiles!) break;
        target.add(file);
      }
    });
  }

  void _removeAt(List<PlatformFile> target, int index) {
    setState(() => target.removeAt(index));
  }

  Widget _fileChips(
      List<PlatformFile> files, void Function(int index) onDelete) {
    if (files.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < files.length; i++)
          Chip(
            label: Text(files[i].name),
            onDeleted: () => onDelete(i),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Listing Assets'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () => _pickInto(_propertyDocs),
                icon: const Icon(Icons.description_outlined),
                label: Text('Property Documents (${_propertyDocs.length})'),
              ),
              _fileChips(_propertyDocs, (i) => _removeAt(_propertyDocs, i)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _pickInto(_ownerAuthDocs),
                icon: const Icon(Icons.verified_user_outlined),
                label:
                    Text('Ownership Authorization (${_ownerAuthDocs.length})'),
              ),
              _fileChips(_ownerAuthDocs, (i) => _removeAt(_ownerAuthDocs, i)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _pickInto(_images, maxFiles: 10),
                icon: const Icon(Icons.image_outlined),
                label: Text('Property Images (${_images.length}/10)'),
              ),
              _fileChips(_images, (i) => _removeAt(_images, i)),
              const SizedBox(height: 8),
              const Text(
                'You can upload any combination. Images are capped at 10 files per upload.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              _UploadAssetsSelection(
                propertyDocuments: List<PlatformFile>.from(_propertyDocs),
                ownershipAuthorizationDocuments:
                    List<PlatformFile>.from(_ownerAuthDocs),
                images: List<PlatformFile>.from(_images),
              ),
            );
          },
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
