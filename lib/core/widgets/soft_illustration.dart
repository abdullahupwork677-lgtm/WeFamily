import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Placeholder for the glossy 3D illustrations used across the app
/// (premium banner, empty states, onboarding).
///
/// TODO(asset): swap the gradient blob for `assets/images/placeholder_3d.png`
/// once the art is exported; keep the icon as fallback.
class SoftIllustration extends StatelessWidget {
  const SoftIllustration({
    super.key,
    this.icon = Icons.lock_rounded,
    this.size = 56,
    this.color = AhlColors.primary,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.45, color: color),
    );
  }
}
