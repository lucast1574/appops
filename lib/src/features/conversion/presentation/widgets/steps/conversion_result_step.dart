import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class ConversionResultStep extends StatelessWidget {
  // Certificado de conversión
  final bool certificateUploaded;
  final String? certificateTag;
  final Function(bool) onCertificateUploadedChanged;
  final Function(String?) onCertificateTagChanged;

  // Foto del checklist
  final bool checklistPhotoUploaded;
  final String? checklistPhotoTag;
  final Function(bool) onChecklistPhotoUploadedChanged;
  final Function(String?) onChecklistPhotoTagChanged;

  // Fito-checklist
  final bool fitoChecklistUploaded;
  final String? fitoChecklistTag;
  final Function(bool) onFitoChecklistUploadedChanged;
  final Function(String?) onFitoChecklistTagChanged;

  // Google Maps link
  final TextEditingController mapsController;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionResultStep({
    super.key,
    required this.certificateUploaded,
    this.certificateTag,
    required this.onCertificateUploadedChanged,
    required this.onCertificateTagChanged,
    required this.checklistPhotoUploaded,
    this.checklistPhotoTag,
    required this.onChecklistPhotoUploadedChanged,
    required this.onChecklistPhotoTagChanged,
    required this.fitoChecklistUploaded,
    this.fitoChecklistTag,
    required this.onFitoChecklistUploadedChanged,
    required this.onFitoChecklistTagChanged,
    required this.mapsController,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultado conversión',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),

                // Certificado de conversión
                _buildUploadSection(
                  title: 'Certificado de conversión',
                  isUploaded: certificateUploaded,
                  fileName: 'Certificado.png',
                  tag: certificateTag,
                  onUpload: () => onCertificateUploadedChanged(true),
                  onDeleteImage: () {
                    onCertificateUploadedChanged(false);
                    onCertificateTagChanged(null);
                  },
                  onDeleteTag: () => onCertificateTagChanged(null),
                  onTagAdded: (val) => onCertificateTagChanged(val),
                ),
                const SizedBox(height: 24),

                // Foto del checklist
                Row(
                  children: [
                    Text(
                      'Foto del checklist?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                    const Spacer(),
                    if (checklistPhotoUploaded)
                      Text(
                        'Ver/editar',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4FA4B5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                checklistPhotoUploaded
                    ? FlowImagePreview(
                        fileName: 'Checklist.png',
                        tag: checklistPhotoTag,
                        onDeleteImage: () {
                          onChecklistPhotoUploadedChanged(false);
                          onChecklistPhotoTagChanged(null);
                        },
                        onDeleteTag: () => onChecklistPhotoTagChanged(null),
                        onTagAdded: (val) => onChecklistPhotoTagChanged(val),
                      )
                    : FlowUploadButton(
                        text: 'Tomar foto',
                        iconAsset: 'assets/CameraPlus.svg',
                        onTap: () => onChecklistPhotoUploadedChanged(true),
                      ),
                const SizedBox(height: 24),

                // Fito-checklist
                const FlowSectionLabel(label: 'Fito-checklist'),
                const SizedBox(height: 12),
                fitoChecklistUploaded
                    ? FlowImagePreview(
                        fileName: 'Fito-checklist.png',
                        tag: fitoChecklistTag,
                        onDeleteImage: () {
                          onFitoChecklistUploadedChanged(false);
                          onFitoChecklistTagChanged(null);
                        },
                        onDeleteTag: () => onFitoChecklistTagChanged(null),
                        onTagAdded: (val) => onFitoChecklistTagChanged(val),
                      )
                    : FlowUploadButton(
                        text: 'Tomar foto',
                        iconAsset: 'assets/CameraPlus.svg',
                        onTap: () => onFitoChecklistUploadedChanged(true),
                      ),
                const SizedBox(height: 24),

                // Link Google Maps
                FlowGoogleMapsSection(
                  label: 'Link Google Maps · Ubicación de entrega',
                  controller: mapsController,
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Finalizar',
        ),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required bool isUploaded,
    required String fileName,
    String? tag,
    required VoidCallback onUpload,
    required VoidCallback onDeleteImage,
    required VoidCallback onDeleteTag,
    required Function(String) onTagAdded,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowSectionLabel(label: title),
        const SizedBox(height: 12),
        isUploaded
            ? FlowImagePreview(
                fileName: fileName,
                tag: tag,
                onDeleteImage: onDeleteImage,
                onDeleteTag: onDeleteTag,
                onTagAdded: onTagAdded,
              )
            : FlowUploadButton(
                text: 'Tomar foto',
                iconAsset: 'assets/CameraPlus.svg',
                onTap: onUpload,
              ),
      ],
    );
  }
}
