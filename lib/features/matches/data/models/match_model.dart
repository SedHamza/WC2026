import '../../domain/entities/match_entity.dart';

class MatchModel {
  static MatchEntity fromFootballData(Map<String, dynamic> json) {
    final home = json['homeTeam'] as Map<String, dynamic>? ?? {};
    final away = json['awayTeam'] as Map<String, dynamic>? ?? {};
    final score = json['score'] as Map<String, dynamic>? ?? {};
    final fullTime = score['fullTime'] as Map<String, dynamic>? ?? {};

    return MatchEntity(
      id: json['id'].toString(),
      homeTeamName: home['shortName'] ?? home['name'] ?? 'TBD',
      awayTeamName: away['shortName'] ?? away['name'] ?? 'TBD',
      homeTeamCrest: home['crest'] as String?,
      awayTeamCrest: away['crest'] as String?,
      homeScore: fullTime['home'] as int?,
      awayScore: fullTime['away'] as int?,
      status: json['status'] as String? ?? 'SCHEDULED',
      stage: json['stage'] as String? ?? 'GROUP_STAGE',
      group: json['group'] as String?,
      matchday: json['matchday'] as int?,
      utcDate: DateTime.parse(json['utcDate'] as String),
    );
  }

  static MatchEntity fromLocalJson(Map<String, dynamic> json) {
    return MatchEntity(
      id: json['id'].toString(),
      homeTeamName: json['home_team_en'] ?? 'TBD',
      awayTeamName: json['away_team_en'] ?? 'TBD',
      homeTeamCrest: json['home_flag'] as String?,
      awayTeamCrest: json['away_flag'] as String?,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
      status: json['finished'] == true ? 'FINISHED' : 'SCHEDULED',
      stage: json['type'] ?? 'GROUP_STAGE',
      group: json['group'] as String?,
      matchday: int.tryParse(json['matchday']?.toString() ?? ''),
      utcDate: DateTime.tryParse(json['local_date'] ?? '') ?? DateTime.now(),
    );
  }
}