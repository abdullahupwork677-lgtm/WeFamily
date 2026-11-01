import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';
import 'onboarding_common.dart';

class OnboardingStageTwo extends StatelessWidget {
  const OnboardingStageTwo({super.key, this.height = 350});

  final double height;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool mirror = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const StageGlow(
            size: 260,
            color: Color(0x55EBDDFF),
            alignment: Alignment.center,
          ),
          Center(
            child: Container(
              width: 292,
              height: 292,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AhlColors.primary.withValues(alpha: 0.10),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 224,
              height: 224,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AhlColors.startSurfaceContainer.withValues(alpha: 0.6),
                boxShadow: AhlColors.softShadowSmall,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 158,
                height: 158,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AhlColors.startSurfaceHigh.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
          Center(
                child: Container(
                  width: 176,
                  height: 176,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AhlColors.primary.withValues(alpha: 0.35),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6D28D9),
                          Color(0xFFA200BA),
                          Color(0xFFEA57FF),
                        ],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 58,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.28),
                                  Colors.white.withValues(alpha: 0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 62,
                              height: 62,
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(
                                    Icons.shield_rounded,
                                    size: 62,
                                    color: Colors.white,
                                  ),
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 22,
                                    color: Color(0xFF8B2BD6),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            StagePill(
                              label: l10n.illLiveGuardian,
                              uppercase: true,
                              background: Colors.white.withValues(alpha: 0.22),
                              foreground: Colors.white,
                              dotColor: const Color(0xFF4ADE80),
                              fontSize: 9,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              shadow: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.94, 0.94),
                end: const Offset(1, 1),
                duration: 450.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 250.ms),
          _zoneChip(
            context: context,
            alignment: Alignment(stageAlignment(mirror, 0.20), -0.74),
            icon: Icons.home_rounded,
            iconColor: const Color(0xFF047857),
            iconBackground: const Color(0xFFD1FAE5),
            title: l10n.illHomeZone,
            subtitle: l10n.illSafeActive,
            subtitleColor: const Color(0xFF047857),
          ),
          _zoneChip(
            context: context,
            alignment: Alignment(stageAlignment(mirror, 0.80), -0.63),
            icon: Icons.school_rounded,
            iconColor: AhlColors.primary,
            iconBackground: AhlColors.startSurfaceContainer,
            title: l10n.illSchoolZone,
            subtitle: l10n.illArrived,
          ),
          _zoneChip(
            context: context,
            alignment: Alignment(stageAlignment(mirror, 0.19), 0.67),
            icon: Icons.directions_car_filled_rounded,
            iconColor: const Color(0xFFA200BA),
            iconBackground: AhlColors.startSecondaryFixed,
            title: l10n.illCrashReady,
          ),
          _zoneChip(
            context: context,
            alignment: Alignment(stageAlignment(mirror, 0.78), 0.76),
            icon: Icons.verified_user_rounded,
            iconColor: AhlColors.primary,
            iconBackground: Colors.transparent,
            title: l10n.illBankLevelSafe,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _zoneChip({
    required BuildContext context,
    required Alignment alignment,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    bool compact = false,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 7,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(999),
            boxShadow: AhlColors.softShadowSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBackground,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 5),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                      color: AhlColors.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                        color: subtitleColor ?? AhlColors.startOnSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
