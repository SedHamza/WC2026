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
  final int? bothTeamsScore; // 1 = Oui, 0 = Non, null/-1 = non choisi
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
    this.bothTeamsScore,
    this.points = 0,
    this.isCalculated = false,
    this.createdAt,
  });

  bool get isExactMode => type == PronosticType.exact;
  bool get isOtherMode => type == PronosticType.other;

  /// Points qui SERAIENT gagnés si TOUS les choix sélectionnés sont corrects.
  /// Mode "exact" → toujours 31.
  /// Mode "autres" → max théorique = 31 (5 vainqueur + 21 buts + 5 BTTS).
  int get potentialPoints {
    if (isExactMode) return 31;
    int pts = 0;
    if (winner != null && winner != -1) pts += 5;
    if (maxGoals != null && maxGoals != -1)
      pts += ((7 - maxGoals!) * 3).clamp(0, 21);
    if (minGoals != null && minGoals != -1) pts += (minGoals! * 3).clamp(0, 21);
    if (bothTeamsScore != null && bothTeamsScore != -1) pts += 5;
    return pts;
  }

  // Points provisoires live — jamais sauvegardés en Firestore
  int livePoints(int currentHome, int currentAway) =>
      calculatePoints(currentHome, currentAway);

  // Détail par option pour affichage live — logique "ET" (tout ou rien)
  LivePointsDetail livePointsDetail(int currentHome, int currentAway) {
    final totalGoals = currentHome + currentAway;
    final currentWinner = currentHome > currentAway
        ? 1
        : currentAway > currentHome
            ? 2
            : 0;
    final currentBoth = (currentHome > 0 && currentAway > 0) ? 1 : 0;

    if (isExactMode) {
      final correct = homeScore == currentHome && awayScore == currentAway;
      return LivePointsDetail(
          exactCorrect: correct, exactPoints: correct ? 31 : 0);
    }

    bool? winnerCorrect, maxGoalsCorrect, minGoalsCorrect, bttsCorrect;
    bool allCorrect = true;
    bool hasAnySelection = false;

    if (winner != null && winner != -1) {
      hasAnySelection = true;
      winnerCorrect = winner == currentWinner;
      if (!winnerCorrect) allCorrect = false;
    }
    if (maxGoals != null && maxGoals != -1) {
      hasAnySelection = true;
      maxGoalsCorrect = totalGoals <= maxGoals!;
      if (!maxGoalsCorrect) allCorrect = false;
    }
    if (minGoals != null && minGoals != -1) {
      hasAnySelection = true;
      minGoalsCorrect = totalGoals >= minGoals!;
      if (!minGoalsCorrect) allCorrect = false;
    }
    if (bothTeamsScore != null && bothTeamsScore != -1) {
      hasAnySelection = true;
      bttsCorrect = bothTeamsScore == currentBoth;
      if (!bttsCorrect) allCorrect = false;
    }

    // Tout ou rien : les points ne sont attribués que si TOUS les choix
    // sélectionnés sont corrects.
    final awardPoints = hasAnySelection && allCorrect;

    return LivePointsDetail(
      winnerCorrect: winnerCorrect,
      winnerPoints: (winnerCorrect == true && awardPoints) ? 5 : 0,
      maxGoalsCorrect: maxGoalsCorrect,
      maxGoalsPoints: (maxGoalsCorrect == true && awardPoints)
          ? ((7 - maxGoals!) * 3).clamp(0, 21)
          : 0,
      minGoalsCorrect: minGoalsCorrect,
      minGoalsPoints: (minGoalsCorrect == true && awardPoints)
          ? (minGoals! * 3).clamp(0, 21)
          : 0,
      bttsCorrect: bttsCorrect,
      bttsPoints: (bttsCorrect == true && awardPoints) ? 5 : 0,
    );
  }

  // Calcul définitif — sauvegardé en Firestore. Logique "ET" (tout ou rien).
  int calculatePoints(int realHome, int realAway) {
    if (isExactMode) {
      return (homeScore == realHome && awayScore == realAway) ? 31 : 0;
    }

    final totalGoals = realHome + realAway;
    final realWinner = realHome > realAway
        ? 1
        : realAway > realHome
            ? 2
            : 0;
    final realBoth = (realHome > 0 && realAway > 0) ? 1 : 0;

    bool allCorrect = true;
    bool hasAnySelection = false;

    if (winner != null && winner != -1) {
      hasAnySelection = true;
      if (winner != realWinner) allCorrect = false;
    }
    if (maxGoals != null && maxGoals != -1) {
      hasAnySelection = true;
      if (totalGoals > maxGoals!) allCorrect = false;
    }
    if (minGoals != null && minGoals != -1) {
      hasAnySelection = true;
      if (totalGoals < minGoals!) allCorrect = false;
    }
    if (bothTeamsScore != null && bothTeamsScore != -1) {
      hasAnySelection = true;
      if (bothTeamsScore != realBoth) allCorrect = false;
    }

    if (!hasAnySelection || !allCorrect) return 0;
    return potentialPoints;
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
  final bool? bttsCorrect;
  final int bttsPoints;

  const LivePointsDetail({
    this.exactCorrect,
    this.exactPoints = 0,
    this.winnerCorrect,
    this.winnerPoints = 0,
    this.maxGoalsCorrect,
    this.maxGoalsPoints = 0,
    this.minGoalsCorrect,
    this.minGoalsPoints = 0,
    this.bttsCorrect,
    this.bttsPoints = 0,
  });

  int get total =>
      exactPoints + winnerPoints + maxGoalsPoints + minGoalsPoints + bttsPoints;
}

enum PronosticType { exact, other }
