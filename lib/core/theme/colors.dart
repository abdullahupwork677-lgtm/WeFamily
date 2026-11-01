import 'package:flutter/material.dart';

abstract class AhlColors {
  static const Color primary = Color(0xFF5B21B6);
  static const Color primaryGradientEnd = Color(0xFFC026D3);
  static const Color gold = Color(0xFFC9A24D);
  static const Color background = Color(0xFFF7F4FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF2B2433);
  static const Color danger = Color(0xFFE11D48);
  static const Color success = Color(0xFF16A34A);

  /// Soft UI neutrals
  static const Color chip = Color(0xFFEDEDF0);
  static const Color placeholder = Color(0xFFE9E4F5);
  static const Color outline = Color(0xFFB9AFCC);

  /// Start-flow surface ramp (Stitch design tokens)
  static const Color startSurface = Color(0xFFFFF7FF);
  static const Color startSurfaceLow = Color(0xFFFBF0FF);
  static const Color startSurfaceContainer = Color(0xFFF6E9FE);
  static const Color startSurfaceHigh = Color(0xFFF0E4F9);
  static const Color startSurfaceDim = Color(0xFFE2D6EA);
  static const Color startPrimaryFixed = Color(0xFFEBDDFF);
  static const Color startSecondaryFixed = Color(0xFFFFD6FD);
  static const Color startOnSurfaceVariant = Color(0xFF4A4455);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> softShadowSmall = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> sheetShadow = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 28, offset: Offset(0, -8)),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryGradientEnd],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  static const LinearGradient goldPurpleBorder = LinearGradient(
    colors: [gold, primary],
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  );

  static Color get inkMedium => ink.withValues(alpha: 0.6);
  static Color get inkLight => ink.withValues(alpha: 0.4);
  static Color get border => const Color(0xFFE9E4F5);

  /// Family Orbit design tokens (kept central, no hardcoded colors in screen).
  static const Color muted = Color(0xFF7B7088);
  static const Color line = Color(0xFFCDBEE3);
  static const Color orbitChip = Color(0xFFEFE8F8);
  static const Color glow = Color(0x73C026D3); // rgba(192,38,211,0.45)
  static const Color ring = Color(0x245B21B6); // rgba(91,33,182,0.14)
  static const Color avatarPastelA = Color(0xFFEBD9A3);
  static const Color avatarPastelB = Color(0xFFCDB8F2);
  static const Color avatarPastelC = Color(0xFFF0BDF3);
  static const Color avatarPastelD = Color(0xFFE3D3F7);

  static const LinearGradient orbitPrimaryGradient = LinearGradient(
    colors: [primary, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orbitGoldGradient = LinearGradient(
    colors: [Color(0xFFC9A24D), Color(0xFFE3C579)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color goldLight = Color(0xFFE3C579);
  static const Color mapStage = Color(0xFFEFEAF6);

  static const List<List<Color>> mapAvatarGradients = [
    [primary, primaryGradientEnd],
    [gold, goldLight],
    [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    [Color(0xFFE879F9), primaryGradientEnd],
    [Color(0xFF7C3AED), primary],
  ];
}
