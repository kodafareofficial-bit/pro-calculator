import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_palette.dart';

enum CalcKeyKind { digit, function, operator, equals }

/// یک دکمه‌ی ماشین‌حساب با انیمیشن لمس و پشتیبانی از دسترس‌پذیری.
class CalcKey extends StatefulWidget {
  const CalcKey({
    super.key,
    required this.kind,
    required this.onTap,
    this.label,
    this.icon,
    this.onLongPress,
    this.semanticLabel,
    this.fontSize = 26,
  }) : assert(label != null || icon != null);

  final CalcKeyKind kind;
  final VoidCallback onTap;
  final String? label;
  final IconData? icon;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final double fontSize;

  @override
  State<CalcKey> createState() => _CalcKeyState();
}

class _CalcKeyState extends State<CalcKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);

    final Color foreground;
    final Color? fill;
    final Gradient? gradient;
    final List<BoxShadow> shadow;

    switch (widget.kind) {
      case CalcKeyKind.digit:
        fill = p.keyDigit;
        foreground = p.textPrimary;
        gradient = null;
        shadow = p.keyShadow;
      case CalcKeyKind.function:
        fill = p.keyFunction;
        foreground = p.accent;
        gradient = null;
        shadow = p.keyShadow;
      case CalcKeyKind.operator:
        fill = p.keyOperator;
        foreground = p.accentStrong;
        gradient = null;
        shadow = p.keyShadow;
      case CalcKeyKind.equals:
        fill = null;
        foreground = Colors.white;
        gradient = CalcPalette.brandGradient;
        shadow = const [
          BoxShadow(
            color: CalcPalette.brandGlow,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ];
    }

    final pressedFill =
        fill == null ? null : Color.alphaBlend(p.pressOverlay, fill);

    final Widget content = widget.icon != null
        ? Icon(widget.icon, size: widget.fontSize + 2, color: foreground)
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.label!,
              style: GoogleFonts.vazirmatn(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          );

    return Semantics(
      button: true,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _pressed ? pressedFill : fill,
              gradient: gradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: shadow,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
