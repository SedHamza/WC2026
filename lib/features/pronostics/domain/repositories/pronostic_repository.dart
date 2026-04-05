import '../entities/pronostic_entity.dart';
import '../entities/user_stats_entity.dart';

abstract class PronosticRepository {
  // Pronostics
  Future<PronosticEntity?> getPronostic(String matchId, String userId);
  Future<void> savePronostic(PronosticEntity pronostic);
  Future<void> deletePronostic(String matchId, String userId);
  Future<List<PronosticEntity>> getUserPronostics(String userId);

  // Stats utilisateur
  Future<UserStatsEntity?> getUserStats(String userId);
  Future<void> createUserProfile(String userId, String displayName, String email);
  Future<void> calculateAndUpdatePoints(
      String matchId, int homeScore, int awayScore);
}