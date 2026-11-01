import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Family-in-a-ring brand mark used on the splash, onboarding header and auth.
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double inner = size - 10;
    final double core = size - 20;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AhlColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AhlColors.primary.withValues(alpha: 0.28),
                  blurRadius: size * 0.24,
                  offset: Offset(0, size * 0.08),
                ),
              ],
            ),
          ),
          Container(
            width: inner,
            height: inner,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          Container(
            width: core,
            height: core,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AhlColors.primaryGradient,
            ),
            child: Icon(
              Icons.family_restroom_rounded,
              size: core * 0.46,
              color: Colors.white,
            ),
          ),
          Positioned(
            right: size * 0.04,
            bottom: size * 0.08,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: AhlColors.softShadowSmall,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: size * 0.15,
                color: AhlColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
