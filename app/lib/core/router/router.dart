import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:maxwell/features/auth/presentation/gate_screen.dart';
import 'package:maxwell/features/auth/presentation/login_screen.dart';
import 'package:maxwell/features/onboarding/presentation/onboarding_screen.dart';
import 'package:maxwell/features/home/presentation/home_screen.dart';
import 'package:maxwell/features/settings/presentation/settings_screen.dart';
import 'package:maxwell/features/machines/presentation/machine_details_screen.dart';
import 'package:maxwell/shared/widgets/scaffold_with_nav_bar.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
class OnboardingStatus extends _$OnboardingStatus
{
  @override
  bool build()
  {
    _checkStatus();
    return false;
  }

  Future<void> _checkStatus() async
  {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('has_completed_onboarding') ?? false;
  }

  void complete()
  {
    state = true;
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

@riverpod
GoRouter router(RouterRef ref)
{
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authState != null ? '/home' : '/gate',
    redirect: (context, state) {
      final isAuthenticated = authState != null;
      final isGate = state.matchedLocation == '/gate';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      
      final isAuthPath = isGate || isLogin || isRegister;

      if (!isAuthenticated && !isAuthPath) {
        return '/gate';
      }

      if (isAuthenticated && isAuthPath) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/gate',
        builder: (context, state) => const GateScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Fullscreen routes (outside the navbar shell)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/machine/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MachineDetailsScreen(id: id);
        },
      ),

      // Main Application Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Settings Branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
