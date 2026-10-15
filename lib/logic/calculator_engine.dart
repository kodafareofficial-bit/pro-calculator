import 'dart:math' as math;

/// حالت زاویه برای توابع مثلثاتی.
enum AngleMode { degrees, radians }

/// خطای محاسبه؛ پیام آن برای نمایش به کاربر آماده است.
class CalcException implements Exception {
  const CalcException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// موتور محاسبه‌ی عبارت‌های ریاضی (بدون وابستگی به UI).
///
/// پشتیبانی: `+ − × ÷ ^ % ! √ ( )`، ثابت‌های `π` و `e`، توابع
/// `sin cos tan ln log sqrt abs`، ضرب ضمنی (مثل `2π` و `3(4+1)`)،
/// نماد علمی (`1.5E+3`) و بستن خودکار پرانتزهای باز.
class CalculatorEngine {
  const CalculatorEngine();

  double evaluate(String expression, {AngleMode angle = AngleMode.degrees}) {
    final value = _Parser(expression, angle).parse();
    if (value.isNaN || value.isInfinite) {
      throw const CalcException('نتیجه نامعتبر است');
    }
    return _round12(value);
  }
}

/// گرد کردن به ۱۲ رقم معنادار برای حذف خطای ممیز شناور (۰٫۱+۰٫۲ = ۰٫۳).
double _round12(double v) {
  if (v == 0) return 0;
  return double.parse(v.toStringAsPrecision(12));
}

class _Parser {
  _Parser(this.src, this.angle);

  final String src;
  final AngleMode angle;
  int _pos = 0;

  /// آیا آخرین فاکتور تجزیه‌شده با «%» تمام شده است؟
  bool _lastFactorPercent = false;

  /// آیا آخرین جمله فقط یک درصدِ ساده بود (مثل `10%`)؟
  bool _termIsBarePercent = false;

  static const CalcException _invalid = CalcException('عبارت نامعتبر است');
  static const CalcException _incomplete = CalcException('عبارت ناقص است');
  static const CalcException _domain = CalcException('ورودی نامعتبر است');
  static const CalcException _divZero = CalcException('تقسیم بر صفر');

  double parse() {
    if (src.trim().isEmpty) throw _incomplete;
    final value = _expression();
    if (_peek() != null) throw _invalid;
    return value;
  }

  String? _peek() {
    while (_pos < src.length && src[_pos] == ' ') {
      _pos++;
    }
    return _pos < src.length ? src[_pos] : null;
  }

  static bool _isDigit(String ch) {
    final u = ch.codeUnitAt(0);
    return u >= 48 && u <= 57;
  }

  static bool _isLetter(String ch) {
    final u = ch.codeUnitAt(0);
    return (u >= 97 && u <= 122) || (u >= 65 && u <= 90);
  }

  static bool _startsPrimary(String? c) {
    if (c == null) return false;
    return _isDigit(c) ||
        c == '.' ||
        c == '(' ||
        c == 'π' ||
        c == '√' ||
        _isLetter(c);
  }

  // expression := term (('+' | '−') term)*
  double _expression() {
    var left = _term();
    while (true) {
      final c = _peek();
      if (c == '+' || c == '−' || c == '-') {
        _pos++;
        final right = _term();
        // «۲۰۰ + ۱۰٪» یعنی ۲۰۰ به‌علاوه‌ی ۱۰٪ از ۲۰۰.
        final operand = _termIsBarePercent ? left * right : right;
        left = c == '+' ? left + operand : left - operand;
      } else {
        return left;
      }
    }
  }

  // term := unary (('×' | '÷' | implicit) unary)*
  double _term() {
    var value = _unary();
    var bare = _lastFactorPercent;
    while (true) {
      final c = _peek();
      if (c == '×' || c == '*') {
        _pos++;
        value *= _unary();
        bare = false;
      } else if (c == '÷' || c == '/') {
        _pos++;
        final divisor = _unary();
        if (divisor == 0) throw _divZero;
        value /= divisor;
        bare = false;
      } else if (_startsPrimary(c)) {
        value *= _unary();
        bare = false;
      } else {
        break;
      }
    }
    _termIsBarePercent = bare;
    return value;
  }

  // unary := ('−' | '+') unary | power
  double _unary() {
    final c = _peek();
    if (c == '−' || c == '-') {
      _pos++;
      return -_unary();
    }
    if (c == '+') {
      _pos++;
      return _unary();
    }
    return _power();
  }

  // power := postfix ('^' unary)?
  double _power() {
    final base = _postfix();
    if (_peek() == '^') {
      _pos++;
      final exponent = _unary();
      _lastFactorPercent = false;
      return _pow(base, exponent);
    }
    return base;
  }

