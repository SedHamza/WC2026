import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pronostics/domain/entities/pronostic_entity.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../pronostics/presentation/screens/match_detail_screen.dart';
import '../../../../shared/providers/repository_providers.dart';

class PronosticHistoryList extends ConsumerWidget {
  final List<PronosticEntity> pronostics;

  const PronosticHistoryList({super.key, required this.pronostics});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesProvider);

    return matchesAsync.maybeWhen(
      data: (matches) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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

  const _HistoryRow({
    required this.pronostic,
    required this.match,
    this.isLast = false,
  });

  Color get _dotColor {
    if (!pronostic.isCalculated) return const Color(0xFFF59E0B);
    if (pronostic.points > 0) return const Color(0xFF006847);
    return const Color(0xFF6B7280);
  }

  int get _maxPossible => pronostic.potentialPoints;

  String get _statusText {
    if (match.isFinished) return 'Terminé';
    if (match.isLive) return 'En direct';
    return 'En attente';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne du haut : dot + teams + points
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${match.homeTeamName} vs ${match.awayTeamName}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _PointsBadge(pronostic: pronostic),
              ],
            ),
            const SizedBox(height: 6),

            // Chips des options
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildChips(),
            ),
            const SizedBox(height: 4),

            // Max possible + statut + modifier
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Text(
                    'Max : $_maxPossible pts · $_statusText',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const Spacer(),
                  if (match.isUpcoming)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchDetailScreen(match: match),
                        ),
                      ),
                      child: const Text(
                        'Modifier →',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF002868),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChips() {
    if (pronostic.isExactMode) {
      final correct = pronostic.isCalculated && pronostic.points == 25;
      return Wrap(
        spacing: 6,
        children: [
          _Chip(
            label: 'Score exact ${pronostic.homeScore}-${pronostic.awayScore}',
            status: pronostic.isCalculated
                ? (correct ? _ChipStatus.correct : _ChipStatus.wrong)
                : _ChipStatus.pending,
          ),
        ],
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (pronostic.winner != null && pronostic.winner != -1)
          _buildWinnerChip(),
        if (pronostic.maxGoals != null && pronostic.maxGoals != -1)
          _buildMaxChip(),
        if (pronostic.minGoals != null && pronostic.minGoals != -1)
          _buildMinChip(),
      ],
    );
  }

  Widget _buildWinnerChip() {
    final name = pronostic.winner == 1
        ? match.homeTeamName
        : pronostic.winner == 2
            ? match.awayTeamName
            : 'Égalité';

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

  Widget _buildMaxChip() {
    _ChipStatus status = _ChipStatus.pending;
    if (pronostic.isCalculated && match.isFinished) {
      final total = (match.homeScore ?? 0) + (match.awayScore ?? 0);
      status = total <= pronostic.maxGoals!
          ? _ChipStatus.correct
          : _ChipStatus.wrong;
    }
    return _Chip(label: 'Max ≤ ${pronostic.maxGoals}', status: status);
  }

  Widget _buildMinChip() {
    _ChipStatus status = _ChipStatus.pending;
    if (pronostic.isCalculated && match.isFinished) {
      final total = (match.homeScore ?? 0) + (match.awayScore ?? 0);
      status = total >= pronostic.minGoals!
          ? _ChipStatus.correct
          : _ChipStatus.wrong;
    }
    return _Chip(label: 'Min ≥ ${pronostic.minGoals}', status: status);
  }

  // ── MODAL DÉTAIL ───────────────────────────────────────────────────────────

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailModal(pronostic: pronostic, match: match),
    );
  }
}

// ── MODAL ─────────────────────────────────────────────────────────────────────

class _DetailModal extends StatelessWidget {
  final PronosticEntity pronostic;
  final MatchEntity match;

  const _DetailModal({required this.pronostic, required this.match});

