import 'package:flutter/material.dart';

/// Палитра Fitty: фиолетовый + коралловый, чистый белый фон.
class AppColors {
  static const primary = Color(0xFF8B5CF6);
  static const primaryDark = Color(0xFF6D3FD8);
  static const primarySoft = Color(0xFFF1EBFF);

  static const accent = Color(0xFFFF7A59);
  static const accentDark = Color(0xFFE0583A);

  static const mint = Color(0xFF2DD4A7);
  static const danger = Color(0xFFFF4B4B);

  static const bg = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF7F7FB);
  static const border = Color(0xFFE5E5EE);
  static const borderDark = Color(0xFFD3D3E0);

  static const text = Color(0xFF2B2B3A);
  static const textSoft = Color(0xFF8A8AA0);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.bg,
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: AppColors.text,
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
