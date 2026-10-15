import 'dart:math' as math;

const List<String> _persianDigits = [
  '۰',
  '۱',
  '۲',
  '۳',
  '۴',
  '۵',
  '۶',
  '۷',
  '۸',
  '۹',
];

/// تبدیل ارقام لاتین به ارقام فارسی.
String toPersianDigits(String input) => input.replaceAllMapped(
      RegExp(r'[0-9]'),
      (m) => _persianDigits[int.parse(m[0]!)],
    );

/// جداکننده‌ی سه‌رقمی برای بخش صحیح یک عدد.
String groupDigits(String digits, String separator) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(separator);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// نمایش استاندارد (لاتین، بدون جداکننده) یک عدد با حداکثر ۱۲ رقم معنادار.
///
/// اعداد خیلی بزرگ یا خیلی کوچک به شکل علمی (مثلاً `1.5E+21`) برمی‌گردند.
/// علامت منفی با «−» (U+2212) نمایش داده می‌شود تا با موتور محاسبه یکسان باشد.
String plainNumber(double value) {
  if (value == 0) return '0';
  final abs = value.abs();
  String text;
  if (abs >= 1e15 || abs < 1e-9) {
    final parts = value.toStringAsExponential(9).split('e');
    var mantissa = parts[0];
    if (mantissa.contains('.')) {
      mantissa = mantissa
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    text = '${mantissa}E${parts[1]}';
  } else {
    int decimals;
    if (abs >= 1) {
      decimals = math.max(0, 12 - abs.floor().toString().length);
    } else {
      var zeros = 0;
      var scaled = abs;
      while (scaled < 0.1) {
        scaled *= 10;
        zeros++;
      }
      decimals = math.min(20, zeros + 12);
    }
    text = value.toStringAsFixed(decimals);
    if (text.contains('.')) {
      text = text
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
  }
  return text.replaceAll('-', '−');
}

/// قالب‌بندی متن‌های نمایشی (ارقام فارسی/لاتین و جداکننده‌ها).
class DisplayFormat {
  const DisplayFormat({required this.persian});

  final bool persian;

  String digit(String d) => persian ? toPersianDigits(d) : d;

  String get decimalSeparator => persian ? '٫' : '.';

  /// عبارت را برای نمایش آماده می‌کند: جداکننده‌ی هزارگان + ارقام فارسی.
  String expression(String raw) {
    final grouped = raw.replaceAllMapped(RegExp(r'(\d+)(\.\d*)?'), (m) {
      final intPart = groupDigits(m[1]!, ',');
      final fraction = m[2] ?? '';
      return '$intPart$fraction';
    });
    if (!persian) return grouped;
    return toPersianDigits(grouped).replaceAll(',', '٬').replaceAll('.', '٫');
  }

  String result(String raw) => expression(raw);

  String time(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return digit('$hh:$mm');
  }
}
