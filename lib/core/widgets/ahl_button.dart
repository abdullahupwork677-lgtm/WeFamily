import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Primary CTA = purple-to-magenta gradient pill.
/// Secondary (`gradient: false`) = light grey pill with purple text and a
/// soft shadow. Both get a subtle tap-scale micro-animation.
class AhlButton extends StatefulWidget {
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
  State<AhlButton> createState() => _AhlButtonState();
}

class _AhlButtonState extends State<AhlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final Color foreground =
        widget.gradient ? Colors.white : AhlColors.primary;

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: foreground),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: foreground),
        ),
      ],
    );

    final ButtonStyle style = FilledButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: foreground,
      shadowColor: Colors.transparent,
      disabledBackgroundColor: Colors.transparent,
      disabledForegroundColor: foreground.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      shape: const StadiumBorder(),
    );

    final Widget button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: widget.gradient
            ? (enabled
                ? AhlColors.primaryGradient
                : LinearGradient(
                    colors: [
                      AhlColors.primary.withValues(alpha: 0.4),
                      AhlColors.primaryGradientEnd.withValues(alpha: 0.4),
                    ],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ))
            : null,
        color: widget.gradient ? null : AhlColors.chip,
        borderRadius: BorderRadius.circular(999),
        boxShadow: widget.gradient
            ? [
                BoxShadow(
                  color: AhlColors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : AhlColors.softShadowSmall,
      ),
      child: FilledButton(
        onPressed: widget.onPressed,
        style: style,
        child: child,
      ),
    );

    final Widget sized =
        widget.expand ? SizedBox(width: double.infinity, child: button) : button;

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: sized,
      ),
    );
  }
}
