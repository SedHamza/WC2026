import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wc2026/core/constants/app_colors.dart';
import 'package:wc2026/l10n/app_localizations.dart';
import '../../../matches/domain/entities/match_entity.dart';
import '../widgets/match_hero_banner.dart';
import '../widgets/pronostic_card.dart';
import '../providers/pronostic_provider.dart';
import '../../../../shared/providers/repository_providers.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  final MatchEntity match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        pronosticProvider(widget.match.id),
        (_, next) {
          next.whenData((existing) {
            ref
                .read(pronosticNotifierProvider(widget.match.id).notifier)
                .init(existing);
          });
        },
        fireImmediately: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final matchesAsync = ref.watch(matchesProvider);
    final liveMatch = matchesAsync.maybeWhen(
      data: (matches) {
        try {
          return matches.firstWhere((m) => m.id == widget.match.id);
        } catch (_) {
          return widget.match;
        }
      },
      orElse: () => widget.match,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPage(isDark),
      appBar: AppBar(
        title: Text(
          '${widget.match.homeTeamName} vs ${widget.match.awayTeamName}',
          style: const TextStyle(fontSize: 14),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MatchHeroBanner(match: liveMatch),
            PronosticCard(
              matchId: liveMatch.id,
              homeTeamName: liveMatch.homeTeamName,
              awayTeamName: liveMatch.awayTeamName,
              matchStarted: liveMatch.isLive || liveMatch.isFinished,
              match: liveMatch,
            ),
            _MatchInfoCard(match: liveMatch),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── INFO CARD ─────────────────────────────────────────────────────────────────

class _MatchInfoCard extends StatelessWidget {
  final MatchEntity match;

  const _MatchInfoCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final local = match.utcDate.toLocal();

    // Format date selon la locale active
    final formattedDate = DateFormat.yMMMMd(locale).format(local);
    final formattedTime =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              l10n.matchInfo.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary(isDark),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Divider(height: 1, color: AppColors.border(isDark)),
          _InfoRow(
            label: l10n.competition,
            value: 'FIFA World Cup 2026',
            isDark: isDark,
          ),
          _InfoRow(
            label: l10n.stage,
            value: match.getFormattedStage(context),
            isDark: isDark,
          ),
          if (match.group != null)
            _InfoRow(
              label: l10n.groupShort,
              value: l10n.group(match.group!.replaceAll('GROUP_', '')),
              isDark: isDark,
            ),
          if (match.matchday != null)
            _InfoRow(
              label: l10n.matchday(match.matchday.toString()),
              value: match.matchday.toString(),
              isDark: isDark,
            ),
          _InfoRow(
            label: l10n.date,
            value: formattedDate,
            isDark: isDark,
          ),
          _InfoRow(
            label: l10n.time,
            value: formattedTime,
            isDark: isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom:
                    BorderSide(color: AppColors.border(isDark), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary(isDark))),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(isDark))),
        ],
      ),
    );
  }
}