import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/verification_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verification = ref.watch(verificationStatusProvider);
    final me = ref.watch(meProvider);

    final user = me.asData?.value;
    final role = (user?.role ?? '').trim().toLowerCase();
    final isOperator =
        role == 'admin' || role == 'agent' || role == 'seller' || role == 'owner';
    final verified = verification.maybeWhen(
      data: (s) => s?.isVerified == true,
      orElse: () => false,
    );
    final displayName = (user?.fullName ?? '').trim().isNotEmpty
        ? (user!.fullName ?? '').trim()
        : ((user?.email ?? '').trim().isNotEmpty
            ? (user!.email ?? '').split('@').first
            : 'Member');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      onLogout: () => ref.read(authRepositoryProvider).signOut(),
                    ),
                    const SizedBox(height: 12),
                    _HeroCard(
                      displayName: displayName,
                      roleLabel: _formatRole(role),
                      verification: verification,
                      onVerifyTap: () => context.go('/verify'),
                    ),
                    const SizedBox(height: 12),
                    _TrustStrip(
                      verified: verified,
                      isOperator: isOperator,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate.fixed([
                  _QuickActionCard(
                    title: 'Verify Account',
                    subtitle: 'OTP + Smile ID',
                    icon: Icons.verified_user_outlined,
                    onTap: () => context.go('/verify'),
                  ),
                  _QuickActionCard(
                    title: 'Services',
                    subtitle: 'Survey, valuation, checks',
                    icon: Icons.design_services_outlined,
                    onTap: () => context.go('/services'),
                  ),
                  _QuickActionCard(
                    title: 'Profile',
                    subtitle: 'Personal details',
                    icon: Icons.person_outline,
                    onTap: () => context.go('/profile'),
                  ),
                  _QuickActionCard(
                    title: 'Apply for Hiring',
                    subtitle: 'Partner onboarding',
                    icon: Icons.work_outline,
                    onTap: () => context.go('/hiring'),
                  ),
                  _QuickActionCard(
                    title: 'Request Callback',
                    subtitle: 'Support follow-up',
                    icon: Icons.phone_in_talk_outlined,
                    onTap: () => context.go('/request-callback'),
                  ),
                  _QuickActionCard(
                    title: 'Schedule Tour',
                    subtitle: 'Book property visit',
                    icon: Icons.event_available_outlined,
                    onTap: () => context.go('/schedule-tour'),
                  ),
                  _QuickActionCard(
                    title: 'Provider Package',
                    subtitle: 'Open token link',
                    icon: Icons.link_outlined,
                    onTap: () async {
                      final token = await _askToken(context);
                      if (token != null && token.trim().isNotEmpty && context.mounted) {
                        context.go('/provider-package/${Uri.encodeComponent(token.trim())}');
                      }
                    },
                  ),
                  _QuickActionCard(
                    title: 'Marketplace',
                    subtitle: 'Listings and activity',
                    icon: Icons.apartment_outlined,
                    onTap: verified ? () => context.go('/dashboard') : () => context.go('/verify'),
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.08,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Text(
                  'Workspace',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _WorkspaceCard(
                    title: 'Listings',
                    subtitle: isOperator
                        ? 'Create and manage properties'
                        : 'Available to admin, agent, seller, owner',
                    icon: Icons.home_work_outlined,
                    enabled: verified && isOperator,
                    onTap: (verified && isOperator) ? () => context.go('/listings') : null,
                  ),
                  const SizedBox(height: 10),
                  _WorkspaceCard(
                    title: 'Chat',
                    subtitle: 'Conversations and transaction updates',
                    icon: Icons.chat_bubble_outline,
                    enabled: verified,
                    onTap: verified ? () => context.go('/chat') : null,
                  ),
                  const SizedBox(height: 10),
                  _WorkspaceCard(
                    title: 'Dashboard',
                    subtitle: 'Role-based operations center',
                    icon: Icons.space_dashboard_outlined,
                    enabled: verified,
                    onTap: verified ? () => context.go('/dashboard') : null,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRole(String role) {
  if (role.isEmpty) return 'Member';
  return role[0].toUpperCase() + role.substring(1);
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                height: 30,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Text(
                    'JUSTICE CITY',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Real estate trust and verification',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.displayName,
    required this.roleLabel,
    required this.verification,
    required this.onVerifyTap,
  });

  final String displayName;
  final String roleLabel;
  final AsyncValue verification;
  final VoidCallback onVerifyTap;

  @override
  Widget build(BuildContext context) {
    final verified = verification.maybeWhen(
      data: (s) => s?.isVerified == true,
      orElse: () => false,
    );
    final loading = verification.isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFFCBD5E1),
                          ),
                    ),
                  ],
                ),
              ),
              _StatusPill(verified: verified, loading: loading),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            loading
                ? 'Checking verification status...'
                : verified
                    ? 'Account verified. All protected workflows are unlocked.'
                    : 'Complete verification to unlock listings, chat, and dashboard controls.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFE2E8F0),
                ),
          ),
          if (!verified && !loading) ...[
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: onVerifyTap,
              child: const Text('Start Verification'),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.verified, required this.loading});

  final bool verified;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bg = loading
        ? const Color(0x33FFFFFF)
        : verified
            ? const Color(0x2634D399)
            : const Color(0x26F59E0B);
    final textColor = loading
        ? const Color(0xFFE2E8F0)
        : verified
            ? const Color(0xFF6EE7B7)
            : const Color(0xFFFCD34D);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Text(
        loading ? 'Checking' : (verified ? 'Verified' : 'Pending'),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.65,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: enabled
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  enabled ? Icons.chevron_right : Icons.lock_outline,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip({
    required this.verified,
    required this.isOperator,
  });

  final bool verified;
  final bool isOperator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrustMetric(
              label: 'Access',
              value: verified ? 'Unlocked' : 'Verification needed',
            ),
          ),
          Expanded(
            child: _TrustMetric(
              label: 'Workspace',
              value: isOperator ? 'Operator tools' : 'Client tools',
            ),
          ),
        const Expanded(
          child: _TrustMetric(
            label: 'Support',
            value: 'Live services',
          ),
          ),
        ],
      ),
    );
  }
}

class _TrustMetric extends StatelessWidget {
  const _TrustMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
        ),
      ],
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
