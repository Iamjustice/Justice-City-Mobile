import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/services_providers.dart';
import '../../state/session_provider.dart';

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
      appBar: AppBar(
        title: const Text('Provider Package'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${pkg.status}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Conversation ID: ${pkg.conversationId}'),
                      if (pkg.serviceRequestId != null)
                        Text('Service Request ID: ${pkg.serviceRequestId}'),
                      const SizedBox(height: 8),
                      Text('Expires: ${pkg.expiresAt}'),
                      if (pkg.openedAt != null) Text('Opened: ${pkg.openedAt}'),
                      const SizedBox(height: 8),
                      Text(
                        'Link ID: ${pkg.linkId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Payload', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(payloadPretty),
                ),
              ),
              const SizedBox(height: 16),
              Text('Attachments',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pkg.attachments.isEmpty) const Text('No attachments.'),
              for (final f in pkg.attachments) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(f.fileName),
                    subtitle: SelectableText(
                        f.signedUrl ?? '${f.bucketId}/${f.storagePath}'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (pkg.transcript != null) ...[
                const SizedBox(height: 16),
                Text('Transcript',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(pkg.transcript!.fileName),
                    subtitle: SelectableText(
                      pkg.transcript!.signedUrl ??
                          '${pkg.transcript!.bucketId}/${pkg.transcript!.storagePath}',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Ops',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Your role: $role'),
                      const SizedBox(height: 12),
                      if (canCreateLinks) ...[
                        TextField(
                          controller: _providerUserIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Provider user ID (optional)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _serviceRequestIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Service request ID (optional)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _payloadCtrl,
                          minLines: 2,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Payload JSON (optional)',
                            hintText: '{"source":"mobile"}',
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                        content:
                                            Text('Payload error: ${e.message}'),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Create link failed: ${_readableApiError(e)}',
                                        ),
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
                          label: const Text('Create Provider Link'),
                        ),
                      ] else
                        const Text(
                          'Only admin/support/agent can create provider links.',
                        ),
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
                                          'Queue job failed: ${_readableApiError(e)}',
                                        ),
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
                          label: const Text('Queue Service PDF Job'),
                        )
                      else
                        const Text(
                          'Only admin/support/agent can queue service PDF jobs.',
                        ),
                      if (_latestPackageUrl != null &&
                          _latestPackageUrl!.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Latest provider package URL:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(_latestPackageUrl!),
                        if (_latestToken != null && _latestToken!.isNotEmpty)
                          SelectableText('Token: $_latestToken'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Provider Links',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              linksAsync.when(
                data: (links) {
                  if (links.isEmpty) {
                    return const Text('No provider links yet.');
                  }
                  return Column(
                    children: links.map((link) {
                      final canRevoke = canRevokeLinks &&
                          (link.status == 'active' || link.status == 'opened');
                      return Card(
                        child: ListTile(
                          title:
                              Text('${link.status.toUpperCase()} - ${link.id}'),
                          subtitle: Text(
                            'Provider: ${link.providerUserId ?? '-'}\n'
                            'Token hint: ${link.tokenHint ?? '-'}\n'
                            'Expires: ${link.expiresAt}',
                          ),
                          trailing: canRevoke
                              ? TextButton(
                                  onPressed: _revokingLinkId == link.id
                                      ? null
                                      : () async {
                                          setState(
                                              () => _revokingLinkId = link.id);
                                          try {
                                            await _revokeProviderLink(
                                              conversationId,
                                              link.id,
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Revoke failed: ${_readableApiError(e)}',
                                                ),
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
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Revoke'),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Failed to load provider links: $e'),
              ),
              const SizedBox(height: 16),
              Text(
                'Service PDF Jobs',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              pdfJobsAsync.when(
                data: (jobs) {
                  if (jobs.isEmpty) return const Text('No PDF jobs yet.');
                  return Column(
                    children: jobs.map((job) {
                      return Card(
                        child: ListTile(
                          title:
                              Text('${job.status.toUpperCase()} - ${job.id}'),
                          subtitle: Text(
                            'Attempts: ${job.attemptCount}/${job.maxAttempts}\n'
                            'Output: ${job.outputBucket}/${job.outputPath ?? '-'}\n'
                            'Updated: ${job.updatedAt}\n'
                            '${job.errorMessage == null ? '' : 'Error: ${job.errorMessage}'}',
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Failed to load PDF jobs: $e'),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tip: Copy a signedUrl and open it in your browser to download/view the file.',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load provider package: $e'),
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
