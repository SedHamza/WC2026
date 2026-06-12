import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../domain/entities/standing_entity.dart';

class BestThirdSection extends StatelessWidget {
  final List<TeamStandingEntity> bestThirds;

  const BestThirdSection({super.key, required this.bestThirds});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.bestThirds,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.bestThirdsSubtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              _buildLegendItem(AppColors.successBg(isDark),
                  AppColors.accentText(isDark), l10n.qualifiedFor32, isDark),
              const SizedBox(width: 16),
              _buildLegendItem(AppColors.bgSubtle(isDark),
                  AppColors.borderStrong(isDark), l10n.eliminated, isDark),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(isDark)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildHeader(l10n, isDark),
                if (bestThirds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l10n.availableAfterGroups,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(isDark)),
                      ),
                    ),
                  )
                else
                  ...bestThirds.asMap().entries.map(
                        (e) => _buildRow(e.key + 1, e.value, l10n, isDark),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 20,
              child: Text('#',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary(isDark)),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          SizedBox(
              width: 28,
              child: Text(l10n.groupShort,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary(isDark)),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(l10n.team,
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textSecondary(isDark)))),
          ..._hCell(l10n.played, isDark),
          ..._hCell(l10n.won, isDark),
          ..._hCell(l10n.drawnShort, isDark),
          ..._hCell(l10n.lost, isDark),
          ..._hCell(l10n.points, isDark),
        ],
      ),
    );
  }

  List<Widget> _hCell(String label, bool isDark) => [
        SizedBox(
            width: 28,
            child: Text(label,
                style: TextStyle(
                    fontSize: 10, color: AppColors.textSecondary(isDark)),
                textAlign: TextAlign.center)),
      ];

  Widget _buildRow(
      int rank, TeamStandingEntity team, AppLocalizations l10n, bool isDark) {
    final isQualified = rank <= 8;
    return Container(
      decoration: BoxDecoration(
        color: isQualified ? AppColors.successBg(isDark) : null,
        border: Border(
            top: BorderSide(color: AppColors.border(isDark), width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: Row(
        children: [
          SizedBox(
              width: 20,
              child: Text('$rank',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isQualified
                          ? AppColors.accentText(isDark)
                          : AppColors.textSecondary(isDark)),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 4),
          SizedBox(
              width: 28,
              child: Text(team.groupName ?? '?',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isQualified
                          ? AppColors.accentText(isDark)
                          : AppColors.textSecondary(isDark)),
                  textAlign: TextAlign.center)),
          const SizedBox(width: 6),
          Expanded(
            child: Row(
              children: [
                _buildFlag(team.teamCrest, team.tla),
                const SizedBox(width: 6),
                Flexible(
                    child: Text(team.teamName,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          ..._sCell('${team.playedGames}', isDark),
          ..._sCell('${team.won}', isDark),
          ..._sCell('${team.draw}', isDark),
          ..._sCell('${team.lost}', isDark),
          SizedBox(
              width: 28,
              child: Text('${team.points}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isQualified
                          ? AppColors.accentText(isDark)
                          : AppColors.infoText(isDark)),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  List<Widget> _sCell(String val, bool isDark) => [
        SizedBox(
            width: 28,
            child: Text(val,
                style: TextStyle(
                    fontSize: 11, color: AppColors.textSecondary(isDark)),
                textAlign: TextAlign.center)),
      ];

  Widget _buildFlag(String? crest, String? tla) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
          shape: BoxShape.circle, color: AppColors.borderLight),
      clipBehavior: Clip.antiAlias,
      child: crest != null && crest.endsWith('.svg')
          ? SvgPicture.network(crest, width: 22, height: 22, fit: BoxFit.cover)
          : crest != null && crest.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: crest,
                  width: 22,
                  height: 22,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => _flagFallback(tla))
              : _flagFallback(tla),
    );
  }

  Widget _flagFallback(String? tla) {
    return Container(
      width: 22,
      height: 22,
      decoration:
          const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(tla != null && tla.length >= 2 ? tla.substring(0, 2) : '??',
          style: const TextStyle(
              fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600)),
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
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10, color: AppColors.textSecondary(isDark))),
      ],
    );
  }
}
