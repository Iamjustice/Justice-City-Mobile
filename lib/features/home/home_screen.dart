import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../env.dart';
import '../../state/me_provider.dart';
import '../../state/saved_properties_provider.dart';
import '../../state/session_provider.dart';
import '../marketplace/marketplace_mock_data.dart';
import '../marketplace/public_agent_profile_screen.dart';
import '../shell/justice_city_shell.dart';

const _border = Color(0xFFE2E8F0);
const _heading = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _blue = Color(0xFF2563EB);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();
  String _tab = 'Buy';
  bool _showFilters = false;
  int _visible = 8;
  String _priceFilter = 'Any';
  String _bedFilter = 'Any';
  VideoPlayerController? _heroVideo;

  @override
  void initState() {
    super.initState();
    _initHeroVideo();
  }

  @override
  void dispose() {
    _heroVideo?.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _initHeroVideo() async {
    final source = Env.homeHeroVideoUrl.trim();
    if (source.isEmpty) {
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(source));
    try {
      _heroVideo = controller;
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.initialize();
      await controller.play();
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      await controller.dispose();
      _heroVideo = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final me = ref.watch(meProvider).valueOrNull;
    final dashboardPath =
        (me?.role ?? '').trim().toLowerCase() == 'admin' ? '/admin' : '/dashboard';
    final query = _search.text.trim().toLowerCase();
    final items = marketplaceProperties.where((property) {
      final typeMatch = _tab == 'Sell'
          ? false
          : _tab == 'Buy'
              ? property.type == 'Sale'
              : property.type == 'Rent';
      final queryMatch = query.isEmpty ||
          property.title.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query);
      final priceMatch = switch (_priceFilter) {
        'Under ₦10M' => property.price < 10000000,
        '₦10M - ₦50M' => property.price >= 10000000 && property.price <= 50000000,
        '₦50M - ₦200M' => property.price > 50000000 && property.price <= 200000000,
        'Above ₦200M' => property.price > 200000000,
        _ => true,
      };
      final bedMatch = switch (_bedFilter) {
        '1+' => property.bedrooms >= 1,
        '2+' => property.bedrooms >= 2,
        '3+' => property.bedrooms >= 3,
        '4+' => property.bedrooms >= 4,
        _ => true,
      };
      return typeMatch && queryMatch && priceMatch && bedMatch;
    }).toList();

    return JusticeCityShell(
      currentPath: '/home',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _hero(),
          _stats(),
          _sectionHeader(
            title: 'Featured Properties',
            subtitle: 'Curated listings with verified documentation.',
            actionLabel: 'View All',
            onAction: () => setState(
              () => _visible = (_visible + 8).clamp(8, marketplaceProperties.length),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                if (_tab == 'Sell')
                  _infoCard(
                    title: 'List and sell verified property',
                    message:
                        'Selling is routed through your dashboard so listings, documents, and verification stay controlled.',
                    button: FilledButton(
                      onPressed: () => context.go(session != null ? dashboardPath : '/sign-in'),
                      child: Text(session != null ? 'Open Dashboard' : 'Sign in to continue'),
                    ),
                  )
                else if (items.isEmpty)
                  _infoCard(
                    title: 'No results',
                    message:
                        'No properties match the current search yet. Adjust your search or filters to see more listings.',
                  )
                else
                  ...items.take(_visible).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _PropertyCard(
                            property: item,
                            onTap: () => context.go('/property/${item.id}'),
                          ),
                        ),
                      ),
                if (_tab != 'Sell' && _visible < items.length)
                  OutlinedButton(
                    onPressed: () => setState(
                      () => _visible = (_visible + 8).clamp(8, items.length),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(220, 50),
                      foregroundColor: _blue,
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text('View More Properties'),
                  ),
              ],
            ),
          ),
          _sectionHeader(
            title: 'Professional Services',
            subtitle: 'Verified experts to assist with your real estate journey.',
            actionLabel: 'View All Services',
            onAction: () => context.go('/services'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: marketplaceServices
                  .map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _ServiceCard(service: service),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 32, 22, 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF12285A)],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Are you a Real Estate Agent?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the elite circle of verified agents. Build trust instantly with your clients by showing your verified badge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE2E8F0), height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/hiring'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _heading,
                    ),
                    child: const Text('Apply as a Professional'),
                  ),
                ],
              ),
            ),
          ),
          const JusticeCityFooter(),
        ],
      ),
    );
  }

  Widget _hero() {
    return SizedBox(
      height: _showFilters ? 690 : 560,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_heroVideo?.value.isInitialized ?? false)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _heroVideo!.value.size.width,
                height: _heroVideo!.value.size.height,
                child: VideoPlayer(_heroVideo!),
              ),
            )
          else
            Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1600&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B4D7B)),
                ),
                Container(color: const Color(0x660B4D7B)),
              ],
            ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x880B4D7B), Color(0xAA0F172A), Color(0xDD0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
            child: Column(
              children: [
                const SizedBox(height: 12),
                _pill('THE TRUST-FIRST MARKETPLACE'),
                const SizedBox(height: 22),
                const Text(
                  'Find Your Home.\nVerify The Truth.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, height: 1.15),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Justice City is the only real estate platform where every user and every property is verified. No fakes. No scams. Just real deals.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFE2E8F0), height: 1.6),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                            hintText: 'Search by location, price, or property type...',
                            hintStyle: const TextStyle(color: _muted),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: _heroBorder(),
                            enabledBorder: _heroBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _showFilters = !_showFilters),
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Filters'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(112, 52),
                          backgroundColor: _showFilters ? _heading : Colors.white,
                          foregroundColor: _showFilters ? Colors.white : _heading,
                          side: BorderSide(color: _showFilters ? _heading : _border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _priceFilter,
                          decoration: const InputDecoration(labelText: 'Price Range', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Any', child: Text('Any')),
                            DropdownMenuItem(value: 'Under ₦10M', child: Text('Under ₦10M')),
                            DropdownMenuItem(value: '₦10M - ₦50M', child: Text('₦10M - ₦50M')),
                            DropdownMenuItem(value: '₦50M - ₦200M', child: Text('₦50M - ₦200M')),
                            DropdownMenuItem(value: 'Above ₦200M', child: Text('Above ₦200M')),
                          ],
                          onChanged: (value) => setState(() => _priceFilter = value ?? 'Any'),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: ['Any', '1+', '2+', '3+', '4+']
                              .map(
                                (value) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: value == '4+' ? 0 : 8),
                                    child: OutlinedButton(
                                      onPressed: () => setState(() => _bedFilter = value),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: _bedFilter == value ? _blue : Colors.white,
                                        foregroundColor: _bedFilter == value ? Colors.white : _heading,
                                        side: BorderSide(color: _bedFilter == value ? _blue : _border),
                                      ),
                                      child: Text(value),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  child: Row(
                    children: ['Buy', 'Rent', 'Sell']
                        .map(
                          (value) => Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tab = value),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _tab == value ? _blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  value,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => setState(() => _visible = 8),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats() {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value, style: const TextStyle(color: _heading, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(label.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        );
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        children: [
          Row(children: [stat('2,400+', 'Verified Listings'), _divider(), stat('100%', 'Identity Checks')]),
          const SizedBox(height: 14),
          Row(children: [stat('0.0%', 'Fraud Rate'), _divider(), stat('500+', 'Active Agents')]),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: _heading, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: _muted)),
              ],
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String message,
    Widget? button,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: _muted, height: 1.6)),
          if (button != null) ...[
            const SizedBox(height: 18),
            button,
          ],
        ],
      ),
    );
  }

  OutlineInputBorder _heroBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      );

  Widget _divider() => Container(width: 1, height: 72, color: _border);

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFFC7D2FE), fontWeight: FontWeight.w700, fontSize: 12)),
      );
}

