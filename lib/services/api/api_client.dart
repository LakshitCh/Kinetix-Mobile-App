import 'package:dio/dio.dart';
import '../../core/constants/app_config.dart';

/// Dio HTTP client with base configuration and interceptors.
class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static String? _authToken;

  /// Set the auth token for subsequent requests.
  static void setToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the auth token.
  static void clearToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  /// GET request.
  static Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  /// POST request.
  static Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _dio.post(path, data: data);
  }

  /// Check if we have an auth token.
  static bool get hasToken => _authToken != null;
}
