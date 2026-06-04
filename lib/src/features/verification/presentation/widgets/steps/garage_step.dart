import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class GarageStep extends StatelessWidget {
  final int taskId;
  final bool? isGarageAtHome;
  final bool garageFacadeUploaded;
  final String? garageFacadeTag;
  final String? garageFacadePath;
  final bool? hasSecurity;
  final bool? hasCameras;
  final bool garageCamerasUploaded;
  final String? garageCamerasTag;
  final String? garageCamerasPath;
  final String? accessType;
  final bool? isRoofing;
  final bool garageRoofingUploaded;
  final String? garageRoofingTag;
  final String? garageRoofingPath;
  final bool? isBasement;
  final bool garageBasementUploaded;
  final String? garageBasementTag;
  final String? garageBasementPath;
  final String? garageDirection;
  final bool garageDirectionUploaded;
  final String? garageDirectionTag;
  final String? garageDirectionPath;
  final String? streetAccessibility;
  final bool streetAccessibilityUploaded;
  final String? streetAccessibilityTag;
  final String? streetAccessibilityPath;
  final TextEditingController mapsController;
  
  // Extra images state
  final int extraImagesCount;
  final bool isCocheraFuera;
  final List<bool> extraImagesUploaded;
  final List<String?> extraImagesTags;
  final List<String?> extraImagesPaths;

  final Function(bool) onGarageAtHomeChanged;
  final Function(bool?) onCocheraFueraChanged;
  final Function(bool, dynamic) onFacadeUploadedChanged;
  final Function(String?) onFacadeTagChanged;
  final Function(bool) onSecurityChanged;
  final Function(bool) onCamerasChanged;
  final Function(bool, dynamic) onCamerasUploadedChanged;
  final Function(String?) onCamerasTagChanged;
  final Function(String) onAccessTypeChanged;
  final Function(bool) onRoofingChanged;
  final Function(bool, dynamic) onRoofingUploadedChanged;
  final Function(String?) onRoofingTagChanged;
  final Function(bool) onBasementChanged;
  final Function(bool, dynamic) onBasementUploadedChanged;
  final Function(String?) onBasementTagChanged;
  final Function(String) onGarageDirectionChanged;
  final Function(bool, dynamic) onDirectionUploadedChanged;
  final Function(String?) onDirectionTagChanged;
  final Function(String) onStreetAccessibilityChanged;
  final Function(bool, dynamic) onAccessibilityUploadedChanged;
  final Function(String?) onAccessibilityTagChanged;
  final VoidCallback onAddExtraImage;
  final Function(int, bool, dynamic) onExtraImageUploadedChanged;
  final Function(int, String?) onExtraImageTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const GarageStep({
    super.key,
    required this.taskId,
    this.isGarageAtHome,
    required this.garageFacadeUploaded,
    this.garageFacadeTag,
    this.garageFacadePath,
    this.hasSecurity,
    this.hasCameras,
    required this.garageCamerasUploaded,
    this.garageCamerasTag,
    this.garageCamerasPath,
    this.accessType,
    this.isRoofing,
    required this.garageRoofingUploaded,
    this.garageRoofingTag,
    this.garageRoofingPath,
    this.isBasement,
    required this.garageBasementUploaded,
    this.garageBasementTag,
    this.garageBasementPath,
    this.garageDirection,
    required this.garageDirectionUploaded,
    this.garageDirectionTag,
    this.garageDirectionPath,
    this.streetAccessibility,
    required this.streetAccessibilityUploaded,
    this.streetAccessibilityTag,
    this.streetAccessibilityPath,
    required this.mapsController,
    required this.extraImagesCount,
    required this.isCocheraFuera,
    required this.extraImagesUploaded,
    required this.extraImagesTags,
    required this.extraImagesPaths,
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
    required this.onAddExtraImage,
    required this.onExtraImageUploadedChanged,
    required this.onExtraImageTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Conditional photo logic:
    // - if isRoofing is true, we need roofing photo.
    // - if isBasement is true, we need basement photo.
    // - if both are false, we need a general garage photo (we'll use roofing fields for this).
    bool needRoofingPhoto = isRoofing == true;
    bool needBasementPhoto = isBasement == true;
    bool needGeneralPhoto = isRoofing == false && isBasement == false;

    bool basePhotosUploaded = garageFacadeUploaded && 
                             (hasCameras == false || garageCamerasUploaded) &&
                             (!needRoofingPhoto || garageRoofingUploaded) &&
                             (!needBasementPhoto || garageBasementUploaded) &&
                             (!needGeneralPhoto || garageRoofingUploaded) && // Reuse roofing for general
                             garageDirectionUploaded &&
                             streetAccessibilityUploaded;
                             
    bool extraPhotosUploaded = true;
    if (isCocheraFuera) {
      extraPhotosUploaded = extraImagesUploaded[0] && 
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
                if (isCocheraFuera) ...[
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
                  
                  for (int i = 0; i < 3; i++) ...[
                    FlowPhotoInput(
                      label: 'Foto fachada y calle ${i + 1}',
                      taskId: taskId,
                      photoLabel: 'fachada_calle_extra_${i + 1}',
                      previewFileName: 'extra_${i + 1}.png',
                      isUploaded: extraImagesUploaded[i],
                      imagePath: extraImagesPaths[i],
                      tag: extraImagesTags[i],
                      onChanged: (val, res) => onExtraImageUploadedChanged(i, val, res),
                      onTagChanged: (val) => onExtraImageTagChanged(i, val),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
                FlowPhotoInput(
                  label: 'Foto de la vivienda / fachada',
                  taskId: taskId,
                  photoLabel: 'fachada_vivienda',
                  previewFileName: 'fachada.png',
                  isUploaded: garageFacadeUploaded,
                  imagePath: garageFacadePath,
                  tag: garageFacadeTag,
                  onChanged: onFacadeUploadedChanged,
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
                  FlowPhotoInput(
                    label: 'Foto de la cámara de vigilancia',
                    taskId: taskId,
                    photoLabel: 'camara_vigilancia',
                    previewFileName: 'camara.png',
                    isUploaded: garageCamerasUploaded,
                    imagePath: garageCamerasPath,
                    tag: garageCamerasTag,
                    onChanged: onCamerasUploadedChanged,
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
                const SizedBox(height: 24),
                FlowYesNoQuestion(
                  question: 'Cochera se ubica en sótano',
                  currentValue: isBasement,
                  onChanged: onBasementChanged,
                ),
                const SizedBox(height: 16),
                
                if (needRoofingPhoto) ...[
                  FlowPhotoInput(
                    label: 'Foto de la cochera techada',
                    taskId: taskId,
                    photoLabel: 'cochera_techada',
                    previewFileName: 'techada.png',
                    isUploaded: garageRoofingUploaded,
                    imagePath: garageRoofingPath,
                    tag: garageRoofingTag,
                    onChanged: onRoofingUploadedChanged,
                    onTagChanged: onRoofingTagChanged,
                  ),
                  const SizedBox(height: 16),
                ],
                
                if (needBasementPhoto) ...[
                  FlowPhotoInput(
                    label: 'Foto de la cochera sótano',
                    taskId: taskId,
                    photoLabel: 'cochera_sotano',
                    previewFileName: 'sotano.png',
                    isUploaded: garageBasementUploaded,
                    imagePath: garageBasementPath,
                    tag: garageBasementTag,
                    onChanged: onBasementUploadedChanged,
                    onTagChanged: onBasementTagChanged,
                  ),
                  const SizedBox(height: 16),
                ],

                if (needGeneralPhoto) ...[
                  FlowPhotoInput(
                    label: 'Foto de la cochera',
                    taskId: taskId,
                    photoLabel: 'cochera_general',
                    previewFileName: 'cochera.png',
                    isUploaded: garageRoofingUploaded, // Use roofing field for general
                    imagePath: garageRoofingPath,
                    tag: garageRoofingTag,
                    onChanged: onRoofingUploadedChanged,
                    onTagChanged: onRoofingTagChanged,
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 8),
                FlowDualOptionQuestion(
                  question: 'Hacia dónde da la cochera?',
                  opt1: 'Calle',
                  opt2: 'Condominio',
                  currentValue: garageDirection,
                  onChanged: onGarageDirectionChanged,
                ),
                const SizedBox(height: 16),
                FlowPhotoInput(
                  label: 'Foto de calle / condominio',
                  taskId: taskId,
                  photoLabel: 'cochera_direccion',
                  previewFileName: 'direccion.png',
                  isUploaded: garageDirectionUploaded,
                  imagePath: garageDirectionPath,
                  tag: garageDirectionTag,
                  onChanged: onDirectionUploadedChanged,
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
                FlowPhotoInput(
                  label: 'Foto accesibilidad de la calle',
                  taskId: taskId,
                  photoLabel: 'accesibilidad_calle',
                  previewFileName: 'accesibilidad.png',
                  isUploaded: streetAccessibilityUploaded,
                  imagePath: streetAccessibilityPath,
                  tag: streetAccessibilityTag,
                  onChanged: onAccessibilityUploadedChanged,
                  onTagChanged: onAccessibilityTagChanged,
                ),

                
                const SizedBox(height: 32),
                FlowGoogleMapsSection(
                  label: 'Link Google Maps - Ubicación de cochera',
                  controller: mapsController,
                  onOpenMaps: () async {
                    final url = mapsController.text.trim();
                    if (url.isNotEmpty) {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
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
}
