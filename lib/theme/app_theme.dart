import 'package:flutter/material.dart';

class AppColors {
  static const Color azulMarino      = Color(0xFF1A2C56);
  static const Color azulMarinoClaro = Color(0xFF243B6B);
  static const Color dorado          = Color(0xFFF0A500);
  static const Color carmesin        = Color(0xFF8B1A1A);
  static const Color blanco          = Colors.white;
  static const Color fondo           = Color(0xFFFCFBF7);
  static const Color textoPrincipal  = Color(0xFF1F2937);
  static const Color textoSecundario = Color(0xFF6B7280);
}

class AppTheme {
  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azulMarino,
        brightness: Brightness.light,
        primary: AppColors.azulMarino,
        secondary: AppColors.dorado,
        surface: AppColors.fondo,
      ),
      scaffoldBackgroundColor: AppColors.fondo,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulMarino,
        foregroundColor: AppColors.blanco,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.blanco,
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.dorado,
        foregroundColor: AppColors.blanco,
      ),

      // SearchBar / InputDecoration limpia
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: const TextStyle(
          color: AppColors.textoSecundario,
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Typography clara y profesional
      textTheme: const TextTheme(
        // Lemas / headings principales en Playfair Serif
        headlineLarge: TextStyle(
          fontFamily: 'Playfair',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.azulMarino,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Playfair',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.azulMarino,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Playfair',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.azulMarino,
        ),
        // Cuerpo y definiciones en sans-serif moderna de alta legibilidad
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textoPrincipal,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.5,
          color: AppColors.textoPrincipal,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          color: AppColors.textoSecundario,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.azulMarino,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulMarino,
          foregroundColor: AppColors.blanco,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE5E7EB),
        selectedColor: AppColors.dorado,
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.azulMarino,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    const darkBg      = Color(0xFF111827);
    const darkSurface = Color(0xFF1F2937);
    const darkCard    = Color(0xFF374151);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.azulMarino,
        brightness: Brightness.dark,
        primary: AppColors.dorado,
        secondary: AppColors.azulMarinoClaro,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBg,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: AppColors.blanco,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.blanco,
        ),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.dorado,
        foregroundColor: AppColors.blanco,
      ),

      // SearchBar / InputDecoration limpia
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      ),

      // Typography
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Playfair',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.dorado,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Playfair',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.dorado,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Playfair',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.blanco,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFE5E7EB),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.5,
          color: Color(0xFFD1D5DB),
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          color: Color(0xFF9CA3AF),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.dorado,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dorado,
          foregroundColor: darkBg,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: AppColors.dorado,
        labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.blanco, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
      ),
    );
  }
}