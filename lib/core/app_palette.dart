import 'package:flutter/material.dart';

/// پالت رنگی یکپارچه‌ی برنامه برای حالت روشن و تیره.
@immutable
class CalcPalette {
  const CalcPalette({
    required this.isDark,
    required this.background,
    required this.backgroundTop,
    required this.sheet,
    required this.textPrimary,
    required this.textSecondary,
    required this.keyDigit,
    required this.keyFunction,
    required this.keyOperator,
    required this.accent,
    required this.accentStrong,
    required this.error,
    required this.pressOverlay,
    required this.keyShadow,
    required this.divider,
  });

  final bool isDark;
  final Color background;
  final Color backgroundTop;
  final Color sheet;
  final Color textPrimary;
  final Color textSecondary;
  final Color keyDigit;
  final Color keyFunction;
  final Color keyOperator;

  /// رنگ متن دکمه‌های عملکردی (AC، پرانتز، درصد و ...).
  final Color accent;

  /// رنگ متن دکمه‌های عملگر (+ − × ÷).
  final Color accentStrong;
  final Color error;
  final Color pressOverlay;
  final List<BoxShadow> keyShadow;
  final Color divider;

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const Color brandGlow = Color(0x666366F1);

  static const CalcPalette dark = CalcPalette(
    isDark: true,
    background: Color(0xFF0B1020),
    backgroundTop: Color(0xFF151C3D),
    sheet: Color(0xFF121832),
    textPrimary: Color(0xFFF1F4FF),
    textSecondary: Color(0xFF8E98B8),
    keyDigit: Color(0xFF1A2140),
    keyFunction: Color(0xFF252E55),
    keyOperator: Color(0xFF2A2F66),
    accent: Color(0xFF5EEAD4),
    accentStrong: Color(0xFFA5B4FF),
    error: Color(0xFFFF6B81),
    pressOverlay: Color(0x1FFFFFFF),
    keyShadow: <BoxShadow>[],
    divider: Color(0x1FFFFFFF),
  );

  static const CalcPalette light = CalcPalette(
    isDark: false,
    background: Color(0xFFF1F3FA),
    backgroundTop: Color(0xFFFFFFFF),
    sheet: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF10142B),
    textSecondary: Color(0xFF6B7391),
    keyDigit: Color(0xFFFFFFFF),
    keyFunction: Color(0xFFE5E9F6),
    keyOperator: Color(0xFFE3E2FF),
    accent: Color(0xFF0F766E),
    accentStrong: Color(0xFF4F46E5),
    error: Color(0xFFE11D48),
    pressOverlay: Color(0x14000000),
    keyShadow: <BoxShadow>[
      BoxShadow(
        color: Color(0x1A1E2A5A),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
    divider: Color(0x1A000000),
  );

  static CalcPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
