import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_palette.dart';
import '../../core/number_format.dart';
import '../../logic/calculator_controller.dart';
import '../../logic/settings_controller.dart';

/// نمایشگر: عبارت در خط اول، نتیجه (یا پیش‌نمایش زنده) در خط دوم.
class DisplayPanel extends StatelessWidget {
  const DisplayPanel({
    super.key,
    required this.controller,
    required this.settings,
  });

  final CalculatorController controller;
  final SettingsController settings;

  Future<void> _copy(BuildContext context) async {
    final text = controller.copyableValue;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('مقدار کپی شد'),
          duration: Duration(milliseconds: 1200),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    final fmt = DisplayFormat(persian: settings.persianDigits);
    final evaluated = controller.evaluated;
    final error = controller.error;
    final isEmpty = !evaluated && controller.expression.isEmpty;

    final String topText;
    if (evaluated) {
      topText = fmt.expression(controller.committedExpression);
    } else if (isEmpty) {
      topText = fmt.digit('0');
    } else {
      topText = fmt.expression(controller.expression);
    }

    final String bottomText;
    if (evaluated) {
      bottomText = fmt.result(controller.rawResult ?? '');
    } else if (error != null) {
      bottomText = error;
    } else if (controller.preview != null) {
      bottomText = fmt.result(controller.preview!);
    } else {
      bottomText = '';
    }

    final topColor = evaluated || isEmpty ? p.textSecondary : p.textPrimary;
    final bottomColor = error != null
        ? p.error
        : (evaluated ? p.textPrimary : p.textSecondary);
    final bottomSize = evaluated ? 54.0 : (error != null ? 20.0 : 28.0);

    const duration = Duration(milliseconds: 220);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => _copy(context),
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0).abs() > 250) {
            if (settings.haptics) HapticFeedback.selectionClick();
            controller.backspace();
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                height: evaluated ? 34 : 66,
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AnimatedDefaultTextStyle(
                    duration: duration,
                    style: GoogleFonts.vazirmatn(
                      fontSize: evaluated ? 26 : 54,
                      fontWeight: FontWeight.w300,
                      color: topColor,
                    ),
                    child: Text(
                      topText,
                      maxLines: 1,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                height: evaluated ? 66 : 38,
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AnimatedDefaultTextStyle(
                    duration: duration,
                    style: GoogleFonts.vazirmatn(
                      fontSize: bottomSize,
                      fontWeight: evaluated ? FontWeight.w600 : FontWeight.w400,
                      color: bottomColor,
                    ),
                    child: Text(
                      bottomText,
                      maxLines: 1,
                      textDirection:
                          error != null ? TextDirection.rtl : TextDirection.ltr,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
