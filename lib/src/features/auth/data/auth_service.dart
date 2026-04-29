import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/notifications/push_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

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
      // Register this device's FCM token with the backend so push
      // notifications start working for this user. Best-effort: any
      // failure is logged inside PushService and never blocks login.
      // ignore: unawaited_futures
      PushService.instance.registerCurrentDevice();
    }

    return data;
  }

  /// Get the currently stored user data.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: 'user_data');
      if (userData == null) return null;
      return jsonDecode(userData);
    } catch (e) {
      // Storage decryption failed after restart
      return null;
    }
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
    // Mark this device's FCM token inactive so the backend stops
    // sending pushes to it. Run before clearing tokens (the request
    // needs auth) and don't let a failure block the logout flow.
    try {
      await PushService.instance.unregisterCurrentDevice();
    } catch (_) {}
    await _apiClient.clearTokens();
  }

  /// Check if user is currently authenticated.
  Future<bool> isAuthenticated() async {
    return await _apiClient.isLoggedIn();
  }
}
