import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/services_providers.dart';
import '../../state/session_provider.dart';

const _jcPageBg = Color(0xFFF4F7FB);
const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);

class ProviderPackageScreen extends ConsumerStatefulWidget {
  const ProviderPackageScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<ProviderPackageScreen> createState() =>
      _ProviderPackageScreenState();
}

class _ProviderPackageScreenState extends ConsumerState<ProviderPackageScreen> {
  final _providerUserIdCtrl = TextEditingController();
  final _serviceRequestIdCtrl = TextEditingController();
  final _payloadCtrl = TextEditingController();

  bool _creatingLink = false;
  bool _queuingPdf = false;
  String? _revokingLinkId;
  String? _latestPackageUrl;
  String? _latestToken;

  @override
  void dispose() {
    _providerUserIdCtrl.dispose();
    _serviceRequestIdCtrl.dispose();
    _payloadCtrl.dispose();
    super.dispose();
  }

  String _resolvedRole() {
    final role =
        (ref.read(meProvider).valueOrNull?.role ?? '').trim().toLowerCase();
    if (role == 'admin' ||
        role == 'support' ||
        role == 'agent' ||
        role == 'seller' ||
        role == 'owner' ||
        role == 'buyer' ||
        role == 'renter') {
      return role;
    }
    return 'buyer';
  }

  bool _canCreateLinks(String role) =>
      role == 'admin' || role == 'support' || role == 'agent';
  bool _canQueuePdf(String role) =>
      role == 'admin' || role == 'support' || role == 'agent';
  bool _canRevokeLinks(String role) => role == 'admin' || role == 'support';

  void _refreshByConversation(String conversationId) {
    ref.invalidate(providerPackageProvider(widget.token));
    ref.invalidate(providerLinksByConversationProvider(conversationId));
    ref.invalidate(servicePdfJobsByConversationProvider(conversationId));
  }

