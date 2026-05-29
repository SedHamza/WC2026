import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import '../../../../../shared/widgets/radio_selector.dart';

class GoalsSelector extends StatelessWidget {
  final String title;
  final String pointsFormula;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool enabled;

  const GoalsSelector({
    super.key,
    required this.title,
    required this.pointsFormula,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  static const _items = [
    RadioSelectorItem(value: -1, label: 'N'),
    RadioSelectorItem(value: 1, label: '1'),
    RadioSelectorItem(value: 2, label: '2'),
    RadioSelectorItem(value: 3, label: '3'),
    RadioSelectorItem(value: 4, label: '4'),
    RadioSelectorItem(value: 5, label: '5'),
    RadioSelectorItem(value: 6, label: '6'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(isDark),
              ),
            ),
            Text(
              pointsFormula,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RadioSelector(
          items: _items,
          selected: selected,
          onSelected: onSelected,
          enabled: enabled,
        ),
      ],
    );
  }
}