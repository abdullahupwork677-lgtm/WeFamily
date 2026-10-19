import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AhlButton extends StatelessWidget {
  const AhlButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
    this.gradient = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool gradient;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
        ],
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
      ],
    );

    final ButtonStyle style = FilledButton.styleFrom(
      backgroundColor: gradient ? Colors.transparent : AhlColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AhlColors.primary.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      shape: const StadiumBorder(),
    );

    final Widget button = gradient
        ? DecoratedBox(
            decoration: const BoxDecoration(
              gradient: AhlColors.primaryGradient,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: FilledButton(onPressed: onPressed, style: style, child: child),
          )
        : FilledButton(onPressed: onPressed, style: style, child: child);

    final Widget sized = expand ? SizedBox(width: double.infinity, child: button) : button;
    return GestureDetector(
      onTapDown: (_) {},
      child: sized,
    );
  }
}
