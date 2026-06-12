import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'winner_selector.dart';
import 'goals_selector.dart';

class OtherPronosticsWidget extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int winner;
  final int maxGoals;
  final int minGoals;
  final int bothTeamsScore;
  final ValueChanged<int> onWinnerChanged;
  final ValueChanged<int> onMaxGoalsChanged;
  final ValueChanged<int> onMinGoalsChanged;
  final ValueChanged<int> onBothTeamsScoreChanged;
  final int potentialPoints;
  final bool enabled;

  const OtherPronosticsWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.winner,
    required this.maxGoals,
    required this.minGoals,
    required this.bothTeamsScore,
    required this.onWinnerChanged,
    required this.onMaxGoalsChanged,
    required this.onMinGoalsChanged,
    required this.onBothTeamsScoreChanged,
    required this.potentialPoints,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.whoWins, points: '5 pts'),
        const SizedBox(height: 8),
        WinnerSelector(
          homeTeamName: homeTeamName,
          awayTeamName: awayTeamName,
          selected: winner,
          onSelected: onWinnerChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        GoalsSelector(
          title: l10n.maxGoals,
          pointsFormula: l10n.maxGoalsFormula,
          selected: maxGoals,
          onSelected: onMaxGoalsChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        GoalsSelector(
          title: l10n.minGoals,
          pointsFormula: l10n.minGoalsFormula,
          selected: minGoals,
          onSelected: onMinGoalsChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),
        _SectionHeader(title: l10n.bothTeamsScore, points: '5 pts'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ChoiceButton(
                label: l10n.yes,
                selected: bothTeamsScore == 1,
                onTap: enabled
                    ? () =>
                        onBothTeamsScoreChanged(bothTeamsScore == 1 ? -1 : 1)
                    : null,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ChoiceButton(
                label: l10n.no,
                selected: bothTeamsScore == 0,
                onTap: enabled
                    ? () =>
                        onBothTeamsScoreChanged(bothTeamsScore == 0 ? -1 : 0)
                    : null,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.successBg(isDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            l10n.totalEstimated(potentialPoints.toString()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── BOUTON CHOIX OUI/NON ──────────────────────────────────────────────────────

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool isDark;

  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.bgSurface(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border(isDark),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textPrimary(isDark),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String points;

  const _SectionHeader({required this.title, required this.points});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
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
          points,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ],
    );
  }
}
