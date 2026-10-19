import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRouter {
  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
