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
      _db.collection('users').doc(userId).collection('pronostics').doc(matchId);

  // ── PRONOSTICS ────────────────────────────────────────────────────────────

  @override
  Future<PronosticEntity?> getPronostic(String matchId, String userId) async {
    try {
      final doc = await _pronosticDoc(userId, matchId).get();
      if (!doc.exists) return null;
      return PronosticModel.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePronostic(PronosticEntity pronostic) async {
    final docRef = _pronosticDoc(pronostic.userId, pronostic.matchId);

    // Vérifie si c'est une création ou une modification
    final existing = await docRef.get();
    final isNew = !existing.exists;

    // Sauvegarde le pronostic (création ou mise à jour)
    await docRef.set(PronosticModel.toFirestore(pronostic));

    // N'incrémente que si c'est un nouveau pronostic
    if (isNew) {
      await _userDoc(pronostic.userId).update({
        'totalPronostics': FieldValue.increment(1),
      });
    }
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
    if (doc.exists) return;

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

}