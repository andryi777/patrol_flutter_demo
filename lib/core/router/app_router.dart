import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/locale_aware_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/scaffold_with_nav_bar.dart';
import 'package:flutter_riverpod_clean_architecture/examples/localization_assets_demo.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/explore/presentation/screens/explore_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/biometrics_settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/notifications_settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/presentation/screens/survey_screen.dart';

// Navigation keys for each branch - created once
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _exploreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'explore');
final _notificationsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'notifications');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  // Create router - locale changes are handled by MaterialApp, not the router
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    // Add the observer for locale awareness
    observers: [ref.read(localizationRouterObserverProvider)],
    redirect: (context, state) {
      // Get the authentication status
      final isLoggedIn = authState.isAuthenticated;

      // Check if the user is going to the login page
      final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;

      // Check if the user is going to the register page
      final isGoingToRegister =
          state.matchedLocation == AppConstants.registerRoute;

      // If not logged in and not going to login or register, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppConstants.loginRoute;
      }

      // If logged in and going to login, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppConstants.homeRoute;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Login route (outside shell)
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register route (outside shell)
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppConstants.homeRoute,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // Chat route (nested under home)
                  GoRoute(
                    path: 'chat',
                    name: 'chat',
                    builder: (context, state) => const ChatScreen(),
                  ),
                  // Survey route (nested under home)
                  GoRoute(
                    path: 'survey',
                    name: 'survey',
                    builder: (context, state) => const SurveyScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Explore branch
          StatefulShellBranch(
            navigatorKey: _exploreNavigatorKey,
            routes: [
              GoRoute(
                path: '/explore',
                name: 'explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),

          // Notifications branch
          StatefulShellBranch(
            navigatorKey: _notificationsNavigatorKey,
            routes: [
              GoRoute(
                path: '/notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsSettingsScreen(),
              ),
            ],
          ),

          // Settings branch
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: AppConstants.settingsRoute,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  // Language settings (nested under settings)
                  GoRoute(
                    path: 'language',
                    name: 'language_settings',
                    builder: (context, state) => const LanguageSettingsScreen(),
                  ),
                  // Biometrics settings (nested under settings)
                  GoRoute(
                    path: 'biometrics',
                    name: 'biometrics_settings',
                    builder: (context, state) => const BiometricsSettingsScreen(),
                  ),
                  // Localization demo (nested under settings)
                  GoRoute(
                    path: 'localization-demo',
                    name: 'localization_assets_demo',
                    builder: (context, state) => const LocalizationAssetsDemo(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Initial route - redirects based on auth state
      GoRoute(
        path: AppConstants.initialRoute,
        name: 'initial',
        redirect: (context, state) => authState.isAuthenticated
            ? AppConstants.homeRoute
            : AppConstants.loginRoute,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Page ${state.uri.path} not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
