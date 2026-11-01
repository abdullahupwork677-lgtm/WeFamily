import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/session_provider.dart';
import 'widgets/onboarding_stage_one.dart';
import 'widgets/onboarding_stage_three.dart';
import 'widgets/onboarding_stage_two.dart';
import 'widgets/start_header.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish({bool signIn = false}) async {
    await ref.read(sessionProvider.notifier).completeOnboarding();
    if (!mounted) return;
    final session = ref.read(sessionProvider);
    if (session.isLoggedIn) {
      context.go(session.hasCircle ? '/home' : '/circle');
      return;
    }
    context.go(signIn ? '/login' : '/login?mode=signup');
  }

  Future<void> _next() async {
    if (_index < 2) {
      await _controller.nextPage(duration: 380.ms, curve: Curves.easeOutCubic);
      return;
    }
    await _finish();
  }

  void _previous() {
    if (_index == 0) return;
    _controller.previousPage(duration: 320.ms, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isLast = _index == 2;

    return Scaffold(
      backgroundColor: AhlColors.startSurface,
      body: SafeArea(
        child: Column(
          children: [
            StartHeader(
              onBack: _index == 0 ? null : _previous,
              onSkip: _finish,
              onMenu: _finish,
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  return _OnboardingPage(index: i);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final bool active = i == _index;
                      return AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: active ? AhlColors.primaryGradient : null,
                          color: active ? null : AhlColors.startSurfaceDim,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  _OnboardingCta(
                    label: isLast ? l10n.getStarted : l10n.next,
                    onTap: _next,
                  ),
                  const SizedBox(height: 12),
                  if (isLast)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.onboardingHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AhlColors.startOnSurfaceVariant,
                              ),
                        ),
                        TextButton(
                          onPressed: () => _finish(signIn: true),
                          style: TextButton.styleFrom(
                            foregroundColor: AhlColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.signIn,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AhlColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    )
                  else
                    _TrustPill(
                      icon: _index == 0
                          ? Icons.lock_outline_rounded
                          : Icons.verified_user_outlined,
                      label: _index == 0
                          ? l10n.onboardingTrust1
                          : l10n.onboardingTrust2,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String? badge = switch (index) {
      0 => l10n.onboardingBadge1,
      1 => l10n.onboardingBadge2,
      _ => null,
    };

    final String title = switch (index) {
      0 => l10n.onboardingTitle1,
      1 => l10n.onboardingTitle2,
      _ => l10n.onboardingTitle3,
    };

    final String body = switch (index) {
      0 => l10n.onboardingBody1,
      1 => l10n.onboardingBody2,
      _ => l10n.onboardingBody3,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final double stageHeight = (constraints.maxHeight - 215).clamp(
          236.0,
          350.0,
        );
        final Widget stage = switch (index) {
          0 => OnboardingStageOne(height: stageHeight),
          1 => OnboardingStageTwo(height: stageHeight),
          _ => OnboardingStageThree(height: stageHeight),
        };

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              stage
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideY(begin: 0.04, end: 0, duration: 350.ms),
              if (badge != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AhlColors.startPrimaryFixed.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        index == 0
                            ? Icons.track_changes_rounded
                            : Icons.shield_rounded,
                        size: 15,
                        color: AhlColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AhlColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const SizedBox(height: 28),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.4,
                  color: AhlColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AhlColors.startOnSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingCta extends StatelessWidget {
  const _OnboardingCta({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AhlColors.primaryGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AhlColors.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AhlColors.startPrimaryFixed.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AhlColors.primary),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AhlColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