  // postfix := primary ('!' | '%')*
  double _postfix() {
    var value = _primary();
    var percent = false;
    while (true) {
      final c = _peek();
      if (c == '!') {
        _pos++;
        value = _factorial(value);
        percent = false;
      } else if (c == '%') {
        _pos++;
        value = value / 100;
        percent = true;
      } else {
        break;
      }
    }
    _lastFactorPercent = percent;
    return value;
  }

  double _primary() {
    final c = _peek();
    if (c == null) throw _incomplete;

    if (c == '(') {
      _pos++;
      final value = _expression();
      final next = _peek();
      if (next == ')') {
        _pos++;
      } else if (next != null) {
        throw _invalid;
      }
      return value;
    }

    if (c == 'π') {
      _pos++;
      return math.pi;
    }

    if (c == '√') {
      _pos++;
      return _sqrt(_postfix());
    }

    if (_isDigit(c) || c == '.') return _number();

    if (_isLetter(c)) {
      final start = _pos;
      while (_pos < src.length && _isLetter(src[_pos])) {
        _pos++;
      }
      final name = src.substring(start, _pos);
      if (name == 'e') return math.e;
      if (_peek() != '(') throw _invalid;
      _pos++;
      final arg = _expression();
      final next = _peek();
      if (next == ')') {
        _pos++;
      } else if (next != null) {
        throw _invalid;
      }
      return _apply(name, arg);
    }

    throw _invalid;
  }

  double _number() {
    final start = _pos;
    var dots = 0;
    while (_pos < src.length) {
      final ch = src[_pos];
      if (_isDigit(ch)) {
        _pos++;
      } else if (ch == '.') {
        dots++;
        if (dots > 1) throw _invalid;
        _pos++;
      } else {
        break;
      }
    }
    var text = src.substring(start, _pos);
    if (text == '.') throw _invalid;
    if (text.startsWith('.')) text = '0$text';
    if (text.endsWith('.')) text = '${text}0';

    if (_pos < src.length && src[_pos] == 'E') {
      _pos++;
      var sign = '';
      if (_pos < src.length && src[_pos] == '+') {
        _pos++;
      } else if (_pos < src.length && (src[_pos] == '−' || src[_pos] == '-')) {
        sign = '-';
        _pos++;
      }
      final digitsStart = _pos;
      while (_pos < src.length && _isDigit(src[_pos])) {
        _pos++;
      }
      if (digitsStart == _pos) throw _invalid;
      text = '${text}e$sign${src.substring(digitsStart, _pos)}';
    }

    final value = double.tryParse(text);
    if (value == null) throw _invalid;
    return value;
  }

  double _apply(String name, double x) {
    switch (name) {
      case 'sin':
        return _sin(x);
      case 'cos':
        return _cos(x);
      case 'tan':
        return _tan(x);
      case 'ln':
        if (x <= 0) throw _domain;
        return math.log(x);
      case 'log':
        if (x <= 0) throw _domain;
        return math.log(x) / math.ln10;
      case 'sqrt':
        return _sqrt(x);
      case 'abs':
        return x.abs();
      default:
        throw _invalid;
    }
  }

  double _toRadians(double x) =>
      angle == AngleMode.degrees ? x * math.pi / 180 : x;

  double _noise(double v) => v.abs() < 1e-14 ? 0 : v;

  double _sin(double x) {
    if (angle == AngleMode.degrees) {
      final r = x % 360;
      if (r % 180 == 0) return 0;
      if (r == 90) return 1;
      if (r == 270) return -1;
    }
    return _noise(math.sin(_toRadians(x)));
  }

  double _cos(double x) {
    if (angle == AngleMode.degrees) {
      final r = x % 360;
      if (r == 90 || r == 270) return 0;
      if (r == 0) return 1;
      if (r == 180) return -1;
    }
    return _noise(math.cos(_toRadians(x)));
  }

  double _tan(double x) {
    if (angle == AngleMode.degrees) {
      final r = x % 180;
      if (r == 90) throw const CalcException('تانژانت تعریف نشده است');
      if (r == 0) return 0;
    } else if (math.cos(x).abs() < 1e-14) {
      throw const CalcException('تانژانت تعریف نشده است');
    }
    return _noise(math.tan(_toRadians(x)));
  }

  double _sqrt(double x) {
    if (x < 0) throw _domain;
    return math.sqrt(x);
  }

  double _pow(double base, double exponent) {
    if (base == 0 && exponent < 0) throw _divZero;
    final r = math.pow(base, exponent).toDouble();
    if (r.isNaN) throw _domain;
    return r;
  }

  double _factorial(double x) {
    if (x < 0 || x != x.truncateToDouble()) {
      throw const CalcException('فاکتوریل فقط برای عدد صحیح نامنفی است');
    }
    if (x > 170) throw const CalcException('عدد بیش از حد بزرگ است');
    var result = 1.0;
    for (var i = 2; i <= x; i++) {
      result *= i;
    }
    return result;
  }
}
