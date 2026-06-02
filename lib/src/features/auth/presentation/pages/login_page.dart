import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../data/auth_service.dart';
import 'permission_gate_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // serverClientId must be the WEB client ID (same as backend GOOGLE_CLIENT_ID)
    // so the ID token can be verified server-side
    serverClientId:
        '863779943763-cm4lce3c93qmo0k2a9apfne998j8t0ba.apps.googleusercontent.com',
  );

  bool _isLoading = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Trigger Google Sign-In flow
      debugPrint('DEBUG: Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      debugPrint('DEBUG: Google Sign-In result: $googleUser');
      if (googleUser == null) {
        debugPrint('DEBUG: User cancelled or sign-in failed silently');
        setState(() {
          _error = 'Inicio de sesión cancelado. Intenta de nuevo.';
          _isLoading = false;
        });
        return;
      }
      debugPrint('DEBUG: Signed in as: ${googleUser.email}');

      // 2. Get the ID token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        setState(() {
          _error = 'No se pudo obtener el token de Google';
          _isLoading = false;
        });
        return;
      }

      // 3. Best-effort: capture current GPS so the backend can resolve
      // the country when several share the same domain suffix (PE/EC/CO
      // all on leasyauto.com). PermissionGatePage already prompted for
      // permission, but we tolerate any failure here.
      double? lat;
      double? lng;
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 5),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
        // GPS not available; backend will fall back to first matching country.
      }

      // 4. Send token + GPS hint to backend with source='mobile'
      final result = await _authService.loginWithGoogle(
        idToken,
        source: 'mobile',
        latitude: lat,
        longitude: lng,
      );

      if (!mounted) return;

      // 4. Handle response status
      final status = result['status'];

      if (status == 'pending_approval') {
        setState(() {
          _error = 'Tu cuenta está pendiente de aprobación';
          _isLoading = false;
        });
        await _authService.logout();
        return;
      }

      if (status != 'ok') {
        setState(() {
          _error = result['message'] ?? 'Error desconocido';
          _isLoading = false;
        });
        return;
      }

      // 5. Navigate to location permission gate
      //    (location sending & tracking start after permission is confirmed)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PermissionGatePage()),
      );
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Google Sign-In ERROR: $e');
      String errorMessage = 'Error al iniciar sesión: ${e.toString()}';

      if (e is DioException && e.response != null) {
        debugPrint('DEBUG: Response status: ${e.response?.statusCode}');
        debugPrint('DEBUG: Response body: ${e.response?.data}');
        final responseData = e.response?.data;
        if (responseData is Map && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'Solo se permiten correos @leasyauto.com y @floty.mx';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Token de Google inválido';
        }
      } else {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          errorMessage = 'Sin conexión al servidor';
        }
      }
      debugPrint('DEBUG: Stack trace: $stackTrace');
      if (!mounted) return;

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/image.png', fit: BoxFit.cover),
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Hero(
                    tag: 'logo',
                    child: SvgPicture.asset(
                      'assets/logo_leasy_editable_blanco.svg',
                      height: 100,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      semanticsLabel: 'Leasy Logo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: const Color(0xFFE3F0F3),
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Inicia sesión para acceder a tu cuenta',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Solo correos @leasyauto.com y @floty.mx',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFED7D7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              const Color(0xFFC53030).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFFC53030)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor: Colors.grey.shade200,
                      padding: EdgeInsets.zero,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/Google.svg', height: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Continuar con Google',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
