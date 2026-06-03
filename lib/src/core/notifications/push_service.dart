// Push notifications service.
//
// Boots Firebase, requests permission, gets the FCM token, registers it
// with the backend, listens for token rotation, shows local
// notifications when a push arrives in the foreground, and exposes a
// stream of incoming messages so the rest of the app can react
// (deep-link to a task, refresh the inbox, etc.).
//
// Usage from main.dart:
//
//     await PushService.instance.bootstrap();
//
// And after a successful login:
//
//     await PushService.instance.registerCurrentDevice();
//
// On logout:
//
//     await PushService.instance.unregisterCurrentDevice();

import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../network/api_client.dart';

/// Background handler — must be a top-level function or static method.
/// We keep it minimal: just let the OS post the system notification.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  // Safely initialize Firebase in the background isolate. If it is already
  // initialized (shouldn't happen in a background isolate, but guard anyway).
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  // We deliberately do nothing here — the system tray notification is
  // handled by the FCM SDK because we send `notification` in the
  // payload from the backend. Logs only for debugging.
  if (kDebugMode) {
    debugPrint('[push] background message: ${message.messageId}');
  }
}

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const String _defaultChannelId = 'leasy_ops_default';
  static const String _defaultChannelName = 'Leasy Ops';
  static const String _defaultChannelDesc =
      'Notificaciones de tareas y avisos de Leasy Ops';

  final FlutterLocalNotificationsPlugin _localNotifs =
      FlutterLocalNotificationsPlugin();

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  /// Stream every incoming push (foreground + tap when opened from background).
  Stream<RemoteMessage> get messages => _messageController.stream;

  // Use a Completer so that if bootstrap() is called concurrently (e.g. from
  // main() and SplashPage at the same time) all callers await the same Future
  // instead of running the init sequence twice.
  Completer<void>? _bootstrapCompleter;

  String? _currentToken;

  /// Returns true if the user has already granted push notification permission.
  Future<bool> isPermissionGranted() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Call once during app startup (after WidgetsFlutterBinding ensureInitialized).
  Future<void> bootstrap() async {
    if (_bootstrapCompleter != null) {
      return _bootstrapCompleter!.future;
    }
    _bootstrapCompleter = Completer<void>();

    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('[push] Firebase.initializeApp FAILED: $e');
      _bootstrapCompleter!.complete();
      return;
    }

    // Background handler (required to be set before any await).
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    // Local notifications (so we can show a banner when foreground).
    await _initLocalNotifications();

    // iOS: ensure the app shows banners while in foreground.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    // Foreground messages -> show our local notification + emit on stream.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // User tapped a notification while app was backgrounded.
    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      _messageController.add(m);
    });

    // App opened from a terminated state via a tap on a push.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      _messageController.add(initial);
    }

    // Token rotation: backend gets the new one automatically.
    FirebaseMessaging.instance.onTokenRefresh.listen((tok) async {
      _currentToken = tok;
      await _sendTokenToBackend(tok);
    });

    _bootstrapCompleter!.complete();
  }

  /// Register the current device's token with the backend (call after login).
  Future<bool> registerCurrentDevice() async {
    // Ensure bootstrap has completed before trying to get a token.
    await bootstrap();
    try {
      final tok = _currentToken ?? await FirebaseMessaging.instance.getToken();
      if (tok == null || tok.isEmpty) return false;
      _currentToken = tok;
      return await _sendTokenToBackend(tok);
    } catch (e) {
      debugPrint('[push] registerCurrentDevice FAILED: $e');
      return false;
    }
  }

  /// Mark the current token as inactive on the backend (call before logout).
  Future<void> unregisterCurrentDevice() async {
    final tok = _currentToken;
    if (tok == null || tok.isEmpty) return;
    try {
      await ApiClient().dio.post(
            '/notifications/devices/unregister/',
            data: {'token': tok},
          );
    } catch (e) {
      debugPrint('[push] unregisterCurrentDevice FAILED: $e');
    }
  }

  // --------------------------------------------------------------
  // Internals
  // --------------------------------------------------------------

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    final initSettings = const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifs.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Map the local-notif tap back to a synthetic RemoteMessage so
        // the rest of the app reacts the same way as a real tap.
        if (response.payload != null) {
          _messageController.add(RemoteMessage(data: _parsePayload(response.payload!)));
        }
      },
    );

    // Create the Android channel that matches the backend payload.
    final androidPlugin = _localNotifs
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _defaultChannelId,
        _defaultChannelName,
        description: _defaultChannelDesc,
        importance: Importance.high,
      ),
    );
  }

  Map<String, dynamic> _parsePayload(String payload) {
    final out = <String, dynamic>{};
    for (final part in payload.split('&')) {
      final eq = part.indexOf('=');
      if (eq <= 0) continue;
      out[Uri.decodeComponent(part.substring(0, eq))] =
          Uri.decodeComponent(part.substring(eq + 1));
    }
    return out;
  }

  String _encodePayload(Map<String, dynamic> data) {
    final parts = <String>[];
    data.forEach((k, v) {
      parts.add('${Uri.encodeComponent(k)}=${Uri.encodeComponent(v.toString())}');
    });
    return parts.join('&');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;
    await _localNotifs.show(
      message.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: const AndroidNotificationDetails(
          _defaultChannelId,
          _defaultChannelName,
          channelDescription: _defaultChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _encodePayload(message.data),
    );
  }

  Future<bool> _sendTokenToBackend(String token) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
              ? 'android'
              : 'web';
      final locale = PlatformDispatcher.instance.locale.toLanguageTag();

      await ApiClient().dio.post(
            '/notifications/devices/register/',
            data: {
              'token': token,
              'platform': platform,
              'app_version': info.version,
              'device_model': '', // could fill via device_info_plus later
              'locale': locale,
            },
          );
      return true;
    } catch (e) {
      debugPrint('[push] _sendTokenToBackend FAILED: $e');
      return false;
    }
  }
}
