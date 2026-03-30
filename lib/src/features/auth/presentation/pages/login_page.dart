import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/pages/main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top section with background image and logo
          Expanded(
            flex: 7,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background city/car image
                Image.asset(
                  'assets/image.png',
                  fit: BoxFit.cover,
                ),
                // "LEASY" Logo on top
                Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Hero(
                    tag: 'logo',
                    child: SvgPicture.asset(
                      'assets/logo_leasy_editable_blanco.svg',
                      height: 100,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      semanticsLabel: 'Leasy Logo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom section with login options
          Container(
            width: double.infinity,
            color: const Color(0xFFE3F0F3),
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bienvenido de nuevo',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ingresa tus credenciales para continuar',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Username Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Usuario',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF002B4B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF002B4B)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Login logic will go here
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MainPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002B4B),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

