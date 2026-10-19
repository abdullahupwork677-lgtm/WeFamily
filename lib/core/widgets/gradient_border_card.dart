import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GradientBorderCard extends StatelessWidget {
  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget bordered = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        gradient: AhlColors.goldPurpleBorder,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.5),
        child: ColoredBox(
          color: AhlColors.surface,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    return onTap != null
        ? GestureDetector(onTap: onTap, child: bordered)
        : bordered;
  }
}
