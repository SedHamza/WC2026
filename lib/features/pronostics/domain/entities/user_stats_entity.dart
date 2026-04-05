class UserStatsEntity {
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int totalPoints;
  final int totalPronostics;
  final int exactScoreCount;
  final int winnerCorrectCount;
  final int maxGoalsCorrectCount;
  final int minGoalsCorrectCount;
  final String? bestMatchId;
  final int bestMatchPoints;
  final DateTime? createdAt;

  const UserStatsEntity({
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.totalPoints = 0,
    this.totalPronostics = 0,
    this.exactScoreCount = 0,
    this.winnerCorrectCount = 0,
    this.maxGoalsCorrectCount = 0,
    this.minGoalsCorrectCount = 0,
    this.bestMatchId,
    this.bestMatchPoints = 0,
    this.createdAt,
  });

  // Pourcentage de réussite
  double get successRate {
    if (totalPronostics == 0) return 0;
    return (exactScoreCount + winnerCorrectCount) / totalPronostics * 100;
  }

  // Points moyens par match
  double get averagePoints {
    if (totalPronostics == 0) return 0;
    return totalPoints / totalPronostics;
  }
}