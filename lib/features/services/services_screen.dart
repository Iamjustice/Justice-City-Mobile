import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/service_offering.dart';
import '../../state/me_provider.dart';
import '../../state/session_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/services_providers.dart';
import '../shell/justice_city_shell.dart';

const _jcPanelBorder = Color(0xFFE2E8F0);
const _jcHeading = Color(0xFF0F172A);
const _jcMuted = Color(0xFF64748B);

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerings = ref.watch(serviceOfferingsProvider);

    return JusticeCityShell(
      currentPath: '/services',
      child: offerings.when(
        data: (items) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh services',
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
            const _ServicesHeroCard(),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const _EmptyStateCard(message: 'No service offerings yet.'),
            ...items.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceOfferingCard(
                  offering: s,
                  onStartChat: () => _startServiceChat(context, ref, s),
                  onOpenPackage: () async {
                    final token = await _promptToken(context);
                    if (token != null && token.isNotEmpty) {
                      if (!context.mounted) return;
                      context.go(
                          '/provider-package/${Uri.encodeComponent(token)}');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            const _ShellCard(
              child: Text(
                'Service chats and provider packages are synchronized with your web dashboard.',
                style: TextStyle(color: _jcMuted),
              ),
            ),
            const JusticeCityFooter(),
          ],
        ),
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: const [
            _ServicesHeroCard(),
            SizedBox(height: 12),
            _ShellCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Loading service offerings...'),
                ],
              ),
            ),
            JusticeCityFooter(),
          ],
        ),
        error: (e, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const _ServicesHeroCard(),
            const SizedBox(height: 12),
            _ShellCard(
              child: Text('Failed to load offerings: $e'),
            ),
            const JusticeCityFooter(),
          ],
        ),
      ),
    );
  }

  Future<void> _startServiceChat(
    BuildContext context,
    WidgetRef ref,
    ServiceOffering offering,
  ) async {
    final session = ref.read(sessionProvider);
    if (session == null) {
      context.go('/auth');
      return;
    }

    String initialMessage;
    final code = offering.code.toLowerCase();
    final name = offering.name;

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
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _jcPanelBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open provider package',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _jcHeading,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Paste the secure token to open a provider package.',
              style: TextStyle(color: _jcMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Token',
                hintText: 'Paste provider package token',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(controller.text.trim()),
                  child: const Text('Open'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  controller.dispose();
  return result;
}

class _ServicesHeroCard extends StatelessWidget {
  const _ServicesHeroCard();

  @override
  Widget build(BuildContext context) {
    return const _ShellCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Services',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Land surveying, valuation, verification, snagging and provider package operations.',
            style: TextStyle(
              fontSize: 16,
              color: _jcMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceOfferingCard extends StatelessWidget {
  const _ServiceOfferingCard({
    required this.offering,
    required this.onStartChat,
    required this.onOpenPackage,
  });

  final ServiceOffering offering;
  final VoidCallback onStartChat;
  final VoidCallback onOpenPackage;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForOffering(offering);
    return _ShellCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _jcHeading),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offering.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _jcHeading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offering.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _jcMuted),
                    ),
                  ],
                ),
              ),
              _CodeTag(code: offering.code),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.payments_outlined, text: offering.price),
              _MetaChip(icon: Icons.timer_outlined, text: offering.turnaround),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onStartChat,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Start service chat'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenPackage,
                  icon: const Icon(Icons.link),
                  label: const Text('Open provider package'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForOffering(ServiceOffering offering) {
    final source = '${offering.icon} ${offering.code}'.toLowerCase();
    if (source.contains('survey')) return Icons.map_outlined;
    if (source.contains('valuation')) return Icons.analytics_outlined;
    if (source.contains('verification')) return Icons.verified_user_outlined;
    if (source.contains('snagging')) return Icons.handyman_outlined;
    return Icons.work_outline;
  }
}

class _ShellCard extends StatelessWidget {
  const _ShellCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: child,
    );
  }
}

class _CodeTag extends StatelessWidget {
  const _CodeTag({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        code.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _jcPanelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _jcMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _jcMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ShellCard(
      child: Text(
        message,
        style: const TextStyle(color: _jcMuted),
      ),
    );
  }
}
