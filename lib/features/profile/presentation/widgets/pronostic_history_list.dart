import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/features/pronostics/domain/entities/pronostic_entity.dart';
import 'package:wc2026/features/matches/domain/entities/match_entity.dart';
import 'package:wc2026/features/pronostics/presentation/screens/match_detail_screen.dart';
import 'package:wc2026/shared/providers/repository_providers.dart';
import 'package:wc2026/l10n/app_localizations.dart';

class PronosticHistoryList extends ConsumerWidget {
  final List<PronosticEntity> pronostics;

  /// Si true, masque les détails des pronostics pour les matchs
  /// pas encore commencés (utilisé sur le profil d'un autre membre)
  final bool hideUpcomingDetails;

  const PronosticHistoryList({
    super.key,
    required this.pronostics,
    this.hideUpcomingDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final matchesAsync = ref.watch(matchesProvider);

    return matchesAsync.maybeWhen(
      data: (matches) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgCard(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Column(
          children: pronostics.asMap().entries.map((entry) {
            final match = matches.firstWhere(
              (m) => m.id == entry.value.matchId,
              orElse: () => MatchEntity(
                id: entry.value.matchId,
                homeTeamName: 'Équipe domicile',
                awayTeamName: 'Équipe extérieure',
                status: 'UNKNOWN',
                stage: 'GROUP_STAGE',
                utcDate: DateTime.now(),
              ),
            );
            return _HistoryRow(
              pronostic: entry.value,
              match: match,
              isLast: entry.key == pronostics.length - 1,
              hideUpcomingDetails: hideUpcomingDetails,
            );
          }).toList(),
        ),
      ),
      orElse: () => const SizedBox(),
    );
  }
}

// ── LIGNE HISTORIQUE ─────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  final PronosticEntity pronostic;
  final MatchEntity match;
  final bool isLast;
  final bool hideUpcomingDetails;

  const _HistoryRow({
    required this.pronostic,
    required this.match,
    this.isLast = false,
    this.hideUpcomingDetails = false,
  });

  /// True si on doit masquer les détails de ce pronostic
  bool get _isHidden => hideUpcomingDetails && match.isUpcoming;

  String _statusText(AppLocalizations l10n) {
    if (match.isFinished) return l10n.finished;
    if (match.isLive) return l10n.inProgress;
    return l10n.pending;
  }

  int get _maxPossible => pronostic.potentialPoints;

  // Points à afficher — définitifs si calculés, provisoires calculés localement si live
  int _displayPoints() {
    if (pronostic.isCalculated) return pronostic.points;
    if (match.isLive && match.homeScore != null) {
      return pronostic.calculatePoints(match.homeScore!, match.awayScore ?? 0);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayPts = _displayPoints();
    final hasPoints = pronostic.isCalculated || match.isLive;

    return GestureDetector(
      onTap: _isHidden ? null : () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom:
                      BorderSide(color: AppColors.border(isDark), width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Dot coloré
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isHidden
                        ? AppColors.textHint(isDark)
                        : pronostic.isCalculated
                            ? (pronostic.points > 0
                                ? AppColors.accentText(isDark)
                                : AppColors.textSecondary(isDark))
                            : match.isLive
                                ? AppColors.live
                                : AppColors.warningText(isDark),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${match.homeTeamName} vs ${match.awayTeamName}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(isDark)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Badge points
                if (_isHidden)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 12, color: AppColors.accentText(isDark)),
                      const SizedBox(width: 4),
                      Text(
                        l10n.hasPronostic,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.accentText(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  _buildBadge(hasPoints, displayPts, isDark),
              ],
            ),

            // ── Détails masqués pour les matchs pas commencés ─────────────
            if (!_isHidden) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildChips(l10n, isDark),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Text(
                      'Max : $_maxPossible pts · ${_statusText(l10n)}',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textHint(isDark)),
                    ),
                    const Spacer(),
                    if (match.isUpcoming)
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MatchDetailScreen(match: match))),
                        child: Text(l10n.modify,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.infoText(isDark),
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  l10n.visibleAfterStart,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint(isDark),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(bool hasPoints, int pts, bool isDark) {
    if (pronostic.isCalculated) {
      final maxPts = pronostic.potentialPoints;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: pts > 0
              ? AppColors.successBg(isDark)
              : AppColors.bgSubtle(isDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$pts/$maxPts pts',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: pts > 0
                  ? AppColors.accentText(isDark)
                  : AppColors.textSecondary(isDark)),
        ),
      );
    }

