import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system matching Inter (body) + Playfair Display (headings).
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    final bodyFont = GoogleFonts.interTextTheme();
    final headingFont = GoogleFonts.playfairDisplayTextTheme();

    return bodyFont.copyWith(
      // Headlines use Playfair Display (serif)
      displayLarge: headingFont.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      displayMedium: headingFont.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      displaySmall: headingFont.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      headlineLarge: headingFont.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      headlineMedium: headingFont.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      headlineSmall: headingFont.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF2F2F7),
      ),
      // Titles use Playfair Display
      titleLarge: headingFont.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      titleMedium: headingFont.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFFF2F2F7),
      ),
      // Body uses Inter
      bodyLarge: bodyFont.bodyLarge?.copyWith(
        color: const Color(0xFFF2F2F7),
      ),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
        color: const Color(0xFFF2F2F7),
      ),
      bodySmall: bodyFont.bodySmall?.copyWith(
        color: const Color(0xFF8E8E93),
      ),
      // Labels use Inter
      labelLarge: bodyFont.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFF2F2F7),
      ),
      labelMedium: bodyFont.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: const Color(0xFF8E8E93),
      ),
      labelSmall: bodyFont.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: const Color(0xFF8E8E93),
      ),
    );
  }
}
