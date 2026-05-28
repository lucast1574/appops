import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RecoveryBeforeStartingStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const RecoveryBeforeStartingStep({
    super.key,
    required this.onContinue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 24.0),
          child: TextButton(
            onPressed: onBack,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Volver',
              style: GoogleFonts.inter(
                color: const Color(0xFF002B4B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/alarm.svg',
                  width: 100,
                  height: 100,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF002B4B),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Antes de comenzar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recuerda que ambos operadores deben\nestar en la ubicación de la tarea antes de comenzar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF002B4B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27A376),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Comenzar tarea',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
