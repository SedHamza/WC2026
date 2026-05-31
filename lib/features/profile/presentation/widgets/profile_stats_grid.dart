import 'package:flutter/material.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../../pronostics/domain/entities/user_stats_entity.dart';

class ProfileStatsGrid extends StatelessWidget {
  final UserStatsEntity stats;

  const ProfileStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statistics.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(isDark),
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
                label: l10n.exactScores,
                color: AppColors.accent,
                bgColor: AppColors.successBg(isDark),
                isDark: isDark,
              ),
              _StatBox(
                value: '${stats.successRate.toStringAsFixed(0)}%',
                label: l10n.successRate,
                color: AppColors.primary,
                bgColor: AppColors.infoBg(isDark),
                isDark: isDark,
              ),
              _StatBox(
                value: '${stats.bestMatchPoints}',
                label: l10n.bestMatch,
                color: AppColors.warning,
                bgColor: AppColors.warningBg(isDark),
                isDark: isDark,
              ),
              _StatBox(
                value: '${stats.winnerCorrectCount}',
                label: l10n.correctWinners,
                color: AppColors.secondary,
                bgColor: AppColors.errorBg(isDark),
                isDark: isDark,
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
  final bool isDark;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.isDark,
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
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary(isDark),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}