    if (match.isLive) {
      final maxPts = pronostic.potentialPoints;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.errorBg(isDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '🔴 $pts/$maxPts pts',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.live),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warningBg(isDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('— pts',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.warningText(isDark))),
    );
  }

  Widget _buildChips(AppLocalizations l10n, bool isDark) {
    if (pronostic.isExactMode) {
      final correct = pronostic.isCalculated && pronostic.points == 31;
      return Wrap(spacing: 6, children: [
        _Chip(
          label:
              '${l10n.exactScoreMode} ${pronostic.homeScore}-${pronostic.awayScore}',
          status: pronostic.isCalculated
              ? (correct ? _ChipStatus.correct : _ChipStatus.wrong)
              : _ChipStatus.pending,
        ),
      ]);
    }

    return Wrap(spacing: 6, runSpacing: 4, children: [
      if (pronostic.winner != null && pronostic.winner != -1)
        _buildWinnerChip(l10n),
      if (pronostic.maxGoals != null && pronostic.maxGoals != -1)
        _buildMaxChip(l10n),
      if (pronostic.minGoals != null && pronostic.minGoals != -1)
        _buildMinChip(l10n),
    ]);
  }

  Widget _buildWinnerChip(AppLocalizations l10n) {
    final name = pronostic.winner == 1
        ? match.homeTeamName
        : pronostic.winner == 2
            ? match.awayTeamName
            : l10n.draw;
    _ChipStatus status = _ChipStatus.pending;
    if (pronostic.isCalculated && match.isFinished) {
      final realWinner = (match.homeScore ?? 0) > (match.awayScore ?? 0)
          ? 1
          : (match.awayScore ?? 0) > (match.homeScore ?? 0)
              ? 2
              : 0;
      status = pronostic.winner == realWinner
          ? _ChipStatus.correct
          : _ChipStatus.wrong;
    }
    return _Chip(label: name, status: status);
  }

  Widget _buildMaxChip(AppLocalizations l10n) {
    _ChipStatus status = _ChipStatus.pending;
    if (pronostic.isCalculated && match.isFinished) {
      final total = (match.homeScore ?? 0) + (match.awayScore ?? 0);
      status = total <= pronostic.maxGoals!
          ? _ChipStatus.correct
          : _ChipStatus.wrong;
    }
    return _Chip(
        label: l10n.maxGoalsLabel(pronostic.maxGoals.toString()),
        status: status);
  }

  Widget _buildMinChip(AppLocalizations l10n) {
    _ChipStatus status = _ChipStatus.pending;
    if (pronostic.isCalculated && match.isFinished) {
      final total = (match.homeScore ?? 0) + (match.awayScore ?? 0);
      status = total >= pronostic.minGoals!
          ? _ChipStatus.correct
          : _ChipStatus.wrong;
    }
    return _Chip(
        label: l10n.minGoalsLabel(pronostic.minGoals.toString()),
        status: status);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailModal(pronostic: pronostic, match: match),
    );
  }
}

// ── MODAL DETAIL ──────────────────────────────────────────────────────────────

class _DetailModal extends StatelessWidget {
  final PronosticEntity pronostic;
  final MatchEntity match;

