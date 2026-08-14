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
  bool _declinedLocationConsent = false;

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
    // 1. Check if already has always permission.
    if (await _locationService.hasAlwaysPermission()) {
      await _goToMain();
      return;
    }

    // 2. Ensure device location service (GPS) is enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      _waitingForSettings = true;
      return;
    }

    // 3. SHOW PROMINENT DISCLOSURE DIALOG FIRST (Google Play Requirement).
    // System permission prompts MUST NOT be triggered before showing this disclosure.
    if (!mounted) return;
    final accepted = await LocationPermissionDialog.show(context);

    if (!accepted) {
      if (!mounted) return;
      setState(() {
        _declinedLocationConsent = true;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _declinedLocationConsent = false;
    });

    // 4. User accepted prominent disclosure -> Now request system permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestBasicPermission();
    }

    if (permission == LocationPermission.deniedForever || 
        permission == LocationPermission.denied) {
      if (!mounted) return;
      _waitingForSettings = true;
      await _locationService.openLocationSettings();
      return;
    }

    if (permission == LocationPermission.always) {
      await _goToMain();
      return;
    }

    // If user granted "whileInUse" but needs "always", send to location settings
    if (!mounted) return;
    _waitingForSettings = true;
    await _locationService.openLocationSettings();
  }

  Future<void> _checkAndProceed() async {
    // Re-check notifications first
    if (!await _pushService.isPermissionGranted()) {
      if (!mounted) return;
      await _runPermissionFlow();
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: _declinedLocationConsent
                ? _buildDeclinedContent()
                : _buildLoadingContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
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
    );
  }

  Widget _buildDeclinedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF4FA4B5).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.location_off_rounded,
            color: Color(0xFF4FA4B5),
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ubicación requerida',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'LeasyOps necesita acceder a tu ubicación en todo momento para registrar operativas de campo y asignación de tareas.',
          style: GoogleFonts.inter(
            fontSize: 14,
            height: 1.5,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _runLocationFlow(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FA4B5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Revisar aviso de ubicación',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
