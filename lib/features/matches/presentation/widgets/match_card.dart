import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../domain/entities/match_entity.dart';
import '../../../pronostics/presentation/screens/match_detail_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color statusColor;
    final String statusLabel;

    if (match.isLive) {
      statusColor = AppColors.live;
      statusLabel = '● LIVE';
    } else if (match.isFinished) {
      statusColor = AppColors.finished;
      statusLabel = l10n.finished;
    } else {
      statusColor = AppColors.infoText(isDark);
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
                      match.getFormattedStage(context),
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
                      isDark: isDark,
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
                                      ? AppColors.live
                                      : AppColors.textPrimary(isDark),
                                ),
                              ),
                              if (match.isLive)
                                Text(
                                  l10n.live,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.live,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                l10n.vs,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                              Text(
                                _formatTime(match.utcDate),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ],
                          ),
                  ),
                  Expanded(
                    child: _TeamWidget(
                      name: match.awayTeamName,
                      crest: match.awayTeamCrest,
                      isDark: isDark,
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
  final bool isDark;

  const _TeamWidget({
    required this.name,
    required this.isDark,
    this.crest,
  });

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
          colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
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
      return Center(
        child: Icon(Icons.flag_rounded,
            size: 28, color: AppColors.textSecondary(isDark)),
      );
    }
    if (crest!.endsWith('.svg')) {
      return SvgPicture.network(crest!,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary)),
              ));
    }
    return CachedNetworkImage(
      imageUrl: crest!,
      fit: BoxFit.cover,
      placeholder: (_, __) => Center(
        child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary)),
      ),
      errorWidget: (_, __, ___) => Center(
        child: Icon(Icons.flag_rounded,
            size: 28, color: AppColors.textSecondary(isDark)),
      ),
    );
  }
}
