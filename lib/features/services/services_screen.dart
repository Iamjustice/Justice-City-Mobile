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
            const _ServicesHeroCard(),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const _EmptyStateCard(message: 'No service offerings yet.'),
            ...items.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceOfferingCard(
                  offering: s,
                  onBook: () => _startServiceChat(context, ref, s),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ShellCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Already have a provider package?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _jcHeading,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Open a secure provider package token from support.',
                          style: TextStyle(color: _jcMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final token = await _promptToken(context);
                      if (token != null && token.isNotEmpty) {
                        if (!context.mounted) return;
                        context.go('/provider-package/${Uri.encodeComponent(token)}');
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('Open'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _QualityGuaranteeCard(),
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
            const SizedBox(height: 16),
            const _QualityGuaranteeCard(),
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
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Access high-intent property services from verified professionals. All our surveyors and valuers are vetted by Justice City for maximum trust.',
            style: TextStyle(
              fontSize: 16,
              color: _jcMuted,
              height: 1.7,
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
    required this.onBook,
  });

  final ServiceOffering offering;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForOffering(offering);
    return _ShellCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: 120,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FBFF),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(64),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -40),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 30),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            offering.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _jcHeading,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            offering.description,
            style: const TextStyle(
              color: _jcMuted,
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          _ServiceInfoRow(
            icon: Icons.schedule_outlined,
            color: const Color(0xFF3B82F6),
            label: 'Delivery: ${offering.turnaround}',
          ),
          const SizedBox(height: 12),
          const _ServiceInfoRow(
            icon: Icons.verified_user_outlined,
            color: Color(0xFF22C55E),
            label: 'Vetted Professionals Only',
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STARTS FROM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offering.price,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _jcHeading,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: onBook,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Book Now'),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            ),
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

class _QualityGuaranteeCard extends StatelessWidget {
  const _QualityGuaranteeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B173A),
            Color(0xFF091633),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              color: Colors.white.withValues(alpha: 0.04),
            ),
            child: const Text(
              'JUSTICE CITY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'The Justice City Quality Guarantee',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Every service report is audited by our internal team before delivery. If a surveyor is not verified, they are not on our platform. Period.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 16,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Learn about Vetting'),
          ),
        ],
      ),
    );
  }
}

class _ServiceInfoRow extends StatelessWidget {
  const _ServiceInfoRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _jcMuted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
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
