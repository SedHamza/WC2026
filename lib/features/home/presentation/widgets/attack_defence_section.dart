import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../../matches/domain/entities/match_entity.dart';

class _TeamGoalStats {
  final String? crest;
  int scored = 0;
  int conceded = 0;
  int played = 0;

  _TeamGoalStats({this.crest});
}

class AttackDefenceSection extends StatefulWidget {
  final List<MatchEntity> matches;

  const AttackDefenceSection({super.key, required this.matches});

  @override
  State<AttackDefenceSection> createState() => _AttackDefenceSectionState();
}

class _AttackDefenceSectionState extends State<AttackDefenceSection> {
  bool _showAttack = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final finished = widget.matches.where((m) => m.isFinished).toList();
    if (finished.isEmpty) return const SizedBox.shrink();

    // ── Agrégation des buts marqués/concédés par équipe ───────────────────
    final stats = <String, _TeamGoalStats>{};

    void addTeam(String name, String? crest) {
      stats.putIfAbsent(name, () => _TeamGoalStats(crest: crest));
    }

    for (final m in finished) {
      final home = m.homeScore ?? 0;
      final away = m.awayScore ?? 0;

      addTeam(m.homeTeamName, m.homeTeamCrest);
      addTeam(m.awayTeamName, m.awayTeamCrest);

      stats[m.homeTeamName]!.scored += home;
      stats[m.homeTeamName]!.conceded += away;
      stats[m.homeTeamName]!.played += 1;

      stats[m.awayTeamName]!.scored += away;
      stats[m.awayTeamName]!.conceded += home;
      stats[m.awayTeamName]!.played += 1;
    }

    final entries = stats.entries.toList();

    List<MapEntry<String, _TeamGoalStats>> top5;
    List<MapEntry<String, _TeamGoalStats>> worst5;
    List<MapEntry<String, _TeamGoalStats>> fullSortedBest;

    if (_showAttack) {
      // Top : plus de buts d'abord, et en cas d'égalité, moins de matchs joués
      // (plus efficace)
      final sortedTop = [...entries]..sort((a, b) {
          final cmp = b.value.scored.compareTo(a.value.scored);
          if (cmp != 0) return cmp;
          return a.value.played.compareTo(b.value.played);
        });
      top5 = sortedTop.take(5).toList();
      fullSortedBest = sortedTop;

      // Pires : moins de buts d'abord, et en cas d'égalité, plus de matchs
      // joués (moins efficace sur la durée)
      final sortedWorst = [...entries]..sort((a, b) {
          final cmp = a.value.scored.compareTo(b.value.scored);
          if (cmp != 0) return cmp;
          return b.value.played.compareTo(a.value.played);
        });
      worst5 = sortedWorst.take(5).toList();
    } else {
      // Top (meilleure défense) : moins de buts concédés d'abord, et en cas
      // d'égalité, plus de matchs joués (plus solide sur la durée)
      final sortedTop = [...entries]..sort((a, b) {
          final cmp = a.value.conceded.compareTo(b.value.conceded);
          if (cmp != 0) return cmp;
          return b.value.played.compareTo(a.value.played);
        });
      top5 = sortedTop.take(5).toList();
      fullSortedBest = sortedTop;

      // Pires : plus de buts concédés d'abord, et en cas d'égalité, moins
      // de matchs joués (encore plus fragile)
      final sortedWorst = [...entries]..sort((a, b) {
          final cmp = b.value.conceded.compareTo(a.value.conceded);
          if (cmp != 0) return cmp;
          return a.value.played.compareTo(b.value.played);
        });
      worst5 = sortedWorst.take(5).toList();
    }

