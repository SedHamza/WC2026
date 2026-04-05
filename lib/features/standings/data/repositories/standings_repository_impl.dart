import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/repositories/standings_repository.dart';
import '../models/standing_model.dart';
import '../../../../core/network/dio_client.dart';

class StandingsRepositoryImpl implements StandingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<GroupStandingEntity>> getStandings() async {
    try {
      // 1. Vérifie Firestore d'abord
      final snapshot = await _db.collection('standings').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => StandingModel.fromFirestore(doc.data()))
            .toList()
          ..sort((a, b) => a.groupName.compareTo(b.groupName));
      }

      // 2. Charge depuis API et stocke dans Firestore
      return await _fetchAndSave();
    } catch (e) {
      try {
        return await _fetchAndSave();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<GroupStandingEntity>> _fetchAndSave() async {
    final response = await DioClient.instance
        .get('/competitions/WC/standings');
    final standings = response.data['standings'] as List;
    final result = standings
        .map((e) => StandingModel.fromFootballData(e))
        .toList()
      ..sort((a, b) => a.groupName.compareTo(b.groupName));

    // Sauvegarde dans Firestore
    final batch = _db.batch();
    for (final group in result) {
      final ref = _db.collection('standings').doc(group.group);
      batch.set(ref, {
        'group': group.group,
        'table': group.table.map((t) => {
          'position': t.position,
          'teamId': t.teamId,
          'teamName': t.teamName,
          'teamCrest': t.teamCrest,
          'tla': t.tla,
          'playedGames': t.playedGames,
          'won': t.won,
          'draw': t.draw,
          'lost': t.lost,
          'points': t.points,
          'goalsFor': t.goalsFor,
          'goalsAgainst': t.goalsAgainst,
          'goalDifference': t.goalDifference,
        }).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return result;
  }
}