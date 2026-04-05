import 'dart:math';

import '../../domain/entities/standing_entity.dart';

class StandingModel {
  static GroupStandingEntity fromFootballData(Map<String, dynamic> json) {
    final groupName = json['group'] ?? json['stage'] ?? 'GROUP_A';
    final shortGroup = groupName.toString().replaceAll('GROUP_', '');

    final table = (json['table'] as List? ?? [])
        .map((e) => TeamStandingEntity(
              position: e['position'] ?? 0,
              teamId: e['team']?['id']?.toString() ?? '',
              teamName: e['team']?['shortName'] ?? e['team']?['name'] ?? 'TBD',
              teamCrest: e['team']?['crest'],
              tla: e['team']?['tla'],
              groupName: shortGroup, // ← AJOUTE
              playedGames: e['playedGames'] ?? 0,
              won: e['won'] ?? 0,
              draw: e['draw'] ?? 0,
              lost: e['lost'] ?? 0,
              points: e['points'] ?? 0,
              goalsFor: e['goalsFor'] ?? 0,
              goalsAgainst: e['goalsAgainst'] ?? 0,
              goalDifference: e['goalDifference'] ?? 0,
            ))
        .toList();

    return GroupStandingEntity(
      group: groupName,
      table: table,
    );
  }

  static GroupStandingEntity fromFirestore(Map<String, dynamic> json) {
    final groupName = json['group'] ?? 'Group A';
    final shortGroup = groupName.toString().replaceAll('Group ', '');
    final table = (json['table'] as List? ?? [])
        .map((e) => TeamStandingEntity(
              position: e['position'] ?? 0,
              teamId: e['teamId'] ?? '',
              teamName: e['teamName'] ?? 'TBD',
              teamCrest: e['teamCrest'],
              tla: e['tla'],
              groupName: shortGroup, // ← AJOUTE
              playedGames: e['playedGames'] ?? 0,
              won: e['won'] ?? 0,
              draw: e['draw'] ?? 0,
              lost: e['lost'] ?? 0,
              points: e['points'] ?? 0,
              goalsFor: e['goalsFor'] ?? 0,
              goalsAgainst: e['goalsAgainst'] ?? 0,
              goalDifference: e['goalDifference'] ?? 0,
            ))
        .toList();

    return GroupStandingEntity(
      group: groupName,
      table: table,
    );
  }
}
