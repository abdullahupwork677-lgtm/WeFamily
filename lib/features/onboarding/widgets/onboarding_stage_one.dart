import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';
import 'onboarding_common.dart';

const LinearGradient _ringPurple = LinearGradient(
  colors: [Color(0xFF6D28D9), Color(0xFFEA57FF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class OnboardingStageOne extends StatelessWidget {
  const OnboardingStageOne({super.key, this.height = 350});

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
            size: 170,
            color: Color(0x66FFD6FD),
            alignment: Alignment.topLeft,
          ),
          const StageGlow(
            size: 190,
            color: Color(0x88EBDDFF),
            alignment: Alignment.bottomRight,
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: StageCurvesPainter(
                mirror: mirror,
                curves: const [
                  StageCurve(
                    start: Offset(0.25, 0.33),
                    control1: Offset(0.40, 0.13),
                    control2: Offset(0.60, 0.16),
                    end: Offset(0.75, 0.35),
                    dashed: true,
                    gradient: LinearGradient(
                      colors: [Color(0xCC7C3AED), Color(0xDDEA57FF)],
                    ),
                  ),
                  StageCurve(
                    start: Offset(0.25, 0.35),
                    control1: Offset(0.27, 0.52),
                    control2: Offset(0.40, 0.68),
                    end: Offset(0.50, 0.76),
                    gradient: LinearGradient(
                      colors: [Color(0xCC8B5CF6), Color(0xCCEA57FF)],
                    ),
                  ),
                  StageCurve(
                    start: Offset(0.75, 0.37),
                    control1: Offset(0.72, 0.52),
                    control2: Offset(0.62, 0.66),
                    end: Offset(0.50, 0.76),
                    dashed: true,
                    width: 1.8,
                    gradient: LinearGradient(
                      colors: [Color(0xCCEA57FF), Color(0xCC8B5CF6)],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _node(
            alignment: Alignment(stageAlignment(mirror, 0.24), -0.36),
            avatar: StageAvatar(
              asset: 'assets/images/onboarding/leo.jpg',
              size: 44,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              badge: IconBadge(
                icon: Icons.school_rounded,
                size: 15,
                background: AhlColors.startSecondaryFixed,
                foreground: const Color(0xFF580066),
                iconSize: 9,
              ),
            ),
            pill: StagePill(
              label: l10n.illLeoAtSchool,
              dotColor: const Color(0xFF6D28D9),
            ),
          ),
          _node(
            alignment: Alignment(stageAlignment(mirror, 0.76), -0.32),
            avatar: StageAvatar(
              asset: 'assets/images/onboarding/mom.jpg',
              size: 44,
              gradient: _ringPurple,
              badge: const IconBadge(
                icon: Icons.directions_car_rounded,
                size: 15,
                iconSize: 9,
              ),
            ),
            pill: StagePill(
              label: l10n.illMomInTransit,
              dotColor: const Color(0xFFA200BA),
            ),
          ),
          _homeNode(context, l10n, mirror),
        ],
      ),
    );
  }

  Widget _homeNode(BuildContext context, AppLocalizations l10n, bool mirror) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment(stageAlignment(mirror, 0.5), 0.58),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StagePill(
              label: l10n.illHomeZoneSafe,
              uppercase: true,
              background: const Color(0xE6F0E4F9),
              foreground: AhlColors.primary,
              shadow: false,
              leading: const Icon(
                Icons.shield_rounded,
                size: 14,
                color: AhlColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 84,
              height: 56,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: StageAvatar(
                      asset: 'assets/images/onboarding/dad.jpg',
                      size: 52,
                      borderWidth: 2,
                      gradient: _ringPurple,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: StageAvatar(
                      asset: 'assets/images/onboarding/buddy.jpg',
                      size: 38,
                      borderWidth: 2,
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: -2,
                    child: IconBadge(
                      icon: Icons.circle,
                      size: 17,
                      background: Colors.white,
                      foreground: Color(0xFFEA57FF),
                      iconSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _node({
    required Alignment alignment,
    required Widget avatar,
    required Widget pill,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [avatar, const SizedBox(height: 6), pill],
        ),
      ),
    );
  }
}
