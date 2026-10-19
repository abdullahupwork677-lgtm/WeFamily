import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

ThemeData ahlTheme(Locale locale) {
  final TextTheme textTheme = ahlTextTheme(locale);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AhlColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AhlColors.primary,
      primary: AhlColors.primary,
      secondary: AhlColors.primaryGradientEnd,
      surface: AhlColors.surface,
      error: AhlColors.danger,
      brightness: Brightness.light,
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AhlColors.background,
      foregroundColor: AhlColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineSmall,
    ),
    cardTheme: CardThemeData(
      color: AhlColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFE9E4F5)),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AhlColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AhlColors.primary,
        side: const BorderSide(color: Color(0xFFE9E4F5)),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AhlColors.primary,
        shape: const StadiumBorder(),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AhlColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE9E4F5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE9E4F5), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AhlColors.primary, width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AhlColors.primary,
      unselectedItemColor: Color(0xFFA599B5),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE9E4F5), thickness: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AhlColors.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
