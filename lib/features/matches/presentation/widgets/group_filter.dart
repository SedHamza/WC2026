import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import '../../../../../shared/widgets/filter_chip_list.dart';

class GroupFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const GroupFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _groups = [
    'Tous', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
  ];

  @override
  Widget build(BuildContext context) {
    return FilterChipList(
      items: _groups.map((g) => FilterChipItem(
        value: g,
        label: g == 'Tous' ? 'Tous' : 'Groupe $g',
      )).toList(),
      selected: selected,
      onSelected: onSelected,
      activeColor: AppColors.primary,
    );
  }
}