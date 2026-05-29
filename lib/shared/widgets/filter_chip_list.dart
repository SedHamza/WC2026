import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';

class FilterChipItem {
  final String value;
  final String label;

  const FilterChipItem({required this.value, required this.label});
}

class FilterChipList extends StatelessWidget {
  final List<FilterChipItem> items;
  final String selected;
  final ValueChanged<String> onSelected;
  final Color activeColor;

  const FilterChipList({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final item = items[i];
          final isActive = selected == item.value;
          return GestureDetector(
            onTap: () => onSelected(item.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? activeColor
                      : AppColors.borderStrong(isDark),
                ),
              ),
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary(isDark),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}