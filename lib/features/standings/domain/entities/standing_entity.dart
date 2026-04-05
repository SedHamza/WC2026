class TeamStandingEntity {
  final int position;
  final String teamId;
  final String teamName;
  final String? teamCrest;
  final String? tla;
  final String? groupName;
  final int playedGames;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  const TeamStandingEntity({
    required this.position,
    required this.teamId,
    required this.teamName,
    this.teamCrest,
    this.tla,
    this.groupName,
    required this.playedGames,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  bool get isQualified => position <= 2;
  bool get isPossibleThird => position == 3;
}

class GroupStandingEntity {
  final String group;
  final List<TeamStandingEntity> table;

  const GroupStandingEntity({
    required this.group,
    required this.table,
  });

  String get groupName {
    // Gère les deux formats : "GROUP_A" et "Group A"
    return group.replaceAll('GROUP_', '').replaceAll('Group ', '').trim();
  }
}
