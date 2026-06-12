import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import 'package:wc2026/features/matches/domain/entities/match_entity.dart';
import 'package:wc2026/features/pronostics/domain/entities/pronostic_entity.dart';
import '../providers/pronostic_provider.dart';
import 'pronostic_toggle.dart';
import 'exact_score_widget.dart';
import 'other_pronostics_widget.dart';

class PronosticCard extends ConsumerWidget {
  final String matchId;
  final String homeTeamName;
  final String awayTeamName;
  final bool matchStarted;
  final MatchEntity? match;

  const PronosticCard({
    super.key,
    required this.matchId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.matchStarted,
    this.match,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(pronosticNotifierProvider(matchId));
    final notifier = ref.read(pronosticNotifierProvider(matchId).notifier);
    final enabled = !matchStarted;

    final pronosticAsync = ref.watch(pronosticProvider(matchId));
    final hasPronostic = state.isSaved ||
        pronosticAsync.maybeWhen(
          data: (p) => p != null,
          orElse: () => false,
        );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        border: Border.all(
          color: match?.isLive == true
              ? AppColors.live
              : match?.isFinished == true
                  ? AppColors.accentText(isDark)
                  : AppColors.infoText(isDark),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.myPronostic,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.infoText(isDark),
                ),
              ),
              _buildPointsBadge(state, isDark, hasPronostic: hasPronostic),
            ],
          ),

          // ── Banners selon statut ────────────────────────────────────────
          if (match?.isLive == true) ...[
            const SizedBox(height: 8),
            if (hasPronostic)
              _LiveScoreBanner(match: match!, state: state, isDark: isDark),
          ] else if (match?.isFinished == true && hasPronostic) ...[
            const SizedBox(height: 8),
            _FinalResultBanner(match: match!, state: state, isDark: isDark),
          ] else if (matchStarted) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.errorBg(isDark),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_rounded,
                      size: 14, color: AppColors.dangerText(isDark)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.lockedMatch,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.dangerText(isDark),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Si match commencé et pas de pronostic → message et stop ────
          if (matchStarted && !hasPronostic) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSubtle(isDark),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied_rounded,
                      color: AppColors.textSecondary(isDark), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.noPronostic,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary(isDark)),
                  ),
                ],
              ),
            ),
          ] else ...[
            PronosticToggle(
                selected: state.type,
                onChanged: notifier.setType,
                enabled: enabled),
            const SizedBox(height: 16),
            if (state.type == PronosticType.exact)
              ExactScoreWidget(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                homeScore: state.homeScore,
                awayScore: state.awayScore,
                onHomeChanged: notifier.setHomeScore,
                onAwayChanged: notifier.setAwayScore,
                enabled: enabled,
              )
            else
              OtherPronosticsWidget(
                homeTeamName: homeTeamName,
                awayTeamName: awayTeamName,
                winner: state.winner,
                maxGoals: state.maxGoals,
                minGoals: state.minGoals,
                bothTeamsScore: state.bothTeamsScore,
                onWinnerChanged: notifier.setWinner,
                onMaxGoalsChanged: notifier.setMaxGoals,
                onMinGoalsChanged: notifier.setMinGoals,
                onBothTeamsScoreChanged: notifier.setBothTeamsScore,
                potentialPoints: state.potentialPoints,
                enabled: enabled,
              ),
            const SizedBox(height: 14),
            if (enabled) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSaving ? null : notifier.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.type == PronosticType.exact
                        ? AppColors.primary
                        : AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          state.isSaved
                              ? l10n.updatePronostic
                              : l10n.confirmPronostic,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              if (state.isSaved) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: notifier.reset,
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text(l10n.clearPronostic,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ],
            if (state.isSaved && !matchStarted)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.accentText(isDark)),
                    const SizedBox(width: 4),
                    Text(l10n.pronosticSaved,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.accentText(isDark),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPointsBadge(PronosticFormState state, bool isDark,
      {bool hasPronostic = false}) {
    if (match?.isFinished == true && hasPronostic && match!.homeScore != null) {
      final pts = _calcPoints(state, match!.homeScore!, match!.awayScore!);
      final maxPts = _calcMaxPoints(state);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: pts > 0 ? AppColors.accent : AppColors.textSecondary(isDark),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$pts/$maxPts pts ✓',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
    }
    if (match?.isLive == true && hasPronostic && match!.homeScore != null) {
      final pts = _calcPoints(state, match!.homeScore!, match!.awayScore!);
      final maxPts = _calcMaxPoints(state);
      return _PulsingBadge(points: pts, maxPoints: maxPts);
    }
    if (matchStarted && !hasPronostic) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: Text('${state.potentialPoints} pts',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  int _calcPoints(PronosticFormState state, int home, int away) {
    final e = PronosticEntity(
        id: '',
        matchId: matchId,
        userId: '',
        type: state.type,
        homeScore: state.homeScore,
        awayScore: state.awayScore,
        winner: state.winner,
        maxGoals: state.maxGoals,
        minGoals: state.minGoals,
        bothTeamsScore: state.bothTeamsScore);
    return e.livePoints(home, away);
  }

  int _calcMaxPoints(PronosticFormState state) {
    return state.potentialPoints;
  }
}

// ── LIVE BANNER ───────────────────────────────────────────────────────────────

class _LiveScoreBanner extends StatelessWidget {
  final MatchEntity match;
  final PronosticFormState state;
  final bool isDark;

  const _LiveScoreBanner(
      {required this.match, required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final home = match.homeScore ?? 0;
    final away = match.awayScore ?? 0;
    final entity = _buildEntity();
    final detail = entity.livePointsDetail(home, away);
    final maxPts = entity.potentialPoints;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.live.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.live.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.live, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(l10n.currentScore(home.toString(), away.toString()),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.live)),
              const Spacer(),
              // ← Format pts/max pts live
              Text('🔴 ${detail.total}/$maxPts pts',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: detail.total > 0
                          ? AppColors.live
                          : AppColors.textSecondary(isDark))),
            ],
          ),
          if (state.isSaved) ...[
            const SizedBox(height: 8),
            _DetailRows(detail: detail, state: state, isDark: isDark)
          ],
        ],
      ),
    );
  }

  PronosticEntity _buildEntity() => PronosticEntity(
      id: '',
      matchId: match.id,
      userId: '',
      type: state.type,
      homeScore: state.homeScore,
      awayScore: state.awayScore,
      winner: state.winner,
      maxGoals: state.maxGoals,
      minGoals: state.minGoals,
      bothTeamsScore: state.bothTeamsScore);
}

