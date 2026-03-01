import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
import '../features/marketplace/marketplace_property_details_screen.dart';
import '../features/listings/listings_screen.dart';
import '../features/listings/listing_details_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/chat/chat_thread_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/verify/verify_screen.dart';
import '../features/transactions/transaction_center_screen.dart';
import '../features/services/services_screen.dart';
import '../features/services/provider_package_screen.dart';
import '../features/parity/web_parity_screens.dart';
import '../domain/models/listing.dart';
import '../domain/models/chat_conversation.dart';
import '../state/session_provider.dart';
import '../state/verification_provider.dart';
import '../state/me_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: ref.watch(routerRefreshProvider),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final me = ref.read(meProvider);
      final isAdminUser = me.maybeWhen(
        data: (u) => (u?.role ?? '').trim().toLowerCase() == 'admin',
        orElse: () => false,
      );

      final loc = state.matchedLocation;
      final isWelcomeRoute = loc == '/welcome';
      final isSignInRoute = loc == '/sign-in';
      final isAuthRoute = loc == '/auth' || isWelcomeRoute || isSignInRoute;
      final isVerifyRoute = loc == '/verify';
      final isAdminRoute = loc == '/admin';
      final isListingsConsoleRoute = loc == '/listings';
      final isPublicAuthRoute =
          loc == '/' ||
          loc == '/home' ||
          loc == '/services' ||
          loc == '/hiring' ||
          loc.startsWith('/property/') ||
          loc == '/request-callback' ||
          loc == '/schedule-tour' ||
          loc == '/terms-of-service' ||
          loc == '/privacy-policy' ||
          loc == '/escrow-policy' ||
          loc.startsWith('/provider-package/');

      final signedIn = session != null;

      // Auth gate
      if (!signedIn && !isAuthRoute && !isPublicAuthRoute) return '/welcome';
      if (signedIn && isAuthRoute) {
        return isAdminUser ? '/admin' : '/home';
      }

      // Admin gate
      if (signedIn && isAdminRoute) {
        if (!isAdminUser) {
          // If role still loading, allow screen to handle; otherwise redirect.
          return me.maybeWhen(
            data: (_) => '/home',
            orElse: () => null,
          );
        }
      }

      // Listings console route gate (operator roles only for current mobile APIs).
      if (signedIn && isListingsConsoleRoute) {
        final me = ref.read(meProvider);
        return me.maybeWhen(
          data: (u) {
            final role = (u?.role ?? '').trim().toLowerCase();
            final isOperator =
                role == 'admin' || role == 'agent' || role == 'seller' || role == 'owner';
            return isOperator ? null : '/dashboard';
          },
          orElse: () => null,
        );
      }

      // Trust gate (verification) - only enforce once we have a resolved status.
      if (signedIn && !isAuthRoute) {
        if (isAdminUser) {
          return isVerifyRoute ? '/admin' : null;
        }

        final verification = ref.read(verificationStatusProvider);

        if (isVerifyRoute) {
          return verification.when(
            data: (s) => (s?.isVerified == true) ? '/home' : null,
            loading: () => null,
            error: (_, __) => null,
          );
        }

        final isPublicRoute = isPublicAuthRoute || isVerifyRoute;
        if (!isPublicRoute) {
          return verification.when(
            data: (s) {
              final verified = s?.isVerified == true;
              return verified ? null : '/verify';
            },
            loading: () => '/verify',
            error: (_, __) => '/verify',
          );
        }
      }

      // If verified, keep /verify optional (don't force redirect away).
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/welcome',
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth',
        redirect: (_, __) => '/welcome',
      ),
      GoRoute(
        path: '/verify',
        builder: (_, __) => const VerifyScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (_, __) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/request-callback',
        builder: (_, __) => const RequestCallbackScreen(),
      ),
      GoRoute(
        path: '/schedule-tour',
        builder: (_, __) => const ScheduleTourScreen(),
      ),
      GoRoute(
        path: '/hiring',
        builder: (_, __) => const HiringScreen(),
      ),
      GoRoute(
        path: '/terms-of-service',
        builder: (_, __) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        builder: (_, __) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/escrow-policy',
        builder: (_, __) => const EscrowPolicyScreen(),
      ),
      GoRoute(
        path: '/provider-package/:token',
        builder: (_, state) {
          final token = state.pathParameters['token'] ?? '';
          return ProviderPackageScreen(token: token);
        },
      ),
      GoRoute(
        path: '/listings',
        builder: (_, __) => const ListingsScreen(),
      ),
      GoRoute(
        path: '/property/:id',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          final openVerification =
              state.uri.queryParameters['view'] == 'verification';
          if (id.startsWith('prop_')) {
            return MarketplacePropertyDetailsScreen(propertyId: id);
          }
          return ListingDetailsScreen(
            listingId: id,
            initial: state.extra is Listing ? state.extra as Listing : null,
            showVerificationOnOpen: openVerification,
          );
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (_, __) => const ChatScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatThreadScreen(
            conversationId: id,
            conversation: state.extra is ChatConversation ? state.extra as ChatConversation : null,
          );
        },
      ),

      GoRoute(
        path: '/transaction/:conversationId',
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return TransactionCenterScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
});

/// A small bridge to refresh go_router when session or verification changes.
final routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, __) => notifier.value++);
  ref.listen(verificationStatusProvider, (_, __) => notifier.value++);
  ref.listen(meProvider, (_, __) => notifier.value++);
  return notifier;
});
