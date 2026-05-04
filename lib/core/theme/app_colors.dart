import 'dart:ui';

/// Exact color system from Kinetix-Flow CSS variables (dark mode).
class AppColors {
  AppColors._();

  // --- Core Palette (VibeMove Dark Theme) ---
  static const Color background = Color(0xFF111112);
  static const Color foreground = Color(0xFFF2F2F7);
  static const Color card = Color(0xFF1C1C1E);
  static const Color cardForeground = Color(0xFFF2F2F7);

  // --- Brand Colors ---
  static const Color primary = Color(0xFFFF6B57); // Bright Coral
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF557A64); // Sage Green
  static const Color secondaryForeground = Color(0xFFFFFFFF);

  // --- Muted/Neutral ---
  static const Color muted = Color(0xFF2C2C2E);
  static const Color mutedForeground = Color(0xFF8E8E93);
  static const Color border = Color(0xFF2C2C2E);
  static const Color input = Color(0xFF2C2C2E);

  // --- Accent ---
  static const Color accent = Color(0xFF2C2C2E);
  static const Color accentForeground = Color(0xFFFF6B57);

  // --- Semantic ---
  static const Color destructive = Color(0xFFFF3B30);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color ring = Color(0xFFFF6B57);

  // --- Welcome/Landing Page Colors (neon theme) ---
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color slateBg = Color(0xFF020617);

  // --- Light Mode (for future reference) ---
  static const Color lightBackground = Color(0xFFF4F4F5);
  static const Color lightForeground = Color(0xFF1C1C1E);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5EA);
  static const Color lightMuted = Color(0xFFE5E5EA);
}