  const _DetailModal({required this.pronostic, required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalReal = (match.homeScore ?? 0) + (match.awayScore ?? 0);
    final realWinner = (match.homeScore ?? 0) > (match.awayScore ?? 0)
        ? 1
        : (match.awayScore ?? 0) > (match.homeScore ?? 0)
            ? 2
            : 0;
    final realBoth =
        ((match.homeScore ?? 0) > 0 && (match.awayScore ?? 0) > 0) ? 1 : 0;

    final displayPts = pronostic.isCalculated
        ? pronostic.points
        : (match.isLive && match.homeScore != null)
            ? pronostic.calculatePoints(match.homeScore!, match.awayScore ?? 0)
            : 0;
    final maxPts = pronostic.potentialPoints;
    final ptsLabel = pronostic.isCalculated
        ? '$displayPts/$maxPts pts'
        : match.isLive
            ? '🔴 $displayPts/$maxPts pts'
            : '—/$maxPts pts';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${match.homeTeamName} vs ${match.awayTeamName}',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(isDark))),
          const SizedBox(height: 2),
          Text(
            '${match.getFormattedStage(context)} · ${match.isFinished ? "${l10n.finished} ${match.homeScore}-${match.awayScore}" : match.isLive ? l10n.inProgress : l10n.pending}',
            style:
                TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
          ),
          const SizedBox(height: 16),
          _DetailRow(
              label: l10n.mode,
              value:
                  pronostic.isExactMode ? l10n.exactScoreMode : l10n.otherMode,
              isDark: isDark),
          if (pronostic.isExactMode)
            _DetailRow(
              label: l10n.predictedScore,
              value: '${pronostic.homeScore} - ${pronostic.awayScore}',
              pts: pronostic.isCalculated
                  ? (pronostic.points == 31 ? '+31/31 pts ✅' : '+0/31 pts ❌')
                  : null,
              ptsColor: pronostic.points == 31
                  ? AppColors.accentText(isDark)
                  : AppColors.dangerText(isDark),
              isDark: isDark,
            )
          else ...[
            if (pronostic.winner != null && pronostic.winner != -1)
              _DetailRow(
                label: l10n.whoWon,
                value: pronostic.winner == 1
                    ? match.homeTeamName
                    : pronostic.winner == 2
                        ? match.awayTeamName
                        : l10n.draw,
                pts: pronostic.isCalculated
                    ? (pronostic.winner == realWinner
                        ? '+5/5 pts ✅'
                        : '+0/5 pts ❌')
                    : null,
                ptsColor: pronostic.winner == realWinner
                    ? AppColors.accentText(isDark)
                    : AppColors.dangerText(isDark),
                isDark: isDark,
              ),
            if (pronostic.maxGoals != null && pronostic.maxGoals != -1)
              _DetailRow(
                label: l10n.maxGoalsLabel(pronostic.maxGoals.toString()),
                value: pronostic.isCalculated
                    ? 'Total réel : $totalReal'
                    : l10n.pending,
                pts: pronostic.isCalculated
                    ? (totalReal <= pronostic.maxGoals!
                        ? '+${((7 - pronostic.maxGoals!) * 3).clamp(0, 21)}/${((7 - pronostic.maxGoals!) * 3).clamp(0, 21)} pts ✅'
                        : '+0/${((7 - pronostic.maxGoals!) * 3).clamp(0, 21)} pts ❌')
                    : null,
                ptsColor: totalReal <= (pronostic.maxGoals ?? 99)
                    ? AppColors.accentText(isDark)
                    : AppColors.dangerText(isDark),
                isDark: isDark,
              ),
            if (pronostic.minGoals != null && pronostic.minGoals != -1)
              _DetailRow(
                label: l10n.minGoalsLabel(pronostic.minGoals.toString()),
                value: pronostic.isCalculated
                    ? 'Total réel : $totalReal'
                    : l10n.pending,
                pts: pronostic.isCalculated
                    ? (totalReal >= pronostic.minGoals!
                        ? '+${(pronostic.minGoals! * 3).clamp(0, 21)}/${(pronostic.minGoals! * 3).clamp(0, 21)} pts ✅'
                        : '+0/${(pronostic.minGoals! * 3).clamp(0, 21)} pts ❌')
                    : null,
                ptsColor: totalReal >= (pronostic.minGoals ?? 0)
                    ? AppColors.accentText(isDark)
                    : AppColors.dangerText(isDark),
                isDark: isDark,
              ),
            if (pronostic.bothTeamsScore != null &&
                pronostic.bothTeamsScore != -1)
              _DetailRow(
                label: l10n.bothTeamsScoreLabel(
                    pronostic.bothTeamsScore == 1 ? l10n.yes : l10n.no),
                value: pronostic.isCalculated
                    ? (realBoth == 1 ? l10n.yes : l10n.no)
                    : l10n.pending,
                pts: pronostic.isCalculated
                    ? (pronostic.bothTeamsScore == realBoth
                        ? '+5/5 pts ✅'
                        : '+0/5 pts ❌')
                    : null,
                ptsColor: pronostic.bothTeamsScore == realBoth
                    ? AppColors.accentText(isDark)
                    : AppColors.dangerText(isDark),
                isDark: isDark,
              ),
          ],
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: match.isLive
                  ? AppColors.errorBg(isDark)
                  : AppColors.infoBg(isDark),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalObtained,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: match.isLive
                            ? AppColors.live
                            : AppColors.infoText(isDark))),
                Text(ptsLabel,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: match.isLive
                            ? AppColors.live
                            : AppColors.infoText(isDark))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.close),
                ),
              ),
              if (match.isUpcoming) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MatchDetailScreen(match: match)));
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: Text(l10n.edit),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── WIDGETS HELPERS ───────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? pts;
  final Color? ptsColor;
  final bool isDark;

  const _DetailRow(
      {required this.label,
      required this.value,
      required this.isDark,
      this.pts,
      this.ptsColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: AppColors.border(isDark), width: 0.5))),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary(isDark)))),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(isDark))),
          if (pts != null) ...[
            const SizedBox(width: 8),
            Text(pts!,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ptsColor ?? AppColors.textSecondary(isDark))),
          ],
        ],
      ),
    );
  }
}

enum _ChipStatus { correct, wrong, pending }

class _Chip extends StatelessWidget {
  final String label;
  final _ChipStatus status;

  const _Chip({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg, textColor, border;
    final String prefix;

    switch (status) {
      case _ChipStatus.correct:
        bg = AppColors.successBg(isDark);
        textColor = AppColors.accentText(isDark);
        border = AppColors.accentText(isDark);
        prefix = '✓ ';
        break;
      case _ChipStatus.wrong:
        bg = AppColors.errorBg(isDark);
        textColor = AppColors.dangerText(isDark);
        border = AppColors.dangerText(isDark);
        prefix = '✗ ';
        break;
      case _ChipStatus.pending:
        bg = AppColors.bgSubtle(isDark);
        textColor = AppColors.textSecondary(isDark);
        border = AppColors.borderStrong(isDark);
        prefix = '';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 0.5)),
      child: Text('$prefix$label',
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w500, color: textColor)),
    );
  }
}
