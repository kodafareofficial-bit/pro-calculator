import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/number_format.dart';
import '../../logic/calculator_controller.dart';
import '../../logic/settings_controller.dart';
import 'calc_key.dart';

/// صفحه‌کلید ماشین‌حساب (چیدمان اعداد همیشه چپ‌به‌راست و استاندارد است).
class Keypad extends StatelessWidget {
  const Keypad({
    super.key,
    required this.controller,
    required this.settings,
    required this.keyHeight,
    required this.gap,
  });

  final CalculatorController controller;
  final SettingsController settings;
  final double keyHeight;
  final double gap;

  static const Map<String, String> _digitNames = {
    '0': 'صفر',
    '1': 'یک',
    '2': 'دو',
    '3': 'سه',
    '4': 'چهار',
    '5': 'پنج',
    '6': 'شش',
    '7': 'هفت',
    '8': 'هشت',
    '9': 'نه',
  };

  void _press(VoidCallback action) {
    if (settings.haptics) HapticFeedback.selectionClick();
    action();
  }

  Widget _row(List<Widget> keys) {
    return SizedBox(
      height: keyHeight,
      child: Row(
        children: [
          for (var i = 0; i < keys.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: keys[i]),
          ],
        ],
      ),
    );
  }

  Widget _digit(String d, DisplayFormat fmt) => CalcKey(
        kind: CalcKeyKind.digit,
        label: fmt.digit(d),
        semanticLabel: _digitNames[d],
        onTap: () => _press(() => controller.inputDigit(d)),
      );

  Widget _operator(String symbol, String name) => CalcKey(
        kind: CalcKeyKind.operator,
        label: symbol,
        semanticLabel: name,
        onTap: () => _press(() => controller.inputOperator(symbol)),
      );

  Widget _sci(String label, String name, VoidCallback action) => CalcKey(
        kind: CalcKeyKind.function,
        label: label,
        semanticLabel: name,
        fontSize: 18,
        onTap: () => _press(action),
      );

  @override
  Widget build(BuildContext context) {
    final fmt = DisplayFormat(persian: settings.persianDigits);
    final c = controller;

    final scientificRows = <Widget>[
      _row([
        _sci('sin', 'سینوس', () => c.inputFunction('sin(')),
        _sci('cos', 'کسینوس', () => c.inputFunction('cos(')),
        _sci('tan', 'تانژانت', () => c.inputFunction('tan(')),
        _sci('π', 'عدد پی', () => c.inputConstant('π')),
        _sci('e', 'عدد نپر', () => c.inputConstant('e')),
      ]),
      SizedBox(height: gap),
      _row([
        _sci('ln', 'لگاریتم طبیعی', () => c.inputFunction('ln(')),
        _sci('log', 'لگاریتم', () => c.inputFunction('log(')),
        _sci('√', 'ریشه دوم', () => c.inputFunction('√(')),
        _sci('xʸ', 'توان', () => c.inputOperator('^')),
        _sci('!', 'فاکتوریل', () => c.inputPostfix('!')),
      ]),
      SizedBox(height: gap),
    ];

    final mainRows = <Widget>[
      _row([
        CalcKey(
          kind: CalcKeyKind.function,
          label: 'AC',
          semanticLabel: 'پاک کردن همه',
          fontSize: 22,
          onTap: () => _press(c.clear),
        ),
        CalcKey(
          kind: CalcKeyKind.function,
          icon: Icons.backspace_outlined,
          semanticLabel: 'حذف',
          fontSize: 20,
          onTap: () => _press(c.backspace),
          onLongPress: () => _press(c.clear),
        ),
        CalcKey(
          kind: CalcKeyKind.function,
          label: '%',
          semanticLabel: 'درصد',
          onTap: () => _press(() => c.inputPostfix('%')),
        ),
        _operator('÷', 'تقسیم'),
      ]),
      SizedBox(height: gap),
      _row([
        _digit('7', fmt),
        _digit('8', fmt),
        _digit('9', fmt),
        _operator('×', 'ضرب'),
      ]),
      SizedBox(height: gap),
      _row([
        _digit('4', fmt),
        _digit('5', fmt),
        _digit('6', fmt),
        _operator('−', 'تفریق'),
      ]),
      SizedBox(height: gap),
      _row([
        _digit('1', fmt),
        _digit('2', fmt),
        _digit('3', fmt),
        _operator('+', 'جمع'),
      ]),
      SizedBox(height: gap),
      _row([
        CalcKey(
          kind: CalcKeyKind.function,
          label: '( )',
          semanticLabel: 'پرانتز',
          fontSize: 22,
          onTap: () => _press(c.inputBracket),
        ),
        _digit('0', fmt),
        CalcKey(
          kind: CalcKeyKind.digit,
          label: fmt.decimalSeparator,
          semanticLabel: 'ممیز',
          onTap: () => _press(c.inputDot),
        ),
        CalcKey(
          kind: CalcKeyKind.equals,
          label: '=',
          semanticLabel: 'مساوی',
          fontSize: 30,
          onTap: () => _press(c.calculate),
        ),
      ]),
    ];

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (settings.scientific) ...scientificRows,
            ...mainRows,
          ],
        ),
      ),
    );
  }
}
