import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pronostics/domain/entities/pronostic_entity.dart';
import '../../../pronostics/domain/entities/user_stats_entity.dart';
import '../../../pronostics/presentation/providers/pronostic_provider.dart';

final userPronosticsProvider =
    FutureProvider<List<PronosticEntity>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId!.isEmpty) return [];

  // Écoute le trigger — se recharge après chaque sauvegarde de pronostic
  ref.watch(profileRefreshTrigger);

  return ref.watch(pronosticRepositoryProvider).getUserPronostics(userId);
});

final userStatsProvider = FutureProvider<UserStatsEntity?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId!.isEmpty) return null;

  // Écoute le trigger
  ref.watch(profileRefreshTrigger);

  return ref.watch(pronosticRepositoryProvider).getUserStats(userId);
});