// ── FINAL BANNER ──────────────────────────────────────────────────────────────

class _FinalResultBanner extends StatelessWidget {
  final MatchEntity match;
  final PronosticFormState state;
  final bool isDark;

  const _FinalResultBanner(
      {required this.match, required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final home = match.homeScore ?? 0;
    final away = match.awayScore ?? 0;
    final entity = PronosticEntity(
        id: '',
        matchId: match.id,
        userId: '',
        type: state.type,
        homeScore: state.homeScore,
        awayScore: state.awayScore,
        winner: state.winner,
        maxGoals: state.maxGoals,
        minGoals: state.minGoals,
        bothTeamsScore: state.bothTeamsScore);
    final detail = entity.livePointsDetail(home, away);
    final total = detail.total;
    final maxPts = entity.potentialPoints;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: total > 0
            ? AppColors.successBg(isDark)
            : AppColors.bgSubtle(isDark),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: total > 0
                ? AppColors.accentText(isDark).withOpacity(0.3)
                : AppColors.borderStrong(isDark)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                  total > 0 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 14,
                  color: total > 0
                      ? AppColors.accentText(isDark)
                      : AppColors.textSecondary(isDark)),
              const SizedBox(width: 6),
              Text(l10n.finalResult(home.toString(), away.toString()),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: total > 0
                          ? AppColors.accentText(isDark)
                          : AppColors.textSecondary(isDark))),
              const Spacer(),
              // ← Format pts/max pts final
              Text('$total/$maxPts pts',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: total > 0
                          ? AppColors.accentText(isDark)
                          : AppColors.textSecondary(isDark))),
            ],
          ),
          const SizedBox(height: 8),
          _DetailRows(detail: detail, state: state, isDark: isDark),
        ],
      ),
    );
  }
}

// ── DETAIL ROWS ───────────────────────────────────────────────────────────────

class _DetailRows extends StatelessWidget {
  final LivePointsDetail detail;
  final PronosticFormState state;
  final bool isDark;

  const _DetailRows(
      {required this.detail, required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.type == PronosticType.exact) {
      return _Row(
          label: l10n.exactScoreLabel,
          correct: detail.exactCorrect,
          points: detail.exactPoints,
          max: 31,
          isDark: isDark);
    }
    return Column(
      children: [
        if (state.winner != null && state.winner != -1)
          _Row(
              label: l10n.winnerLabel,
              correct: detail.winnerCorrect,
              points: detail.winnerPoints,
              max: 5,
              isDark: isDark),
        if (state.maxGoals != null && state.maxGoals != -1)
          _Row(
              label: l10n.maxGoalsLabel2(state.maxGoals.toString()),
              correct: detail.maxGoalsCorrect,
              points: detail.maxGoalsPoints,
              max: ((7 - state.maxGoals!) * 3).clamp(0, 21),
              isDark: isDark),
        if (state.minGoals != null && state.minGoals != -1)
          _Row(
              label: l10n.minGoalsLabel2(state.minGoals.toString()),
              correct: detail.minGoalsCorrect,
              points: detail.minGoalsPoints,
              max: (state.minGoals! * 3).clamp(0, 21),
              isDark: isDark),
        if (state.bothTeamsScore != -1)
          _Row(
              label: l10n.bothTeamsScoreLabel(
                  state.bothTeamsScore == 1 ? l10n.yes : l10n.no),
              correct: detail.bttsCorrect,
              points: detail.bttsPoints,
              max: 5,
              isDark: isDark),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final bool? correct;
  final int points;
  final int max;
  final bool isDark;

  const _Row(
      {required this.label,
      required this.correct,
      required this.points,
      required this.max,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isOk = correct == true;
    final isNo = correct == false;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
              isOk
                  ? Icons.check_rounded
                  : isNo
                      ? Icons.close_rounded
                      : Icons.remove_rounded,
              size: 14,
              color: isOk
                  ? AppColors.accentText(isDark)
                  : isNo
                      ? AppColors.dangerText(isDark)
                      : AppColors.textSecondary(isDark)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textSecondary(isDark)))),
          // ← Format +pts/max pts
          Text(
              isOk
                  ? '+$points/$max pts'
                  : isNo
                      ? '+0/$max pts'
                      : '±$max pts',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isOk
                      ? AppColors.accentText(isDark)
                      : isNo
                          ? AppColors.dangerText(isDark)
                          : AppColors.textSecondary(isDark))),
        ],
      ),
    );
  }
}

// ── BADGE PULSANT ─────────────────────────────────────────────────────────────

class _PulsingBadge extends StatefulWidget {
  final int points;
  final int maxPoints;
  const _PulsingBadge({required this.points, required this.maxPoints});

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
            color: AppColors.live, borderRadius: BorderRadius.circular(12)),
        // ← Format pts/max pts live dans le badge
        child: Text('🔴 ${widget.points}/${widget.maxPoints} pts live',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
