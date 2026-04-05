import 'dart:convert';
import 'package:flutter/services.dart';

class LocalDataService {
  static LocalDataService? _instance;
  LocalDataService._();
  static LocalDataService get instance {
    _instance ??= LocalDataService._();
    return _instance!;
  }

  Future<List<dynamic>> getMatches() async {
    final String data =
        await rootBundle.loadString('assets/data/football.matches.json');
    final decoded = jsonDecode(data);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] != null) return decoded['data'];
    return [];
  }

  Future<List<dynamic>> getTeams() async {
    final String data =
        await rootBundle.loadString('assets/data/football.teams.json');
    final decoded = jsonDecode(data);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] != null) return decoded['data'];
    return [];
  }

  Future<List<dynamic>> getStandings() async {
    final String data =
        await rootBundle.loadString('assets/data/football.matchtables.json');
    final decoded = jsonDecode(data);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] != null) return decoded['data'];
    return [];
  }

  Future<List<dynamic>> getStadiums() async {
    final String data =
        await rootBundle.loadString('assets/data/football.stadiums.json');
    final decoded = jsonDecode(data);
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['data'] != null) return decoded['data'];
    return [];
  }
}
