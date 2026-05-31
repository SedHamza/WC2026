import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';

class DateFilter extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  const DateFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selected ?? DateTime(2026, 6, 11),
                firstDate: DateTime(2026, 6, 11),
                lastDate: DateTime(2026, 7, 19),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onSelected(picked);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:
                    selected != null ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected != null
                      ? AppColors.primary
                      : AppColors.borderStrong(isDark),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: selected != null
                        ? Colors.white
                        : AppColors.textSecondary(isDark),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    selected != null
                        ? '${selected!.day}/${selected!.month}/${selected!.year}'
                        : l10n.chooseDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: selected != null
                          ? Colors.white
                          : AppColors.textSecondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selected != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onSelected(null),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderStrong(isDark)),
                ),
                child: Text(
                  l10n.clearDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(isDark),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
