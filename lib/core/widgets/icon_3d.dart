import 'package:flutter/material.dart';

/// Renders one of the glossy 3D icon assets used across the app.
class Icon3D extends StatelessWidget {
  const Icon3D(
    this.name, {
    super.key,
    this.size = 28,
    this.semanticLabel,
  });

  final String name;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons3d/$name.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      gaplessPlayback: true,
      semanticLabel: semanticLabel,
    );
  }
}
