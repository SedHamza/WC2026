import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
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
    'ALL',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L'
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilterChipList(
      items: _groups
          .map((g) => FilterChipItem(
                value: g,
                label: g == 'ALL' ? l10n.all : l10n.group(g),
              ))
          .toList(),
      selected: selected,
      onSelected: onSelected,
      activeColor: AppColors.primary,
    );
  }
}
