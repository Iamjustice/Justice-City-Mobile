import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';
import 'listings_screen.dart';

final listingByIdProvider = Provider.family<Listing?, String>((ref, id) {
  final asyncListings = ref.watch(listingsProvider);
  return asyncListings.maybeWhen(
    data: (items) => items.where((e) => e.id == id).cast<Listing?>().firstOrNull,
    orElse: () => null,
  );
});

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class ListingDetailsScreen extends ConsumerStatefulWidget {
  const ListingDetailsScreen({super.key, required this.listingId, this.initial});
  final String listingId;
  final Listing? initial;

  @override
  ConsumerState<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends ConsumerState<ListingDetailsScreen> {
  String? _statusDraft;

  bool _isOperatorRole(String role) {
    const allowed = <String>{'admin', 'agent', 'seller', 'owner'};
    return allowed.contains(role.trim().toLowerCase());
  }

  String _viewerRole() {
    return (ref.read(meProvider).valueOrNull?.role ?? '').trim().toLowerCase();
  }

  bool _canEditListingStatus() {
    return _isOperatorRole(_viewerRole());
  }

  String _requesterRole() {
    final role = (ref.read(meProvider).valueOrNull?.role ?? '').trim().toLowerCase();
    const allowedRoles = <String>{'admin', 'agent', 'seller', 'buyer', 'owner', 'renter'};
    return allowedRoles.contains(role) ? role : 'buyer';
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.initial ?? ref.watch(listingByIdProvider(widget.listingId));
    final canEditStatus = _canEditListingStatus();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: listing == null
          ? const Center(child: Text('Listing not found (try refreshing).'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (listing.coverImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      listing.coverImageUrl!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
                  )
                else
                  _placeholder(),
                const SizedBox(height: 12),

                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (listing.location != null) listing.location!,
                    if (listing.listingType != null) listing.listingType!,
                  ].join(' - '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(
                                [listing.price, listing.priceSuffix].whereType<String>().join(' '),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(listing.status ?? '-'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if ((listing.description ?? '').trim().isNotEmpty) ...[
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(listing.description!.trim()),
                  const SizedBox(height: 16),

                  // Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Next steps', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: () => _openRequestCallback(context, listing),
                                icon: const Icon(Icons.phone),
                                label: const Text('Request callback'),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () => _openScheduleTour(context, listing),
                                icon: const Icon(Icons.calendar_month),
                                label: const Text('Schedule tour'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _startChat(context, listing),
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Message support'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'These requests are routed to Justice City support and linked to this property.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                ],

                const Text('Update status', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (canEditStatus) ...[
                  _statusPicker(listing),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _statusDraft == null ? null : () => _applyStatus(listing),
                    icon: const Icon(Icons.save),
                    label: const Text('Save status'),
                  ),
                ] else ...[
                  const Text(
                    'Status updates are restricted to operator roles (admin, agent, seller, owner).',
                  ),
                ],
                const SizedBox(height: 24),

                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Tip: This screen is fed by your agent listings API. '
                  'When you later add public marketplace endpoints, we can make this accessible without requiring agent auth.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }

  Widget _statusPicker(Listing listing) {
    const allowed = <String>[
      'Draft',
      'Pending Review',
      'Published',
      'Archived',
      'Sold',
      'Rented',
    ];

    final current = listing.status;
    final value = _statusDraft ?? current;

    return DropdownButtonFormField<String>(
      key: ValueKey(value ?? 'empty'),
      initialValue: allowed.contains(value) ? value : null,
      items: allowed.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      decoration: const InputDecoration(border: OutlineInputBorder()),
      onChanged: (v) => setState(() => _statusDraft = v),
    );
  }

  Future<void> _applyStatus(Listing listing) async {
    if (!_canEditListingStatus()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are not allowed to update listing status.')),
      );
      return;
    }

    final status = _statusDraft;
    if (status == null) return;

    try {
      final updated = await ref.read(listingsRepositoryProvider).updateListingStatus(
            listingId: listing.id,
            status: status,
          );

      // refresh list cache so previous screen updates too
      ref.invalidate(listingsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${updated.status ?? status}')),
      );

      setState(() {
        _statusDraft = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }


  Future<void> _startChat(BuildContext context, Listing listing) async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }
    final requesterId = session.userId;
    final requesterName = session.email ?? 'User';

    final chatRepo = ref.read(chatRepositoryProvider);
    try {
      final convoId = await chatRepo.upsertConversation(
        requesterId: requesterId,
        requesterName: requesterName,
        requesterRole: _requesterRole(),
        recipientName: 'Justice City Support',
        recipientRole: 'support',
        subject: listing.title,
        listingId: listing.id,
        initialMessage: 'Hello, I have a question about "${listing.title}".',
        conversationScope: 'listing',
      );
      if (!mounted) return;
      context.go('/chat/$convoId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: $e')),
      );
    }
  }

  Future<void> _openRequestCallback(BuildContext context, Listing listing) async {
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request a callback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("We'll ask support to call you about \"${listing.title}\"."),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone number (E.164)',
                hintText: '+2349012345678',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Best time to call / what you need...',
              ),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send')),
        ],
      ),
    );

    if (ok != true) return;

    final phone = phoneCtrl.text.trim();
    final note = noteCtrl.text.trim();

    final msg = [
      'CALLBACK REQUEST',
      'Property: ${listing.title}',
      'Listing ID: ${listing.id}',
      if (phone.isNotEmpty) 'Phone: $phone',
      if (note.isNotEmpty) 'Notes: $note',
    ].join('\n');

    await _createSupportConversationAndOpen(context, listing, msg);
  }

  Future<void> _openScheduleTour(BuildContext context, Listing listing) async {
    DateTime? date;
    TimeOfDay? time;
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Schedule a tour'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pick a preferred date/time for "${listing.title}".'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 180)),
                        );
                        if (picked != null) setState(() => date = picked);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: Text(date == null ? 'Select date' : '${date!.year}-${date!.month.toString().padLeft(2,'0')}-${date!.day.toString().padLeft(2,'0')}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                        if (picked != null) setState(() => time = picked);
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text(time == null ? 'Select time' : time!.format(ctx)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Preferred duration / special requests...',
                ),
                minLines: 2,
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: (date == null || time == null) ? null : () => Navigator.pop(ctx, true),
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) return;

    final when = DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
    final note = noteCtrl.text.trim();

    final msg = [
      'TOUR REQUEST',
      'Property: ${listing.title}',
      'Listing ID: ${listing.id}',
      'Preferred: ${when.toIso8601String()}',
      if (note.isNotEmpty) 'Notes: $note',
    ].join('\n');

    await _createSupportConversationAndOpen(context, listing, msg);
  }

  Future<void> _createSupportConversationAndOpen(
    BuildContext context,
    Listing listing,
    String initialMessage,
  ) async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      if (!mounted) return;
      context.go('/auth');
      return;
    }

    final chatRepo = ref.read(chatRepositoryProvider);

    try {
      final convoId = await chatRepo.upsertConversation(
        requesterId: session.userId,
        requesterName: session.email ?? 'User',
        requesterRole: _requesterRole(),
        recipientName: 'Justice City Support',
        recipientRole: 'support',
        subject: listing.title,
        listingId: listing.id,
        initialMessage: initialMessage,
        conversationScope: 'listing',
      );

      if (!mounted) return;
      context.go('/chat/$convoId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }

  Widget _placeholder() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 40),
      ),
    );
  }
}
