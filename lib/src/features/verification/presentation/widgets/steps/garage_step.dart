import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class GarageStep extends StatelessWidget {
  final bool? isGarageAtHome;
  final bool garageFacadeUploaded;
  final String? garageFacadeTag;
  final bool? hasSecurity;
  final bool? hasCameras;
  final bool garageCamerasUploaded;
  final String? garageCamerasTag;
  final String? accessType;
  final bool? isRoofing;
  final bool garageRoofingUploaded;
  final String? garageRoofingTag;
  final bool? isBasement;
  final bool garageBasementUploaded;
  final String? garageBasementTag;
  final String? garageDirection;
  final bool garageDirectionUploaded;
  final String? garageDirectionTag;
  final String? streetAccessibility;
  final bool streetAccessibilityUploaded;
  final String? streetAccessibilityTag;
  final TextEditingController mapsController;
  
  // Extra images state
  final int extraImagesCount;
  final bool isCocheraFuera;
  final List<bool> extraImagesUploaded;
  final List<String?> extraImagesTags;

  final Function(bool) onGarageAtHomeChanged;
  final Function(bool?) onCocheraFueraChanged;
  final Function(bool) onFacadeUploadedChanged;
  final Function(String?) onFacadeTagChanged;
  final Function(bool) onSecurityChanged;
  final Function(bool) onCamerasChanged;
  final Function(bool) onCamerasUploadedChanged;
  final Function(String?) onCamerasTagChanged;
  final Function(String) onAccessTypeChanged;
  final Function(bool) onRoofingChanged;
  final Function(bool) onRoofingUploadedChanged;
  final Function(String?) onRoofingTagChanged;
  final Function(bool) onBasementChanged;
  final Function(bool) onBasementUploadedChanged;
  final Function(String?) onBasementTagChanged;
  final Function(String) onGarageDirectionChanged;
  final Function(bool) onDirectionUploadedChanged;
  final Function(String?) onDirectionTagChanged;
  final Function(String) onStreetAccessibilityChanged;
  final Function(bool) onAccessibilityUploadedChanged;
  final Function(String?) onAccessibilityTagChanged;
  final TextEditingController? extraController; // Temporary to avoid errors if needed
  final VoidCallback onAddExtraImage;
  final Function(int, bool) onExtraImageUploadedChanged;
  final Function(int, String?) onExtraImageTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const GarageStep({
    super.key,
    this.isGarageAtHome,
    required this.garageFacadeUploaded,
    this.garageFacadeTag,
    this.hasSecurity,
    this.hasCameras,
    required this.garageCamerasUploaded,
    this.garageCamerasTag,
    this.accessType,
    this.isRoofing,
    required this.garageRoofingUploaded,
    this.garageRoofingTag,
    this.isBasement,
    required this.garageBasementUploaded,
    this.garageBasementTag,
    this.garageDirection,
    required this.garageDirectionUploaded,
    this.garageDirectionTag,
    this.streetAccessibility,
    required this.streetAccessibilityUploaded,
    this.streetAccessibilityTag,
    required this.mapsController,
    required this.extraImagesCount,
    required this.isCocheraFuera,
    required this.extraImagesUploaded,
    required this.extraImagesTags,
    required this.onGarageAtHomeChanged,
    required this.onCocheraFueraChanged,
    required this.onFacadeUploadedChanged,
    required this.onFacadeTagChanged,
    required this.onSecurityChanged,
    required this.onCamerasChanged,
    required this.onCamerasUploadedChanged,
    required this.onCamerasTagChanged,
    required this.onAccessTypeChanged,
    required this.onRoofingChanged,
    required this.onRoofingUploadedChanged,
    required this.onRoofingTagChanged,
    required this.onBasementChanged,
    required this.onBasementUploadedChanged,
    required this.onBasementTagChanged,
    required this.onGarageDirectionChanged,
    required this.onDirectionUploadedChanged,
    required this.onDirectionTagChanged,
    required this.onStreetAccessibilityChanged,
    required this.onAccessibilityUploadedChanged,
    required this.onAccessibilityTagChanged,
    this.extraController,
    required this.onAddExtraImage,
    required this.onExtraImageUploadedChanged,
    required this.onExtraImageTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    bool basePhotosUploaded = garageFacadeUploaded && 
                             (hasCameras == false || garageCamerasUploaded) &&
                             garageRoofingUploaded &&
                             garageBasementUploaded &&
                             garageDirectionUploaded &&
                             streetAccessibilityUploaded;
                             
    bool extraPhotosUploaded = true;
    if (isCocheraFuera) {
      extraPhotosUploaded = extraImagesCount == 3 && 
                           extraImagesUploaded[0] && 
                           extraImagesUploaded[1] && 
                           extraImagesUploaded[2];
    }

    bool isContinueEnabled = isGarageAtHome != null &&
                            hasSecurity != null &&
                            hasCameras != null &&
                            accessType != null &&
                            isRoofing != null &&
                            isBasement != null &&
                            garageDirection != null &&
                            streetAccessibility != null &&
                            basePhotosUploaded &&
                            extraPhotosUploaded &&
                            mapsController.text.trim().isNotEmpty;

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
                FlowYesNoQuestion(
                  question: '¿Vivienda es también la cochera?',
                  currentValue: isGarageAtHome,
                  onChanged: onGarageAtHomeChanged,
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => onCocheraFueraChanged(!isCocheraFuera),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isCocheraFuera,
                          onChanged: onCocheraFueraChanged,
                          activeColor: const Color(0xFF002B4B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cochera fuera del domicilio',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF002B4B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildUploadSection(
                  'Foto de la vivienda / fachada',
                  isUploaded: garageFacadeUploaded,
                  onUploadedChanged: onFacadeUploadedChanged,
                  tag: garageFacadeTag,
                  onTagChanged: onFacadeTagChanged,
                ),
                const SizedBox(height: 24),
                FlowYesNoQuestion(
                  question: '¿Cochera cuenta con seguridad?',
                  currentValue: hasSecurity,
                  onChanged: onSecurityChanged,
                ),
                const SizedBox(height: 16),
                FlowYesNoQuestion(
                  question: '¿Cochera cuenta con cámara de vigilancia?',
                  currentValue: hasCameras,
                  onChanged: onCamerasChanged,
                ),
                if (hasCameras == true) ...[
                  const SizedBox(height: 16),
                  _buildUploadSection(
                    'Foto de la cámara de vigilancia',
                    isUploaded: garageCamerasUploaded,
                    onUploadedChanged: onCamerasUploadedChanged,
                    tag: garageCamerasTag,
                    onTagChanged: onCamerasTagChanged,
                  ),
                ],
                const SizedBox(height: 24),
                FlowDualOptionQuestion(
                  question: 'Tipo de vía de acceso a la cochera',
                  opt1: 'Asfaltado',
                  opt2: 'Rural',
                  currentValue: accessType,
                  onChanged: onAccessTypeChanged,
                ),
                const SizedBox(height: 16),
                FlowYesNoQuestion(
                  question: 'Cochera es techada?',
                  currentValue: isRoofing,
                  onChanged: onRoofingChanged,
                ),
                const SizedBox(height: 16),
                _buildUploadSection(
                  'Foto de la cochera',
                  isUploaded: garageRoofingUploaded,
                  onUploadedChanged: onRoofingUploadedChanged,
                  tag: garageRoofingTag,
                  onTagChanged: onRoofingTagChanged,
                ),
                const SizedBox(height: 24),
                FlowYesNoQuestion(
                  question: 'Cochera se ubica en sótano',
                  currentValue: isBasement,
                  onChanged: onBasementChanged,
                ),
                const SizedBox(height: 16),
                _buildUploadSection(
                  'Foto de la cochera',
                  isUploaded: garageBasementUploaded,
                  onUploadedChanged: onBasementUploadedChanged,
                  tag: garageBasementTag,
                  onTagChanged: onBasementTagChanged,
                ),
                const SizedBox(height: 24),
                FlowDualOptionQuestion(
                  question: 'Hacia dónde da la cochera?',
                  opt1: 'Calle',
                  opt2: 'Condominio',
                  currentValue: garageDirection,
                  onChanged: onGarageDirectionChanged,
                ),
                const SizedBox(height: 16),
                _buildUploadSection(
                  'Foto de calle / condominio',
                  isUploaded: garageDirectionUploaded,
                  onUploadedChanged: onDirectionUploadedChanged,
                  tag: garageDirectionTag,
                  onTagChanged: onDirectionTagChanged,
                ),
                const SizedBox(height: 24),
                FlowDualOptionQuestion(
                  question: 'Accesibilidad de la calle',
                  opt1: 'Calle con reja',
                  opt2: 'Libre acceso',
                  currentValue: streetAccessibility,
                  onChanged: onStreetAccessibilityChanged,
                ),
                const SizedBox(height: 16),
                _buildUploadSection(
                  'Foto accesibilidad de la calle',
                  isUploaded: streetAccessibilityUploaded,
                  onUploadedChanged: onAccessibilityUploadedChanged,
                  tag: streetAccessibilityTag,
                  onTagChanged: onAccessibilityTagChanged,
                ),
                
                if (isCocheraFuera) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF002B4B), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'En caso de que la cochera no quede en el domicilio se debe adjuntar 3 fotos más',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF002B4B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  for (int i = 0; i < extraImagesCount; i++) ...[
                    _buildUploadSection(
                      'Foto fachada y calle ${i + 1}',
                      isUploaded: extraImagesUploaded[i],
                      onUploadedChanged: (val) => onExtraImageUploadedChanged(i, val),
                      tag: extraImagesTags[i],
                      onTagChanged: (val) => onExtraImageTagChanged(i, val),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (extraImagesCount < 3)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onAddExtraImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002B4B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Agregar imagen', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
                
                const SizedBox(height: 32),
                FlowGoogleMapsSection(
                  label: 'Link Google Maps - Ubicación de cochera',
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
          onBack: onBack,
          onContinue: onContinue,
          isContinueEnabled: isContinueEnabled,
        ),
      ],
    );
  }

  Widget _buildUploadSection(
    String title, {
    required bool isUploaded, 
    required Function(bool) onUploadedChanged,
    String? tag,
    required Function(String?) onTagChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowSectionLabel(label: title),
        const SizedBox(height: 12),
        isUploaded 
            ? FlowImagePreview(
                fileName: 'imagen_capturada.png',
                tag: tag,
                onDeleteImage: () {
                  onUploadedChanged(false);
                  onTagChanged(null);
                },
                onDeleteTag: () => onTagChanged(null),
                onTagAdded: (val) => onTagChanged(val),
              )
            : FlowUploadButton(
                text: 'Tomar foto',
                iconAsset: 'assets/CameraPlus.svg',
                onTap: () => onUploadedChanged(true),
              ),
      ],
    );
  }
}
