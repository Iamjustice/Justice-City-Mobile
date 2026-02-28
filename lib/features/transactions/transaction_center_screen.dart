import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/me_provider.dart';
import '../../state/transaction_providers.dart';
import '../../domain/models/chat_action.dart';
import '../../domain/models/transaction.dart';
import '../shell/justice_city_shell.dart';

const _txPanelBorder = Color(0xFFE2E8F0);
const _txHeading = Color(0xFF0F172A);
const _txMuted = Color(0xFF64748B);

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

    return JusticeCityShell(
      currentPath: '/chat',
      leadingWidth: 56,
      leading: IconButton(
        tooltip: 'Back to conversation',
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF475569)),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/chat/${widget.conversationId}');
          }
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.invalidate(transactionByConversationProvider(widget.conversationId));
          },
        ),
      ],
      child: txAsync.when(
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
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TransactionHeroHeader(
              title: 'Transaction workspace',
              subtitle:
                  'Create the escrow record for this conversation and start the formal transaction flow.',
            ),
            const SizedBox(height: 12),
            const Text(
              'No transaction is linked to this conversation yet.',
              style: TextStyle(fontSize: 16, color: _txMuted),
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
          const SizedBox(height: 12),
          const JusticeCityFooter(),
        ],
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
        padding: const EdgeInsets.all(20),
        children: [
          _TransactionHeroHeader(
            title: 'Escrow and closing workspace',
            subtitle:
                'Track status, approvals, disputes, payout, and ratings for this deal.',
            trailing: _HeroStatusBadge(text: tx!.status),
          ),
          const SizedBox(height: 12),
          _TransactionMetricStrip(tx: tx!),
          const SizedBox(height: 12),
          _TransactionCard(tx: tx!),
          const SizedBox(height: 12),
          _SurfaceSection(
            title: 'Status control',
            subtitle: 'Move the deal through the next escrow stage.',
            child: _StatusCard(
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
          ),
          if (canCreateActions) ...[
            const SizedBox(height: 12),
            _SurfaceSection(
              title: 'Required actions',
              subtitle: 'Request proofs, signatures, deliverables, and approvals.',
              child: _CreateActionCard(
                conversationId: conversationId,
                transactionId: tx!.id,
                onCreated: () =>
                    ref.invalidate(transactionActionsProvider(tx!.id)),
              ),
            ),
          ],
          if (canClaimPayout) ...[
            const SizedBox(height: 12),
            _SurfaceSection(
              title: 'Payout claim',
              subtitle: 'Register payout requests and settlement details.',
              child: _PayoutClaimCard(
                conversationId: conversationId,
                transactionId: tx!.id,
              ),
            ),
          ],
          if (canSubmitRatings) ...[
            const SizedBox(height: 12),
            _SurfaceSection(
              title: 'Completion rating',
              subtitle: 'Score the experience after delivery or closing.',
              child: _SubmitRatingCard(
                conversationId: conversationId,
                transactionId: tx!.id,
              ),
            ),
          ],
          const SizedBox(height: 12),
          _SurfaceSection(
            title: 'Action queue',
            subtitle: 'System prompts, pending approvals, and required responses.',
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Actions'),
              subtitle: const Text('System prompts and approvals'),
              children: [
                actionsAsync.when(
                  data: (items) => items.isEmpty
                      ? const ListTile(title: Text('No actions yet.'))
                      : Column(
                          children: items
                              .map((a) => _ActionResolutionTile(
                                    action: a,
                                    conversationId: conversationId,
                                    transactionId: tx!.id,
                                    userRole: userRole,
                                    onResolved: () {
                                      ref.invalidate(
                                          transactionActionsProvider(tx!.id));
                                      ref.invalidate(
                                        transactionByConversationProvider(
                                            conversationId),
                                      );
                                    },
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
          ),
          const SizedBox(height: 12),
          _SurfaceSection(
            title: 'Dispute center',
            subtitle: 'Open a case or review active dispute history.',
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
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
                            content: Text(
                                'Dispute failed: ${_readableApiError(e)}')),
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
          ),
          const SizedBox(height: 12),
          const JusticeCityFooter(),
        ],
      ),
    );
  }
}

class _TransactionHeroHeader extends StatelessWidget {
  const _TransactionHeroHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _HeroStatusBadge extends StatelessWidget {
  const _HeroStatusBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TransactionMetricStrip extends StatelessWidget {
  const _TransactionMetricStrip({required this.tx});

  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TransactionMetricCard(
            label: 'Type',
            value: tx.transactionKind,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TransactionMetricCard(
            label: 'Mode',
            value: tx.closingMode.trim().isEmpty ? 'standard' : tx.closingMode,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TransactionMetricCard(
            label: 'Amount',
            value: tx.principalAmount == null
                ? tx.currency
                : '${tx.currency} ${tx.principalAmount}',
          ),
        ),
      ],
    );
  }
}

class _TransactionMetricCard extends StatelessWidget {
  const _TransactionMetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _txPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _txMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _txHeading,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceSection extends StatelessWidget {
  const _SurfaceSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _txPanelBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _txHeading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: _txMuted),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActionResolutionTile extends ConsumerStatefulWidget {
  const _ActionResolutionTile({
    required this.action,
    required this.conversationId,
    required this.transactionId,
    required this.userRole,
    required this.onResolved,
  });

  final ChatAction action;
  final String conversationId;
  final String transactionId;
  final String userRole;
  final VoidCallback onResolved;

  @override
  ConsumerState<_ActionResolutionTile> createState() =>
      _ActionResolutionTileState();
}

class _ActionResolutionTileState extends ConsumerState<_ActionResolutionTile> {
  final _payloadCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _payloadCtrl.dispose();
    super.dispose();
  }

  bool get _canResolve {
    if (widget.action.status.trim().toLowerCase() != 'pending') return false;
    final role = widget.userRole.trim().toLowerCase();
    if (role == 'admin' || role == 'support') return true;
    return widget.action.targetRole.trim().toLowerCase() == role;
  }

  String get _primaryLabel {
    final type = widget.action.actionType.trim().toLowerCase();
    if (type == 'upload_payment_proof' ||
        type == 'upload_signed_closing_contract' ||
        type == 'upload_service_deliverable') {
      return 'Submit';
    }
    if (type == 'accept_delivery') return 'Accept';
    return 'Accept';
  }

  String get _primaryDecision {
    final type = widget.action.actionType.trim().toLowerCase();
    if (type == 'upload_payment_proof' ||
        type == 'upload_signed_closing_contract' ||
        type == 'upload_service_deliverable') {
      return 'submit';
    }
    return 'accept';
  }

  String get _secondaryLabel {
    if (widget.action.actionType.trim().toLowerCase() == 'accept_delivery') {
      return 'Dispute';
    }
    return 'Decline';
  }

  Future<void> _resolve(String decision) async {
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
    final result = await controller.resolveAction(
      widget.conversationId,
      widget.transactionId,
      actionId: widget.action.id,
      decision: decision,
      payload: payload,
    );

    widget.onResolved();
    if (!mounted) return;
    final warningText =
        result.warnings.isNotEmpty ? ' Warning: ${result.warnings.first}' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action resolved.$warningText')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.action.status.trim().toLowerCase();
    final target = widget.action.targetRole.trim().toLowerCase();
    return ListTile(
      title: Text(widget.action.actionType),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status: $status - Target: $target'),
          if (_canResolve) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _payloadCtrl,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Payload JSON (optional)',
                hintText: '{"note":"optional"}',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          try {
                            await _resolve(_primaryDecision);
                          } on FormatException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Payload error: ${e.message}'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Action resolve failed: ${_readableApiError(e)}',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _submitting = false);
                          }
                        },
                  child: Text(_primaryLabel),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () async {
                          setState(() => _submitting = true);
                          try {
                            await _resolve('decline');
                          } on FormatException catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Payload error: ${e.message}'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Action resolve failed: ${_readableApiError(e)}',
                                ),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _submitting = false);
                          }
                        },
                  child: Text(_secondaryLabel),
                ),
              ],
            ),
          ],
        ],
      ),
      isThreeLine: _canResolve,
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
