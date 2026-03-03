import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shell/justice_city_shell.dart';
import 'marketplace_mock_data.dart';

const _bg = Color(0xFFF4F7FB);
const _border = Color(0xFFE2E8F0);
const _heading = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _blue = Color(0xFF2563EB);

class PublicAgentRouteArgs {
  const PublicAgentRouteArgs({
    required this.name,
    this.imageUrl,
    this.verified = true,
  });

  final String name;
  final String? imageUrl;
  final bool verified;
}

class PublicAgentProfileScreen extends StatelessWidget {
  const PublicAgentProfileScreen({
    super.key,
    required this.slug,
    this.routeArgs,
  });

  final String slug;
  final PublicAgentRouteArgs? routeArgs;

  @override
  Widget build(BuildContext context) {
    final profile = routeArgs == null
        ? marketplacePublicAgentProfileBySlug(slug)
        : marketplacePublicAgentProfileFor(
            name: routeArgs!.name,
            imageUrl: routeArgs!.imageUrl,
            verified: routeArgs!.verified,
          );

    return JusticeCityShell(
      currentPath: '/home',
      backgroundColor: _bg,
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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          const Center(
            child: Text(
              'Agent Public Profile',
              style: TextStyle(
                color: _heading,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xFFF8FAFC),
                    image: DecorationImage(
                      image: NetworkImage(profile.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              profile.name,
                              style: const TextStyle(
                                color: _heading,
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (profile.verified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_outlined, size: 16, color: _blue),
                                  SizedBox(width: 6),
                                  Text(
                                    'Verified Agent',
                                    style: TextStyle(color: _blue, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile.bio,
                        style: const TextStyle(color: _muted, height: 1.55, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _metricCard(
            title: 'Sales Rating',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.salesRating.toStringAsFixed(1),
                  style: const TextStyle(color: _heading, fontSize: 32, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) => const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _metricCard(
            title: 'Reviews',
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: Color(0xFF16A34A), size: 32),
                const SizedBox(width: 12),
                Text(
                  '${profile.reviewCount}',
                  style: const TextStyle(color: _heading, fontSize: 32, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _metricCard(
            title: 'Closed Deals',
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded, color: _blue, size: 32),
                const SizedBox(width: 12),
                Text(
                  '${profile.closedDealsCount}',
                  style: const TextStyle(color: _heading, fontSize: 32, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Recent Deals',
            child: Column(
              children: profile.recentDeals
                  .map((deal) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _dealTile(deal),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Closed Deals',
            child: Column(
              children: profile.closedDeals
                  .map((deal) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _closedDealTile(deal),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          _sectionCard(
            title: 'Latest Reviews',
            child: Column(
              children: profile.latestReviews
                  .map((review) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _reviewTile(review),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          const JusticeCityFooter(),
        ],
      ),
    );
  }

  Widget _metricCard({required String title, required Widget child}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: _muted, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: _heading, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _dealTile(MarketplaceAgentDeal deal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.title,
            style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(deal.location, style: const TextStyle(color: _muted, fontSize: 15)),
          const SizedBox(height: 8),
          Text(deal.priceLabel, style: const TextStyle(color: _heading, fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _closedDealTile(MarketplaceAgentDeal deal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              if ((deal.statusLabel ?? '').isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Text(
                    deal.statusLabel!,
                    style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(deal.location, style: const TextStyle(color: _muted, fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.priceLabel,
                  style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              if ((deal.dateLabel ?? '').isNotEmpty) ...[
                const Icon(Icons.schedule_outlined, color: _muted, size: 18),
                const SizedBox(width: 6),
                Text(deal.dateLabel!, style: const TextStyle(color: _muted, fontSize: 15)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(MarketplaceAgentReview review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewer,
                  style: const TextStyle(color: _heading, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              Text(review.dateLabel, style: const TextStyle(color: _muted, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(
                5,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 24),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(color: _heading, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: const TextStyle(color: _muted, fontSize: 16, height: 1.55)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}
