import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Sends the Google ID token to the backend for verification.
  /// [source] should be 'mobile' or 'backoffice'.
  /// Returns the full response data map.
  Future<Map<String, dynamic>> loginWithGoogle(String googleIdToken, {String source = 'mobile'}) async {
    final response = await _apiClient.dio.post(
      '/users/auth/google/',
      data: {
        'token': googleIdToken,
        'source': source,
      },
    );

    final data = response.data;

    // Only save tokens if login was successful
    if (data['status'] == 'ok' && data['token'] != null) {
      await _apiClient.saveTokens(
        access: data['token'],
        refresh: data['refresh'],
      );
      await _storage.write(key: 'user_data', value: jsonEncode(data['user']));
    }

    return data;
  }

  /// Get the currently stored user data.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _storage.read(key: 'user_data');
    if (userData == null) return null;
    return jsonDecode(userData);
  }

  /// Fetch fresh user data from backend.
  Future<Map<String, dynamic>> fetchMe() async {
    final response = await _apiClient.dio.get('/users/me/');
    final data = response.data;
    await _storage.write(key: 'user_data', value: jsonEncode(data));
    return data;
  }

  /// Logout: clear all stored tokens and user data.
  Future<void> logout() async {
    await _apiClient.clearTokens();
  }

  /// Check if user is currently authenticated.
  Future<bool> isAuthenticated() async {
    return await _apiClient.isLoggedIn();
  }
}
