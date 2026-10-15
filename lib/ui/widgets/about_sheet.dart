import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_info.dart';
import '../../core/app_palette.dart';
import '../../core/number_format.dart';
import 'app_logo.dart';

/// صفحه‌ی «درباره‌ی برنامه» با نام توسعه‌دهنده.
class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(size: 72),
          const SizedBox(height: 16),
          Text(
            AppInfo.appName,
            style: GoogleFonts.vazirmatn(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: p.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppInfo.tagline,
            style: GoogleFonts.vazirmatn(fontSize: 14, color: p.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'نسخه ${toPersianDigits(AppInfo.version)}',
            style: GoogleFonts.vazirmatn(fontSize: 13, color: p.textSecondary),
          ),
          const SizedBox(height: 20),
          Divider(color: p.divider, height: 1),
          const SizedBox(height: 20),
          Text(
            AppInfo.developerLabel,
            style: GoogleFonts.vazirmatn(fontSize: 13, color: p.textSecondary),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                CalcPalette.brandGradient.createShader(bounds),
            child: Text(
              AppInfo.developer,
              style: GoogleFonts.vazirmatn(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppInfo.copyright,
            textAlign: TextAlign.center,
            style: GoogleFonts.vazirmatn(fontSize: 12, color: p.textSecondary),
          ),
        ],
      ),
    );
  }
}