  Future<void> _createProviderLink(String conversationId) async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      throw Exception('Sign in required.');
    }

    Map<String, dynamic>? payload;
    final payloadText = _payloadCtrl.text.trim();
    if (payloadText.isNotEmpty) {
      final decoded = jsonDecode(payloadText);
      if (decoded is! Map) {
        throw const FormatException('Payload must be a JSON object.');
      }
      payload = Map<String, dynamic>.from(decoded);
    }

    final repo = ref.read(servicesRepositoryProvider);
    final result = await repo.createProviderLink(
      conversationId: conversationId,
      providerUserId: _providerUserIdCtrl.text.trim().isEmpty
          ? null
          : _providerUserIdCtrl.text.trim(),
      serviceRequestId: _serviceRequestIdCtrl.text.trim().isEmpty
          ? null
          : _serviceRequestIdCtrl.text.trim(),
      createdByUserId: session.userId,
      createdByRole: _resolvedRole(),
      payload: payload,
    );

    if (!mounted) return;
    _latestPackageUrl = result.packageUrl;
    _latestToken = result.token;
    _refreshByConversation(conversationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Provider link created.')),
    );
    _providerUserIdCtrl.clear();
    _serviceRequestIdCtrl.clear();
    _payloadCtrl.clear();
  }

  Future<void> _queueServicePdfJob(
    String conversationId, {
    String? serviceRequestId,
  }) async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      throw Exception('Sign in required.');
    }
    final repo = ref.read(servicesRepositoryProvider);
    await repo.queueServicePdfJob(
      conversationId: conversationId,
      serviceRequestId: serviceRequestId,
      createdByUserId: session.userId,
      actorRole: _resolvedRole(),
      payload: {
        'source': 'mobile_provider_package_screen',
      },
    );
    if (!mounted) return;
    _refreshByConversation(conversationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service PDF job queued.')),
    );
  }

  Future<void> _revokeProviderLink(String conversationId, String linkId) async {
    final repo = ref.read(servicesRepositoryProvider);
    await repo.revokeProviderLink(
      linkId: linkId,
      actorRole: _resolvedRole(),
    );
    if (!mounted) return;
    _refreshByConversation(conversationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Provider link revoked.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pkgAsync = ref.watch(providerPackageProvider(widget.token));

    return Scaffold(
      backgroundColor: _jcPageBg,
      appBar: AppBar(
        backgroundColor: _jcPageBg,
        surfaceTintColor: Colors.transparent,
        title: const SizedBox(
          height: 32,
          child: _BrandWordmark(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh package',
            onPressed: () =>
                ref.invalidate(providerPackageProvider(widget.token)),
          ),
        ],
      ),
      body: pkgAsync.when(
        data: (pkg) {
          final payloadPretty =
              const JsonEncoder.withIndent('  ').convert(pkg.payload);
          final conversationId = pkg.conversationId;
          final role = _resolvedRole();
          final canCreateLinks = _canCreateLinks(role);
          final canQueuePdf = _canQueuePdf(role);
          final canRevokeLinks = _canRevokeLinks(role);

          final linksAsync =
              ref.watch(providerLinksByConversationProvider(conversationId));
          final pdfJobsAsync =
              ref.watch(servicePdfJobsByConversationProvider(conversationId));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const _PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provider Package',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: _jcHeading,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Token-based package with attachments, transcript, provider links, and PDF job controls.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _jcMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Package Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _jcHeading,
                            ),
                          ),
                        ),
                        _StatusTag(
                          text: pkg.status,
                          active: pkg.status.toLowerCase() == 'active' ||
                              pkg.status.toLowerCase() == 'opened',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                        label: 'Conversation ID', value: pkg.conversationId),
                    _SummaryRow(
                        label: 'Service Request ID',
                        value: pkg.serviceRequestId ?? '-'),
                    _SummaryRow(label: 'Expires', value: pkg.expiresAt),
                    _SummaryRow(label: 'Opened', value: pkg.openedAt ?? '-'),
                    _SummaryRow(label: 'Link ID', value: pkg.linkId),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _SectionTitle('Payload'),
              const SizedBox(height: 8),
              _PanelCard(
                child: SelectableText(payloadPretty),
              ),
              const SizedBox(height: 16),
              const _SectionTitle('Attachments'),
              const SizedBox(height: 8),
              if (pkg.attachments.isEmpty)
                const _PanelCard(child: Text('No attachments.'))
              else
                ...pkg.attachments.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PanelCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.attach_file, color: _jcMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.fileName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _jcHeading,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  f.signedUrl ??
                                      '${f.bucketId}/${f.storagePath}',
                                  style: const TextStyle(color: _jcMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (pkg.transcript != null) ...[
                const SizedBox(height: 16),
                const _SectionTitle('Transcript'),
                const SizedBox(height: 8),
                _PanelCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.description_outlined, color: _jcMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.transcript!.fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _jcHeading,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              pkg.transcript!.signedUrl ??
                                  '${pkg.transcript!.bucketId}/${pkg.transcript!.storagePath}',
                              style: const TextStyle(color: _jcMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _PanelCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Operations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Your role: $role',
                        style: const TextStyle(color: _jcMuted)),
                    const SizedBox(height: 12),
                    if (canCreateLinks) ...[
                      TextField(
                        controller: _providerUserIdCtrl,
                        decoration:
                            _fieldDecoration('Provider user ID (optional)'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _serviceRequestIdCtrl,
                        decoration:
                            _fieldDecoration('Service request ID (optional)'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _payloadCtrl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: _fieldDecoration(
                          'Payload JSON (optional)',
                          hint: '{"source":"mobile"}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: _creatingLink
                            ? null
                            : () async {
                                setState(() => _creatingLink = true);
                                try {
                                  await _createProviderLink(conversationId);
                                } on FormatException catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Payload error: ${e.message}')),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Create link failed: ${_readableApiError(e)}'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _creatingLink = false);
                                  }
                                }
                              },
                        icon: _creatingLink
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.link),
                        label: const Text('Create provider link'),
                      ),
                    ] else
                      const Text(
                          'Only admin/support/agent can create provider links.'),
                    const SizedBox(height: 10),
                    if (canQueuePdf)
                      OutlinedButton.icon(
                        onPressed: _queuingPdf
                            ? null
                            : () async {
                                setState(() => _queuingPdf = true);
                                try {
                                  await _queueServicePdfJob(
                                    conversationId,
                                    serviceRequestId: pkg.serviceRequestId,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Queue job failed: ${_readableApiError(e)}'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _queuingPdf = false);
                                  }
                                }
                              },
                        icon: _queuingPdf
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Queue service PDF job'),
                      )
                    else
                      const Text(
                          'Only admin/support/agent can queue service PDF jobs.'),
                    if (_latestPackageUrl != null &&
                        _latestPackageUrl!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Latest provider package URL',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(_latestPackageUrl!),
                      if (_latestToken != null && _latestToken!.isNotEmpty)
                        SelectableText('Token: $_latestToken'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle('Provider Links'),
              const SizedBox(height: 8),
              linksAsync.when(
                data: (links) {
                  if (links.isEmpty) {
                    return const _PanelCard(
                        child: Text('No provider links yet.'));
                  }
                  return Column(
                    children: links.map((link) {
                      final canRevoke = canRevokeLinks &&
                          (link.status == 'active' || link.status == 'opened');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PanelCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            link.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: _jcHeading,
                                            ),
                                          ),
                                        ),
                                        _StatusTag(
                                          text: link.status,
                                          active: link.status == 'active' ||
                                              link.status == 'opened',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Provider: ${link.providerUserId ?? '-'}\n'
                                      'Token hint: ${link.tokenHint ?? '-'}\n'
                                      'Expires: ${link.expiresAt}',
                                      style: const TextStyle(color: _jcMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (canRevoke)
                                TextButton(
                                  onPressed: _revokingLinkId == link.id
                                      ? null
                                      : () async {
                                          setState(
                                              () => _revokingLinkId = link.id);
                                          try {
                                            await _revokeProviderLink(
                                                conversationId, link.id);
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Revoke failed: ${_readableApiError(e)}'),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(
                                                  () => _revokingLinkId = null);
                                            }
                                          }
                                        },
                                  child: _revokingLinkId == link.id
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Revoke'),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const _PanelCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Loading provider links...'),
                    ],
                  ),
                ),
                error: (e, _) => _PanelCard(
                  child: Text('Failed to load provider links: $e'),
                ),
              ),
              const SizedBox(height: 16),
              const _SectionTitle('Service PDF Jobs'),
              const SizedBox(height: 8),
              pdfJobsAsync.when(
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return const _PanelCard(child: Text('No PDF jobs yet.'));
                  }
                  return Column(
                    children: jobs.map((job) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PanelCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      job.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: _jcHeading,
                                      ),
                                    ),
                                  ),
                                  _StatusTag(
                                    text: job.status,
                                    active: job.status == 'completed',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Attempts: ${job.attemptCount}/${job.maxAttempts}\n'
                                'Output: ${job.outputBucket}/${job.outputPath ?? '-'}\n'
                                'Updated: ${job.updatedAt}\n'
                                '${job.errorMessage == null ? '' : 'Error: ${job.errorMessage}'}',
                                style: const TextStyle(color: _jcMuted),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const _PanelCard(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text('Loading PDF jobs...'),
                    ],
                  ),
                ),
                error: (e, _) => _PanelCard(
                  child: Text('Failed to load PDF jobs: $e'),
                ),
              ),
              const SizedBox(height: 12),
              const _PanelCard(
                child: Text(
                  'Tip: Copy a signed URL and open it in your browser to download the file.',
                  style: TextStyle(color: _jcMuted),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _PanelCard(
              child: Text(
                'Provider Package',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: _jcHeading,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PanelCard(child: Text('Failed to load provider package: $e')),
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

InputDecoration _fieldDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: _jcPanelBorder),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    labelStyle: const TextStyle(color: _jcMuted),
  );
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _jcHeading,
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.text,
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? const Color(0xFF15803D) : const Color(0xFF475569),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: _jcMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF334155)),
            ),
          ),
        ],
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
          'JUSTICE CITY LTD',
          style: TextStyle(
            color: _jcHeading,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
