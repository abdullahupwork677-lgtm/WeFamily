import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

bool _isArabic(Locale locale) => locale.languageCode == 'ar';

TextTheme ahlTextTheme(Locale locale) {
  final bool isAr = _isArabic(locale);
  final String family = isAr ? 'IBM Plex Sans Arabic' : 'Plus Jakarta Sans';

  TextStyle style(
    double size,
    FontWeight weight, {
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: isAr ? (height ?? 1.5) : height,
      letterSpacing: isAr ? 0 : letterSpacing,
      color: const Color(0xFF2B2433),
    );
  }

  if (isAr) {
    return TextTheme(
      displayLarge: style(36, FontWeight.w800, height: 1.4),
      displayMedium: style(28, FontWeight.w800, height: 1.4),
      headlineLarge: style(28, FontWeight.w700, height: 1.4),
      headlineMedium: style(22, FontWeight.w700, height: 1.4),
      headlineSmall: style(20, FontWeight.w700, height: 1.45),
      titleLarge: style(17, FontWeight.w600, height: 1.45),
      titleMedium: style(16, FontWeight.w600, height: 1.45),
      bodyLarge: style(16, FontWeight.w400, height: 1.55),
      bodyMedium: style(14, FontWeight.w400, height: 1.55),
      bodySmall: style(13, FontWeight.w400, height: 1.5),
      labelLarge: style(12, FontWeight.w600, height: 1.4),
      labelSmall: style(11, FontWeight.w700, height: 1.35),
    );
  }

  return TextTheme(
    displayLarge: style(36, FontWeight.w800, height: 1.22, letterSpacing: -0.03),
    displayMedium: style(28, FontWeight.w800, height: 1.21, letterSpacing: -0.02),
    headlineLarge: style(28, FontWeight.w700, height: 1.29, letterSpacing: -0.02),
    headlineMedium: style(22, FontWeight.w700, height: 1.27, letterSpacing: -0.015),
    headlineSmall: style(20, FontWeight.w700, height: 1.3, letterSpacing: -0.01),
    titleLarge: style(17, FontWeight.w600, height: 1.29, letterSpacing: -0.01),
    titleMedium: style(16, FontWeight.w600, height: 1.35),
    bodyLarge: style(16, FontWeight.w400, height: 1.5),
    bodyMedium: style(14, FontWeight.w400, height: 1.43),
    bodySmall: style(13, FontWeight.w400, height: 1.38),
    labelLarge: style(12, FontWeight.w600, height: 1.33, letterSpacing: 0.04),
    labelSmall: style(11, FontWeight.w700, height: 1.27, letterSpacing: 0.06),
  );
}

// Ensure google_fonts is referenced so fonts download at runtime for EN.
// AR uses IBM Plex Sans Arabic via the same package when available.
void ensureFontsRegistered() {
  GoogleFonts.plusJakartaSans();
}
