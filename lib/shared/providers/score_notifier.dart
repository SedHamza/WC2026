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
  final UserStatsEntity? myStats;
  final List<PronosticEntity> myPronostics;
  final Map<String, Map<String, int>> livePoints;
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

  int getLivePoints(String userId, String matchId) =>
      livePoints[userId]?[matchId] ?? 0;

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
  Set<String> _previousLiveMatchIds = {};

  static const _timerInterval = Duration(seconds: 30);

  ScoreNotifier(this._ref) : super(const ScoreState());

  String? get _myId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. LANCEMENT DE L'APP
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> initializeOnLaunch() async {
    final userId = _myId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    await _loadMyData(userId);
    await _calculateFinishedForUser(userId);
    await _calculateLiveForUsers({userId});

    state = state.copyWith(isLoading: false);

    // Démarre le timer seulement s'il y a des matchs live
    if (state.liveMatchCount > 0) {
      _startTimer();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. OUVERTURE DES ROOMS
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> initializeForRooms() async {
    final userId = _myId;
    if (userId == null) return;

    final memberIds = await _collectRoomMemberIds(userId);
    state = state.copyWith(roomMemberIds: memberIds);

    for (final memberId in memberIds) {
      await _calculateFinishedForUser(memberId);
    }

    await _calculateLiveForUsers(memberIds);
    _ref.invalidate(userRoomsProvider);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. OUVERTURE DU PROFIL
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
  // ───────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_timerInterval, (_) => _onTimer());
  }

  void _stopTimerIfNoLive() {
    if (state.liveMatchCount == 0 && !state.isLoading) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> forceRefresh() async {
    await _onTimer();
    if (state.liveMatchCount > 0 && _timer == null) {
      _startTimer();
    }
  }

  Future<void> _onTimer() async {
    if (state.isRefreshingLive) return;
    state = state.copyWith(isRefreshingLive: true);

    try {
      final repo = _ref.read(matchRepositoryProvider);
      final liveMatches = await repo.getLiveMatches();

      _ref.invalidate(matchesProvider);
      _ref.invalidate(todayMatchesProvider);

      state = state.copyWith(
        liveMatchCount: liveMatches.where((m) => m.isLive).length,
      );

      final userId = _myId;
      final allUsers = <String>{
        if (userId != null) userId,
        ...state.roomMemberIds,
      };

      await _calculateLiveForUsersFromMatches(allUsers, liveMatches);

      // Détecte les matchs qui viennent de passer FINISHED
      final currentLiveIds = liveMatches.map((m) => m.id).toSet();
      final newlyFinishedIds = _previousLiveMatchIds.difference(currentLiveIds);
      _previousLiveMatchIds = currentLiveIds;

      if (newlyFinishedIds.isNotEmpty) {
        for (final uid in allUsers) {
          await _calculateFinishedForUser(uid);
        }
        if (userId != null) await _loadMyData(userId);
        _ref.invalidate(userRoomsProvider);
      }
    } catch (_) {
      // Silencieux — le timer réessaiera dans 60s
    } finally {
      if (mounted) state = state.copyWith(isRefreshingLive: false);
      // Arrête le timer s'il n'y a plus de matchs live
      _stopTimerIfNoLive();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MÉTHODES INTERNES
  // ─────────────────────────────────────────────────────────────────────────

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
  /// pour un utilisateur donné — UN SEUL BATCH pour tous les pronostics
  Future<void> _calculateFinishedForUser(String userId) async {
    final db = FirebaseFirestore.instance;

    final pronosticsSnap = await db
        .collection('users')
        .doc(userId)
        .collection('pronostics')
        .where('isCalculated', isEqualTo: false)
        .get();

    if (pronosticsSnap.docs.isEmpty) return;

    // Lit le userDoc UNE SEULE FOIS avant la boucle
    final userDoc = await db.collection('users').doc(userId).get();
    int bestPoints = (userDoc.data()?['bestMatchPoints'] as num?)?.toInt() ?? 0;

    // Un seul batch global pour tous les pronostics
    final batch = db.batch();
    int totalPointsToAdd = 0;
    final Map<String, dynamic> statsUpdate = {};
    bool anyUpdated = false;

    for (final pronosticDoc in pronosticsSnap.docs) {
      final matchId = pronosticDoc.id;
      final pronosticData = pronosticDoc.data();

      final matchDoc = await db.collection('matches').doc(matchId).get();
      if (!matchDoc.exists) continue;

      final matchData = matchDoc.data()!;
      final status = matchData['status'] as String? ?? '';
      if (status != 'FINISHED') continue;

      final homeScore = (matchData['homeScore'] as num?)?.toInt();
      final awayScore = (matchData['awayScore'] as num?)?.toInt();
      if (homeScore == null || awayScore == null) continue;

      final points = _computePoints(pronosticData, homeScore, awayScore);

      batch.update(pronosticDoc.reference, {
        'points': points,
        'isCalculated': true,
      });

      totalPointsToAdd += points;
      anyUpdated = true;

      final totalGoals = homeScore + awayScore;
      final realWinner = homeScore > awayScore
          ? 1
          : awayScore > homeScore
              ? 2
              : 0;
      final type = pronosticData['type'] == 'exact' ? 'exact' : 'other';

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

      if (points > bestPoints) {
        bestPoints = points;
        statsUpdate['bestMatchId'] = matchId;
        statsUpdate['bestMatchPoints'] = points;
      }
    }

    if (!anyUpdated) return;

    statsUpdate['totalPoints'] = FieldValue.increment(totalPointsToAdd);
    batch.update(db.collection('users').doc(userId), statsUpdate);

    // UN SEUL COMMIT pour tout
    await batch.commit();

    // Met à jour les rooms avec le nouveau totalPoints
    final updatedDoc = await db.collection('users').doc(userId).get();
    final newTotal = (updatedDoc.data()?['totalPoints'] as num?)?.toInt() ?? 0;
    await RoomRepositoryImpl().updateMemberPoints(userId, newTotal);
  }

  Future<void> _calculateLiveForUsers(Set<String> userIds) async {
    if (userIds.isEmpty) return;

    final db = FirebaseFirestore.instance;

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

  Future<void> _computeLiveForUsers(
    Set<String> userIds,
    List<_LiveMatch> liveMatches,
    FirebaseFirestore db,
  ) async {
    if (liveMatches.isEmpty) return;

    final updatedLivePoints =
        Map<String, Map<String, int>>.from(state.livePoints);

    for (final userId in userIds) {
      updatedLivePoints[userId] = {};

      for (final match in liveMatches) {
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
