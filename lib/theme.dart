import 'package:flutter/material.dart';

/// MetroPulse color system
class MPColors {
  // Brand and lines
  static const purple = Color(0xFF7B3FF2);
  static const green = Color(0xFF28A745);
  static const yellow = Color(0xFFFFC107);
  static const red = Color(0xFFDC3545);

  // Base
  static const background = Color(0xFFF8F9FA); // light gray background
  static const surface = Color(0xFFFFFFFF); // white cards
  static const textDark = Color(0xFF1A202C);
  static const textSecondary = Color(0xFF4A5568);

  // Gradients
  static const gradientStart = Color(0xFF667EEA);
  static const gradientEnd = Color(0xFF764BA2);

  // Crowd levels
  static const crowdLow = green;
  static const crowdModerate = yellow;
  static const crowdHigh = red;
}

class FontSizes {
  static const double h1 = 28.0; // headers 24-28
  static const double h2 = 24.0;
  static const double body = 16.0; // base body
  static const double label = 14.0;
  static const double small = 12.0;
}

ThemeData get lightTheme {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  final scheme = ColorScheme.fromSeed(
    seedColor: MPColors.purple,
    brightness: Brightness.light,
    primary: MPColors.purple,
    surface: MPColors.surface,
    error: MPColors.red,
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: MPColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: MPColors.surface,
      foregroundColor: MPColors.textDark,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: MPColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    textTheme: base.textTheme.copyWith(
      headlineMedium: const TextStyle(
        fontSize: FontSizes.h1,
        fontWeight: FontWeight.w700,
        color: MPColors.textDark,
      ),
      headlineSmall: const TextStyle(
        fontSize: FontSizes.h2,
        fontWeight: FontWeight.w700,
        color: MPColors.textDark,
      ),
      bodyLarge: const TextStyle(
        fontSize: FontSizes.body,
        fontWeight: FontWeight.w400,
        color: MPColors.textDark,
      ),
      bodyMedium: const TextStyle(
        fontSize: FontSizes.label,
        fontWeight: FontWeight.w400,
        color: MPColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: FontSizes.label,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(Colors.white),
        backgroundColor: WidgetStateProperty.all(MPColors.purple),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: MPColors.purple,
      unselectedItemColor: MPColors.textSecondary.withValues(alpha: 0.7),
      type: BottomNavigationBarType.fixed,
      backgroundColor: MPColors.surface,
    ),
  );
}

ThemeData get darkTheme {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  final scheme = ColorScheme.fromSeed(
    seedColor: MPColors.purple,
    brightness: Brightness.dark,
    primary: MPColors.purple,
    error: MPColors.red,
  );

  return base.copyWith(
    colorScheme: scheme,
    appBarTheme: AppBarTheme(
      backgroundColor: base.colorScheme.surface,
      foregroundColor: base.colorScheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: base.colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: MPColors.purple,
      unselectedItemColor: base.colorScheme.onSurface.withValues(alpha: 0.7),
      type: BottomNavigationBarType.fixed,
      backgroundColor: base.colorScheme.surface,
    ),
  );
}

/// Common gradients and decorations
class MPDecorations {
  static const LinearGradient purpleHeaderGradient = LinearGradient(
    colors: [MPColors.gradientStart, MPColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
