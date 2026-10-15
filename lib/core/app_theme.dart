import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette =
        brightness == Brightness.dark ? CalcPalette.dark : CalcPalette.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: palette.background,
    );
    return base.copyWith(
      textTheme: GoogleFonts.vazirmatnTextTheme(base.textTheme),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.isDark
            ? const Color(0xFF252E55)
            : const Color(0xFF1B2140),
        contentTextStyle: GoogleFonts.vazirmatn(color: Colors.white),
      ),
    );
  }
}
