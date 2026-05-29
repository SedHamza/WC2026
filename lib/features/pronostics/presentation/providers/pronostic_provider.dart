import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/shared/providers/score_notifier.dart';
import '../../data/repositories/pronostic_repository_impl.dart';
import '../../domain/entities/pronostic_entity.dart';
import '../../domain/repositories/pronostic_repository.dart';

// Provider de trigger pour forcer le rechargement du profil
// après chaque sauvegarde de pronostic
final profileRefreshTrigger = StateProvider<int>((ref) => 0);

/// Appeler cette fonction pour forcer le rechargement du profil
void invalidateProfileCache(Ref ref) {
  ref.read(profileRefreshTrigger.notifier).state++;
}

final pronosticRepositoryProvider = Provider<PronosticRepository>((ref) {
  return PronosticRepositoryImpl();
});

final currentUserIdProvider = Provider<String>((ref) {
  return FirebaseAuth.instance.currentUser?.uid ?? '';
});

final pronosticProvider =
    FutureProvider.family<PronosticEntity?, String>((ref, matchId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) return null;
  return ref.watch(pronosticRepositoryProvider).getPronostic(matchId, userId);
});

// ── STATE ─────────────────────────────────────────────────────────────────────

class PronosticFormState {
  final PronosticType type;
  final int homeScore;
  final int awayScore;
  final int winner;
  final int maxGoals;
  final int minGoals;
  final bool isSaving;
  final bool isSaved;

  const PronosticFormState({
    this.type = PronosticType.exact,
    this.homeScore = 0,
    this.awayScore = 0,
    this.winner = -1,
    this.maxGoals = -1,
    this.minGoals = -1,
    this.isSaving = false,
    this.isSaved = false,
  });

  int get potentialPoints {
    if (type == PronosticType.exact) return 25;
    int pts = 0;
    if (winner != -1) pts += 5;
    if (maxGoals != -1) pts += ((7 - maxGoals) * 2).clamp(0, 14);
    if (minGoals != -1) pts += (minGoals * 2).clamp(0, 14);
    return pts;
  }

  PronosticFormState copyWith({
    PronosticType? type,
    int? homeScore,
    int? awayScore,
    int? winner,
    int? maxGoals,
    int? minGoals,
    bool? isSaving,
    bool? isSaved,
  }) {
    return PronosticFormState(
      type: type ?? this.type,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      winner: winner ?? this.winner,
      maxGoals: maxGoals ?? this.maxGoals,
      minGoals: minGoals ?? this.minGoals,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

// ── NOTIFIER ──────────────────────────────────────────────────────────────────

class PronosticNotifier extends StateNotifier<PronosticFormState> {
  final PronosticRepository _repository;
  final String _matchId;
  final String _userId;
  final Ref _ref; // ← pour invalider les providers après save

  PronosticNotifier(this._repository, this._matchId, this._userId, this._ref)
      : super(const PronosticFormState());

  void init(PronosticEntity? existing) {
    if (existing == null) return;
    state = PronosticFormState(
      type: existing.type,
      homeScore: existing.homeScore ?? 0,
      awayScore: existing.awayScore ?? 0,
      winner: existing.winner ?? -1,
      maxGoals: existing.maxGoals ?? -1,
      minGoals: existing.minGoals ?? -1,
      isSaved: true,
    );
  }

  void setType(PronosticType type) => state = state.copyWith(type: type);
  void setHomeScore(int v) => state = state.copyWith(homeScore: v.clamp(0, 20));
  void setAwayScore(int v) => state = state.copyWith(awayScore: v.clamp(0, 20));
  void setWinner(int v) => state = state.copyWith(winner: v);

  void setMaxGoals(int v) {
    if (state.minGoals != -1 && v != -1 && v < state.minGoals) return;
    state = state.copyWith(maxGoals: v);
  }

  void setMinGoals(int v) {
    if (state.maxGoals != -1 && v != -1 && v > state.maxGoals) return;
    state = state.copyWith(minGoals: v);
  }

  void reset() => state = const PronosticFormState();

  Future<void> save() async {
    state = state.copyWith(isSaving: true);
    try {
      final pronostic = PronosticEntity(
        id: '${_matchId}_$_userId',
        matchId: _matchId,
        userId: _userId,
        type: state.type,
        homeScore: state.type == PronosticType.exact ? state.homeScore : null,
        awayScore: state.type == PronosticType.exact ? state.awayScore : null,
        winner: state.type == PronosticType.other ? state.winner : null,
        maxGoals: state.type == PronosticType.other ? state.maxGoals : null,
        minGoals: state.type == PronosticType.other ? state.minGoals : null,
      );

      await _repository.savePronostic(pronostic);
      state = state.copyWith(isSaving: false, isSaved: true);

      // Invalide le pronostic provider pour ce match
      _ref.invalidate(pronosticProvider(_matchId));
      // Recharge appState → profil + rooms mis à jour partout
      await _ref.read(scoreNotifierProvider.notifier).refreshMyProfile();
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }
}

// ── PROVIDER ──────────────────────────────────────────────────────────────────

final pronosticNotifierProvider =
    StateNotifierProvider.family<PronosticNotifier, PronosticFormState, String>(
  (ref, matchId) {
    final userId = ref.read(currentUserIdProvider);
    final repository = ref.read(pronosticRepositoryProvider);
    return PronosticNotifier(repository, matchId, userId, ref); // ← passe ref
  },
);
