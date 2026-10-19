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
}
