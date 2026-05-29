import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import '../../../../../shared/widgets/filter_chip_list.dart';

class StageFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const StageFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _stages = {
    'Tous': 'Tous',
    'LAST_32': '32èmes',
    'LAST_16': '16èmes',
    'QUARTER_FINALS': 'Quarts',
    'SEMI_FINALS': 'Demis',
    'THIRD_PLACE': '3ème place',
    'FINAL': 'Finale',
  };

  @override
  Widget build(BuildContext context) {
    return FilterChipList(
      items: _stages.entries.map((e) => FilterChipItem(
        value: e.key,
        label: e.value,
      )).toList(),
      selected: selected,
      onSelected: onSelected,
      activeColor: AppColors.secondary,
    );
  }
}