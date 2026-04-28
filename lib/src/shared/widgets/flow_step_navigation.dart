import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlowStepNavigation extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onContinue;
  final String buttonText;
  final bool isContinueEnabled;
  final String backText;

  const FlowStepNavigation({
    super.key,
    this.onBack,
    required this.onContinue,
    this.buttonText = 'Continuar',
    this.isContinueEnabled = true,
    this.backText = 'Atrás',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E9EB))),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCCD4DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    backText,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF002B4B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isContinueEnabled ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FA4B5),
                  disabledBackgroundColor: const Color(0xFFCCD5DB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
