import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/standing_entity.dart';

class BestThirdSection extends StatelessWidget {
  final List<TeamStandingEntity> bestThirds;

  const BestThirdSection({super.key, required this.bestThirds});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header vert
        Container(
          width: double.infinity,
          color: const Color(0xFF006847),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meilleurs 3èmes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '8 qualifiés sur 12 groupes — règles FIFA',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Légende
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              _buildLegendItem(
                const Color(0xFFF0FDF4),
                const Color(0xFF166534),
                'Qualifié pour le 32è',
              ),
              const SizedBox(width: 16),
              _buildLegendItem(
                const Color(0xFFF9FAFB),
                const Color(0xFFD1D5DB),
                'Éliminé',
              ),
            ],
          ),
        ),

        // Tableau
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildHeader(),
                if (bestThirds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Disponible après la phase de groupes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  )
                else
                  ...bestThirds.asMap().entries.map(
                    (e) => _buildRow(e.key + 1, e.value),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            child: Text(
              '#',
              style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),
          const SizedBox(
            width: 28,
            child: Text(
              'Grp',
              style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Équipe',
              style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            ),
          ),
          ..._hCell('MJ'),
          ..._hCell('G'),
          ..._hCell('N'),
          ..._hCell('P'),
          ..._hCell('Pts'),
        ],
      ),
    );
  }

  List<Widget> _hCell(String label) => [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ),
      ];

  Widget _buildRow(int rank, TeamStandingEntity team) {
    final isQualified = rank <= 8;

    return Container(
      decoration: BoxDecoration(
        color: isQualified ? const Color(0xFFF0FDF4) : null,
        border: const Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          // Position
          SizedBox(
            width: 20,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isQualified
                    ? const Color(0xFF166534)
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 4),

          // Groupe
          SizedBox(
            width: 28,
            child: Text(
              team.groupName ?? '?',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isQualified
                    ? const Color(0xFF166634)
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 6),

          // Équipe
          Expanded(
            child: Row(
              children: [
                _buildFlag(team.teamCrest, team.tla),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    team.teamName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Stats
          ..._sCell('${team.playedGames}'),
          ..._sCell('${team.won}'),
          ..._sCell('${team.draw}'),
          ..._sCell('${team.lost}'),

          // Points
          SizedBox(
            width: 28,
            child: Text(
              '${team.points}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isQualified
                    ? const Color(0xFF006847)
                    : const Color(0xFF002868),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _sCell(String val) => [
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
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF006847),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        tla != null && tla.length >= 2 ? tla.substring(0, 2) : '??',
        style: const TextStyle(
          fontSize: 7,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
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
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}