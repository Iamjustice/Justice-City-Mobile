import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/transaction_providers.dart';
import '../../domain/models/transaction.dart';

class TransactionCenterScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const TransactionCenterScreen({super.key, required this.conversationId});

  @override
  ConsumerState<TransactionCenterScreen> createState() => _TransactionCenterScreenState();
}

class _TransactionCenterScreenState extends ConsumerState<TransactionCenterScreen> {
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
    final txAsync = ref.watch(transactionByConversationProvider(widget.conversationId));

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
          onRetry: () => ref.invalidate(transactionByConversationProvider(widget.conversationId)),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction created.')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
                await controller.changeStatus(conversationId, tx!.id, toStatus,
                    reason: statusReasonCtrl.text.trim().isEmpty ? null : statusReasonCtrl.text.trim());
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Status updated.')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
          ),
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
                                  subtitle: Text('Status: ${a.status} - Target: ${a.targetRole}'),
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
                    onPressed: () => ref.invalidate(transactionActionsProvider(tx!.id)),
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
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Reason is required.')));
                    return;
                  }
                  try {
                    await controller.openDispute(conversationId, tx!.id, reason,
                        details: detailsCtrl.text.trim().isEmpty ? null : detailsCtrl.text.trim());
                    reasonCtrl.clear();
                    detailsCtrl.clear();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Dispute opened.')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                  }
                },
              ),
              disputesAsync.when(
                data: (items) => items.isEmpty
                    ? const ListTile(title: Text('No disputes.'))
                    : Column(
                        children: items
                            .map((d) => ListTile(
                                  title: Text('${d.status.toUpperCase()}: ${d.reason}'),
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
                    onPressed: () => ref.invalidate(transactionDisputesProvider(tx!.id)),
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
          Text('Status: ${tx.status}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Kind: ${tx.transactionKind} - Closing: ${tx.closingMode}'),
          const SizedBox(height: 6),
          Text('Currency: ${tx.currency} - Principal: ${tx.principalAmount ?? 0}'),
          const SizedBox(height: 6),
          Text('Inspection fee: ${tx.inspectionFeeAmount} (${tx.inspectionFeeRefundable ? 'refundable' : 'non-refundable'})'),
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
          Text('Change status (current: $current)', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _statuses.contains(toStatus) ? toStatus : _statuses.first,
            items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
          const Text('Open a dispute', style: TextStyle(fontWeight: FontWeight.bold)),
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
          const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
