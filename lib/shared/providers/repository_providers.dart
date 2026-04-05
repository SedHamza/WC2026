import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/features/matches/data/datasources/firestore_datasource.dart';
import '../../features/matches/data/datasources/remote/football_data_datasource.dart';
import '../../features/matches/data/repositories/match_repository_impl.dart';
import '../../features/matches/domain/entities/match_entity.dart';
import '../../features/matches/domain/repositories/match_repository.dart';

final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  return FirestoreDatasource();
});

final remoteMatchDatasourceProvider = Provider<RemoteMatchDatasource>((ref) {
  return FootballDataDatasource();
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepositoryImpl(
    remote: ref.read(remoteMatchDatasourceProvider),
    firestore: ref.read(firestoreDatasourceProvider),
  );
});

final matchesProvider = FutureProvider<List<MatchEntity>>((ref) {
  return ref.read(matchRepositoryProvider).getAllMatches();
});

final liveMatchesProvider = FutureProvider<List<MatchEntity>>((ref) {
  return ref.read(matchRepositoryProvider).getLiveMatches();
});

final todayMatchesProvider = FutureProvider<List<MatchEntity>>((ref) {
  return ref.read(matchRepositoryProvider).getMatchesByDate(DateTime.now());
});