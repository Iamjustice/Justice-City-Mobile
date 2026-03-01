import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/me_provider.dart';
import '../../state/session_provider.dart';
import '../shell/justice_city_shell.dart';
import 'marketplace_mock_data.dart';

const _pageBg = Color(0xFFF4F7FB);
const _panelBorder = Color(0xFFE2E8F0);
const _heading = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _blue = Color(0xFF2563EB);

class MarketplacePropertyDetailsScreen extends ConsumerStatefulWidget {
  const MarketplacePropertyDetailsScreen({
    super.key,
    required this.propertyId,
    this.initial,
  });

  final String propertyId;
  final MarketplaceProperty? initial;

  @override
  ConsumerState<MarketplacePropertyDetailsScreen> createState() =>
      _MarketplacePropertyDetailsScreenState();
}

class _MarketplacePropertyDetailsScreenState
    extends ConsumerState<MarketplacePropertyDetailsScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.initial ?? marketplacePropertyById(widget.propertyId);
    final session = ref.watch(sessionProvider);
    final me = ref.watch(meProvider).valueOrNull;
    final isVerified = me?.isVerified == true;

    if (property == null) {
      return JusticeCityShell(
        currentPath: '/home',
        backgroundColor: _pageBg,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_rounded, color: _heading),
        ),
        leadingWidth: 56,
        child: const Center(
          child: Text(
            'Property not found.',
            style: TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final images = property.galleryUrls.isEmpty ? [property.imageUrl] : property.galleryUrls;

    return JusticeCityShell(
      currentPath: '/home',
      backgroundColor: _pageBg,
      leading: IconButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        icon: const Icon(Icons.arrow_back_rounded, color: _heading),
      ),
      leadingWidth: 56,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          Container(
            height: 440,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _heading,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (value) => setState(() => _pageIndex = value),
                  itemBuilder: (_, index) => Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: _heading),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Color(0x14000000), Color(0xB0000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: _badge(property.type.toUpperCase(), Colors.white, _heading),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: _badge('Verified', _blue, Colors.white, icon: Icons.verified_outlined),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.54),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Text(
                            _ngn(property.price),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => setState(() => _saved = !_saved),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _heading,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        icon: Icon(
                          _saved ? Icons.favorite : Icons.favorite_border,
                          color: _saved ? Colors.red : _heading,
                        ),
                        label: Text(_saved ? 'Saved' : 'Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _panelBorder),
              ),
              child: Text(
                '${_pageIndex + 1} / ${images.length}',
                style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            property.title,
            style: const TextStyle(color: _heading, fontSize: 32, fontWeight: FontWeight.w800, height: 1.05),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: _blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(property.location, style: const TextStyle(color: _muted, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _panelBorder),
            ),
            child: Row(
              children: [
                Expanded(child: _stat('Bedrooms', '${property.bedrooms}', Icons.bed_outlined)),
                _divider(),
                Expanded(child: _stat('Bathrooms', '${property.bathrooms}', Icons.bathtub_outlined)),
                _divider(),
                Expanded(child: _stat('Square Ft', '${property.sqft}', Icons.open_in_full_outlined)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About this property',
                  style: TextStyle(color: _heading, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Text(
                  property.description,
                  style: const TextStyle(color: Color(0xFF334155), height: 1.7, fontSize: 16),
                ),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FeatureChip(label: '24/7 Power'),
                    _FeatureChip(label: 'Gated Security'),
                    _FeatureChip(label: 'Treated Water'),
                    _FeatureChip(label: 'Parking Space'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _heading,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: Color(0xFF4ADE80)),
                    SizedBox(width: 10),
                    Text(
                      'Verified Documentation',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isVerified
                      ? 'Document previews follow the verification workflow for this property.'
                      : 'Full document access is restricted to verified users only.',
                  style: const TextStyle(color: Color(0xFF94A3B8), height: 1.5),
                ),
                const SizedBox(height: 18),
                ...['Certificate of Occupancy', 'Governor\'s Consent', 'Survey Plan']
                    .map((title) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _docTile(title),
                        )),
                if (!isVerified)
                  _lockNotice('Full document access is restricted to verified users only.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 32, backgroundImage: NetworkImage(property.agent.imageUrl)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(property.agent.name, style: const TextStyle(color: _heading, fontSize: 20, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(property.agent.verified ? 'Verified Agent' : 'Agent profile', style: const TextStyle(color: _muted)),
                          const SizedBox(height: 2),
                          const Text('Tap to view agent profile', style: TextStyle(color: _blue, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (property.agent.verified)
                      const Icon(Icons.verified_user_outlined, color: Color(0xFF16A34A)),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () => session == null ? context.go('/sign-in') : context.go('/chat'),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(session == null ? 'Sign in to Chat' : 'Chat with Agent'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.go('/request-callback'),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Request Callback'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: const BorderSide(color: _heading, width: 1.6),
                    foregroundColor: _heading,
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => context.go('/schedule-tour'),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Schedule Tour'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: _heading,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Your identity is protected. Contact details are only shared once mutual verification is complete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
                ),
              ],
            ),
          ),
          const JusticeCityFooter(),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _panelBorder),
        ),
        child: child,
      );

  Widget _stat(String label, String value, IconData icon) => Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _blue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _heading, fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _divider() => Container(width: 1, height: 48, color: _panelBorder);

  Widget _badge(String label, Color background, Color foreground, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 14),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _docTile(String title) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x22FFFFFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0x1A60A5FA),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.description_outlined, color: Color(0xFF60A5FA)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Verified by Justice City Admin', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _lockNotice(String message) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0x1AF59E0B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x33F59E0B)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFFFCD34D)),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Color(0xFFFDE68A), height: 1.4))),
          ],
        ),
      );
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _panelBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 14, color: _blue),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

String _ngn(int value) {
  const naira = '\u20A6';
  final digits = value.toString();
  final buffer = StringBuffer(naira);
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}

