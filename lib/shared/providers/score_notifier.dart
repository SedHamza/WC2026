import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wc2026/features/matches/domain/entities/match_entity.dart';
import 'package:wc2026/features/pronostics/domain/entities/pronostic_entity.dart';
import 'package:wc2026/features/pronostics/domain/entities/user_stats_entity.dart';
import 'package:wc2026/features/pronostics/presentation/providers/pronostic_provider.dart';
import 'package:wc2026/features/rooms/data/repositories/room_repository_impl.dart';
import 'package:wc2026/features/rooms/presentation/providers/room_provider.dart';
import 'package:wc2026/shared/providers/repository_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

class ScoreState {
  /// Mes stats personnelles
  final UserStatsEntity? myStats;

  /// Mes pronostics
  final List<PronosticEntity> myPronostics;

  /// Points live provisoires — Map<userId, Map<matchId, points>>
  /// Jamais sauvegardé en Firestore — recalculé toutes les 60s
  final Map<String, Map<String, int>> livePoints;

  /// IDs des membres de mes rooms (pour le timer)
  final Set<String> roomMemberIds;

  final bool isLoading;
  final bool isRefreshingLive;
  final int liveMatchCount;

  const ScoreState({
    this.myStats,
    this.myPronostics = const [],
    this.livePoints = const {},
    this.roomMemberIds = const {},
    this.isLoading = false,
    this.isRefreshingLive = false,
    this.liveMatchCount = 0,
  });

  ScoreState copyWith({
    UserStatsEntity? myStats,
    List<PronosticEntity>? myPronostics,
    Map<String, Map<String, int>>? livePoints,
    Set<String>? roomMemberIds,
    bool? isLoading,
    bool? isRefreshingLive,
    int? liveMatchCount,
  }) {
    return ScoreState(
      myStats: myStats ?? this.myStats,
      myPronostics: myPronostics ?? this.myPronostics,
      livePoints: livePoints ?? this.livePoints,
      roomMemberIds: roomMemberIds ?? this.roomMemberIds,
      isLoading: isLoading ?? this.isLoading,
      isRefreshingLive: isRefreshingLive ?? this.isRefreshingLive,
      liveMatchCount: liveMatchCount ?? this.liveMatchCount,
    );
  }

  /// Points live pour un user et un match donné
  int getLivePoints(String userId, String matchId) =>
      livePoints[userId]?[matchId] ?? 0;

