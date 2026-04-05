import 'package:flutter/material.dart';
import '../../../pronostics/domain/entities/user_stats_entity.dart';

class ProfileStatsGrid extends StatelessWidget {
  final UserStatsEntity stats;

  const ProfileStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATISTIQUES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _StatBox(
                value: '${stats.exactScoreCount}',
                label: 'Scores exacts',
                color: const Color(0xFF006847),
                bgColor: const Color(0xFFF0FDF4),
              ),
              _StatBox(
                value: '${stats.successRate.toStringAsFixed(0)}%',
                label: 'Taux de réussite',
                color: const Color(0xFF002868),
                bgColor: const Color(0xFFEEF2FF),
              ),
              _StatBox(
                value: '${stats.bestMatchPoints}',
                label: 'Meilleur match',
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
              ),
              _StatBox(
                value: '${stats.winnerCorrectCount}',
                label: 'Vainqueurs corrects',
                color: const Color(0xFFC8102E),
                bgColor: const Color(0xFFFEF2F2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}