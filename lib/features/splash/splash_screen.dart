import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/onboarding');
    });
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

