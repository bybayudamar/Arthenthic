import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// macOS Golden Gate Design System for Arthentic
/// Light mode as default setting, Plus Jakarta Sans typeface,
/// and California coastal golden gate amber / international orange accents
/// blended with Apple frosted glass vibrancy.
class AppTheme {
  // Airbnb Design System Palette & Coral Signature
  static const Color airbnbCoral = Color(0xFFFF385C);      // Airbnb Signature Rausch Coral
  static const Color airbnbDarkCoral = Color(0xFFE00B41);
  static const Color airbnbBg = Color(0xFFF7F7F7);
  static const Color airbnbBorder = Color(0xFFEBEBEB);
  static const Color airbnbTextSecondary = Color(0xFF717171);

  // Golden Gate & Pacific coastal palette
  static const Color goldenGateOrange = airbnbCoral; // Harmonized with Airbnb Coral
  static const Color goldenGateAccent = Color(0xFFF06543);
  static const Color sunsetAmber = Color(0xFFD97706);      // Warm Golden Amber
  static const Color champagneGold = Color(0xFFF59E0B);
  static const Color pacificNavy = Color(0xFF0F172A);       // Deep Obsidian / Pacific Slate
  static const Color pacificSlate = Color(0xFF334155);

  // Surface & Background (Light mode default)
  static const Color bgLight = Color(0xFFF8F9FB);          // macOS Light background
  static const Color bgSubtle = Color(0xFFF1F3F7);
  static const Color cardBg = Colors.white;
  static const Color glassWhite = Color(0xEBFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFEEF2F6);

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Functional & Status
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF0071E3);         // Cupertino Blue

  // Legacy compatibility aliases
  static const Color brandBlue = Color(0xFF0071E3);
  static const Color brandDark = pacificNavy;
  static const Color bubbleYellow = champagneGold;
  static const Color bubbleBlue = infoBlue;
  static const Color bubbleCoral = goldenGateOrange;
  static const Color goldBadgeBg = Color(0xFFFEF3C7);
  static const Color goldBadgeText = Color(0xFFB45309);
  static const Color softLavender = Color(0xFFF1F5F9);

  // macOS Window decoration shadows
  static List<BoxShadow> get macCardShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get goldenGlowShadow => [
        BoxShadow(
          color: goldenGateOrange.withValues(alpha: 0.18),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: goldenGateOrange,
        onPrimary: Colors.white,
        secondary: sunsetAmber,
        onSecondary: Colors.white,
        tertiary: infoBlue,
        onTertiary: Colors.white,
        error: dangerRed,
        onError: Colors.white,
        surface: cardBg,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary, size: 20),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.8,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.6,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldenGateOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderLight, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
