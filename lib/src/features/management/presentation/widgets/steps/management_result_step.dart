import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class ManagementResultStep extends StatelessWidget {
  final String? result;
  final TextEditingController observationsController;
  final Function(String) onResultChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ManagementResultStep({
    super.key,
    this.result,
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Placa',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9EB)),
                  ),
                  child: Text(
                    'EDZ-478',
                    style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  ),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
                Text(
                  'Observaciones',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF002B4B)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: observationsController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Lorem ipsum dolor sit amet consectetur...',
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
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: result != null,
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Finalizar',
        ),
      ],
    );
  }

  Widget _buildResultOption(String label, Color textColor, Color bgColor, Color borderColor) {
    bool isActive = result == label;
    return GestureDetector(
      onTap: () => onResultChanged(label),
      child: Container(
        width: double.infinity,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? bgColor : const Color(0xFFF8FBFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB9DBE1), width: 1.0),
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
