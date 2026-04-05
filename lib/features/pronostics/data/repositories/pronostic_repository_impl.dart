import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/pronostic_entity.dart';
import '../../domain/entities/user_stats_entity.dart';
import '../../domain/repositories/pronostic_repository.dart';
import '../models/pronostic_model.dart';

class PronosticRepositoryImpl implements PronosticRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── HELPERS ───────────────────────────────────────────────────────────────

  DocumentReference _userDoc(String userId) =>
      _db.collection('users').doc(userId);

  DocumentReference _pronosticDoc(String userId, String matchId) =>
      _db.collection('users').doc(userId)
         .collection('pronostics').doc(matchId);

  // ── PRONOSTICS ────────────────────────────────────────────────────────────

  @override
  Future<PronosticEntity?> getPronostic(
      String matchId, String userId) async {
    try {
      final doc = await _pronosticDoc(userId, matchId).get();
      if (!doc.exists) return null;
      return PronosticModel.fromFirestore(
          doc.data() as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePronostic(PronosticEntity pronostic) async {
    // Sauvegarde le pronostic
    await _pronosticDoc(pronostic.userId, pronostic.matchId)
        .set(PronosticModel.toFirestore(pronostic));

    // Met à jour le compteur total
    await _userDoc(pronostic.userId).update({
      'totalPronostics': FieldValue.increment(1),
    });
  }

  @override
  Future<void> deletePronostic(String matchId, String userId) async {
    await _pronosticDoc(userId, matchId).delete();
    await _userDoc(userId).update({
      'totalPronostics': FieldValue.increment(-1),
    });
  }

  @override
  Future<List<PronosticEntity>> getUserPronostics(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('pronostics')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PronosticModel.fromFirestore(doc.data()))
        .toList();
  }

  // ── USER STATS ────────────────────────────────────────────────────────────

  @override
  Future<UserStatsEntity?> getUserStats(String userId) async {
    try {
      final doc = await _userDoc(userId).get();
      if (!doc.exists) return null;
      return PronosticModel.userStatsFromFirestore(
          userId, doc.data() as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createUserProfile(
      String userId, String displayName, String email) async {
    final doc = await _userDoc(userId).get();
    if (doc.exists) return; // Déjà créé

    await _userDoc(userId).set({
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'totalPoints': 0,
      'totalPronostics': 0,
      'exactScoreCount': 0,
      'winnerCorrectCount': 0,
      'maxGoalsCorrectCount': 0,
      'minGoalsCorrectCount': 0,
      'bestMatchId': null,
      'bestMatchPoints': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ── CALCUL DES POINTS ─────────────────────────────────────────────────────

  @override
  Future<void> calculateAndUpdatePoints(
      String matchId, int homeScore, int awayScore) async {
    // Récupère tous les pronostics de ce match non calculés
    final snapshot = await _db
        .collectionGroup('pronostics')
        .where('matchId', isEqualTo: matchId)
        .where('isCalculated', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      final pronostic = PronosticModel.fromFirestore(doc.data());
      final points = pronostic.calculatePoints(homeScore, awayScore);
      final totalGoals = homeScore + awayScore;
      final realWinner = homeScore > awayScore
          ? 1
          : awayScore > homeScore
              ? 2
              : 0;

      // Met à jour le pronostic
      await doc.reference.update({
        'points': points,
        'isCalculated': true,
      });

      // Met à jour les stats utilisateur
      final Map<String, dynamic> statsUpdate = {
        'totalPoints': FieldValue.increment(points),
      };

      if (pronostic.isExactMode) {
        if (pronostic.homeScore == homeScore &&
            pronostic.awayScore == awayScore) {
          statsUpdate['exactScoreCount'] = FieldValue.increment(1);
        }
      } else {
        if (pronostic.winner != null &&
            pronostic.winner != -1 &&
            pronostic.winner == realWinner) {
          statsUpdate['winnerCorrectCount'] = FieldValue.increment(1);
        }
        if (pronostic.maxGoals != null &&
            pronostic.maxGoals != -1 &&
            totalGoals <= pronostic.maxGoals!) {
          statsUpdate['maxGoalsCorrectCount'] = FieldValue.increment(1);
        }
        if (pronostic.minGoals != null &&
            pronostic.minGoals != -1 &&
            totalGoals >= pronostic.minGoals!) {
          statsUpdate['minGoalsCorrectCount'] = FieldValue.increment(1);
        }
      }

      // Vérifie si c'est le meilleur match
      final userDoc = await _userDoc(pronostic.userId).get();
      final currentBest = (userDoc.data()
          as Map<String, dynamic>?)?['bestMatchPoints'] ?? 0;
      if (points > currentBest) {
        statsUpdate['bestMatchId'] = matchId;
        statsUpdate['bestMatchPoints'] = points;
      }

      await _userDoc(pronostic.userId).update(statsUpdate);
    }
  }
}