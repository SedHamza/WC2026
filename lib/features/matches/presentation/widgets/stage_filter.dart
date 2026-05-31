import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../../../../shared/widgets/filter_chip_list.dart';

class StageFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const StageFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final stages = {
      'ALL': l10n.all,
      'LAST_32': l10n.last32,
      'LAST_16': l10n.last16,
      'QUARTER_FINALS': l10n.quarterFinals,
      'SEMI_FINALS': l10n.semiFinals,
      'THIRD_PLACE': l10n.thirdPlace,
      'FINAL': l10n.finalMatch,
    };

    return FilterChipList(
      items: stages.entries
          .map((e) => FilterChipItem(
                value: e.key,
                label: e.value,
              ))
          .toList(),
      selected: selected,
      onSelected: onSelected,
      activeColor: AppColors.secondary,
    );
  }
}
