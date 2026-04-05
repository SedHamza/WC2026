import 'package:dio/dio.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../core/errors/exceptions.dart';

abstract class RemoteMatchDatasource {
  Future<List<Map<String, dynamic>>> getMatches();
  Future<List<Map<String, dynamic>>> getLiveMatches();
  Future<List<Map<String, dynamic>>> getStandings();
  Future<List<Map<String, dynamic>>> getTeams();
}

class FootballDataDatasource implements RemoteMatchDatasource {
  final Dio _dio = DioClient.instance;

  @override
  Future<List<Map<String, dynamic>>> getMatches() async {
    try {
      final response = await _dio.get('/competitions/WC/matches');
      return List<Map<String, dynamic>>.from(response.data['matches']);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to load matches',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLiveMatches() async {
    try {
      final response = await _dio.get(
        '/matches',
        queryParameters: {'status': 'LIVE'},
      );
      return List<Map<String, dynamic>>.from(response.data['matches'] ?? []);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to load live matches',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStandings() async {
    try {
      final response = await _dio.get('/competitions/WC/standings');
      return List<Map<String, dynamic>>.from(response.data['standings']);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to load standings',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTeams() async {
    try {
      final response = await _dio.get('/competitions/WC/teams');
      return List<Map<String, dynamic>>.from(response.data['teams']);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to load teams',
        statusCode: e.response?.statusCode,
      );
    }
  }
}