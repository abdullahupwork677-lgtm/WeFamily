import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/constants/config.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      await ref
          .read(sessionProvider.notifier)
          .loaded
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // navigate with whatever state we have instead of getting stuck
    }
    final User? authUser = await firstAuthUser();
    if (authUser != null && !AppConfig.useMockData) {
      try {
        await ref
            .read(sessionProvider.notifier)
            .syncWithBackend()
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Offline start: use the cached membership state.
      }
    }
    _navigate(authUser);
  }

  void _navigate(User? authUser) {
    if (!mounted) return;
    final session = ref.read(sessionProvider);
    if (authUser != null) {
      if (session.hasCircle) {
        context.go('/home');
      } else if (session.isLoggedIn) {
        context.go('/circle');
      } else {
        context.go('/profile-setup');
      }
      return;
    }
    if (session.isLoggedIn && session.hasCircle) {
      context.go('/home');
    } else if (session.isLoggedIn) {
      context.go('/circle');
    } else if (session.onboardingSeen) {
      context.go('/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AhlColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                gradient: AhlColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.family_restroom_rounded, size: 48, color: Colors.white),
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(
              l10n.appName,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AhlColors.ink,
                  ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              'ع · ${l10n.appName}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AhlColors.inkMedium),
            ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}

