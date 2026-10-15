import 'package:flutter_test/flutter_test.dart';
import 'package:pro_calculator/core/number_format.dart';
import 'package:pro_calculator/logic/calculator_engine.dart';

void main() {
  const engine = CalculatorEngine();

  double eval(String expression, {AngleMode angle = AngleMode.degrees}) =>
      engine.evaluate(expression, angle: angle);

  group('حساب پایه', () {
    test('اولویت عملگرها', () {
      expect(eval('2+3×4'), 14);
      expect(eval('(2+3)×4'), 20);
      expect(eval('10−2−3'), 5);
      expect(eval('100÷5÷2'), 10);
    });

    test('اعشار و خطای ممیز شناور', () {
      expect(eval('10÷4'), 2.5);
      expect(eval('0.1+0.2'), 0.3);
      expect(eval('.5+.5'), 1);
    });

    test('منفی یکتایی', () {
      expect(eval('−5+2'), -3);
      expect(eval('3×−2'), -6);
      expect(eval('−2^2'), -4);
    });

    test('توان راست‌شرکت‌پذیر است', () {
      expect(eval('2^3^2'), 512);
      expect(eval('2^−1'), 0.5);
    });

    test('ضرب ضمنی', () {
      expect(eval('2(3+4)'), 14);
      expect(eval('3sin(90)'), 3);
      expect(eval('2π'), closeTo(6.283185307, 1e-9));
    });

    test('بستن خودکار پرانتز', () {
      expect(eval('(2+3'), 5);
      expect(eval('sin(90'), 1);
    });

    test('نماد علمی', () {
      expect(eval('1.5E+3'), 1500);
      expect(eval('2E−2'), 0.02);
    });
  });

  group('درصد و فاکتوریل', () {
    test('درصد ساده', () {
      expect(eval('50%'), 0.5);
    });

    test('درصد نسبت به عدد قبلی در جمع و تفریق', () {
      expect(eval('200+10%'), 220);
      expect(eval('200−10%'), 180);
    });

    test('درصد در ضرب', () {
      expect(eval('200×10%'), 20);
    });

    test('فاکتوریل', () {
      expect(eval('5!'), 120);
      expect(eval('0!'), 1);
    });
  });

  group('توابع علمی', () {
    test('ریشه', () {
      expect(eval('√(16)'), 4);
      expect(eval('√16'), 4);
    });

    test('لگاریتم', () {
      expect(eval('log(1000)'), 3);
      expect(eval('ln(e)'), 1);
    });

    test('مثلثات در حالت درجه', () {
      expect(eval('sin(30)'), 0.5);
      expect(eval('cos(60)'), 0.5);
      expect(eval('tan(45)'), 1);
      expect(eval('sin(180)'), 0);
      expect(eval('cos(90)'), 0);
    });

    test('مثلثات در حالت رادیان', () {
      expect(eval('sin(π)', angle: AngleMode.radians), 0);
      expect(eval('cos(0)', angle: AngleMode.radians), 1);
    });
  });

  group('خطاها', () {
    void expectError(String expression) {
      expect(() => eval(expression), throwsA(isA<CalcException>()));
    }

    test('تقسیم بر صفر', () => expectError('1÷0'));
    test('عبارت ناقص', () => expectError('5+'));
    test('عبارت خالی', () => expectError(''));
    test('ریشه‌ی عدد منفی', () => expectError('√(−1)'));
    test('لگاریتم صفر', () => expectError('ln(0)'));
    test('دو ممیز', () => expectError('1..2'));
    test('تانژانت ۹۰ درجه', () => expectError('tan(90)'));
    test('فاکتوریل عدد اعشاری', () => expectError('2.5!'));
    test('پرانتز اضافه', () => expectError('2+3)'));
  });

  group('قالب‌بندی', () {
    test('plainNumber', () {
      expect(plainNumber(1234.5), '1234.5');
      expect(plainNumber(100), '100');
      expect(plainNumber(-5.5), '−5.5');
      expect(plainNumber(1 / 3), '0.333333333333');
      expect(plainNumber(1e20), '1E+20');
      expect(plainNumber(0), '0');
    });

    test('ارقام فارسی و جداکننده‌ی هزارگان', () {
      const fa = DisplayFormat(persian: true);
      const en = DisplayFormat(persian: false);
      expect(fa.expression('1234567.5'), '۱٬۲۳۴٬۵۶۷٫۵');
      expect(en.expression('1234567.5'), '1,234,567.5');
      expect(fa.expression('12+3'), '۱۲+۳');
    });
  });
}
