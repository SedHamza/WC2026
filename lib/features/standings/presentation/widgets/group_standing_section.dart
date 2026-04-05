import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/standing_entity.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../../../matches/presentation/widgets/match_card.dart';
import '../../../../shared/providers/repository_providers.dart';

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
    final groupMatches = matchesAsync.maybeWhen(
      data: (matches) {
        final filtered = matches.where((m) {
          if (m.group == null) return false;
          // Gère les deux formats
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
          color: const Color(0xFFF3F4F6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF002868),
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
                'Groupe ${group.groupName}',
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
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildTableHeader(),
                ...group.table
                    .asMap()
                    .entries
                    .map((e) => _buildTeamRow(e.value)),
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
                  const Color(0xFFF0FDF4), const Color(0xFF166534), 'Qualifié'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFFFFBEB), const Color(0xFF854F0B),
                  'Possible 3ème'),
            ],
          ),
        ),

        // Matchs du groupe
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            'MATCHS DU GROUPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...groupMatches.map((m) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MatchCard(match: m),
            )),

        const Divider(height: 24, thickness: 6, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          const SizedBox(
              width: 20,
              child: Text('#',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 8),
          const Expanded(
              child: Text('Équipe',
                  style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)))),
          ..._headerCell('MJ'),
          ..._headerCell('G'),
          ..._headerCell('N'),
          ..._headerCell('P'),
          ..._headerCell('Pts'),
        ],
      ),
    );
  }

  List<Widget> _headerCell(String label) => [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
      ];

  Widget _buildTeamRow(TeamStandingEntity team) {
    Color? bgColor;
    Color posColor = const Color(0xFF6B7280);

    if (team.isQualified) {
      bgColor = const Color(0xFFF0FDF4);
      posColor = const Color(0xFF166534);
    } else if (team.isPossibleThird) {
      bgColor = const Color(0xFFFFFBEB);
      posColor = const Color(0xFF854F0B);
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
                _buildFlag(team.teamCrest, team.tla),
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
          ..._statCell('${team.playedGames}'),
          ..._statCell('${team.won}'),
          ..._statCell('${team.draw}'),
          ..._statCell('${team.lost}'),
          SizedBox(
            width: 28,
            child: Text(
              '${team.points}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF002868)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _statCell(String val) => [
        SizedBox(
          width: 28,
          child: Text(
            val,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
      ];

  Widget _buildFlag(String? crest, String? tla) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE5E7EB),
      ),
      clipBehavior: Clip.antiAlias,
      child: crest != null && crest.endsWith('.svg')
          ? SvgPicture.network(
              crest,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
            )
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
      decoration:
          const BoxDecoration(color: Color(0xFF002868), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        tla?.substring(0, 2) ?? '??',
        style: const TextStyle(
            fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildLegendItem(Color bg, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
      ],
    );
  }
}
