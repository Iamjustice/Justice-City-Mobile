import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/listing.dart';
import '../../state/me_provider.dart';
import '../../state/session_provider.dart';
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
  int _visible = 4;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final me = ref.watch(meProvider).valueOrNull;
    final dashboardPath =
        (me?.role ?? '').trim().toLowerCase() == 'admin' ? '/admin' : '/dashboard';
    final query = _search.text.trim().toLowerCase();
    final items = _marketplace.where((e) {
      final typeMatch = _tab == 'Sell'
          ? true
          : _tab == 'Buy'
              ? e.type == 'Sale'
              : e.type == 'Rent';
      final queryMatch = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          e.location.toLowerCase().contains(query);
      return typeMatch && queryMatch;
    }).toList();

    return JusticeCityShell(
      currentPath: '/home',
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHero(),
          _buildStats(),
          _buildSectionHeader(
            context,
            title: 'Featured Properties',
            subtitle: 'Curated listings with verified documentation.',
            actionLabel: 'View All',
            onAction: () => setState(
              () => _visible = (_visible + 4).clamp(4, _marketplace.length),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                if (_tab == 'Sell')
                  _sellCard(context, session != null, dashboardPath)
                else if (items.isEmpty)
                  _infoCard(
                    'No properties match the current search yet. Adjust your filters to see more listings.',
                  )
                else
                  ...items.take(_visible).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _MarketplaceCard(
                            item: item,
                            onTap: () => context.go(
                              '/property/${item.id}',
                              extra: item.toListing(),
                            ),
                          ),
                        ),
                      ),
                if (_tab != 'Sell' && _visible < items.length)
                  OutlinedButton(
                    onPressed: () => setState(
                      () => _visible = (_visible + 4).clamp(4, items.length),
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
          _buildSectionHeader(
            context,
            title: 'Professional Services',
            subtitle: 'Verified experts to assist with your real estate journey.',
            actionLabel: 'View All Services',
            onAction: () => context.go('/services'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: _services
                  .map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _ServiceCard(
                        item: service,
                        onTap: () => context.go('/services'),
                      ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join the elite circle of verified agents. Build trust instantly with your clients by showing your verified badge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE2E8F0), height: 1.6),
                  ),
                  const SizedBox(height: 26),
                  FilledButton(
                    onPressed: () => context.go('/hiring'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _heading,
                      minimumSize: const Size(280, 52),
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

  Widget _buildHero() {
    return SizedBox(
      height: 520,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1511818966892-d7d671e672a2?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0B4D7B)),
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
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              children: [
                const SizedBox(height: 16),
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                      hintText: 'Search by location, price, or property type...',
                      hintStyle: const TextStyle(color: _muted),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _border),
                      ),
                    ),
                  ),
                ),
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
                        .map((value) => Expanded(
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
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
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

  Widget _buildStats() {
    Widget stat(String value, String label) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(value, style: const TextStyle(color: _heading, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(label.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
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

  Widget _buildSectionHeader(
    BuildContext context, {
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

  Widget _sellCard(BuildContext context, bool signedIn, String dashboardPath) {
    return _infoCard(
      'Selling is routed through your dashboard so listings, documents, and verification stay controlled.',
      button: FilledButton(
        onPressed: () => context.go(signedIn ? dashboardPath : '/sign-in'),
        style: FilledButton.styleFrom(backgroundColor: _blue, minimumSize: const Size(double.infinity, 48)),
        child: Text(signedIn ? 'Open Dashboard' : 'Sign in to continue'),
      ),
      title: 'List and sell verified property',
    );
  }

  Widget _infoCard(String message, {String? title, Widget? button}) {
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
          if (title != null) ...[
            Text(title, style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
          ],
          Text(message, style: const TextStyle(color: _muted, height: 1.6)),
          if (button != null) ...[
            const SizedBox(height: 18),
            button,
          ],
        ],
      ),
    );
  }

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

class _MarketplaceCard extends StatefulWidget {
  const _MarketplaceCard({required this.item, required this.onTap});

  final _MarketplaceItem item;
  final VoidCallback onTap;

  @override
  State<_MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<_MarketplaceCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: widget.onTap,
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
                    Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFE2E8F0))),
                    Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0x55000000), Color(0xB3000000)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
                    Positioned(top: 14, left: 14, child: _topBadge(item.type.toUpperCase())),
                    Positioned(top: 14, right: 14, child: _verifiedBadge()),
                    Positioned(
                      right: 14,
                      bottom: 18,
                      child: InkWell(
                        onTap: () => setState(() => _saved = !_saved),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.36))),
                          child: Icon(_saved ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(left: 16, bottom: 18, child: Text(_ngn(item.price), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(color: _blue, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [const Icon(Icons.location_on_outlined, size: 18, color: _muted), const SizedBox(width: 4), Expanded(child: Text(item.location, style: const TextStyle(color: _muted)))]),
                  const SizedBox(height: 12),
                  const Divider(color: _border),
                  const SizedBox(height: 12),
                  Row(children: [
                    _metric(Icons.bed_outlined, '${item.bedrooms}', 'Beds'),
                    const SizedBox(width: 16),
                    _metric(Icons.bathtub_outlined, '${item.bathrooms}', 'Baths'),
                    const SizedBox(width: 16),
                    _metric(Icons.open_in_full_outlined, '${item.sqft}', 'sqft'),
                  ]),
                  const SizedBox(height: 14),
                  const Divider(color: _border),
                  const SizedBox(height: 14),
                  Row(children: [
                    CircleAvatar(radius: 20, backgroundImage: NetworkImage(item.agentAvatarUrl)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.agentName, style: const TextStyle(color: _heading, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      const Text('Tap to view agent profile', style: TextStyle(color: _blue, fontSize: 12)),
                    ])),
                    const Icon(Icons.verified_user_outlined, color: Color(0xFF16A34A)),
                  ]),
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

  Widget _topBadge(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: const TextStyle(color: _heading, fontWeight: FontWeight.w700, fontSize: 12)),
      );

  Widget _verifiedBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(999)),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.verified_outlined, color: Colors.white, size: 14),
          SizedBox(width: 4),
          Text('Verified', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item, required this.onTap});

  final _ServiceItem item;
  final VoidCallback onTap;

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
            decoration: BoxDecoration(color: item.tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18)),
            child: Icon(item.icon, color: item.tint),
          ),
          const SizedBox(height: 24),
          Text(item.title, style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Text(item.description, style: const TextStyle(color: _muted, height: 1.65)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: _blue),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Request Service', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded),
            ]),
          ),
        ],
      ),
    );
  }
}