  @override
  Widget build(BuildContext context) {
    final totalReal = (match.homeScore ?? 0) + (match.awayScore ?? 0);
    final realWinner = (match.homeScore ?? 0) > (match.awayScore ?? 0)
        ? 1
        : (match.awayScore ?? 0) > (match.homeScore ?? 0)
            ? 2
            : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '${match.homeTeamName} vs ${match.awayTeamName}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${match.formattedStage} · '
            '${match.isFinished ? "Terminé ${match.homeScore}-${match.awayScore}" : match.isLive ? "En direct" : "À venir"}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),

          // Type de pronostic
          _DetailRow(
            label: 'Mode',
            value: pronostic.isExactMode
                ? 'Résultat exact'
                : 'Autres pronostics',
          ),

          if (pronostic.isExactMode) ...[
            _DetailRow(
              label: 'Score prédit',
              value: '${pronostic.homeScore} - ${pronostic.awayScore}',
              pts: pronostic.isCalculated
                  ? (pronostic.points == 25 ? '+25 pts ✅' : '+0 pt ❌')
                  : null,
              ptsColor: pronostic.points == 25
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
            ),
          ] else ...[
            if (pronostic.winner != null && pronostic.winner != -1) ...[
              _DetailRow(
                label: 'Qui gagne',
                value: pronostic.winner == 1
                    ? match.homeTeamName
                    : pronostic.winner == 2
                        ? match.awayTeamName
                        : 'Égalité',
                pts: pronostic.isCalculated
                    ? (pronostic.winner == realWinner
                        ? '+5 pts ✅'
                        : '+0 pt ❌')
                    : null,
                ptsColor: pronostic.winner == realWinner
                    ? const Color(0xFF166534)
                    : const Color(0xFF991B1B),
              ),
            ],
            if (pronostic.maxGoals != null && pronostic.maxGoals != -1) ...[
              _DetailRow(
                label: 'Max buts (≤${pronostic.maxGoals})',
                value: pronostic.isCalculated
                    ? 'Total réel : $totalReal'
                    : 'En attente',
                pts: pronostic.isCalculated
                    ? (totalReal <= pronostic.maxGoals!
                        ? '+${(7 - pronostic.maxGoals!) * 2} pts ✅'
                        : '+0 pt ❌')
                    : null,
                ptsColor: totalReal <= (pronostic.maxGoals ?? 99)
                    ? const Color(0xFF166534)
                    : const Color(0xFF991B1B),
              ),
            ],
            if (pronostic.minGoals != null && pronostic.minGoals != -1) ...[
              _DetailRow(
                label: 'Min buts (≥${pronostic.minGoals})',
                value: pronostic.isCalculated
                    ? 'Total réel : $totalReal'
                    : 'En attente',
                pts: pronostic.isCalculated
                    ? (totalReal >= pronostic.minGoals!
                        ? '+${pronostic.minGoals! * 2} pts ✅'
                        : '+0 pt ❌')
                    : null,
                ptsColor: totalReal >= (pronostic.minGoals ?? 0)
                    ? const Color(0xFF166534)
                    : const Color(0xFF991B1B),
              ),
            ],
          ],

          const SizedBox(height: 8),

          // Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total obtenu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF002868),
                  ),
                ),
                Text(
                  pronostic.isCalculated
                      ? '${pronostic.points} / ${pronostic.potentialPoints} pts max'
                      : '— / ${pronostic.potentialPoints} pts max',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF002868),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Fermer'),
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
                          builder: (_) =>
                              MatchDetailScreen(match: match),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002868),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
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

  const _DetailRow({
    required this.label,
    required this.value,
    this.pts,
    this.ptsColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          if (pts != null) ...[
            const SizedBox(width: 8),
            Text(
              pts!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ptsColor ?? const Color(0xFF6B7280),
              ),
            ),
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
    Color bg, textColor, border;
    String prefix;

    switch (status) {
      case _ChipStatus.correct:
        bg = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF166534);
        border = const Color(0xFF166534);
        prefix = '✓ ';
        break;
      case _ChipStatus.wrong:
        bg = const Color(0xFFFEF2F2);
        textColor = const Color(0xFF991B1B);
        border = const Color(0xFF991B1B);
        prefix = '✗ ';
        break;
      case _ChipStatus.pending:
        bg = const Color(0xFFF9FAFB);
        textColor = const Color(0xFF6B7280);
        border = const Color(0xFFD1D5DB);
        prefix = '';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        '$prefix$label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final PronosticEntity pronostic;

  const _PointsBadge({required this.pronostic});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    String text;

    if (!pronostic.isCalculated) {
      bg = const Color(0xFFFFFBEB);
      textColor = const Color(0xFF854F0B);
      text = '— pts';
    } else if (pronostic.points >= 20) {
      bg = const Color(0xFFEEF2FF);
      textColor = const Color(0xFF002868);
      text = '${pronostic.points} pts';
    } else if (pronostic.points > 0) {
      bg = const Color(0xFFF0FDF4);
      textColor = const Color(0xFF166534);
      text = '${pronostic.points} pts';
    } else {
      bg = const Color(0xFFF9FAFB);
      textColor = const Color(0xFF6B7280);
      text = '0 pts';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}