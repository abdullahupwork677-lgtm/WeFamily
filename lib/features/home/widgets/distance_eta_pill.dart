import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Floating pill on the route line showing road distance and ETA.
class DistanceEtaPill extends StatelessWidget {
  const DistanceEtaPill({
    super.key,
    required this.distanceText,
    required this.etaText,
    this.isEstimate = false,
    this.loading = false,
  });

  final String distanceText;
  final String etaText;
  final bool isEstimate;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final prefix = isEstimate ? '~' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AhlColors.primary.withValues(alpha: 0.12)),
        boxShadow: AhlColors.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me_rounded, size: 15, color: AhlColors.primary),
          const SizedBox(width: 5),
          Text(
            '$prefix$distanceText',
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w800, color: AhlColors.ink),
          ),
          const SizedBox(width: 6),
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: AhlColors.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$prefix$etaText',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AhlColors.inkMedium,
            ),
          ),
          if (loading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: AhlColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
