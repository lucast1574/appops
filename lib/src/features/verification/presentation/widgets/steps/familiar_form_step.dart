import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/signature_pad.dart';

class FamiliarFormStep extends StatelessWidget {
  final String? selectedRelationship;
  final GlobalKey<SignaturePadState> signatureKey;
  final Function(String?) onRelationshipChanged;
  final TextEditingController dniController;
  final TextEditingController nameController;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const FamiliarFormStep({
    super.key,
    this.selectedRelationship,
    required this.signatureKey,
    required this.onRelationshipChanged,
    required this.dniController,
    required this.nameController,
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
                _buildFormTextField('DNI/INE del familiar', dniController),
                const SizedBox(height: 16),
                _buildFormTextField('Nombre completo', nameController),
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
                      onPressed: () => signatureKey.currentState?.clear(),
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
                SignaturePad(key: signatureKey),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          isContinueEnabled: nameController.text.trim().isNotEmpty &&
              dniController.text.trim().isNotEmpty &&
              selectedRelationship != null,
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

  Widget _buildFormTextField(String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(hint),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
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