class _PropertyCard extends ConsumerWidget {
  const _PropertyCard({required this.property, required this.onTap});

  final MarketplaceProperty property;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final property = this.property;
    final isSaved = ref.watch(isListingSavedProvider(property.id));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: const [BoxShadow(color: Color(0x140F172A), blurRadius: 16, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(property.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE2E8F0))),
                    Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0x55000000), Color(0xB3000000)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                    Positioned(top: 14, left: 14, child: _badge(property.type.toUpperCase(), Colors.white, _heading)),
                    Positioned(top: 14, right: 14, child: _badge('Verified', _blue, Colors.white, icon: Icons.verified_outlined)),
                    Positioned(
                      right: 14,
                      bottom: 18,
                      child: InkWell(
                        onTap: () => ref
                            .read(savedListingIdsProvider.notifier)
                            .toggle(property.id),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.36))),
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(left: 16, bottom: 18, child: Text(_ngn(property.price), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, style: const TextStyle(color: _blue, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [const Icon(Icons.location_on_outlined, size: 18, color: _muted), const SizedBox(width: 4), Expanded(child: Text(property.location, style: const TextStyle(color: _muted)))]),
                  const SizedBox(height: 12),
                  const Divider(color: _border),
                  const SizedBox(height: 12),
                  Row(children: [
                    _metric(Icons.bed_outlined, '${property.bedrooms}', 'Beds'),
                    const SizedBox(width: 16),
                    _metric(Icons.bathtub_outlined, '${property.bathrooms}', 'Baths'),
                    const SizedBox(width: 16),
                    _metric(Icons.open_in_full_outlined, '${property.sqft}', 'sqft'),
                  ]),
                  const SizedBox(height: 14),
                  const Divider(color: _border),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => context.go(
                      '/agents/${marketplaceAgentSlug(property.agent.name)}',
                      extra: PublicAgentRouteArgs(
                        name: property.agent.name,
                        imageUrl: property.agent.imageUrl,
                        verified: property.agent.verified,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(property.agent.imageUrl)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(property.agent.name, style: const TextStyle(color: _heading, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          const Text('Tap to view agent profile', style: TextStyle(color: _blue, fontSize: 12)),
                        ])),
                        if (property.agent.verified)
                          const Icon(Icons.verified_user_outlined, color: Color(0xFF16A34A)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) => Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: _heading, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        ],
      );

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
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final MarketplaceService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: service.tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
            child: Icon(service.icon, color: service.tint),
          ),
          const SizedBox(height: 24),
          Text(service.title, style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text(service.description, style: const TextStyle(color: _muted, height: 1.65)),
          const SizedBox(height: 20),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Request Service', style: TextStyle(color: _blue, fontWeight: FontWeight.w700)),
              SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: _blue),
            ],
          ),
        ],
      ),
    );
  }
}

String _ngn(int value) {
  final digits = value.toString();
  final buffer = StringBuffer('₦');
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}
