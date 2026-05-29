import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'winner_selector.dart';
import 'goals_selector.dart';

class OtherPronosticsWidget extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int winner;
  final int maxGoals;
  final int minGoals;
  final ValueChanged<int> onWinnerChanged;
  final ValueChanged<int> onMaxGoalsChanged;
  final ValueChanged<int> onMinGoalsChanged;
  final int potentialPoints;
  final bool enabled;

  const OtherPronosticsWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.winner,
    required this.maxGoals,
    required this.minGoals,
    required this.onWinnerChanged,
    required this.onMaxGoalsChanged,
    required this.onMinGoalsChanged,
    required this.potentialPoints,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Qui va gagner ?', points: '5 pts'),
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
          title: 'Max buts dans le match',
          pointsFormula: '(7 - valeur) × 2 pts',
          selected: maxGoals,
          onSelected: onMaxGoalsChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 16),

        GoalsSelector(
          title: 'Min buts dans le match',
          pointsFormula: 'valeur × 2 pts',
          selected: minGoals,
          onSelected: onMinGoalsChanged,
          enabled: enabled,
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
            'Total estimé → $potentialPoints points',
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