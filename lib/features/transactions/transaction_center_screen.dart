import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/me_provider.dart';
import '../../state/transaction_providers.dart';
import '../../domain/models/transaction.dart';

class TransactionCenterScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const TransactionCenterScreen({super.key, required this.conversationId});

  @override
  ConsumerState<TransactionCenterScreen> createState() =>
      _TransactionCenterScreenState();
}

class _TransactionCenterScreenState
    extends ConsumerState<TransactionCenterScreen> {
  final _reasonCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _statusReasonCtrl = TextEditingController();
  String _toStatus = 'inspection_pending';

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _detailsCtrl.dispose();
    _statusReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync =
        ref.watch(transactionByConversationProvider(widget.conversationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction & Escrow')),
      body: txAsync.when(
        data: (tx) => _Body(
          conversationId: widget.conversationId,
          tx: tx,
          reasonCtrl: _reasonCtrl,
          detailsCtrl: _detailsCtrl,
          statusReasonCtrl: _statusReasonCtrl,
          toStatus: _toStatus,
          onStatusChanged: (v) => setState(() => _toStatus = v),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(
              transactionByConversationProvider(widget.conversationId)),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final String conversationId;
  final Transaction? tx;
  final TextEditingController reasonCtrl;
  final TextEditingController detailsCtrl;
  final TextEditingController statusReasonCtrl;
  final String toStatus;
  final ValueChanged<String> onStatusChanged;

  const _Body({
    required this.conversationId,
    required this.tx,
    required this.reasonCtrl,
    required this.detailsCtrl,
    required this.statusReasonCtrl,
    required this.toStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(transactionControllerProvider);
    final me = ref.watch(meProvider);
    final userRole = me.maybeWhen(
      data: (u) => (u?.role ?? '').trim().toLowerCase(),
      orElse: () => 'buyer',
    );
    final canCreateActions = {
      'admin',
      'support',
      'agent',
      'seller',
      'owner',
    }.contains(userRole);
    final canClaimPayout = canCreateActions;
    final canSubmitRatings = userRole == 'buyer' || userRole == 'renter';

    if (tx == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'No transaction is linked to this conversation yet.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create transaction (default sale)'),
              onPressed: () async {
                try {
                  await controller.upsertForConversation(conversationId);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction created.')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Create failed: ${_readableApiError(e)}')),
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    final actionsAsync = ref.watch(transactionActionsProvider(tx!.id));
    final disputesAsync = ref.watch(transactionDisputesProvider(tx!.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(transactionByConversationProvider(conversationId));
        ref.invalidate(transactionActionsProvider(tx!.id));
        ref.invalidate(transactionDisputesProvider(tx!.id));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TransactionCard(tx: tx!),
          const SizedBox(height: 12),
          _StatusCard(
            current: tx!.status,
            toStatus: toStatus,
            reasonCtrl: statusReasonCtrl,
            onChanged: onStatusChanged,
            onApply: () async {
              try {
                await controller.changeStatus(
                  conversationId,
                  tx!.id,
                  toStatus,
                  reason: statusReasonCtrl.text.trim().isEmpty
                      ? null
                      : statusReasonCtrl.text.trim(),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status updated.')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Status update failed: ${_readableApiError(e)}'),
                  ),
                );
              }
            },
          ),
          if (canCreateActions) ...[
            const SizedBox(height: 12),
            _CreateActionCard(
              conversationId: conversationId,
              transactionId: tx!.id,
              onCreated: () =>
                  ref.invalidate(transactionActionsProvider(tx!.id)),
            ),
          ],
          if (canClaimPayout) ...[
            const SizedBox(height: 12),
            _PayoutClaimCard(
              conversationId: conversationId,
              transactionId: tx!.id,
            ),
          ],
          if (canSubmitRatings) ...[
            const SizedBox(height: 12),
            _SubmitRatingCard(
              conversationId: conversationId,
              transactionId: tx!.id,
            ),
          ],
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Actions'),
            subtitle: const Text('System prompts and approvals'),
            children: [
              actionsAsync.when(
                data: (items) => items.isEmpty
                    ? const ListTile(title: Text('No actions yet.'))
                    : Column(
                        children: items
                            .map((a) => ListTile(
                                  title: Text(a.actionType),
                                  subtitle: Text(
                                      'Status: ${a.status} - Target: ${a.targetRole}'),
                                ))
                            .toList(),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => ListTile(
                  title: const Text('Failed to load actions'),
                  subtitle: Text(e.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        ref.invalidate(transactionActionsProvider(tx!.id)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Disputes'),
            subtitle: const Text('Open and resolved cases'),
            children: [
              _OpenDisputeForm(
                reasonCtrl: reasonCtrl,
                detailsCtrl: detailsCtrl,
                onSubmit: () async {
                  final reason = reasonCtrl.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reason is required.')));
                    return;
                  }
                  try {
                    await controller.openDispute(
                      conversationId,
                      tx!.id,
                      reason,
                      details: detailsCtrl.text.trim().isEmpty
                          ? null
                          : detailsCtrl.text.trim(),
                    );
                    reasonCtrl.clear();
                    detailsCtrl.clear();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispute opened.')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Dispute failed: ${_readableApiError(e)}')),
                    );
                  }
                },
              ),
              disputesAsync.when(
                data: (items) => items.isEmpty
                    ? const ListTile(title: Text('No disputes.'))
                    : Column(
                        children: items
                            .map((d) => ListTile(
                                  title: Text(
                                      '${d.status.toUpperCase()}: ${d.reason}'),
                                  subtitle: Text(d.details ?? '-'),
                                ))
                            .toList(),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => ListTile(
                  title: const Text('Failed to load disputes'),
                  subtitle: Text(e.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () =>
                        ref.invalidate(transactionDisputesProvider(tx!.id)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              ref.invalidate(transactionByConversationProvider(conversationId));
              ref.invalidate(transactionActionsProvider(tx!.id));
              ref.invalidate(transactionDisputesProvider(tx!.id));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          )
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Status: ${tx.status}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Kind: ${tx.transactionKind} - Closing: ${tx.closingMode}'),
          const SizedBox(height: 6),
          Text(
              'Currency: ${tx.currency} - Principal: ${tx.principalAmount ?? 0}'),
          const SizedBox(height: 6),
          Text(
              'Inspection fee: ${tx.inspectionFeeAmount} (${tx.inspectionFeeRefundable ? 'refundable' : 'non-refundable'})'),
          const SizedBox(height: 6),
          Text('Escrow ref: ${tx.escrowReference ?? '-'}'),
          const SizedBox(height: 6),
          Text('Updated: ${tx.updatedAt}'),
        ]),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String current;
  final String toStatus;
  final TextEditingController reasonCtrl;
  final ValueChanged<String> onChanged;
  final VoidCallback onApply;

  const _StatusCard({
    required this.current,
    required this.toStatus,
    required this.reasonCtrl,
    required this.onChanged,
    required this.onApply,
  });

  static const _statuses = <String>[
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Change status (current: $current)',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue:
                _statuses.contains(toStatus) ? toStatus : _statuses.first,
            items: _statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => onChanged(v ?? _statuses.first),
            decoration: const InputDecoration(labelText: 'To status'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(labelText: 'Reason (optional)'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.save),
            label: const Text('Apply'),
          ),
        ]),
      ),
    );
  }
}

class _OpenDisputeForm extends StatelessWidget {
  final TextEditingController reasonCtrl;
  final TextEditingController detailsCtrl;
  final VoidCallback onSubmit;

  const _OpenDisputeForm({
    required this.reasonCtrl,
    required this.detailsCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Open a dispute',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(labelText: 'Reason *'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: detailsCtrl,
            decoration: const InputDecoration(labelText: 'Details (optional)'),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.report_problem),
            label: const Text('Submit dispute'),
          ),
        ],
      ),
    );
  }
}

class _CreateActionCard extends ConsumerStatefulWidget {
  const _CreateActionCard({
    required this.conversationId,
    required this.transactionId,
    required this.onCreated,
  });

  final String conversationId;
  final String transactionId;
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateActionCard> createState() => _CreateActionCardState();
}

class _CreateActionCardState extends ConsumerState<_CreateActionCard> {
  static const _actionTypes = <String>[
    'inspection_request',
    'escrow_payment_request',
    'upload_payment_proof',
    'request_signed_contract',
    'schedule_meeting_request',
    'upload_signed_closing_contract',
    'mark_delivered',
    'accept_delivery',
    'service_intake_form',
    'service_quote',
    'upload_service_deliverable',
    'rating_request',
  ];

  static const _targetRoles = <String>[
    'buyer',
    'seller',
    'agent',
    'owner',
    'renter',
    'support',
    'admin',
  ];

  final _contentCtrl = TextEditingController();
  final _payloadCtrl = TextEditingController();
  final _expiresAtCtrl = TextEditingController();

  String _actionType = _actionTypes.first;
  String _targetRole = _targetRoles.first;
  bool _submitting = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    _payloadCtrl.dispose();
    _expiresAtCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    Map<String, dynamic>? payload;
    final payloadText = _payloadCtrl.text.trim();
    if (payloadText.isNotEmpty) {
      final decoded = jsonDecode(payloadText);
      if (decoded is! Map) {
        throw const FormatException('Payload must be a JSON object.');
      }
      payload = Map<String, dynamic>.from(decoded);
    }

    final controller = ref.read(transactionControllerProvider);
    final result = await controller.createAction(
      widget.conversationId,
      widget.transactionId,
      actionType: _actionType,
      targetRole: _targetRole,
      content:
          _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
      payload: payload,
      expiresAt: _expiresAtCtrl.text.trim().isEmpty
          ? null
          : _expiresAtCtrl.text.trim(),
    );

    if (!mounted) return;
    widget.onCreated();
    final warningText =
        result.warnings.isNotEmpty ? ' Warning: ${result.warnings.first}' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action created.$warningText')),
    );
    _contentCtrl.clear();
    _payloadCtrl.clear();
    _expiresAtCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Transaction Action',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _actionType,
              items: _actionTypes
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _actionType = v ?? _actionTypes.first),
              decoration: const InputDecoration(labelText: 'Action type'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _targetRole,
              items: _targetRoles
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _targetRole = v ?? _targetRoles.first),
              decoration: const InputDecoration(labelText: 'Target role'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentCtrl,
              decoration: const InputDecoration(
                labelText: 'Message content (optional)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _expiresAtCtrl,
              decoration: const InputDecoration(
                labelText: 'Expires at ISO (optional)',
                hintText: '2026-02-26T12:00:00.000Z',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _payloadCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Payload JSON object (optional)',
                hintText: '{"key":"value"}',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _submitting
                  ? null
                  : () async {
                      setState(() => _submitting = true);
                      try {
                        await _submit();
                      } on FormatException catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Payload error: ${e.message}')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Action create failed: ${_readableApiError(e)}'),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.task_alt),
              label: const Text('Create Action'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutClaimCard extends ConsumerStatefulWidget {
  const _PayoutClaimCard({
    required this.conversationId,
    required this.transactionId,
  });

  final String conversationId;
  final String transactionId;

  @override
  ConsumerState<_PayoutClaimCard> createState() => _PayoutClaimCardState();
}

class _PayoutClaimCardState extends ConsumerState<_PayoutClaimCard> {
  final _amountCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'NGN');
  final _recipientCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  String _ledgerType = 'payout';
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _currencyCtrl.dispose();
    _recipientCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Claim Payout Ledger Entry',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _ledgerType,
              items: const [
                DropdownMenuItem(value: 'payout', child: Text('payout')),
                DropdownMenuItem(value: 'refund', child: Text('refund')),
                DropdownMenuItem(
                    value: 'commission', child: Text('commission')),
              ],
              onChanged: (v) => setState(() => _ledgerType = v ?? 'payout'),
              decoration: const InputDecoration(labelText: 'Ledger type'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _currencyCtrl,
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _recipientCtrl,
              decoration: const InputDecoration(
                  labelText: 'Recipient user ID (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceCtrl,
              decoration:
                  const InputDecoration(labelText: 'Reference (optional)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _submitting
                  ? null
                  : () async {
                      final amount = double.tryParse(_amountCtrl.text.trim());
                      if (amount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Amount must be numeric.')),
                        );
                        return;
                      }

                      setState(() => _submitting = true);
                      try {
                        final controller =
                            ref.read(transactionControllerProvider);
                        final result = await controller.claimPayout(
                          widget.conversationId,
                          widget.transactionId,
                          amount: amount,
                          ledgerType: _ledgerType,
                          currency: _currencyCtrl.text.trim().isEmpty
                              ? null
                              : _currencyCtrl.text.trim(),
                          recipientUserId: _recipientCtrl.text.trim().isEmpty
                              ? null
                              : _recipientCtrl.text.trim(),
                          reference: _referenceCtrl.text.trim().isEmpty
                              ? null
                              : _referenceCtrl.text.trim(),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.claimed
                                  ? 'Payout claimed (entry: ${result.entryId}).'
                                  : 'Payout already claimed for this key.',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Payout claim failed: ${_readableApiError(e)}'),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.account_balance_wallet),
              label: const Text('Submit Payout Claim'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitRatingCard extends ConsumerStatefulWidget {
  const _SubmitRatingCard({
    required this.conversationId,
    required this.transactionId,
  });

  final String conversationId;
  final String transactionId;

  @override
  ConsumerState<_SubmitRatingCard> createState() => _SubmitRatingCardState();
}

class _SubmitRatingCardState extends ConsumerState<_SubmitRatingCard> {
  final _reviewCtrl = TextEditingController();
  final _ratedUserCtrl = TextEditingController();
  int _stars = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _reviewCtrl.dispose();
    _ratedUserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Transaction Rating',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _stars,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1 star')),
                DropdownMenuItem(value: 2, child: Text('2 stars')),
                DropdownMenuItem(value: 3, child: Text('3 stars')),
                DropdownMenuItem(value: 4, child: Text('4 stars')),
                DropdownMenuItem(value: 5, child: Text('5 stars')),
              ],
              onChanged: (v) => setState(() => _stars = v ?? 5),
              decoration: const InputDecoration(labelText: 'Stars'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ratedUserCtrl,
              decoration:
                  const InputDecoration(labelText: 'Rated user ID (optional)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Review (optional)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _submitting
                  ? null
                  : () async {
                      setState(() => _submitting = true);
                      try {
                        final controller =
                            ref.read(transactionControllerProvider);
                        final result = await controller.submitRating(
                          widget.conversationId,
                          widget.transactionId,
                          stars: _stars,
                          review: _reviewCtrl.text.trim().isEmpty
                              ? null
                              : _reviewCtrl.text.trim(),
                          ratedUserId: _ratedUserCtrl.text.trim().isEmpty
                              ? null
                              : _ratedUserCtrl.text.trim(),
                        );
                        if (!context.mounted) return;
                        final suffix = result.editableUntil == null
                            ? ''
                            : ' Editable until: ${result.editableUntil}';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result.created
                                  ? 'Rating submitted.$suffix'
                                  : 'Rating updated.$suffix',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Rating failed: ${_readableApiError(e)}'),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.star),
              label: const Text('Submit Rating'),
            ),
          ],
        ),
      ),
    );
  }
}

String _readableApiError(Object error) {
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          )
        ]),
      ),
    );
  }
}
