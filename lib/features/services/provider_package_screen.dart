import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/services_providers.dart';

class ProviderPackageScreen extends ConsumerWidget {
  final String token;
  const ProviderPackageScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pkgAsync = ref.watch(providerPackageProvider(token));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Package'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(providerPackageProvider(token)),
          ),
        ],
      ),
      body: pkgAsync.when(
        data: (pkg) {
          final payloadPretty = const JsonEncoder.withIndent('  ').convert(pkg.payload);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${pkg.status}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Conversation ID: ${pkg.conversationId}'),
                      if (pkg.serviceRequestId != null) Text('Service Request ID: ${pkg.serviceRequestId}'),
                      const SizedBox(height: 8),
                      Text('Expires: ${pkg.expiresAt}'),
                      if (pkg.openedAt != null) Text('Opened: ${pkg.openedAt}'),
                      const SizedBox(height: 8),
                      Text('Link ID: ${pkg.linkId}', style: Theme.of(context).textTheme.bodySmall),
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
              Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pkg.attachments.isEmpty)
                const Text('No attachments.'),
              for (final f in pkg.attachments) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(f.fileName),
                    subtitle: SelectableText(f.signedUrl ?? '${f.bucketId}/${f.storagePath}'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (pkg.transcript != null) ...[
                const SizedBox(height: 16),
                Text('Transcript', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(pkg.transcript!.fileName),
                    subtitle: SelectableText(pkg.transcript!.signedUrl ?? '${pkg.transcript!.bucketId}/${pkg.transcript!.storagePath}'),
                  ),
                ),
              ],
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
