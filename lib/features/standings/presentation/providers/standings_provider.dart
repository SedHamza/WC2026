import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/standings_repository_impl.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/repositories/standings_repository.dart';

final standingsRepositoryProvider = Provider<StandingsRepository>((ref) {
  return StandingsRepositoryImpl();
});

final standingsProvider = FutureProvider<List<GroupStandingEntity>>((ref) {
  return ref.read(standingsRepositoryProvider).getStandings();
});

final bestThirdProvider = Provider<List<TeamStandingEntity>>((ref) {
  final standingsAsync = ref.watch(standingsProvider);
  return standingsAsync.maybeWhen(
    data: (standings) {
      // Prend uniquement les 3èmes de chaque groupe
      final thirds = standings
          .where((g) => g.table.length >= 3)
          .map((g) => g.table.firstWhere(
                (t) => t.position == 3,
                orElse: () => g.table[2],
              ))
          .toList();

      // Tri selon les règles FIFA officielles WC2026
      thirds.sort((a, b) {
        // 1. Points
        if (b.points != a.points) return b.points.compareTo(a.points);

        // 2. Différence de buts
        if (b.goalDifference != a.goalDifference)
          return b.goalDifference.compareTo(a.goalDifference);

        // 3. Buts marqués
        if (b.goalsFor != a.goalsFor) return b.goalsFor.compareTo(a.goalsFor);

        // 4. Moins de buts encaissés
        if (a.goalsAgainst != b.goalsAgainst)
          return a.goalsAgainst.compareTo(b.goalsAgainst);

        // 5. Ordre alphabétique (approximation du classement FIFA)
        return a.teamName.compareTo(b.teamName);
      });

      return thirds;
    },
    orElse: () => [],
  );
});
