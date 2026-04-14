import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class RecoveryWhoDeliveredStep extends StatelessWidget {
  final String? selectedPerson;
  final Function(String) onPersonSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryWhoDeliveredStep({
    super.key,
    this.selectedPerson,
    required this.onPersonSelected,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final options = ['Cliente', 'Familiar', 'Nadie / Recupero forzado'];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Carlos Mendoza | DNI: 45678912', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF667085), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                  Text('¿Quién entregó el vehículo?', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  ...options.map((option) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: () => onPersonSelected(option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity, height: 64, alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedPerson == option ? const Color(0xFF4FA4B5).withValues(alpha: 0.1) : const Color(0xFFF8FBFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selectedPerson == option ? const Color(0xFF4FA4B5) : const Color(0xFFE5E9EB)),
                        ),
                        child: Text(option, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF002B4B))),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: selectedPerson != null,
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Continuar',
        ),
      ],
    );
  }
}