  /// Mon pronostic pour un match donné
  PronosticEntity? myPronosticFor(String matchId) {
    try {
      return myPronostics.firstWhere((p) => p.matchId == matchId);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final scoreNotifierProvider =
    StateNotifierProvider<ScoreNotifier, ScoreState>((ref) {
  return ScoreNotifier(ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class ScoreNotifier extends StateNotifier<ScoreState> {
  final Ref _ref;
  Timer? _timer;
  static const _timerInterval = Duration(seconds: 60);

  ScoreNotifier(this._ref) : super(const ScoreState());

  String? get _myId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. LANCEMENT DE L'APP
  // Appelé depuis HomeScreen.initState()
  // Calcule MES matchs terminés → Firestore
  // Calcule MES matchs live → state.livePoints
  // Démarre le timer 60s
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> initializeOnLaunch() async {
    final userId = _myId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    // Charge mes stats et pronostics
    await _loadMyData(userId);

    // Calcule mes matchs terminés → sauvegarde Firestore
    await _calculateFinishedForUser(userId);

    // Calcule mes matchs live → provider (pas Firestore)
    await _calculateLiveForUsers({userId});

    state = state.copyWith(isLoading: false);

    // Démarre le timer 60s
    _startTimer();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. OUVERTURE DES ROOMS
  // Appelé depuis RoomsScreen.initState()
  // Collecte tous les membres de mes rooms
  // Calcule FINISHED → Firestore pour chaque membre
  // Calcule live → state.livePoints pour chaque membre
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> initializeForRooms() async {
    final userId = _myId;
    if (userId == null) return;

    // Récupère tous les membres de mes rooms
    final memberIds = await _collectRoomMemberIds(userId);

    // Mémorise ces IDs pour le timer (inclure tous les membres)
    state = state.copyWith(roomMemberIds: memberIds);

    // Calcule FINISHED pour chaque membre → Firestore
    for (final memberId in memberIds) {
      await _calculateFinishedForUser(memberId);
    }

    // Calcule live pour tous les membres → provider
    await _calculateLiveForUsers(memberIds);

    // Invalide les rooms pour refléter les nouveaux points
    _ref.invalidate(userRoomsProvider);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. OUVERTURE DU PROFIL
  // Recalcule juste mes stats et mes points
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> refreshMyProfile() async {
    final userId = _myId;
    if (userId == null) return;

    await _calculateFinishedForUser(userId);
    await _loadMyData(userId);
    await _calculateLiveForUsers({userId});
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TIMER 60S
  // Toutes les 60s :
  //   - Refresh scores live depuis API
  //   - Recalcule live pour MOI + tous les membres de mes rooms
  //   - Si un match passe à FINISHED → calcule et sauvegarde Firestore
  // ───────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_timerInterval, (_) => _onTimer());
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> forceRefresh() => _onTimer();

  Future<void> _onTimer() async {
    if (state.isRefreshingLive) return;
    state = state.copyWith(isRefreshingLive: true);

    try {
      // Rafraîchit les scores depuis l'API
      final repo = _ref.read(matchRepositoryProvider);
      final liveMatches = await repo.getLiveMatches();

      // Invalide les providers UI pour forcer le reload
      _ref.invalidate(matchesProvider);
      _ref.invalidate(todayMatchesProvider);

      state = state.copyWith(
        liveMatchCount: liveMatches.where((m) => m.isLive).length,
      );

      // Qui calculer → moi + tous les membres de mes rooms
      final userId = _myId;
      final allUsers = <String>{
        if (userId != null) userId,
        ...state.roomMemberIds,
      };

      // Calcule les points live → provider (pas Firestore)
      await _calculateLiveForUsersFromMatches(allUsers, liveMatches);

      // Si un match vient de passer à FINISHED → calcule + sauvegarde Firestore
      // Seulement pour les matchs qui ont un score et ne sont pas encore calculés
      final newlyFinished = liveMatches
          .where((m) => m.isFinished && m.homeScore != null)
          .toList();

      if (newlyFinished.isNotEmpty) {
        for (final userId in allUsers) {
          await _calculateFinishedForUser(userId);
        }
        // Recharge mes stats après calcul
        if (userId != null) await _loadMyData(userId);
        _ref.invalidate(userRoomsProvider);
      }
    } catch (_) {
      // Silencieux — le timer réessaiera dans 60s
    } finally {
      if (mounted) state = state.copyWith(isRefreshingLive: false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTHODES INTERNES
  // ─────────────────────────────────────────────────────────────────────────

  /// Charge mes stats et pronostics depuis Firestore
  Future<void> _loadMyData(String userId) async {
    final repo = _ref.read(pronosticRepositoryProvider);
    final results = await Future.wait([
      repo.getUserStats(userId),
      repo.getUserPronostics(userId),
    ]);
    if (!mounted) return;
    state = state.copyWith(
      myStats: results[0] as UserStatsEntity?,
      myPronostics: results[1] as List<PronosticEntity>,
    );
  }

  /// Collecte tous les userIds uniques dans les rooms de cet user
  Future<Set<String>> _collectRoomMemberIds(String userId) async {
    final db = FirebaseFirestore.instance;
    final userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) return {};

    final roomIds = List<String>.from(userDoc.data()?['rooms'] as List? ?? []);
    final Set<String> memberIds = {};

    for (final roomId in roomIds) {
      final roomDoc = await db.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) continue;
      final members = roomDoc.data()?['members'] as Map<String, dynamic>? ?? {};
      memberIds.addAll(members.keys);
    }

    return memberIds;
  }

  /// Calcule et sauvegarde en Firestore les matchs FINISHED non calculés
  /// pour un utilisateur donné
  Future<void> _calculateFinishedForUser(String userId) async {
    final db = FirebaseFirestore.instance;

    // Récupère les pronostics non calculés
    final pronosticsSnap = await db
        .collection('users')
        .doc(userId)
        .collection('pronostics')
        .where('isCalculated', isEqualTo: false)
        .get();

    if (pronosticsSnap.docs.isEmpty) return;

    bool anyUpdated = false;

    for (final pronosticDoc in pronosticsSnap.docs) {
      final matchId = pronosticDoc.id;
      final pronosticData = pronosticDoc.data();

      // Lit le match directement depuis Firestore (score frais)
      final matchDoc = await db.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) continue;

      final matchData = matchDoc.data()!;
      final status = matchData['status'] as String? ?? '';

      // Seulement pour les matchs FINISHED
      if (status != 'FINISHED') continue;

      final homeScore = (matchData['homeScore'] as num?)?.toInt();
      final awayScore = (matchData['awayScore'] as num?)?.toInt();
      if (homeScore == null || awayScore == null) continue;

      // Calcul des points
      final points = _computePoints(pronosticData, homeScore, awayScore);

      // Sauvegarde en batch
      final batch = db.batch();

      batch.update(pronosticDoc.reference, {
        'points': points,
        'isCalculated': true,
      });

      final totalGoals = homeScore + awayScore;
      final realWinner = homeScore > awayScore
          ? 1
          : awayScore > homeScore
              ? 2
              : 0;
      final type = pronosticData['type'] == 'exact' ? 'exact' : 'other';

      final Map<String, dynamic> statsUpdate = {
        'totalPoints': FieldValue.increment(points),
      };

      if (type == 'exact' && points == 25) {
        statsUpdate['exactScoreCount'] = FieldValue.increment(1);
      }
      if (type == 'other') {
        final winner = (pronosticData['winner'] as num?)?.toInt() ?? -1;
        final maxGoals = (pronosticData['maxGoals'] as num?)?.toInt() ?? -1;
        final minGoals = (pronosticData['minGoals'] as num?)?.toInt() ?? -1;
        if (winner != -1 && winner == realWinner) {
          statsUpdate['winnerCorrectCount'] = FieldValue.increment(1);
        }
        if (maxGoals != -1 && totalGoals <= maxGoals) {
          statsUpdate['maxGoalsCorrectCount'] = FieldValue.increment(1);
        }
        if (minGoals != -1 && totalGoals >= minGoals) {
          statsUpdate['minGoalsCorrectCount'] = FieldValue.increment(1);
        }
      }

      // Meilleur match
      final userDoc = await db.collection('users').doc(userId).get();
      final currentBest =
          (userDoc.data()?['bestMatchPoints'] as num?)?.toInt() ?? 0;
      if (points > currentBest) {
        statsUpdate['bestMatchId'] = matchId;
        statsUpdate['bestMatchPoints'] = points;
      }

      batch.update(db.collection('users').doc(userId), statsUpdate);
      await batch.commit();
      anyUpdated = true;
    }

    if (anyUpdated) {
      // Met à jour les rooms avec le nouveau totalPoints
      final updatedDoc = await db.collection('users').doc(userId).get();
      final newTotal =
          (updatedDoc.data()?['totalPoints'] as num?)?.toInt() ?? 0;
      await RoomRepositoryImpl().updateMemberPoints(userId, newTotal);
    }
  }

  /// Calcule les points live pour un ensemble d'utilisateurs
  /// depuis les matchs live Firestore
  Future<void> _calculateLiveForUsers(Set<String> userIds) async {
    if (userIds.isEmpty) return;

    final db = FirebaseFirestore.instance;

    // Récupère les matchs IN_PLAY depuis Firestore
    final liveSnap = await db
        .collection('matches')
        .where('status', whereIn: ['IN_PLAY', 'PAUSED']).get();

    if (liveSnap.docs.isEmpty) return;

    final liveMatches = liveSnap.docs
        .map((doc) {
          final data = doc.data();
          return _LiveMatch(
            id: data['id'] as String? ?? doc.id,
            homeScore: (data['homeScore'] as num?)?.toInt(),
            awayScore: (data['awayScore'] as num?)?.toInt(),
          );
        })
        .where((m) => m.homeScore != null)
        .toList();

    await _computeLiveForUsers(userIds, liveMatches, db);
  }

  /// Calcule les points live depuis des MatchEntity déjà chargés (timer)
  Future<void> _calculateLiveForUsersFromMatches(
      Set<String> userIds, List<MatchEntity> matches) async {
    if (userIds.isEmpty) return;

    final db = FirebaseFirestore.instance;

    final liveMatches = matches
        .where((m) => m.isLive && m.homeScore != null)
        .map((m) => _LiveMatch(
              id: m.id,
              homeScore: m.homeScore,
              awayScore: m.awayScore,
            ))
        .toList();

    await _computeLiveForUsers(userIds, liveMatches, db);
  }

  /// Calcul effectif des points live → mise à jour du state
  Future<void> _computeLiveForUsers(
    Set<String> userIds,
    List<_LiveMatch> liveMatches,
    FirebaseFirestore db,
  ) async {
    if (liveMatches.isEmpty) return;

    // Copie de l'état actuel des livePoints
    final updatedLivePoints =
        Map<String, Map<String, int>>.from(state.livePoints);

    for (final userId in userIds) {
      updatedLivePoints[userId] = {};

      for (final match in liveMatches) {
        // Lit le pronostic de cet user pour ce match
        final pronosticDoc = await db
            .collection('users')
            .doc(userId)
            .collection('pronostics')
            .doc(match.id)
            .get();

        if (!pronosticDoc.exists) continue;

        final pts = _computePoints(
          pronosticDoc.data()!,
          match.homeScore!,
          match.awayScore ?? 0,
        );

        updatedLivePoints[userId]![match.id] = pts;
      }
    }

    if (mounted) {
      state = state.copyWith(livePoints: updatedLivePoints);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALCUL DES POINTS (logique métier)
  // ─────────────────────────────────────────────────────────────────────────

  int _computePoints(Map<String, dynamic> data, int homeScore, int awayScore) {
    final type = data['type'] == 'exact' ? 'exact' : 'other';
    final totalGoals = homeScore + awayScore;
    final realWinner = homeScore > awayScore
        ? 1
        : awayScore > homeScore
            ? 2
            : 0;
    int pts = 0;

    if (type == 'exact') {
      final pHome = (data['homeScore'] as num?)?.toInt() ?? 0;
      final pAway = (data['awayScore'] as num?)?.toInt() ?? 0;
      if (pHome == homeScore && pAway == awayScore) pts = 25;
    } else {
      final winner = (data['winner'] as num?)?.toInt() ?? -1;
      final maxGoals = (data['maxGoals'] as num?)?.toInt() ?? -1;
      final minGoals = (data['minGoals'] as num?)?.toInt() ?? -1;
      if (winner != -1 && winner == realWinner) pts += 5;
      if (maxGoals != -1 && totalGoals <= maxGoals) {
        pts += ((7 - maxGoals) * 2).clamp(0, 14);
      }
      if (minGoals != -1 && totalGoals >= minGoals) {
        pts += (minGoals * 2).clamp(0, 14);
      }
    }
    return pts;
  }
}

/// Classe helper interne pour les matchs live
class _LiveMatch {
  final String id;
  final int? homeScore;
  final int? awayScore;
  const _LiveMatch(
      {required this.id, required this.homeScore, required this.awayScore});
}
