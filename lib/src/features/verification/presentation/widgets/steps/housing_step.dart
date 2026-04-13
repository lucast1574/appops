import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

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
                    child: FlowToggleOption(
                      text: type,
                      isActive: housingType == type,
                      onTap: () => onHousingTypeChanged(type),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FlowGoogleMapsSection(
                  label: 'Link Google Maps - Ubicación de vivienda',
                  controller: mapsController,
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: housingType != null,
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }
}
