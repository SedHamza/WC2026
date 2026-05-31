import 'package:flutter/material.dart';
import 'package:wc2026/l10n/app_localizations.dart';

class MatchEntity {
  final String id;
  final String homeTeamName;
  final String awayTeamName;
  final String? homeTeamCrest;
  final String? awayTeamCrest;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final String stage;
  final String? group;
  final int? matchday;
  final DateTime utcDate;

  const MatchEntity({
    required this.id,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamCrest,
    this.awayTeamCrest,
    this.homeScore,
    this.awayScore,
    required this.status,
    required this.stage,
    this.group,
    this.matchday,
    required this.utcDate,
  });

  bool get isLive => status == 'IN_PLAY' || status == 'PAUSED';
  bool get isFinished => status == 'FINISHED';
  bool get isUpcoming => status == 'SCHEDULED' || status == 'TIMED';
  bool get isTBD => homeTeamName == 'TBD' || awayTeamName == 'TBD';

String getFormattedStage(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final groupName = group?.replaceAll('GROUP_', '') ?? '';
  switch (stage) {
    case 'GROUP_STAGE':
      return '${l10n.group(groupName)} · ${l10n.matchday(matchday ?? 1)}';
    case 'LAST_32':
      return l10n.last32;
    case 'LAST_16':
      return l10n.last16;
    case 'QUARTER_FINALS':
      return l10n.quarterFinals;
    case 'SEMI_FINALS':
      return l10n.semiFinals;
    case 'THIRD_PLACE':
      return l10n.thirdPlace;
    case 'FINAL':
      return l10n.finalMatch;
    default:
      return stage;
  }
}
}
