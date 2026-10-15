import 'package:flutter/material.dart';

import '../../core/app_palette.dart';

/// لوگوی برنامه (مربع گرد با گرادیان و آیکون ماشین‌حساب).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: CalcPalette.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: CalcPalette.brandGlow,
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.calculate_rounded,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}
