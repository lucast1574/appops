import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/auth_service.dart';
import '../../data/location_service.dart';
import '../../../../core/notifications/push_service.dart';
import 'login_page.dart';
import 'permission_gate_page.dart';
import '../../../home/presentation/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authService = AuthService();
    final isLoggedIn = await authService.isAuthenticated();

    Widget destination;
    if (isLoggedIn) {
      // Verify token is still valid by fetching user data
      try {
        await authService.fetchMe();

        // Refresh FCM token registration with the backend (token may
        // have rotated while the app was closed). Best-effort.
        // ignore: unawaited_futures
        PushService.instance.registerCurrentDevice();

        // Token valid — check if permissions are already granted.
        final locationService = LocationService();
        final hasAlways = await locationService.hasAlwaysPermission();
        final hasNotifs = await PushService.instance.isPermissionGranted();

        if (hasAlways && hasNotifs) {
          // Send current location to backend (assigns city if missing)
          // and start background tracking.
          await locationService.sendCurrentLocation();
          locationService.startTracking();
          destination = const MainPage();
        } else {
          destination = const PermissionGatePage();
        }
      } catch (_) {
        // Token expired or invalid, go to login
        await authService.logout();
        destination = const LoginPage();
      }
    } else {
      destination = const LoginPage();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
                parent: animation, curve: Curves.easeInOutQuart),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002B4A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF002B4A),
                  Color(0xFF001F35),
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: Hero(
                        tag: 'logo',
                        child: SvgPicture.asset(
                          'assets/logo_leasy_editable_blanco.svg',
                          width: 250,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