String _ngn(int value) {
  final s = value.toString();
  final out = StringBuffer('₦');
  for (var i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    out.write(s[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) out.write(',');
  }
  return out.toString();
}

class _MarketplaceItem {
  const _MarketplaceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
    required this.imageUrl,
    required this.agentName,
    required this.agentAvatarUrl,
    required this.description,
  });

  final String id;
  final String title;
  final int price;
  final String location;
  final String type;
  final int bedrooms;
  final int bathrooms;
  final int sqft;
  final String imageUrl;
  final String agentName;
  final String agentAvatarUrl;
  final String description;

  Listing toListing() => Listing(
        id: id,
        title: title,
        description: description,
        listingType: type,
        location: location,
        price: price.toString(),
        coverImageUrl: imageUrl,
      );
}

class _ServiceItem {
  const _ServiceItem(this.title, this.description, this.icon, this.tint);

  final String title;
  final String description;
  final IconData icon;
  final Color tint;
}

const _marketplace = [
  _MarketplaceItem(
    id: 'prop_1',
    title: 'Luxury Apartment in Victoria Island',
    price: 150000000,
    location: '1024 Adetokunbo Ademola, VI, Lagos',
    type: 'Sale',
    bedrooms: 3,
    bathrooms: 3,
    sqft: 2200,
    imageUrl:
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?auto=format&fit=crop&q=80&w=1000',
    agentName: 'Sarah Okon',
    agentAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Sarah',
    description:
        'A stunning 3-bedroom apartment with ocean view, 24/7 power, and maximum security. Verified title.',
  ),
  _MarketplaceItem(
    id: 'prop_5',
    title: 'Modern Apartment Owerri',
    price: 35000000,
    location: 'Wetheral Road, Owerri, Imo State',
    type: 'Sale',
    bedrooms: 2,
    bathrooms: 2,
    sqft: 1200,
    imageUrl:
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&q=80&w=1000',
    agentName: 'Ikenna Uzor',
    agentAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Ikenna',
    description:
        'Cozy 2-bedroom apartment in a secure neighborhood in Owerri.',
  ),
  _MarketplaceItem(
    id: 'prop_6',
    title: 'Luxury Villa Port Harcourt',
    price: 120000000,
    location: 'GRA Phase 2, Port Harcourt, Rivers State',
    type: 'Sale',
    bedrooms: 5,
    bathrooms: 6,
    sqft: 4500,
    imageUrl:
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&q=80&w=1000',
    agentName: 'Blessing Amadi',
    agentAvatarUrl:
        'https://api.dicebear.com/7.x/avataaars/png?seed=Blessing',
    description: 'Massive 5-bedroom villa with pool and cinema room.',
  ),
  _MarketplaceItem(
    id: 'prop_11',
    title: 'Office Complex Abuja',
    price: 850000000,
    location: 'Central Business District, Abuja',
    type: 'Sale',
    bedrooms: 0,
    bathrooms: 10,
    sqft: 12000,
    imageUrl:
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=1000',
    agentName: 'Ibrahim Lawal',
    agentAvatarUrl:
        'https://api.dicebear.com/7.x/avataaars/png?seed=Ibrahim',
    description: "Full office building in Abuja's CBD.",
  ),
  _MarketplaceItem(
    id: 'prop_2',
    title: 'Modern Duplex in Lekki Phase 1',
    price: 8500000,
    location: 'Block 4, Admiralty Way, Lekki',
    type: 'Rent',
    bedrooms: 4,
    bathrooms: 5,
    sqft: 3500,
    imageUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=1000',
    agentName: 'Emmanuel Kalu',
    agentAvatarUrl:
        'https://api.dicebear.com/7.x/avataaars/png?seed=Emmanuel',
    description:
        'Newly built duplex with BQ. Fully serviced estate with gym and pool.',
  ),
  _MarketplaceItem(
    id: 'prop_13',
    title: 'Apartment Owerri North',
    price: 2500000,
    location: 'Owerri North, Imo State',
    type: 'Rent',
    bedrooms: 3,
    bathrooms: 3,
    sqft: 1800,
    imageUrl:
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&q=80&w=1000',
    agentName: 'Chidi Igwe',
    agentAvatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Chidi',
    description: 'Modern 3-bedroom apartment for rent.',
  ),
];

const _services = [
  _ServiceItem('Land Surveying', 'Accurate boundary mapping and topographical surveys by licensed professionals.', Icons.explore_outlined, _blue),
  _ServiceItem('Property Valuation', 'Professional appraisal services to determine the true market value of any asset.', Icons.assignment_turned_in_outlined, Color(0xFF16A34A)),
  _ServiceItem('Land Verification', 'Complete document review and physical site inspection for absolute peace of mind.', Icons.shield_outlined, Color(0xFF9333EA)),
];
