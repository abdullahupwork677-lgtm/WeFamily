import 'package:flutter/material.dart';
import 'package:wefamily/l10n/generated/app_localizations.dart';

import '../../../core/theme/colors.dart';

class StartHeader extends StatelessWidget {
  const StartHeader({
    super.key,
    this.onBack,
    this.onSkip,
    this.onMenu,
    this.showSkip = true,
  });

  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final VoidCallback? onMenu;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AhlColors.startSurface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onBack,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: Transform.flip(
                flipX: isRtl,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AhlColors.startOnSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AhlColors.primaryGradient,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.01,
                color: AhlColors.ink,
              ),
            ),
          ),
          if (showSkip && onSkip != null)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: AhlColors.primary,
              ),
              child: Text(
                l10n.skip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AhlColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
          if (onMenu != null)
            Material(
              color: AhlColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onMenu,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
