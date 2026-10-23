import 'package:flutter/material.dart';

/// FinCalc visual system: bright, modern finance palette with vivid accents and high-contrast surfaces.
class AppTheme {
  static const primary = Color(0xFF2563EB);       // vivid primary blue
  static const primaryDark = Color(0xFF60A5FA);   // bright blue for dark surfaces
  static const secondary = Color(0xFF475569);     // deep slate secondary
  static const accent = Color(0xFF10B981);        // vivid financial green
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF667085);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF4F6F9);

  // AMOLED dark theme: true black surfaces with crisp, high-contrast text.
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF0A0A0A);
  static const darkSurfaceRaised = Color(0xFF111111);
  static const darkBorder = Color(0xFF202020);
  static const darkText = Color(0xFFF5F5F5);
  static const darkMuted = Color(0xFFA0A0A0);
  static const darkIcon = Color(0xFF60A5FA);

  static ThemeData light() {
    final scheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDBEAFE),
      onPrimaryContainer: const Color(0xFF123B78),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE0E7FF),
      onSecondaryContainer: const Color(0xFF26324A),
      tertiary: accent,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFD1FAE5),
      onTertiaryContainer: const Color(0xFF065F46),
      surface: surface,
      onSurface: ink,
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF8F9FB),
      surfaceContainer: const Color(0xFFF1F3F6),
      surfaceContainerHigh: const Color(0xFFE9EDF2),
      outline: const Color(0xFFD2D8E0),
      outlineVariant: const Color(0xFFE3E7EC),
      error: const Color(0xFFB42318),
      onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E5EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E5EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primary, width: 1.3),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE4E8ED)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E9EE)),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      primary: primaryDark,
      onPrimary: const Color(0xFF0B1A2D),
      primaryContainer: const Color(0xFF172554),
      onPrimaryContainer: const Color(0xFFE0F2FE),
      secondary: const Color(0xFF93C5FD),
      onSecondary: const Color(0xFF06101D),
      secondaryContainer: const Color(0xFF171717),
      onSecondaryContainer: const Color(0xFFE4E4E4),
      tertiary: const Color(0xFF34D399),
      onTertiary: const Color(0xFF08251E),
      tertiaryContainer: const Color(0xFF064E3B),
      onTertiaryContainer: const Color(0xFFD1FAE5),
      surface: darkSurface,
      onSurface: darkText,
      surfaceContainerLowest: const Color(0xFF000000),
      surfaceContainerLow: const Color(0xFF070707),
      surfaceContainer: darkSurface,
      surfaceContainerHigh: darkSurfaceRaised,
      outline: darkBorder,
      outlineVariant: const Color(0xFF181818),
      error: const Color(0xFFFF8A80),
      onError: const Color(0xFF3B0805),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D0D0D),
        hintStyle: const TextStyle(color: darkMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryDark, width: 1.3),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder),
    );
  }
}
