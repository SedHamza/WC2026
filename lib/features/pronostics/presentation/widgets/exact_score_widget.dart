import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import '../../../../../shared/widgets/score_counter.dart';

class ExactScoreWidget extends StatelessWidget {
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final ValueChanged<int> onHomeChanged;
  final ValueChanged<int> onAwayChanged;
  final bool enabled;

  const ExactScoreWidget({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.onHomeChanged,
    required this.onAwayChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                homeTeamName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Text(
                awayTeamName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary(isDark),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScoreCounter(
              value: homeScore,
              onChanged: onHomeChanged,
              enabled: enabled,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '—',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint(isDark),
                ),
              ),
            ),
            ScoreCounter(
              value: awayScore,
              onChanged: onAwayChanged,
              enabled: enabled,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.infoBg(isDark),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Résultat exact → 25 points',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}