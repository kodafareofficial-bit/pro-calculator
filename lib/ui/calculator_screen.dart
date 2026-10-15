import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_palette.dart';
import '../logic/calculator_controller.dart';
import '../logic/settings_controller.dart';
import 'widgets/display_panel.dart';
import 'widgets/keypad.dart';
import 'widgets/top_bar.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({
    super.key,
    required this.settings,
    required this.controller,
  });

  final SettingsController settings;
  final CalculatorController controller;

  static const double _gap = 12;
  static const double _horizontalPadding = 16;
  static const double _bottomPadding = 16;
  static const double _minDisplayHeight = 200;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    final overlay =
        (p.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: p.background,
      systemNavigationBarIconBrightness:
          p.isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: p.background,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [p.backgroundTop, p.background],
            ),
          ),
          child: SafeArea(
            child: ListenableBuilder(
              listenable: Listenable.merge([settings, controller]),
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // ارتفاع دکمه‌ها همیشه طوری محاسبه می‌شود که حالت علمی
                    // (۷ ردیف) هم جا شود؛ بنابراین با تغییر حالت، اندازه‌ها
                    // نمی‌پرند.
                    final keyWidth = (constraints.maxWidth -
                            _horizontalPadding * 2 -
                            _gap * 3) /
                        4;
                    const maxRows = 7;
                    final maxKeyHeight = (constraints.maxHeight -
                            _minDisplayHeight -
                            _bottomPadding -
                            _gap * (maxRows - 1)) /
                        maxRows;
                    final keyHeight = math
                        .min(keyWidth * 0.95, maxKeyHeight)
                        .clamp(44.0, 100.0)
                        .toDouble();

                    return Column(
                      children: [
                        TopBar(controller: controller, settings: settings),
                        Expanded(
                          child: DisplayPanel(
                            controller: controller,
                            settings: settings,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            _horizontalPadding,
                            8,
                            _horizontalPadding,
                            _bottomPadding,
                          ),
                          child: Keypad(
                            controller: controller,
                            settings: settings,
                            keyHeight: keyHeight,
                            gap: _gap,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
