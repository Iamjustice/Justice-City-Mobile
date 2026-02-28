import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/me_provider.dart';
import '../../state/repositories_providers.dart';
import '../../state/session_provider.dart';

const _shellBg = Color(0xFFF4F7FB);
const _shellBorder = Color(0xFFE2E8F0);
const _shellHeading = Color(0xFF0F172A);
const _shellMuted = Color(0xFF64748B);
const _shellBlue = Color(0xFF2563EB);

class JusticeCityShell extends ConsumerWidget {
  const JusticeCityShell({
    super.key,
    required this.currentPath,
    required this.child,
    this.backgroundColor = _shellBg,
    this.actions,
    this.floatingActionButton,
    this.leading,
    this.leadingWidth,
  });

  final String currentPath;
  final Widget child;
  final Color backgroundColor;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? leading;
  final double? leadingWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        toolbarHeight: 78,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: leading,
        leadingWidth: leadingWidth,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => context.go('/home'),
            child: const SizedBox(
              height: 34,
              child: JusticeCityWordmark(),
            ),
          ),
        ),
        actions: [
          ...(actions ?? const <Widget>[]),
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Open menu',
              icon: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF475569),
                size: 34,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 10),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _shellBorder),
        ),
      ),
      endDrawer: _JusticeCityMenu(currentPath: currentPath),
      body: child,
    );
  }
}

class JusticeCityFooter extends StatelessWidget {
  const JusticeCityFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _shellBorder)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 28,
            child: JusticeCityWordmark(),
          ),
          SizedBox(height: 18),
          Text(
            'Restoring trust in real estate through mandatory identity and property verification.',
            style: TextStyle(
              color: _shellMuted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FooterColumn(
                  title: 'Platform',
                  items: [
                    'Marketplace',
                    'Verification',
                    'Pricing',
                    'Hiring',
                  ],
                ),
              ),
              Expanded(
                child: _FooterColumn(
                  title: 'Legal',
                  items: [
                    'Terms of Service',
                    'Privacy Policy',
                    'Escrow Policy',
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          _FooterColumn(
            title: 'Contact',
            items: [
              'contact@justicecityltd.com',
              '+234 906 534 0189',
              'Owerri, Imo, Nigeria',
            ],
          ),
        ],
      ),
    );
  }
}

class JusticeCityWordmark extends StatelessWidget {
  const JusticeCityWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Text(
        'JUSTICE CITY',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _shellHeading,
            ),
      ),
    );
  }
}

class _JusticeCityMenu extends ConsumerWidget {
  const _JusticeCityMenu({required this.currentPath});

  final String currentPath;

  bool _selected(String value) => currentPath == value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final me = ref.watch(meProvider).valueOrNull;
    final role = (me?.role ?? '').trim().toLowerCase();
    final isAdmin = role == 'admin';
    final dashboardPath = isAdmin ? '/admin' : '/dashboard';
    final userLabel = (me?.fullName ?? '').trim().isNotEmpty
        ? me!.fullName!.trim()
        : ((session?.email ?? '').trim().isNotEmpty
            ? session!.email!.trim()
            : 'Guest');
    final initial = userLabel.isNotEmpty ? userLabel.characters.first : 'J';
    final verified = me?.isVerified == true;

    Future<void> navigate(String path) async {
      Navigator.of(context).maybePop();
      if (!context.mounted) return;
      context.go(path);
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.92,
      backgroundColor: _shellBg,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    height: 30,
                    child: JusticeCityWordmark(),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF475569)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _MenuLink(
                label: 'Marketplace',
                selected: _selected('/home'),
                onTap: () => navigate('/home'),
              ),
              _MenuLink(
                label: 'Services',
                selected: _selected('/services'),
                onTap: () => navigate('/services'),
              ),
              _MenuLink(
                label: 'Hiring',
                selected: _selected('/hiring'),
                onTap: () => navigate('/hiring'),
              ),
              if (session != null)
                _MenuLink(
                  label: 'Dashboard',
                  selected:
                      currentPath == '/dashboard' || currentPath == '/admin',
                  onTap: () => navigate(dashboardPath),
                ),
              const SizedBox(height: 16),
              const Divider(color: _shellBorder),
              const SizedBox(height: 18),
              if (session != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        initial.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _shellHeading,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _shellHeading,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            verified ? 'Verified User' : 'Account in progress',
                            style: const TextStyle(
                              color: _shellMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).maybePop();
                    await ref.read(authRepositoryProvider).signOut();
                    if (!context.mounted) return;
                    context.go('/welcome');
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.red),
                  label: const Text('Log out'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Color(0xFFFECACA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else ...[
                OutlinedButton(
                  onPressed: () => navigate('/sign-in'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Log in'),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => navigate('/welcome'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _shellBlue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Create account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuLink extends StatelessWidget {
  const _MenuLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? _shellBlue : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _shellHeading,
          ),
        ),
        const SizedBox(height: 12),
        for (final item in items) ...[
          Text(
            item,
            style: const TextStyle(
              fontSize: 13,
              color: _shellMuted,
              height: 1.7,
            ),
          ),
          if (item != items.last) const SizedBox(height: 4),
        ],
      ],
    );
  }
}
