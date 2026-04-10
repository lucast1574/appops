import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/form_widgets.dart';
import '../shared/verification_step_navigation.dart';

class HousingStep extends StatelessWidget {
  final String? housingType;
  final TextEditingController mapsController;
  final Function(String) onHousingTypeChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const HousingStep({
    super.key,
    this.housingType,
    required this.mapsController,
    required this.onHousingTypeChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalles de vivienda',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 16),
                ...['Propia', 'Alquilada', 'Familiar'].map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ToggleOption(
                      text: type,
                      isActive: housingType == type,
                      onTap: () => onHousingTypeChanged(type),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormSectionLabel(label: 'Link Google Maps - Ubicación de vivienda'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mapsController,
                        decoration: InputDecoration(
                          hintText: 'Agregar link Google maps',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.location_on_outlined, color: Color(0xFF002B4B)),
                          label: Text(
                            'Abrir Google maps',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF002B4B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF002B4B), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
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
          isContinueEnabled: housingType != null,
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }
}
