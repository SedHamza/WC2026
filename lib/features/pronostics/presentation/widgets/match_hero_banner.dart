import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../../matches/domain/entities/match_entity.dart';

class MatchHeroBanner extends StatelessWidget {
  final MatchEntity match;

  const MatchHeroBanner({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF1a3a6b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          Text(
            match.getFormattedStage(context),
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
              _ScoreWidget(match: match, l10n: l10n),
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
            _formatDateTime(match.utcDate, locale),
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date, String locale) {
    final local = date.toLocal();
    final datePart = DateFormat.yMMMMd(locale).format(local);
    final timePart =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$datePart · $timePart';
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
      return const Icon(Icons.flag_rounded, color: AppColors.primary);
    }
    if (crest!.endsWith('.svg')) {
      return SvgPicture.network(crest!, fit: BoxFit.cover);
    }
    return CachedNetworkImage(
      imageUrl: crest!,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) =>
          const Icon(Icons.flag_rounded, color: AppColors.primary),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  final MatchEntity match;
  final AppLocalizations l10n;

  const _ScoreWidget({required this.match, required this.l10n});

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
                    ? Colors.white.withOpacity(0.85)
                    : Colors.white,
              ),
            )
          else
            Text(
              l10n.vs,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white54,
              ),
            ),
          if (match.isLive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary,
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
            Text(
              l10n.finished,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}