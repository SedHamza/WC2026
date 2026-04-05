import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Qui gagne
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
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 16),

        // Max buts
        GoalsSelector(
          title: 'Max buts dans le match',
          pointsFormula: '(7 - valeur) × 2 pts',
          selected: maxGoals,
          onSelected: onMaxGoalsChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        const SizedBox(height: 16),

        // Min buts
        GoalsSelector(
          title: 'Min buts dans le match',
          pointsFormula: 'valeur × 2 pts',
          selected: minGoals,
          onSelected: onMinGoalsChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 12),

        // Total estimé
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Total estimé → $potentialPoints points',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006847),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        Text(
          points,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}