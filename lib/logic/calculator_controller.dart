import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/number_format.dart';
import 'calculator_engine.dart';
import 'settings_controller.dart';

/// یک مورد از تاریخچه‌ی محاسبات.
@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.expression,
    required this.result,
    required this.time,
  });

  final String expression;
  final String result;
  final DateTime time;

  Map<String, dynamic> toJson() => {
        'e': expression,
        'r': result,
        't': time.millisecondsSinceEpoch,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        expression: json['e'] as String,
        result: json['r'] as String,
        time: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
      );
}

/// وضعیت و منطق ورودی ماشین‌حساب (جدا از UI).
class CalculatorController extends ChangeNotifier {
  CalculatorController(this._prefs, this.settings) {
    _loadHistory();
    settings.addListener(_onSettingsChanged);
  }

  static const _kHistory = 'calculator.history';
  static const _maxHistory = 100;
  static const _maxLength = 100;
  static const _maxDigits = 15;
  static const _functionTokens = ['sin(', 'cos(', 'tan(', 'ln(', 'log(', '√('];

  final SharedPreferences _prefs;
  final SettingsController settings;
  final CalculatorEngine _engine = const CalculatorEngine();

  String _expression = '';
  String _committed = '';
  String? _rawResult;
  String? _preview;
  String? _error;
  bool _evaluated = false;
  List<HistoryEntry> _history = [];

  String get expression => _expression;
  String get committedExpression => _committed;
  String? get rawResult => _rawResult;
  String? get preview => _preview;
  String? get error => _error;
  bool get evaluated => _evaluated;
  List<HistoryEntry> get history => List.unmodifiable(_history);

  /// مقداری که با نگه‌داشتن روی صفحه کپی می‌شود (با ارقام لاتین).
  String? get copyableValue {
    final value = _evaluated ? _rawResult : _preview;
    return value?.replaceAll('−', '-');
  }

  @override
  void dispose() {
    settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    _updatePreview();
    notifyListeners();
  }

  // ---------------------------------------------------------------- helpers

  String get _last =>
      _expression.isEmpty ? '' : _expression[_expression.length - 1];

