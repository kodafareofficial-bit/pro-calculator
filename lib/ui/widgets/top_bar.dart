import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_info.dart';
import '../../core/app_palette.dart';
import '../../logic/calculator_controller.dart';
import '../../logic/calculator_engine.dart';
import '../../logic/settings_controller.dart';
import 'app_logo.dart';
import 'app_sheet.dart';
import 'history_sheet.dart';
import 'settings_sheet.dart';

/// نوار بالایی: نام برنامه در سمت راست و دکمه‌های ابزار در سمت چپ.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.controller, required this.settings});

  final CalculatorController controller;
  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    final scientific = settings.scientific;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        children: [
          const AppLogo(size: 34),
          const SizedBox(width: 10),
          Text(
            AppInfo.appName,
            style: GoogleFonts.vazirmatn(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
          ),
          const Spacer(),
          if (scientific) ...[
            _AngleChip(settings: settings),
            const SizedBox(width: 4),
          ],
          IconButton(
            tooltip: 'تاریخچه',
            icon: Icon(Icons.history_rounded, color: p.textSecondary),
            onPressed: () => showAppSheet<void>(
              context,
              builder: (_) => HistorySheet(
                controller: controller,
                settings: settings,
              ),
            ),
          ),
          IconButton(
            tooltip: scientific ? 'ماشین‌حساب ساده' : 'ماشین‌حساب علمی',
            icon: Icon(
              scientific ? Icons.apps_rounded : Icons.functions_rounded,
              color: scientific ? p.accentStrong : p.textSecondary,
            ),
            onPressed: settings.toggleScientific,
          ),
          IconButton(
            tooltip: 'تنظیمات',
            icon: Icon(Icons.tune_rounded, color: p.textSecondary),
            onPressed: () => showAppSheet<void>(
              context,
              builder: (_) => SettingsSheet(settings: settings),
            ),
          ),
        ],
      ),
    );
  }
}

class _AngleChip extends StatelessWidget {
  const _AngleChip({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    final degrees = settings.angleMode == AngleMode.degrees;
    return Semantics(
      button: true,
      label: degrees ? 'حالت زاویه: درجه' : 'حالت زاویه: رادیان',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: settings.toggleAngleMode,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: p.keyFunction,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            degrees ? 'درجه' : 'رادیان',
            style: GoogleFonts.vazirmatn(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: p.accent,
            ),
          ),
        ),
      ),
    );
  }
}
