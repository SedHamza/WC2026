import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/features/pronostics/presentation/providers/pronostic_provider.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/features/pronostics/domain/entities/user_stats_entity.dart';
import 'package:wc2026/features/pronostics/domain/entities/pronostic_entity.dart';
import 'package:wc2026/shared/widgets/loading_widget.dart';
import 'package:wc2026/features/profile/presentation/widgets/pronostic_history_list.dart';

// ── PROVIDERS ─────────────────────────────────────────────────────────────────

final memberStatsProvider =
    FutureProvider.family<UserStatsEntity?, String>((ref, userId) async {
  return ref.read(pronosticRepositoryProvider).getUserStats(userId);
});

final memberPronosticsProvider =
    FutureProvider.family<List<PronosticEntity>, String>((ref, userId) async {
  return ref.read(pronosticRepositoryProvider).getUserPronostics(userId);
});

// ── SCREEN ────────────────────────────────────────────────────────────────────

class MemberProfileScreen extends ConsumerWidget {
  final String userId;
  final String displayName;
  final int totalPoints;
  final int rank;

  const MemberProfileScreen({
    super.key,
    required this.userId,
    required this.displayName,
    required this.totalPoints,
    required this.rank,
  });

  String get _initials {
    final parts = displayName.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName
        .substring(0, displayName.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  String _rankText() {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(memberStatsProvider(userId));
    final pronosticsAsync = ref.watch(memberPronosticsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _initials,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rankText(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingWidget(),
              ),
              error: (_, __) => const SizedBox(),
              data: (stats) => stats == null
                  ? const SizedBox()
                  : _StatsSection(stats: stats, isDark: isDark, l10n: l10n),
            ),
          ),

          // ── Historique ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.pronosticHistory.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(isDark),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: pronosticsAsync.when(
              loading: () => const LoadingWidget(),
              error: (_, __) => const SizedBox(),
              data: (pronostics) => pronostics.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.noPronosticsHistory,
                          style:
                              TextStyle(color: AppColors.textSecondary(isDark)),
                        ),
                      ),
                    )
                  : PronosticHistoryList(pronostics: pronostics),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── STATS SECTION ─────────────────────────────────────────────────────────────

class _StatsSection extends StatelessWidget {
  final UserStatsEntity stats;
  final bool isDark;
  final AppLocalizations l10n;

  const _StatsSection({
    required this.stats,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row stats principales ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.bgCard(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  value: '${stats.totalPoints}',
                  label: l10n.totalPoints,
                  isDark: isDark,
                ),
                Container(
                    width: 1, height: 32, color: AppColors.border(isDark)),
                _StatItem(
                  value: '${stats.totalPronostics}',
                  label: l10n.totalPronostics,
                  isDark: isDark,
                ),
                Container(
                    width: 1, height: 32, color: AppColors.border(isDark)),
                _StatItem(
                  value: stats.totalPronostics > 0
                      ? stats.averagePoints.toStringAsFixed(1)
                      : '0',
                  label: l10n.avgPtsPerMatch,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Grille stats détaillées ────────────────────────────────────
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
              ),
              _StatBox(
                value: '${stats.successRate.toStringAsFixed(0)}%',
                label: l10n.successRate,
                color: AppColors.primary,
                bgColor: AppColors.infoBg(isDark),
              ),
              _StatBox(
                value: '${stats.bestMatchPoints}',
                label: l10n.bestMatch,
                color: AppColors.warning,
                bgColor: AppColors.warningBg(isDark),
              ),
              _StatBox(
                value: '${stats.winnerCorrectCount}',
                label: l10n.correctWinners,
                color: AppColors.secondary,
                bgColor: AppColors.errorBg(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary(isDark),
          ),
        ),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
