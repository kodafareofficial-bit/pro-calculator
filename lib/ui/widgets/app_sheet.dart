import 'package:flutter/material.dart';

import '../../core/app_palette.dart';

/// نمایش یک Bottom Sheet با ظاهر یکپارچه‌ی برنامه.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) => AppSheet(child: builder(ctx)),
  );
}

class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: p.sheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: p.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
