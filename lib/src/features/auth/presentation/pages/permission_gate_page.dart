import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/notifications/push_service.dart';
import '../../data/location_service.dart';
import '../../../home/presentation/pages/main_page.dart';
import '../widgets/location_permission_dialog.dart';
import '../widgets/notification_permission_dialog.dart';

/// Mandatory intermediate page shown after login (or on app restart) when
/// the user has not yet granted required permissions (Notifications and Location).
///
/// This page **cannot** be skipped:
/// - Back navigation is blocked via [PopScope].
/// - Dialogs re-appear in a loop until permissions are granted.
/// - Order: Notifications -> Location.
class PermissionGatePage extends StatefulWidget {
  const PermissionGatePage({super.key});

  @override
  State<PermissionGatePage> createState() => _PermissionGatePageState();
}

class _PermissionGatePageState extends State<PermissionGatePage>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  final PushService _pushService = PushService.instance;
  bool _waitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runPermissionFlow());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check permissions every time the app resumes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForSettings) {
      _waitingForSettings = false;
      _checkAndProceed();
    }
  }

  // ---------------------------------------------------------------------------
  // Permission flow
  // ---------------------------------------------------------------------------

  Future<void> _runPermissionFlow() async {
    // 1. Notifications first
    final hasNotifications = await _pushService.isPermissionGranted();
    if (!hasNotifications) {
      if (!mounted) return;
      await NotificationPermissionDialog.show(context);
      
      // Request permission (triggers OS dialog)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, badge: true, sound: true,
      );
      
      // After OS dialog, check again.
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        // If they denied, we must send them to app settings because
        // requestPermission might not show the dialog again.
        _waitingForSettings = true;
        await openAppSettings();
        return;
      }
    }

    // 2. Location (after notifications are granted)
    await _runLocationFlow();
  }

  Future<void> _runLocationFlow() async {
    // 1. Ensure the device location service is enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      _waitingForSettings = true;
      return;
    }

    // 2. Request basic "while in use" permission (shows OS dialog).
    final permission = await _locationService.requestBasicPermission();

    // 3. If user chose "denied forever" or "denied", show our dialog.
    if (permission == LocationPermission.deniedForever || 
        permission == LocationPermission.denied) {
      if (!mounted) return;
      await _showLocationDialogAndOpenSettings();
      return;
    }

    // 4. Check if already "always".
    if (await _locationService.hasAlwaysPermission()) {
      await _goToMain();
      return;
    }

    // 5. Has "while in use" but not "always" — show our mandatory dialog.
    if (!mounted) return;
    await _showLocationDialogAndOpenSettings();
  }

  Future<void> _showLocationDialogAndOpenSettings() async {
    await LocationPermissionDialog.show(context);
    if (!mounted) return;

    _waitingForSettings = true;
    await _locationService.openLocationSettings();
  }

  Future<void> _checkAndProceed() async {
    // Re-check notifications first
    if (!await _pushService.isPermissionGranted()) {
      if (!mounted) return;
      await _runPermissionFlow(); // Re-start flow
      return;
    }

    // Then re-check location
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      await _runLocationFlow();
      return;
    }

    if (await _locationService.hasAlwaysPermission()) {
      await _goToMain();
    } else {
      if (!mounted) return;
      await _runLocationFlow();
    }
  }

  Future<void> _goToMain() async {
    if (!mounted) return;

    // Send location to backend BEFORE navigating
    await _locationService.sendCurrentLocation();

    // Start periodic background tracking.
    _locationService.startTracking();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF002B4A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security_rounded,
                color: Color(0xFF4FA4B5),
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                'Configurando permisos…',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
