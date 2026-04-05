import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../matches/domain/entities/match_entity.dart';

class MatchHeroBanner extends StatelessWidget {
  final MatchEntity match;

  const MatchHeroBanner({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF002868), Color(0xFF1a3a6b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          Text(
            match.formattedStage,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TeamWidget(
                  name: match.homeTeamName,
                  crest: match.homeTeamCrest,
                ),
              ),
              _ScoreWidget(match: match),
              Expanded(
                child: _TeamWidget(
                  name: match.awayTeamName,
                  crest: match.awayTeamCrest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatDateTime(match.utcDate),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${local.day} ${months[local.month]} ${local.year} · '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _TeamWidget extends StatelessWidget {
  final String name;
  final String? crest;

  const _TeamWidget({required this.name, this.crest});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            color: Colors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildImage(),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (crest == null || crest!.isEmpty) {
      return const Icon(Icons.flag_rounded, color: Color(0xFF002868));
    }
    if (crest!.endsWith('.svg')) {
      return SvgPicture.network(crest!, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: crest!,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) =>
          const Icon(Icons.flag_rounded, color: Color(0xFF002868)),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  final MatchEntity match;

  const _ScoreWidget({required this.match});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          if (match.isFinished || match.isLive)
            Text(
              '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: match.isLive
                    ? const Color(0xFFFCA5A5)
                    : Colors.white,
              ),
            )
          else
            const Text(
              'VS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white54,
              ),
            ),
          if (match.isLive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFC8102E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '● LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (match.isFinished)
            const Text(
              'Terminé',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}