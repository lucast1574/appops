import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/form_widgets.dart';
import '../shared/verification_upload_button.dart';
import '../shared/verification_step_navigation.dart';

class GarageStep extends StatelessWidget {
  final bool? isGarageAtHome;
  final bool? hasSecurity;
  final bool? hasCameras;
  final String? accessType;
  final bool? isRoofing;
  final bool? isBasement;
  final String? garageDirection;
  final String? streetAccessibility;
  final Function(bool) onGarageAtHomeChanged;
  final Function(bool) onSecurityChanged;
  final Function(bool) onCamerasChanged;
  final Function(String) onAccessTypeChanged;
  final Function(bool) onRoofingChanged;
  final Function(bool) onBasementChanged;
  final Function(String) onGarageDirectionChanged;
  final Function(String) onStreetAccessibilityChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const GarageStep({
    super.key,
    this.isGarageAtHome,
    this.hasSecurity,
    this.hasCameras,
    this.accessType,
    this.isRoofing,
    this.isBasement,
    this.garageDirection,
    this.streetAccessibility,
    required this.onGarageAtHomeChanged,
    required this.onSecurityChanged,
    required this.onCamerasChanged,
    required this.onAccessTypeChanged,
    required this.onRoofingChanged,
    required this.onBasementChanged,
    required this.onGarageDirectionChanged,
    required this.onStreetAccessibilityChanged,
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
                  'Cochera',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                YesNoQuestion(
                  question: '¿Vivienda es también la cochera?',
                  currentValue: isGarageAtHome,
                  onChanged: onGarageAtHomeChanged,
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto de la vivienda / fachada',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 24),
                YesNoQuestion(
                  question: '¿Cochera cuenta con seguridad?',
                  currentValue: hasSecurity,
                  onChanged: onSecurityChanged,
                ),
                const SizedBox(height: 16),
                YesNoQuestion(
                  question: '¿Cochera cuenta con cámara de vigilancia?',
                  currentValue: hasCameras,
                  onChanged: onCamerasChanged,
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto de la cámara de vigilancia',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 24),
                DualOptionQuestion(
                  question: 'Tipo de vía de acceso a la cochera',
                  opt1: 'Asfaltado',
                  opt2: 'Rural',
                  currentValue: accessType,
                  onChanged: onAccessTypeChanged,
                ),
                const SizedBox(height: 16),
                YesNoQuestion(
                  question: 'Cochera es techada?',
                  currentValue: isRoofing,
                  onChanged: onRoofingChanged,
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto de la cochera',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 24),
                YesNoQuestion(
                  question: 'Cochera se ubica en sótano',
                  currentValue: isBasement,
                  onChanged: onBasementChanged,
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto de la cochera',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 24),
                DualOptionQuestion(
                  question: 'Hacia dónde da la cochera?',
                  opt1: 'Calle',
                  opt2: 'Condominio',
                  currentValue: garageDirection,
                  onChanged: onGarageDirectionChanged,
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto de calle / condominio',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 24),
                DualOptionQuestion(
                  question: 'Accesibilidad de la calle',
                  opt1: 'Calle con reja',
                  opt2: 'Libre acceso',
                  currentValue: streetAccessibility,
                  onChanged: onStreetAccessibilityChanged,
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto accesibilidad de la calle',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'En caso de que la cochera no quede en el domicilio se debe adjuntar 3 fotos más',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF002B4B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildValidationWrapper(
                  'Foto fachada y calle',
                  child: const VerificationUploadButton(
                    text: 'Tomar foto',
                    icon: Icons.add_a_photo_outlined,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002B4B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Agregar imagen', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
                _buildMapsSection('Link Google Maps - Ubicación de cochera'),
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

  Widget _buildValidationWrapper(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionLabel(label: title),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildMapsSection(String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionLabel(label: label),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'Agregar link Google maps',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
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
    );
  }
}
