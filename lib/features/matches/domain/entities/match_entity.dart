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

  String get formattedStage {
    final groupName = group?.replaceAll('GROUP_', '') ?? '';
    switch (stage) {
      case 'GROUP_STAGE':
        return 'Groupe $groupName · J$matchday';
      case 'LAST_32':
        return '32èmes de finale';
      case 'LAST_16':
        return '16èmes de finale';
      case 'QUARTER_FINALS':
        return 'Quarts de finale';
      case 'SEMI_FINALS':
        return 'Demi-finales';
      case 'THIRD_PLACE':
        return '3ème place';
      case 'FINAL':
        return 'FINALE';
      default:
        return stage;
    }
  }
}
