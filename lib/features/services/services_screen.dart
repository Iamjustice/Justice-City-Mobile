import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/me_provider.dart';
import '../../state/session_provider.dart';
import '../../state/repositories_providers.dart';

import '../../state/services_providers.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(serviceOfferingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(serviceOfferingsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.link),
            tooltip: 'Open provider package',
            onPressed: () async {
              final token = await _promptToken(context);
              if (token != null && token.isNotEmpty) {
                if (!context.mounted) return;
                context.go('/provider-package/${Uri.encodeComponent(token)}');
              }
            },
          ),
        ],
      ),
      body: offerings.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No service offerings yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = items[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.work_outline),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            s.price,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(s.description),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18),
                          const SizedBox(width: 6),
                          Text('Turnaround: ${s.turnaround}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Code: ${s.code}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _startServiceChat(context, ref, s),
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Start service chat'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final token = await _promptToken(context);
                              if (token != null && token.isNotEmpty) {
                                if (!context.mounted) return;
                                context.go(
                                    '/provider-package/${Uri.encodeComponent(token)}');
                              }
                            },
                            icon: const Icon(Icons.link),
                            label: const Text('Open provider package'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Failed to load offerings: $e'),
        ),
      ),
    );
  }

  Future<void> _startServiceChat(
      BuildContext context, WidgetRef ref, dynamic offering) async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      context.go('/auth');
      return;
    }

    String initialMessage;
    final code = (offering.code as String?)?.toLowerCase() ?? '';
    final name = (offering.name as String?) ?? 'service';

    if (code == 'land_surveying') {
      initialMessage =
          'Hello! I saw you are interested in our professional services. Do you mind giving detail description of the type of survey service you want?';
    } else if (code == 'real_estate_valuation') {
      initialMessage =
          'Hello! I saw you are interested in our professional services. Could you provide the address and type of property you\'d like us to value?';
    } else if (code == 'land_verification') {
      initialMessage =
          'Hello! I saw you are interested in our professional services. Please provide the details of the land or title number you\'d like us to verify.';
    } else if (code == 'snagging') {
      initialMessage =
          'Hello! I saw you are interested in our professional services. When is your move-in date and what\'s the location of the new building?';
    } else {
      initialMessage =
          'Hello! I saw you were interested in our $name. How can we help you today?';
    }

    final chatRepo = ref.read(chatRepositoryProvider);
    final role =
        (ref.read(meProvider).valueOrNull?.role ?? '').trim().toLowerCase();
    const allowedRoles = <String>{
      'admin',
      'agent',
      'seller',
      'buyer',
      'owner',
      'renter'
    };
    final requesterRole = allowedRoles.contains(role) ? role : 'buyer';

    try {
      final convoId = await chatRepo.upsertConversation(
        requesterId: session.userId,
        requesterName: session.email ?? 'User',
        requesterRole: requesterRole,
        recipientName: 'Justice City Support',
        recipientRole: 'support',
        subject: name,
        initialMessage: initialMessage,
        conversationScope: 'service',
        serviceCode: code.isEmpty ? null : code,
      );

      if (!context.mounted) return;
      context.go('/chat/$convoId');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start service chat: $e')),
      );
    }
  }
}

Future<String?> _promptToken(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Open provider package'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Token',
          hintText: 'Paste provider package token',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          child: const Text('Open'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
