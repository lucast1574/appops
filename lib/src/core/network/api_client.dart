import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Production API
  static const String _baseUrl = 'https://api.opps-app.leasyauto.com/api/v1';

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Attach JWT token to every request
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _readSafe('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            final token = await _readSafe('access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
          await clearTokens();
        }
        return handler.next(error);
      },
    ));
  }

  /// Safe read that catches decryption failures (e.g. after device restart
  /// where Android Keystore keys were invalidated). Returns null on error.
  Future<String?> _readSafe(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _debugLog('SecureStorage read failed for "$key": $e');
      return null;
    }
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _readSafe('refresh_token');
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$_baseUrl/../token/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: 'access_token', value: response.data['access']);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveTokens({required String access, required String refresh}) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // If deleteAll fails due to corrupt storage, ignore silently
    }
  }

  Future<String?> getAccessToken() async {
    return await _readSafe('access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _readSafe('access_token');
    return token != null;
  }

  static void _debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print(message);
      return true;
    }());
  }
}
