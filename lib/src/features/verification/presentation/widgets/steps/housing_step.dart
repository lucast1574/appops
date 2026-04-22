import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final url = mapsController.text.trim();
                      if (url.isNotEmpty) {
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      }
                    },
                    icon: const Icon(Icons.location_on_outlined, size: 18),
                    label: Text(
                      'Abrir Google maps',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFF002B4B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: housingType != null && mapsController.text.trim().isNotEmpty,
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }
}
