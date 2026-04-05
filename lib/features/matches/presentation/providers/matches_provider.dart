import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/shared/providers/repository_providers.dart';
import '../../domain/entities/match_entity.dart';

final matchesProvider = FutureProvider<List<MatchEntity>>((ref) {
  return ref.read(matchRepositoryProvider).getAllMatches();
});

final liveMatchesProvider = FutureProvider<List<MatchEntity>>((ref) {
  return ref.read(matchRepositoryProvider).getLiveMatches();
});

final todayMatchesProvider = FutureProvider<List<MatchEntity>>((ref) {
  return ref.read(matchRepositoryProvider).getMatchesByDate(DateTime.now());
});