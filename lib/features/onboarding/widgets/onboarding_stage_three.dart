import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';
import 'onboarding_common.dart';

const LinearGradient _ringPurple = LinearGradient(
  colors: [Color(0xFF6D28D9), Color(0xFFEA57FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class OnboardingStageThree extends StatelessWidget {
  const OnboardingStageThree({super.key, this.height = 350});

  final double height;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool mirror = Directionality.of(context) == TextDirection.rtl;

    return StageCard(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const StageGlow(
            size: 190,
            color: Color(0x55FFD6FD),
            alignment: Alignment.topLeft,
          ),
          const StageGlow(
            size: 220,
            color: Color(0x44EBDDFF),
            alignment: Alignment.bottomRight,
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: StageCurvesPainter(
                mirror: mirror,
                curves: const [
                  StageCurve(
                    start: Offset(0.50, 0.20),
                    control1: Offset(0.38, 0.26),
                    control2: Offset(0.28, 0.34),
                    end: Offset(0.22, 0.44),
                    dashed: true,
                    gradient: LinearGradient(
                      colors: [Color(0xCC8B5CF6), Color(0xCCEA57FF)],
                    ),
                  ),
                  StageCurve(
                    start: Offset(0.50, 0.20),
                    control1: Offset(0.62, 0.26),
                    control2: Offset(0.72, 0.34),
                    end: Offset(0.78, 0.44),
                    dashed: true,
                    gradient: LinearGradient(
                      colors: [Color(0xCCEA57FF), Color(0xCC8B5CF6)],
                    ),
                  ),
                  StageCurve(
                    start: Offset(0.22, 0.50),
                    control1: Offset(0.24, 0.64),
                    control2: Offset(0.36, 0.73),
                    end: Offset(0.50, 0.72),
                    gradient: LinearGradient(
                      colors: [Color(0xCC8B5CF6), Color(0xCCEA57FF)],
                    ),
                  ),
                  StageCurve(
                    start: Offset(0.78, 0.50),
                    control1: Offset(0.76, 0.64),
                    control2: Offset(0.64, 0.73),
                    end: Offset(0.50, 0.72),
                    width: 1.8,
                    gradient: LinearGradient(
                      colors: [Color(0x99EA57FF), Color(0x998B5CF6)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _nanaNode(context, l10n, mirror),
          _personNode(
            context,
            alignment: Alignment(stageAlignment(mirror, 0.22), 0.16),
            asset: 'assets/images/onboarding/elena.jpg',
            label: l10n.illElenaMom,
            topBadge: const IconBadge(
              icon: Icons.favorite_rounded,
              size: 21,
              background: AhlColors.startSecondaryFixed,
              foreground: Color(0xFFA200BA),
              iconSize: 11,
            ),
          ),
          _personNode(
            context,
            alignment: Alignment(stageAlignment(mirror, 0.78), 0.16),
            asset: 'assets/images/onboarding/marcus.jpg',
            label: l10n.illMarcus,
            pill: StagePill(
              label: l10n.illTales,
              fontSize: 9,
              leading: const Icon(
                Icons.menu_book_rounded,
                size: 11,
                color: AhlColors.primary,
              ),
            ),
          ),
          _mayaNode(context, l10n, mirror),
        ],
      ),
    );
  }

  Widget _nanaNode(BuildContext context, AppLocalizations l10n, bool mirror) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(stageAlignment(mirror, 0.5), -0.62),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 78,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child:
                        StageAvatar(
                              asset: 'assets/images/onboarding/nana_rose.jpg',
                              size: 74,
                              gradient: _ringPurple,
                            )
                            .animate()
                            .scale(
                              begin: const Offset(0.92, 0.92),
                              end: const Offset(1, 1),
                              duration: 450.ms,
                              curve: Curves.easeOutBack,
                            )
                            .fadeIn(duration: 250.ms),
                  ),
                  Positioned(
                    left: 15,
                    bottom: 2,
                    child: StagePill(
                      label: '0:42',
                      foreground: Colors.white,
                      background: AhlColors.primary,
                      fontSize: 9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: const Icon(
                        Icons.graphic_eq_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 2,
                    child: StagePill(
                      label: l10n.illAnniversary,
                      fontSize: 9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: const Icon(
                        Icons.cake_rounded,
                        size: 12,
                        color: AhlColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.illNanaRose,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AhlColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _personNode(
    BuildContext context, {
    required Alignment alignment,
    required String asset,
    required String label,
    Widget? topBadge,
    StagePill? pill,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 128,
              height: 62,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  StageAvatar(asset: asset, size: 58, gradient: _ringPurple),
                  if (topBadge != null)
                    Positioned(top: -5, left: 22, child: topBadge),
                  if (pill != null)
                    Positioned(left: 0, bottom: -2, child: pill),
                ],
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AhlColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mayaNode(BuildContext context, AppLocalizations l10n, bool mirror) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(stageAlignment(mirror, 0.5), 0.72),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 62,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      StageAvatar(
                        asset: 'assets/images/onboarding/maya.jpg',
                        size: 54,
                        gradient: _ringPurple,
                      ),
                      const Positioned(
                        top: -6,
                        right: -6,
                        child: IconBadge(
                          icon: Icons.star_rounded,
                          size: 19,
                          iconSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    bottom: -2,
                    child: StagePill(
                      label: l10n.illLiveMemory,
                      dotColor: AhlColors.primary,
                      fontSize: 9,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.illMayaAge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AhlColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
