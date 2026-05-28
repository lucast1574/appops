import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class RecoveryEfectuadoStep extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryEfectuadoStep({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      {'label': 'Si', 'val': true},
      {'label': 'No', 'val': false},
    ];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Recupero efectuado',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...options.map((option) {
                    final label = option['label'] as String;
                    final val = option['val'] as bool;
                    final isSelected = value == val;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => onChanged(val),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF4FA4B5).withValues(alpha: 0.1)
                                : const Color(0xFFF8FBFA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF4FA4B5) : const Color(0xFFE5E9EB),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        // Warning Banner at the bottom
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF002B4B),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Los datos registrados no se podrán deshacer una vez enviada la información',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF002B4B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FlowStepNavigation(
          isContinueEnabled: value != null,
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Continuar',
        ),
      ],
    );
  }
}
