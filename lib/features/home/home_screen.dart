import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/repositories_providers.dart';
import '../../state/verification_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verification = ref.watch(verificationStatusProvider);

    final verified = verification.maybeWhen(
      data: (s) => s?.isVerified == true,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Justice City'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: verification.when(
                data: (s) {
                  if (s == null) return const Text('Sign in to continue.');
                  return Row(
                    children: [
                      Icon(
                        s.isVerified ? Icons.verified : Icons.warning_amber_rounded,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.isVerified
                              ? 'Your account is verified.'
                              : 'Your account is not verified yet. Complete verification to unlock chat, listings, and dashboards.',
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (!s.isVerified)
                        ElevatedButton(
                          onPressed: () => context.go('/verify'),
                          child: const Text('Verify'),
                        ),
                    ],
                  );
                },
                loading: () => const Row(
                  children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('Loading verification status...'),
                  ],
                ),
                error: (e, _) => Text('Verification status error: $e'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ListTile(
            title: const Text('Verify account'),
            subtitle: const Text('Email OTP, Phone OTP, Smile ID'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/verify'),
          ),
          const Divider(),

          ListTile(
            title: const Text('Professional services'),
            subtitle: const Text('Surveying, valuation, land verification, etc.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/services'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Open provider package'),
            subtitle: const Text('Use a provider-package token link'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final token = await _askToken(context);
              if (token != null && token.trim().isNotEmpty) {
                context.go('/provider-package/${Uri.encodeComponent(token.trim())}');
              }
            },
          ),
          const Divider(),

          ListTile(
            enabled: verified,
            title: const Text('Listings'),
            subtitle: const Text('Browse / manage listings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: verified ? () => context.go('/listings') : null,
          ),
          ListTile(
            enabled: verified,
            title: const Text('Chat'),
            subtitle: const Text('Conversations & messages'),
            trailing: const Icon(Icons.chevron_right),
            onTap: verified ? () => context.go('/chat') : null,
          ),
          ListTile(
            enabled: verified,
            title: const Text('Dashboard'),
            subtitle: const Text('Agent/Admin dashboard'),
            trailing: const Icon(Icons.chevron_right),
            onTap: verified ? () => context.go('/dashboard') : null,
          ),
        ],
      ),
    );
  }
}

Future<String?> _askToken(BuildContext context) async {
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
