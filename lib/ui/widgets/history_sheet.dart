import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_palette.dart';
import '../../core/number_format.dart';
import '../../logic/calculator_controller.dart';
import '../../logic/settings_controller.dart';

class HistorySheet extends StatelessWidget {
  const HistorySheet({
    super.key,
    required this.controller,
    required this.settings,
  });

  final CalculatorController controller;
  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    final fmt = DisplayFormat(persian: settings.persianDigits);
    final height = MediaQuery.sizeOf(context).height * 0.68;

    return SizedBox(
      height: height,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final items = controller.history;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 0),
                child: Row(
                  children: [
                    Text(
                      'تاریخچه',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: p.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (items.isNotEmpty)
                      TextButton.icon(
                        onPressed: controller.clearHistory,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                        label: Text(
                          'پاک کردن همه',
                          style: GoogleFonts.vazirmatn(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'برای استفاده از نتیجه ضربه بزنید • برای ویرایش عبارت نگه دارید • برای حذف بکشید',
                      style: GoogleFonts.vazirmatn(
                        fontSize: 11.5,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? _EmptyState(color: p.textSecondary)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: p.divider, height: 1),
                        itemBuilder: (context, index) {
                          final entry = items[index];
                          return Dismissible(
                            key: ValueKey(
                              'h_${entry.time.microsecondsSinceEpoch}',
                            ),
                            background: Container(
                              color: p.error.withAlpha(46),
                              alignment: AlignmentDirectional.centerStart,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: p.error,
                              ),
                            ),
                            onDismissed: (_) =>
                                controller.removeHistoryAt(index),
                            child: _HistoryTile(
                              entry: entry,
                              fmt: fmt,
                              onTap: () {
                                controller.useResult(entry);
                                Navigator.of(context).pop();
                              },
                              onLongPress: () {
                                controller.restoreExpression(entry);
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.fmt,
    required this.onTap,
    required this.onLongPress,
  });

  final HistoryEntry entry;
  final DisplayFormat fmt;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final p = CalcPalette.of(context);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fmt.expression(entry.expression),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 14,
                        color: p.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '= ${fmt.result(entry.result)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: p.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              fmt.time(entry.time),
              style: GoogleFonts.vazirmatn(
                fontSize: 11.5,
                color: p.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            'هنوز محاسبه‌ای انجام نشده است',
            style: GoogleFonts.vazirmatn(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}
