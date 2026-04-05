import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  String? _token;

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'https://worldcup26.ir',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(this));
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));
  }

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  Future<void> authenticate() async {
    try {
      final response = await _dio.post(
        '/auth/authenticate',
        data: {
          'email': dotenv.env['API_EMAIL'] ?? '',
          'password': dotenv.env['API_PASSWORD'] ?? '',
        },
        options: Options(
          extra: {'skipAuth': true},
        ),
      );
      _token = response.data['token'];
    } catch (e) {
      throw Exception('API Auth failed: $e');
    }
  }

  Future<void> register() async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': dotenv.env['API_NAME'] ?? 'WC2026App',
          'email': dotenv.env['API_EMAIL'] ?? '',
          'password': dotenv.env['API_PASSWORD'] ?? '',
        },
        options: Options(extra: {'skipAuth': true}),
      );
      _token = response.data['token'];
    } catch (e) {
      await authenticate();
    }
  }

  Future<void> ensureAuthenticated() async {
    if (_token == null) await authenticate();
  }

  String? get token => _token;
  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final ApiService _service;
  _AuthInterceptor(this._service);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra['skipAuth'] == true) return handler.next(options);
    final token = _service.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        await _service.authenticate();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${_service.token}';
        final response = await _service.dio.fetch(opts);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}