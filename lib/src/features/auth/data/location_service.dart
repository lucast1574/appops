import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/api_client.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ApiClient _apiClient = ApiClient();
  StreamSubscription<Position>? _positionStream;
  Timer? _periodicTimer;

  /// Initialize location tracking. Call once after login.
  Future<void> startTracking() async {
    // Check & request permissions
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Send initial location
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
      await _sendLocation(position.latitude, position.longitude);
    } catch (_) {}

    // Send location every 5 minutes
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

  Future<void> _sendLocation(double lat, double lng) async {
    try {
      await _apiClient.dio.post('/users/me/location/', data: {
        'latitude': lat,
        'longitude': lng,
      });
    } catch (_) {}
  }

  /// Send location once (e.g. on login)
  Future<Map<String, dynamic>?> sendCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
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
}
