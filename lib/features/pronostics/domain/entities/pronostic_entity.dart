class PronosticEntity {
  final String id;
  final String matchId;
  final String userId;
  final PronosticType type;
  final int? homeScore;
  final int? awayScore;
  final int? winner;
  final int? maxGoals;
  final int? minGoals;
  final int points;
  final bool isCalculated;
  final DateTime? createdAt;

  const PronosticEntity({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.type,
    this.homeScore,
    this.awayScore,
    this.winner,
    this.maxGoals,
    this.minGoals,
    this.points = 0,
    this.isCalculated = false,
    this.createdAt,
  });

  bool get isExactMode => type == PronosticType.exact;
  bool get isOtherMode => type == PronosticType.other;

  int get potentialPoints {
    if (isExactMode) return 25;
    int pts = 0;
    if (winner != null && winner != -1) pts += 5;
    if (maxGoals != null && maxGoals != -1)
      pts += ((7 - maxGoals!) * 2).clamp(0, 14);
    if (minGoals != null && minGoals != -1) pts += (minGoals! * 2).clamp(0, 14);
    return pts;
  }

  // Points provisoires live — jamais sauvegardés en Firestore
  int livePoints(int currentHome, int currentAway) =>
      calculatePoints(currentHome, currentAway);

  // Détail par option pour affichage live
  LivePointsDetail livePointsDetail(int currentHome, int currentAway) {
    final totalGoals = currentHome + currentAway;
    final currentWinner = currentHome > currentAway
        ? 1
        : currentAway > currentHome
            ? 2
            : 0;

    if (isExactMode) {
      final correct = homeScore == currentHome && awayScore == currentAway;
      return LivePointsDetail(
          exactCorrect: correct, exactPoints: correct ? 25 : 0);
    }

    bool? winnerCorrect, maxGoalsCorrect, minGoalsCorrect;
    if (winner != null && winner != -1) winnerCorrect = winner == currentWinner;
    if (maxGoals != null && maxGoals != -1)
      maxGoalsCorrect = totalGoals <= maxGoals!;
    if (minGoals != null && minGoals != -1)
      minGoalsCorrect = totalGoals >= minGoals!;

    return LivePointsDetail(
      winnerCorrect: winnerCorrect,
      winnerPoints: winnerCorrect == true ? 5 : 0,
      maxGoalsCorrect: maxGoalsCorrect,
      maxGoalsPoints:
          maxGoalsCorrect == true ? ((7 - maxGoals!) * 2).clamp(0, 14) : 0,
      minGoalsCorrect: minGoalsCorrect,
      minGoalsPoints:
          minGoalsCorrect == true ? (minGoals! * 2).clamp(0, 14) : 0,
    );
  }

  // Calcul définitif — sauvegardé en Firestore
  int calculatePoints(int realHome, int realAway) {
    if (isExactMode)
      return (homeScore == realHome && awayScore == realAway) ? 25 : 0;
    int pts = 0;
    final totalGoals = realHome + realAway;
    final realWinner = realHome > realAway
        ? 1
        : realAway > realHome
            ? 2
            : 0;
    if (winner != null && winner != -1 && winner == realWinner) pts += 5;
    if (maxGoals != null && maxGoals != -1 && totalGoals <= maxGoals!)
      pts += ((7 - maxGoals!) * 2).clamp(0, 14);
    if (minGoals != null && minGoals != -1 && totalGoals >= minGoals!)
      pts += (minGoals! * 2).clamp(0, 14);
    return pts;
  }
}

class LivePointsDetail {
  final bool? exactCorrect;
  final int exactPoints;
  final bool? winnerCorrect;
  final int winnerPoints;
  final bool? maxGoalsCorrect;
  final int maxGoalsPoints;
  final bool? minGoalsCorrect;
  final int minGoalsPoints;

  const LivePointsDetail({
    this.exactCorrect,
    this.exactPoints = 0,
    this.winnerCorrect,
    this.winnerPoints = 0,
    this.maxGoalsCorrect,
    this.maxGoalsPoints = 0,
    this.minGoalsCorrect,
    this.minGoalsPoints = 0,
  });

  int get total => exactPoints + winnerPoints + maxGoalsPoints + minGoalsPoints;
}

enum PronosticType { exact, other }
