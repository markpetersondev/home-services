import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/app_user.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/role_select_screen.dart';
import 'screens/customer/customer_shell.dart';
import 'screens/customer/home_screen.dart';
import 'screens/customer/create_booking_screen.dart';
import 'screens/customer/my_requests_screen.dart';
import 'screens/customer/booking_detail_screen.dart';
import 'screens/customer/call_screen.dart';
import 'screens/customer/profile_screen.dart';
import 'screens/provider/provider_shell.dart';
import 'screens/provider/home_screen.dart';
import 'screens/provider/job_detail_screen.dart';
import 'screens/provider/requests_screen.dart';
import 'screens/provider/chat_screen.dart';
import 'screens/provider/profile_screen.dart';

// ── Router provider ───────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: _routes,
  );
  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });
  return router;
});

// ── Auth redirect notifier ────────────────────────────────────────────────────

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen<AppUser?>(authProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final user = _ref.read(authProvider);
    final path = state.matchedLocation;

    final isProtected = path.startsWith('/customer') ||
        path.startsWith('/provider');
    final isAuthRoute = path == '/' ||
        path == '/verify-otp' ||
        path == '/role-select';

    // Not logged in → block protected routes
    if (user == null && isProtected) return '/';

    // Already logged in → skip auth screens
    if (user != null && isAuthRoute) {
      return user.role == 'customer' ? '/customer/home' : '/provider/home';
    }

    return null;
  }
}

// ── Routes ────────────────────────────────────────────────────────────────────

final _routes = <RouteBase>[
  // ── Auth ──────────────────────────────────────────────────────────────────
  GoRoute(
    path: '/',
    builder: (context, state) => const PhoneScreen(),
  ),
  GoRoute(
    path: '/verify-otp',
    builder: (context, state) => const OtpScreen(),
  ),
  GoRoute(
    path: '/role-select',
    builder: (context, state) => const RoleSelectScreen(),
  ),

  // ── Customer detail screens (no shell / bottom nav) ───────────────────────
  GoRoute(
    path: '/customer/create-booking',
    builder: (context, state) => CreateBookingScreen(
      serviceType: (state.extra as String?) ?? 'Plumbing',
    ),
  ),
  GoRoute(
    path: '/customer/booking-detail',
    builder: (context, state) => BookingDetailScreen(
      bookingId: state.extra as int,
    ),
  ),

  // ── Provider detail screen (no shell / bottom nav) ────────────────────────
  GoRoute(
    path: '/provider/job-detail',
    builder: (context, state) => JobDetailScreen(
      bookingId: state.extra as int,
    ),
  ),

  // ── Customer shell (tabbed) ───────────────────────────────────────────────
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        CustomerShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/customer/home',
          builder: (context, state) => const CustomerHomeScreen(),
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/customer/my-requests',
          builder: (context, state) => const MyRequestsScreen(),
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/customer/call',
          builder: (context, state) => const CustomerCallScreen(),
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/customer/profile',
          builder: (context, state) => const CustomerProfileScreen(),
        ),
      ]),
    ],
  ),

  // ── Provider shell (tabbed) ───────────────────────────────────────────────
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        ProviderShell(navigationShell: navigationShell),
    branches: [
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/provider/home',
          builder: (context, state) => const ProviderHomeScreen(),
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/provider/requests',
          builder: (context, state) => const ProviderRequestsScreen(),
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/provider/chat',
          builder: (context, state) => const ProviderChatScreen(),
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/provider/profile',
          builder: (context, state) => const ProviderProfileScreen(),
        ),
      ]),
    ],
  ),
];
