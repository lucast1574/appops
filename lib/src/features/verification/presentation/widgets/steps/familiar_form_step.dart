import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/verification_step_navigation.dart';

class FamiliarFormStep extends StatelessWidget {
  final String? selectedRelationship;
  final List<Offset?> signaturePoints;
  final Function(String?) onRelationshipChanged;
  final Function(Offset?) onSignaturePointAdded;
  final VoidCallback onClearSignature;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const FamiliarFormStep({
    super.key,
    this.selectedRelationship,
    required this.signaturePoints,
    required this.onRelationshipChanged,
    required this.onSignaturePointAdded,
    required this.onClearSignature,
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
                _buildFormTextField('DNI del familiar'),
                const SizedBox(height: 16),
                _buildFormTextField('Nombre completo'),
                const SizedBox(height: 16),
                _buildLabel('Parentesco con el cliente'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedRelationship,
                    hint: Text(
                      'Seleccionar',
                      style: GoogleFonts.inter(color: const Color(0xFF002B4B)),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
                    items: ['Padre/Madre', 'Hijo/a', 'Cónyuge', 'Otros'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: onRelationshipChanged,
                    underline: const SizedBox(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Firma de familiar'),
                    TextButton(
                      onPressed: onClearSignature,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD9D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        'Borrar',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE35959),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9EB)),
                  ),
                  child: Stack(
                    children: [
                      if (signaturePoints.isEmpty)
                        Center(
                          child: Text(
                            'Área de firma',
                            style: GoogleFonts.inter(
                              color: const Color(
                                0xFF99AAB7,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onPanUpdate: (details) {
                          RenderBox renderBox = context.findRenderObject() as RenderBox;
                          onSignaturePointAdded(renderBox.globalToLocal(details.globalPosition));
                        },
                        onPanEnd: (details) => onSignaturePointAdded(null),
                        child: CustomPaint(
                          painter: SignaturePainter(points: signaturePoints),
                          size: Size.infinite,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        VerificationStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF002B4B),
      ),
    );
  }

  Widget _buildFormTextField(String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(hint),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
            ),
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
              borderSide: const BorderSide(color: Color(0xFF002B4B)),
            ),
          ),
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF002B4B)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => oldDelegate.points != points;
}
