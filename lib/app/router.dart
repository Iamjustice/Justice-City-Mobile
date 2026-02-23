import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/home/home_screen.dart';
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
import '../domain/models/listing.dart';
import '../domain/models/chat_conversation.dart';
import '../state/session_provider.dart';
import '../state/verification_provider.dart';
import '../state/me_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: ref.watch(routerRefreshProvider),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);

      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/auth';
      final isVerifyRoute = loc == '/verify';
      final isAdminRoute = loc == '/admin';

      final signedIn = session != null;

      // Auth gate
      if (!signedIn && !isAuthRoute) return '/auth';
      if (signedIn && isAuthRoute) return '/home';

      // Admin gate
      if (signedIn && isAdminRoute) {
        final isAdmin = ref.read(isAdminProvider);
        if (!isAdmin) {
          // If role still loading, allow screen to handle; otherwise redirect.
          final me = ref.read(meProvider);
          return me.maybeWhen(
            data: (_) => '/home',
            orElse: () => null,
          );
        }
      }

      // Trust gate (verification) — only enforce once we have a resolved status.
      if (signedIn && !isAuthRoute) {
        final verification = ref.read(verificationStatusProvider);

        final isPublicRoute = loc == '/home' || isVerifyRoute;
        if (!isPublicRoute) {
          return verification.maybeWhen(
            data: (s) {
              final verified = s?.isVerified == true;
              return verified ? null : '/verify';
            },
            orElse: () => null, // loading/error -> don't block navigation
          );
        }
      }

      // If verified, keep /verify optional (don't force redirect away).
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
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
          return ListingDetailsScreen(
            listingId: id,
            initial: state.extra is Listing ? state.extra as Listing : null,
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
  return notifier;
});
