import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AhlCard extends StatelessWidget {
  const AhlCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AhlColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AhlColors.softShadow,
      ),
      child: child,
    );

    return Padding(
      padding: margin,
      child: onTap != null
          ? GestureDetector(onTap: onTap, child: card)
          : card,
    );
  }
}
