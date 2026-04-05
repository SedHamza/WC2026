import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pronostic_entity.dart';
import '../../domain/entities/user_stats_entity.dart';

class PronosticModel {
  static PronosticEntity fromFirestore(Map<String, dynamic> json) {
    return PronosticEntity(
      id: json['id'] ?? '',
      matchId: json['matchId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] == 'exact'
          ? PronosticType.exact
          : PronosticType.other,
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      winner: json['winner'],
      maxGoals: json['maxGoals'],
      minGoals: json['minGoals'],
      points: json['points'] ?? 0,
      isCalculated: json['isCalculated'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  static Map<String, dynamic> toFirestore(PronosticEntity p) {
    return {
      'id': p.id,
      'matchId': p.matchId,
      'userId': p.userId,
      'type': p.isExactMode ? 'exact' : 'other',
      'homeScore': p.homeScore,
      'awayScore': p.awayScore,
      'winner': p.winner,
      'maxGoals': p.maxGoals,
      'minGoals': p.minGoals,
      'points': p.points,
      'isCalculated': p.isCalculated,
      'createdAt': p.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }

  static UserStatsEntity userStatsFromFirestore(
      String userId, Map<String, dynamic> json) {
    return UserStatsEntity(
      userId: userId,
      displayName: json['displayName'] ?? 'Utilisateur',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      totalPoints: json['totalPoints'] ?? 0,
      totalPronostics: json['totalPronostics'] ?? 0,
      exactScoreCount: json['exactScoreCount'] ?? 0,
      winnerCorrectCount: json['winnerCorrectCount'] ?? 0,
      maxGoalsCorrectCount: json['maxGoalsCorrectCount'] ?? 0,
      minGoalsCorrectCount: json['minGoalsCorrectCount'] ?? 0,
      bestMatchId: json['bestMatchId'],
      bestMatchPoints: json['bestMatchPoints'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  static Map<String, dynamic> userStatsToFirestore(UserStatsEntity s) {
    return {
      'userId': s.userId,
      'displayName': s.displayName,
      'email': s.email,
      'photoUrl': s.photoUrl,
      'totalPoints': s.totalPoints,
      'totalPronostics': s.totalPronostics,
      'exactScoreCount': s.exactScoreCount,
      'winnerCorrectCount': s.winnerCorrectCount,
      'maxGoalsCorrectCount': s.maxGoalsCorrectCount,
      'minGoalsCorrectCount': s.minGoalsCorrectCount,
      'bestMatchId': s.bestMatchId,
      'bestMatchPoints': s.bestMatchPoints,
      'createdAt': s.createdAt?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    };
  }
}