import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/match_entity.dart';

class FirestoreDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── MATCHES ──────────────────────────────────────────────────────────────

  Future<void> saveMatches(List<MatchEntity> matches) async {
    final batch = _db.batch();
    for (final match in matches) {
      final ref = _db.collection('matches').doc(match.id);
      batch.set(ref, {
        'id': match.id,
        'homeTeamName': match.homeTeamName,
        'awayTeamName': match.awayTeamName,
        'homeTeamCrest': match.homeTeamCrest,
        'awayTeamCrest': match.awayTeamCrest,
        'homeScore': match.homeScore,
        'awayScore': match.awayScore,
        'status': match.status,
        'stage': match.stage,
        'group': match.group,
        'matchday': match.matchday,
        'utcDate': match.utcDate.toIso8601String(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<List<MatchEntity>> getMatches() async {
    final snapshot = await _db.collection('matches').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MatchEntity(
        id: data['id'] ?? doc.id,
        homeTeamName: data['homeTeamName'] ?? 'TBD',
        awayTeamName: data['awayTeamName'] ?? 'TBD',
        homeTeamCrest: data['homeTeamCrest'],
        awayTeamCrest: data['awayTeamCrest'],
        homeScore: data['homeScore'],
        awayScore: data['awayScore'],
        status: data['status'] ?? 'SCHEDULED',
        stage: data['stage'] ?? 'GROUP_STAGE',
        group: data['group'],
        matchday: data['matchday'],
        utcDate: DateTime.parse(data['utcDate']),
      );
    }).toList();
  }

  Future<bool> matchesExist() async {
    final snapshot = await _db.collection('matches').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> updateMatchScore(String matchId, int? homeScore, int? awayScore, String status) async {
    await _db.collection('matches').doc(matchId).update({
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': status,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // ── TEAMS ─────────────────────────────────────────────────────────────────

  Future<void> saveTeams(List<Map<String, dynamic>> teams) async {
    final batch = _db.batch();
    for (final team in teams) {
      final ref = _db.collection('teams').doc(team['id'].toString());
      batch.set(ref, team);
    }
    await batch.commit();
  }

  Future<bool> teamsExist() async {
    final snapshot = await _db.collection('teams').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  // ── STREAM LIVE ───────────────────────────────────────────────────────────

  Stream<List<MatchEntity>> watchLiveMatches() {
    return _db
        .collection('matches')
        .where('status', whereIn: ['IN_PLAY', 'PAUSED'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MatchEntity(
                id: data['id'] ?? doc.id,
                homeTeamName: data['homeTeamName'] ?? 'TBD',
                awayTeamName: data['awayTeamName'] ?? 'TBD',
                homeTeamCrest: data['homeTeamCrest'],
                awayTeamCrest: data['awayTeamCrest'],
                homeScore: data['homeScore'],
                awayScore: data['awayScore'],
                status: data['status'] ?? 'IN_PLAY',
                stage: data['stage'] ?? 'GROUP_STAGE',
                group: data['group'],
                matchday: data['matchday'],
                utcDate: DateTime.parse(data['utcDate']),
              );
            }).toList());
  }
}