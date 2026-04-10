import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/api_client.dart';
import '../../../core/platform/native_settings.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiClient _apiClient = ApiClient();
  StreamSubscription<Position>? _positionStream;
  Timer? _periodicTimer;

  // ---------------------------------------------------------------------------
  // Permission helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` when the app has *always* (background) location permission
  /// **and** the device location service is enabled.
  Future<bool> hasAlwaysPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always;
  }

  /// Requests the basic "while in use" permission.
  /// Returns the resulting [LocationPermission].
  Future<LocationPermission> requestBasicPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Opens the device's **location-permission page** for this app so the user
  /// can select "Permitir todo el tiempo" directly, without extra navigation.
  Future<void> openLocationSettings() async {
    await NativeSettings.openLocationPermission();
  }

  // ---------------------------------------------------------------------------
  // Tracking
  // ---------------------------------------------------------------------------

  /// Initialize location tracking. Call once after login & permission granted.
  Future<void> startTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Send initial position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
      await _sendLocation(position.latitude, position.longitude);
    } catch (_) {}

    // Periodic updates every 5 minutes
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        );
        await _sendLocation(pos.latitude, pos.longitude);
      } catch (_) {}
    });
  }

  /// Send a single location update (e.g. on login).
  Future<Map<String, dynamic>?> sendCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );

      final response = await _apiClient.dio.post('/users/me/location/', data: {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      return response.data;
    } catch (_) {
      return null;
    }
  }

  void stopTracking() {
    _positionStream?.cancel();
    _periodicTimer?.cancel();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _sendLocation(double lat, double lng) async {
    try {
      await _apiClient.dio.post('/users/me/location/', data: {
        'latitude': lat,
        'longitude': lng,
      });
    } catch (_) {}
  }
}
