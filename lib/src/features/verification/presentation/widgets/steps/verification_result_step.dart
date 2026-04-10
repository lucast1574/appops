import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/verification_step_navigation.dart';

class VerificationResultStep extends StatelessWidget {
  final String? verificationResult;
  final TextEditingController observationsController;
  final Function(String) onResultChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const VerificationResultStep({
    super.key,
    this.verificationResult,
    required this.observationsController,
    required this.onResultChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Resultado de la verificación',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildResultOption('Aprobado', const Color(0xFF002B4B), const Color(0xFFA7DAC5), const Color(0xFF3DAE7E)),
                const SizedBox(height: 12),
                _buildResultOption('Rechazado', Colors.white, const Color(0xFFFF5A5F), const Color(0xFFFFADAF)),
                const SizedBox(height: 12),
                _buildResultOption('Observado', const Color(0xFF002B4B), const Color(0xFFFDE084), const Color(0xFFFCD352)),
                const SizedBox(height: 24),
                Text(
                  'Observaciones',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF002B4B)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: observationsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Agregar observaciones',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF002B4B), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Los datos registrados no se podrán deshacer una vez enviada la información',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF002B4B).withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        VerificationStepNavigation(
          isContinueEnabled: verificationResult != null,
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }

  Widget _buildResultOption(String label, Color textColor, Color bgColor, Color borderColor) {
    bool isActive = verificationResult == label;
    return GestureDetector(
      onTap: () => onResultChanged(label),
      child: Container(
        width: double.infinity,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? bgColor : const Color(0xFFF8FBFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB9DBE1),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? textColor : const Color(0xFF002B4B),
          ),
        ),
      ),
    );
  }
}
