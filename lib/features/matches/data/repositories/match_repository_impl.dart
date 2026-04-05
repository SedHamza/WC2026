import 'package:flutter/services.dart';
import 'package:wc2026/features/matches/data/datasources/firestore_datasource.dart';
import 'dart:convert';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/remote/football_data_datasource.dart';
import '../models/match_model.dart';


class MatchRepositoryImpl implements MatchRepository {
  final RemoteMatchDatasource _remote;
  final FirestoreDatasource _firestore;

  MatchRepositoryImpl({
    required RemoteMatchDatasource remote,
    required FirestoreDatasource firestore,
  })  : _remote = remote,
        _firestore = firestore;

  @override
  Future<List<MatchEntity>> getAllMatches() async {
    try {
      // 1. Vérifie si les matchs existent dans Firestore
      final exists = await _firestore.matchesExist();

      if (exists) {
        // 2. Lit depuis Firestore directement
        print('✅ Loading matches from Firestore');
        return await _firestore.getMatches();
      } else {
        // 3. Premier lancement → charge depuis API → stocke dans Firestore
        print('🌐 First launch — loading from API and saving to Firestore');
        final data = await _remote.getMatches();
        final matches = data.map((e) => MatchModel.fromFootballData(e)).toList();
        await _firestore.saveMatches(matches);
        return matches;
      }
    } catch (e) {
      print('❌ Error: $e — falling back to local assets');
      return await _getLocalMatches();
    }
  }

  @override
  Future<List<MatchEntity>> getLiveMatches() async {
    try {
      final data = await _remote.getLiveMatches();
      final liveMatches = data.map((e) => MatchModel.fromFootballData(e)).toList();

      // Met à jour les scores dans Firestore
      for (final match in liveMatches) {
        await _firestore.updateMatchScore(
          match.id,
          match.homeScore,
          match.awayScore,
          match.status,
        );
      }
      return liveMatches;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<MatchEntity>> getMatchesByDate(DateTime date) async {
    final all = await getAllMatches();
    return all.where((m) {
      final local = m.utcDate.toLocal();
      return local.day == date.day &&
          local.month == date.month &&
          local.year == date.year;
    }).toList();
  }

  @override
  Future<List<MatchEntity>> getMatchesByStage(String stage) async {
    final all = await getAllMatches();
    return all.where((m) => m.stage == stage).toList();
  }

  Future<List<MatchEntity>> _getLocalMatches() async {
    try {
      final String data = await rootBundle.loadString(
        'assets/data/football.matches.json',
      );
      final decoded = jsonDecode(data);
      final List list = decoded is List ? decoded : decoded['data'] ?? [];
      return list.map((e) => MatchModel.fromLocalJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}