    void openFullList() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _FullRankingModal(
          entries: fullSortedBest,
          showAttack: _showAttack,
          isDark: isDark,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Titre de section (cliquable) ─────────────────────────────────
          GestureDetector(
            onTap: openFullList,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  l10n.teamStats.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary(isDark),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.textSecondary(isDark)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Toggle Attaque / Défense ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ToggleButton(
                  label: l10n.attack,
                  selected: _showAttack,
                  isDark: isDark,
                  onTap: () => setState(() => _showAttack = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ToggleButton(
                  label: l10n.defence,
                  selected: !_showAttack,
                  isDark: isDark,
                  onTap: () => setState(() => _showAttack = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Top 5 ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showAttack ? l10n.topAttacks : l10n.topDefences,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              GestureDetector(
                onTap: openFullList,
                child: Text(
                  l10n.seeAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.infoText(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _TeamList(
            entries: top5,
            isDark: isDark,
            showAttack: _showAttack,
            positive: true,
          ),

          const SizedBox(height: 16),

          // ── Pires 5 ─────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showAttack ? l10n.worstAttacks : l10n.worstDefences,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
              GestureDetector(
                onTap: openFullList,
                child: Text(
                  l10n.seeAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.infoText(isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _TeamList(
            entries: worst5,
            isDark: isDark,
            showAttack: _showAttack,
            positive: false,
          ),
        ],
      ),
    );
  }
}

// ── TOGGLE BUTTON ────────────────────────────────────────────────────────────

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.infoText(isDark).withOpacity(0.12)
              : AppColors.bgSurface(isDark),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.infoText(isDark)
                : AppColors.border(isDark),
            width: selected ? 1.2 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.infoText(isDark)
                : AppColors.textSecondary(isDark),
          ),
        ),
      ),
    );
  }
}

// ── LISTE D'ÉQUIPES ───────────────────────────────────────────────────────────

class _TeamList extends StatelessWidget {
  final List<MapEntry<String, _TeamGoalStats>> entries;
  final bool isDark;
  final bool showAttack;
  final bool positive; // true = top5 (vert), false = pires5 (rouge)

  const _TeamList({
    required this.entries,
    required this.isDark,
    required this.showAttack,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accentColor =
        positive ? AppColors.accentText(isDark) : AppColors.dangerText(isDark);
    final bgColor =
        positive ? AppColors.successBg(isDark) : AppColors.errorBg(isDark);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        children: entries.asMap().entries.map((e) {
          final rank = e.key + 1;
          final teamName = e.value.key;
          final teamStats = e.value.value;
          final value = showAttack ? teamStats.scored : teamStats.conceded;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              border: rank < entries.length
                  ? Border(
                      bottom: BorderSide(
                          color: AppColors.border(isDark), width: 0.5),
                    )
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '$rank',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary(isDark)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                _TeamFlag(crest: teamStats.crest, teamName: teamName),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.matchesPlayedShort(teamStats.played),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    showAttack
                        ? l10n.goalsScoredShort(value)
                        : l10n.goalsConcededShort(value),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── DRAPEAU ÉQUIPE ────────────────────────────────────────────────────────────

class _TeamFlag extends StatelessWidget {
  final String? crest;
  final String teamName;

  const _TeamFlag({required this.crest, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            AppColors.border(Theme.of(context).brightness == Brightness.dark),
      ),
      clipBehavior: Clip.antiAlias,
      child: crest != null && crest!.isNotEmpty
          ? (crest!.endsWith('.svg')
              ? SvgPicture.network(
                  crest!,
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                  placeholderBuilder: (_) => _fallback(),
                )
              : CachedNetworkImage(
                  imageUrl: crest!,
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _fallback(),
                ))
          : _fallback(),
    );
  }

  Widget _fallback() {
    final initials =
        teamName.length >= 2 ? teamName.substring(0, 2).toUpperCase() : '??';
    return Container(
      width: 26,
      height: 26,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
            fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── MODAL CLASSEMENT COMPLET ──────────────────────────────────────────────────

class _FullRankingModal extends StatelessWidget {
  final List<MapEntry<String, _TeamGoalStats>> entries;
  final bool showAttack;
  final bool isDark;

  const _FullRankingModal({
    required this.entries,
    required this.showAttack,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgPage(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Poignée + titre
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showAttack ? l10n.allAttacks : l10n.allDefences,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close_rounded,
                          size: 22, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.border(isDark)),

              // Liste complète
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final rank = i + 1;
                    final teamName = entries[i].key;
                    final teamStats = entries[i].value;
                    final value =
                        showAttack ? teamStats.scored : teamStats.conceded;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: AppColors.border(isDark), width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary(isDark)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TeamFlag(crest: teamStats.crest, teamName: teamName),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamName,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  l10n.matchesPlayedShort(teamStats.played),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textHint(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            showAttack
                                ? l10n.goalsScoredShort(value)
                                : l10n.goalsConcededShort(value),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
