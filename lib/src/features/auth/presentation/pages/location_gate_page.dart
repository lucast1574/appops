import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/location_service.dart';
import '../../../home/presentation/pages/main_page.dart';
import '../widgets/location_permission_dialog.dart';

/// Mandatory intermediate page shown after login (or on app restart) when
/// the user has not yet granted "always" location permission.
///
/// This page **cannot** be skipped:
/// - Back navigation is blocked via [PopScope].
/// - The dialog re-appears in a loop until the permission is granted.
/// - Handles all edge cases: denied, denied-forever, service disabled.
class LocationGatePage extends StatefulWidget {
  const LocationGatePage({super.key});

  @override
  State<LocationGatePage> createState() => _LocationGatePageState();
}

class _LocationGatePageState extends State<LocationGatePage>
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
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

  /// Re-check permission every time the app resumes (user may return from
  /// system settings).
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
    // 1. Ensure the device location service is enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      _waitingForSettings = true;
      return;
    }

    // 2. Request basic "while in use" permission (shows OS dialog).
    final permission = await _locationService.requestBasicPermission();

    // 3. If user chose "denied forever", we must send them to app settings.
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      await _showDialogAndOpenSettings();
      return;
    }

    // 4. If still just denied (cancelled the OS dialog), show our dialog.
    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      await _showDialogAndOpenSettings();
      return;
    }

    // 5. Check if already "always".
    if (await _locationService.hasAlwaysPermission()) {
      await _goToMain();
      return;
    }

    // 6. Has "while in use" but not "always" — show our mandatory dialog.
    if (!mounted) return;
    await _showDialogAndOpenSettings();
  }

  /// Shows the mandatory bottom-sheet dialog, then opens system app settings.
  /// Loops until the user grants "always" permission.
  Future<void> _showDialogAndOpenSettings() async {
    await LocationPermissionDialog.show(context);
    if (!mounted) return;

    _waitingForSettings = true;
    await _locationService.openLocationSettings();
  }

  Future<void> _checkAndProceed() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      await _showDialogAndOpenSettings();
      return;
    }

    if (await _locationService.hasAlwaysPermission()) {
      await _goToMain();
    } else {
      if (!mounted) return;
      await _showDialogAndOpenSettings();
    }
  }

  Future<void> _goToMain() async {
    if (!mounted) return;

    // Send location to backend BEFORE navigating — this ensures the user's
    // city is assigned on first login.
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
                Icons.location_on_rounded,
                color: Color(0xFF4FA4B5),
                size: 48,
              ),
              const SizedBox(height: 20),
              Text(
                'Configurando ubicación…',
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