  static bool _isDigitChar(String c) {
    if (c.isEmpty) return false;
    final u = c.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  static bool _isOperatorChar(String c) =>
      c == '+' || c == '−' || c == '×' || c == '÷' || c == '^';

  bool get _endsWithDigit => _isDigitChar(_last);

  bool get _endsWithValue =>
      _endsWithDigit ||
      _last == ')' ||
      _last == 'π' ||
      _last == 'e' ||
      _last == '%' ||
      _last == '!';

  String get _trailingNumber =>
      RegExp(r'(\d*\.?\d*)$').firstMatch(_expression)?.group(1) ?? '';

  int get _openParens => '('.allMatches(_expression).length;
  int get _closeParens => ')'.allMatches(_expression).length;

  bool _append(String text) {
    if (_expression.length + text.length > _maxLength) return false;
    _expression += text;
    return true;
  }

  void _prepareForInput({required bool continueFromResult}) {
    _error = null;
    if (_evaluated) {
      _expression = continueFromResult ? (_rawResult ?? '') : '';
      _evaluated = false;
    }
  }

  void _afterChange() {
    _updatePreview();
    notifyListeners();
  }

  void _updatePreview() {
    _preview = null;
    if (_evaluated || _expression.isEmpty) return;
    if (RegExp(r'^−?[0-9.]*$').hasMatch(_expression)) return;
    try {
      final value = _engine.evaluate(_expression, angle: settings.angleMode);
      _preview = plainNumber(value);
    } catch (_) {
      _preview = null;
    }
  }

  // ------------------------------------------------------------------ input

  void inputDigit(String digit) {
    _prepareForInput(continueFromResult: false);
    final token = _trailingNumber;
    if (token.replaceAll('.', '').length >= _maxDigits) {
      notifyListeners();
      return;
    }
    if (token == '0') {
      _expression = _expression.substring(0, _expression.length - 1);
    } else if (token.isEmpty && _endsWithValue) {
      _expression += '×';
    }
    _append(digit);
    _afterChange();
  }

  void inputDot() {
    _prepareForInput(continueFromResult: false);
    final token = _trailingNumber;
    if (token.contains('.')) {
      notifyListeners();
      return;
    }
    if (token.isNotEmpty) {
      _append('.');
    } else {
      if (_endsWithValue) _expression += '×';
      _append('0.');
    }
    _afterChange();
  }

  void inputOperator(String op) {
    _error = null;
    if (_evaluated) {
      _expression = _rawResult ?? '';
      _evaluated = false;
    }
    if (_expression.isEmpty) {
      if (op == '−') _append('−');
      _afterChange();
      return;
    }
    final last = _last;
    if (_isOperatorChar(last)) {
      if (op == '−' && (last == '×' || last == '÷' || last == '^')) {
        _append(op);
      } else {
        var base = _expression;
        while (base.isNotEmpty && _isOperatorChar(base[base.length - 1])) {
          base = base.substring(0, base.length - 1);
        }
        if ((base.isEmpty || base.endsWith('(')) && op != '−') {
          notifyListeners();
          return;
        }
        _expression = base + op;
      }
    } else if (last == '(') {
      if (op == '−') _append(op);
    } else {
      _append(op);
    }
    _afterChange();
  }

  /// درصد (`%`) و فاکتوریل (`!`).
  void inputPostfix(String symbol) {
    _error = null;
    if (_evaluated) {
      _expression = _rawResult ?? '';
      _evaluated = false;
    }
    if (_endsWithDigit || _last == ')' || _last == 'π' || _last == 'e') {
      _append(symbol);
    }
    _afterChange();
  }

  /// دکمه‌ی هوشمند پرانتز: بسته یا باز را بر اساس زمینه انتخاب می‌کند.
  void inputBracket() {
    final canClose = _openParens > _closeParens &&
        !_evaluated &&
        (_endsWithValue);
    if (canClose) {
      _error = null;
      _append(')');
      _afterChange();
    } else {
      _prepareForInput(continueFromResult: false);
      if (_endsWithValue) _expression += '×';
      _append('(');
      _afterChange();
    }
  }

  void inputFunction(String token) {
    _prepareForInput(continueFromResult: false);
    if (_endsWithValue) _expression += '×';
    _append(token);
    _afterChange();
  }

  void inputConstant(String symbol) {
    _prepareForInput(continueFromResult: false);
    if (_endsWithValue) _expression += '×';
    _append(symbol);
    _afterChange();
  }

  void backspace() {
    _error = null;
    if (_evaluated) {
      _expression = _committed;
      _evaluated = false;
      _afterChange();
      return;
    }
    if (_expression.isEmpty) {
      notifyListeners();
      return;
    }
    var removed = false;
    for (final token in _functionTokens) {
      if (_expression.endsWith(token)) {
        _expression = _expression.substring(0, _expression.length - token.length);
        removed = true;
        break;
      }
    }
    if (!removed) {
      _expression = _expression.substring(0, _expression.length - 1);
    }
    _afterChange();
  }

  void clear() {
    _expression = '';
    _committed = '';
    _rawResult = null;
    _preview = null;
    _error = null;
    _evaluated = false;
    notifyListeners();
  }

  void calculate() {
    if (_evaluated || _expression.isEmpty) return;
    try {
      final value = _engine.evaluate(_expression, angle: settings.angleMode);
      final raw = plainNumber(value);
      final isPlainNumber = _expression == raw;
      _committed = _expression;
      _rawResult = raw;
      _evaluated = true;
      _error = null;
      _preview = null;
      if (!isPlainNumber) {
        _pushHistory(
          HistoryEntry(expression: _committed, result: raw, time: DateTime.now()),
        );
      }
    } on CalcException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'عبارت نامعتبر است';
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------- history

  void useResult(HistoryEntry entry) {
    _error = null;
    if (_evaluated || _expression.isEmpty) {
      _expression = entry.result;
      _evaluated = false;
    } else {
      if (_endsWithValue) _expression += '×';
      _expression += entry.result;
    }
    _afterChange();
  }

  void restoreExpression(HistoryEntry entry) {
    _error = null;
    _expression = entry.expression;
    _evaluated = false;
    _afterChange();
  }

  void removeHistoryAt(int index) {
    if (index < 0 || index >= _history.length) return;
    _history = List.of(_history)..removeAt(index);
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history = [];
    _saveHistory();
    notifyListeners();
  }

  void _pushHistory(HistoryEntry entry) {
    final next = [entry, ..._history];
    _history = next.length > _maxHistory ? next.sublist(0, _maxHistory) : next;
    _saveHistory();
  }

  void _loadHistory() {
    final raw = _prefs.getString(_kHistory);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _history = list
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _history = [];
    }
  }

  void _saveHistory() {
    _prefs.setString(
      _kHistory,
      jsonEncode(_history.map((e) => e.toJson()).toList()),
    );
  }
}
