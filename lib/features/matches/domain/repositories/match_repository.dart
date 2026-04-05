import '../entities/match_entity.dart';

abstract class MatchRepository {
  Future<List<MatchEntity>> getAllMatches();
  Future<List<MatchEntity>> getLiveMatches();
  Future<List<MatchEntity>> getMatchesByDate(DateTime date);
  Future<List<MatchEntity>> getMatchesByStage(String stage);
}