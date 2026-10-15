import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_info.dart';
import '../../core/app_palette.dart';
import '../../logic/settings_controller.dart';
import 'about_sheet.dart';
import 'app_sheet.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    final titleStyle = GoogleFonts.vazirmatn(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: p.textPrimary,
    );
    final labelStyle = GoogleFonts.vazirmatn(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: p.textSecondary,
    );
    final bodyStyle = GoogleFonts.vazirmatn(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: p.textPrimary,
    );

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تنظیمات', style: titleStyle),
              const SizedBox(height: 20),
              Text('ظاهر برنامه', style: labelStyle),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('خودکار')),
                  ButtonSegment(value: ThemeMode.light, label: Text('روشن')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('تیره')),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) =>
                    settings.setThemeMode(selection.first),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('ارقام فارسی', style: bodyStyle),
                subtitle: Text(
                  'نمایش اعداد به صورت ۱۲۳ به جای 123',
                  style: labelStyle,
                ),
                value: settings.persianDigits,
                onChanged: settings.setPersianDigits,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('لرزش هنگام لمس', style: bodyStyle),
                value: settings.haptics,
                onChanged: settings.setHaptics,
              ),
              Divider(color: p.divider, height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline_rounded, color: p.accentStrong),
                title: Text('درباره‌ی برنامه', style: bodyStyle),
                subtitle: Text(
                  '${AppInfo.developerLabel}: ${AppInfo.developer}',
                  style: labelStyle,
                ),
                trailing: Icon(
                  Icons.chevron_left_rounded,
                  color: p.textSecondary,
                ),
                onTap: () => showAppSheet<void>(
                  context,
                  builder: (_) => const AboutSheet(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
