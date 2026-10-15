#!/usr/bin/env bash
# راه‌اندازی اولیه‌ی پروژه (یک‌بار اجرا کنید).
#  - پوشه‌های android و ios را با flutter create می‌سازد (اگر وجود نداشته باشند)
#  - نام برنامه را روی دستگاه به «ماشین‌حساب پرو» تغییر می‌دهد
#  - مجوز INTERNET را برای دانلود فونت وزیرمتن اضافه می‌کند (نسخه‌ی release)
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d android ]; then
  flutter create . \
    --org ir.farahani \
    --project-name pro_calculator \
    --platforms=android,ios
fi

# تست پیش‌فرضِ شمارنده که flutter create می‌سازد با این پروژه ناسازگار است.
if [ -f test/widget_test.dart ] && grep -q 'MyApp' test/widget_test.dart; then
  rm test/widget_test.dart
fi

MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  perl -pi -e 's/android:label="[^"]*"/android:label="ماشین‌حساب پرو"/' "$MANIFEST"
  if ! grep -q 'android.permission.INTERNET' "$MANIFEST"; then
    perl -0pi -e 's/<application/<uses-permission android:name="android.permission.INTERNET"\/>\n    <application/' "$MANIFEST"
  fi
fi

echo "✅ راه‌اندازی تمام شد. حالا: flutter pub get && flutter run"
