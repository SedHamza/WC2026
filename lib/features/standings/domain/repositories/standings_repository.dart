import '../entities/standing_entity.dart';

abstract class StandingsRepository {
  Future<List<GroupStandingEntity>> getStandings();
}