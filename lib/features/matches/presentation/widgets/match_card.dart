import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/match_entity.dart';
import '../../../pronostics/presentation/screens/match_detail_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;

    if (match.isLive) {
      statusColor = const Color(0xFFEF4444);
      statusLabel = '● LIVE';
    } else if (match.isFinished) {
      statusColor = const Color(0xFF6B7280);
      statusLabel = 'Terminé';
    } else {
      statusColor = const Color(0xFF3B82F6);
      statusLabel = _formatDate(match.utcDate);
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(match: match),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.formattedStage,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: match.isFinished || match.isLive
                        ? Column(
                            children: [
                              Text(
                                '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: match.isLive
                                      ? const Color(0xFFEF4444)
                                      : null,
                                ),
                              ),
                              if (match.isLive)
                                const Text(
                                  'EN DIRECT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                _formatTime(match.utcDate),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Expanded(
                    child: _TeamWidget(
                      name: match.awayTeamName,
                      crest: match.awayTeamCrest,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
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
        _buildCrest(),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCrest() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF002868),
            Color(0xFFC8102E),
            Color(0xFF006847),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002868).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: ClipOval(
          child: Container(
            color: Colors.white,
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (crest == null || crest!.isEmpty) {
      return const Center(
        child: Icon(
          Icons.flag_rounded,
          size: 28,
          color: Color(0xFF6B7280),
        ),
      );
    }
    if (crest!.endsWith('.svg')) {
      return SvgPicture.network(
        crest!,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF002868),
            ),
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: crest!,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF002868),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(
          Icons.flag_rounded,
          size: 28,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}