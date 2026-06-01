import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class RecoveryPhotosIntroStep extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryPhotosIntroStep({
    super.key,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sync,
                    size: 100,
                    color: Color(0xFF002B4B),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Fotos unidad recuperada',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iniciar toma de fotos en 360°',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF002B4B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Comenzar',
        ),
      ],
    );
  }
}
