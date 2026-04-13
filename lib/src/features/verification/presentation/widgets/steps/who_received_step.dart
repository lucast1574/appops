import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class WhoReceivedStep extends StatelessWidget {
  final String? selectedRecipient;
  final Function(String) onRecipientSelected;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const WhoReceivedStep({
    super.key,
    this.selectedRecipient,
    required this.onRecipientSelected,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final options = ['Cliente', 'Familiar', 'Nadie'];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Juan Ramos | DNI: 12999312232',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF667085),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¿Quién te recibió?',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...options.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => onRecipientSelected(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedRecipient == option
                                ? const Color(0xFF4FA4B5).withValues(alpha: 0.1)
                                : const Color(0xFFF8FBFA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedRecipient == option
                                  ? const Color(0xFF4FA4B5)
                                  : const Color(0xFFE5E9EB),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            option,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: selectedRecipient != null,
          onBack: onBack,
          onContinue: onContinue,
          buttonText: selectedRecipient == 'Nadie' ? 'Finalizar' : 'Continuar',
        ),
      ],
    );
  }
}
