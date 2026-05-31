import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../domain/entities/standing_entity.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../matches/presentation/widgets/match_card.dart';

class GroupStandingSection extends ConsumerWidget {
  final GroupStandingEntity group;
  final AsyncValue<List<MatchEntity>> matchesAsync;

  const GroupStandingSection({
    super.key,
    required this.group,
    required this.matchesAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final groupMatches = matchesAsync.maybeWhen(
      data: (matches) {
        final filtered = matches.where((m) {
          if (m.group == null) return false;
          final matchGroup =
              m.group!.replaceAll('GROUP_', '').replaceAll('Group ', '').trim();
          return matchGroup == group.groupName;
        }).toList()
          ..sort((a, b) => a.utcDate.compareTo(b.utcDate));
        return filtered;
      },
      orElse: () => <MatchEntity>[],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header groupe
        Container(
          color: AppColors.bgSurface(isDark),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.groupStandings(group.groupName),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Tableau classement
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(isDark)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildTableHeader(isDark, l10n),
                ...group.table.map((t) => _buildTeamRow(t, isDark)),
              ],
            ),
          ),
        ),

        // Légende
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              _buildLegendItem(
                AppColors.successBg(isDark),
                AppColors.successDark,
                l10n.qualified,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                AppColors.warningBg(isDark),
                AppColors.warningDark,
                l10n.possibleThird,
                isDark,
              ),
            ],
          ),
        ),

        // Matchs du groupe
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            l10n.groupMatches.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(isDark),
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...groupMatches.map((m) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MatchCard(match: m),
            )),

        Divider(
          height: 24,
          thickness: 6,
          color: AppColors.bgSurface(isDark),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '#',
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSecondary(isDark)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.team,
              style: TextStyle(
                  fontSize: 10, color: AppColors.textSecondary(isDark)),
            ),
          ),
          ..._headerCell(l10n.played, isDark),
          ..._headerCell(l10n.won, isDark),
          ..._headerCell(l10n.drawnShort, isDark),
          ..._headerCell(l10n.lost, isDark),
          ..._headerCell(l10n.points, isDark),
        ],
      ),
    );
  }

  List<Widget> _headerCell(String label, bool isDark) => [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style:
                TextStyle(fontSize: 10, color: AppColors.textSecondary(isDark)),
            textAlign: TextAlign.center,
          ),
        ),
      ];

  Widget _buildTeamRow(TeamStandingEntity team, bool isDark) {
    Color? bgColor;
    Color posColor = AppColors.textSecondary(isDark);

    if (team.isQualified) {
      bgColor = AppColors.successBg(isDark);
      posColor = AppColors.successDark;
    } else if (team.isPossibleThird) {
      bgColor = AppColors.warningBg(isDark);
      posColor = AppColors.warningDark;
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '${team.position}',
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: posColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                _buildFlag(team.teamCrest, team.tla, isDark),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    team.teamName,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ..._statCell('${team.playedGames}', isDark),
          ..._statCell('${team.won}', isDark),
          ..._statCell('${team.draw}', isDark),
          ..._statCell('${team.lost}', isDark),
          SizedBox(
            width: 28,
            child: Text(
              '${team.points}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _statCell(String val, bool isDark) => [
        SizedBox(
          width: 28,
          child: Text(
            val,
            style:
                TextStyle(fontSize: 11, color: AppColors.textSecondary(isDark)),
            textAlign: TextAlign.center,
          ),
        ),
      ];

  Widget _buildFlag(String? crest, String? tla, bool isDark) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.border(isDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: crest != null && crest.endsWith('.svg')
          ? SvgPicture.network(crest, width: 22, height: 22, fit: BoxFit.cover)
          : crest != null && crest.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: crest,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _flagFallback(tla),
                )
              : _flagFallback(tla),
    );
  }

  Widget _flagFallback(String? tla) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        tla?.substring(0, 2) ?? '??',
        style: const TextStyle(
            fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLegendItem(Color bg, Color border, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style:
              TextStyle(fontSize: 10, color: AppColors.textSecondary(isDark)),
        ),
      ],
    );
  }
}
