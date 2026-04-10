import 'package:flutter/services.dart';

/// Thin wrapper around a platform [MethodChannel] that opens native Android
/// settings pages that are not reachable via the standard Flutter plugins.
class NativeSettings {
  const NativeSettings._();

  static const _channel = MethodChannel('com.leasy.ops/settings');

  /// Opens the **location-permission** settings page for this app directly
  /// (the screen where the user can select "Permitir todo el tiempo").
  ///
  /// On devices where the direct intent is not available, falls back to the
  /// general app-info settings page.
  static Future<void> openLocationPermission() async {
    try {
      await _channel.invokeMethod('openLocationPermission');
    } on PlatformException {
      // Silently fail — the gate page will re-prompt on resume anyway.
    }
  }
}
