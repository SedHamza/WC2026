class PronosticEntity {
  final String id;
  final String matchId;
  final String userId;
  final PronosticType type;

  // Mode 1 — Résultat exact
  final int? homeScore;
  final int? awayScore;

  // Mode 2 — Autres pronostics
  final int? winner;   // 0=nul, 1=home, 2=away, -1=non choisi
  final int? maxGoals; // -1=non choisi
  final int? minGoals; // -1=non choisi

  // Points
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

  // Points potentiels avant le match
  int get potentialPoints {
    if (isExactMode) return 25;
    int pts = 0;
    if (winner != null && winner != -1) pts += 5;
    if (maxGoals != null && maxGoals != -1) pts += (7 - maxGoals!) * 2;
    if (minGoals != null && minGoals != -1) pts += minGoals! * 2;
    return pts;
  }

  // Calcul réel — chaque option est indépendante
  int calculatePoints(int realHome, int realAway) {
    if (isExactMode) {
      return (homeScore == realHome && awayScore == realAway) ? 25 : 0;
    }

    int pts = 0;
    final totalGoals = realHome + realAway;
    final realWinner = realHome > realAway
        ? 1
        : realAway > realHome
            ? 2
            : 0;

    // Qui gagne — indépendant
    if (winner != null && winner != -1) {
      if (winner == realWinner) pts += 5;
    }

    // Max buts — indépendant
    if (maxGoals != null && maxGoals != -1) {
      if (totalGoals <= maxGoals!) pts += (7 - maxGoals!) * 2;
    }

    // Min buts — indépendant
    if (minGoals != null && minGoals != -1) {
      if (totalGoals >= minGoals!) pts += minGoals! * 2;
    }

    return pts;
  }
}

enum PronosticType { exact, other }