import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';
import '../../../../../core/network/photo_upload_helper.dart';

/// Step 3: "Resultado conversión"
/// Upload certificate photo, checklist photo, creative photo, and a Google
/// Maps button for delivery location.
class ConversionResultStep extends StatelessWidget {
  final int taskId;
  final String? googleMapsLink;

  // Certificado de conversión
  final bool certificateUploaded;
  final String? certificateKey;
  final Function(bool, String?) onCertificateChanged;

  // Foto del checklist
  final bool checklistUploaded;
  final String? checklistKey;
  final Function(bool, String?) onChecklistChanged;

  // Foto creativa
  final bool creativeUploaded;
  final String? creativeKey;
  final Function(bool, String?) onCreativeChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionResultStep({
    super.key,
    required this.taskId,
    this.googleMapsLink,
    required this.certificateUploaded,
    this.certificateKey,
    required this.onCertificateChanged,
    required this.checklistUploaded,
    this.checklistKey,
    required this.onChecklistChanged,
    required this.creativeUploaded,
    this.creativeKey,
    required this.onCreativeChanged,
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
                _buildPhotoSection(
                  context: context,
                  label: 'Certificado de conversión',
                  isUploaded: certificateUploaded,
                  fileName: 'Certificado.png',
                  photoLabel: 'certificado_conversion',
                  onChanged: onCertificateChanged,
                ),
                const SizedBox(height: 24),

                // Foto del checklist
                _buildPhotoSection(
                  context: context,
                  label: 'Foto del checklist',
                  isUploaded: checklistUploaded,
                  fileName: 'Checklist.png',
                  photoLabel: 'checklist',
                  onChanged: onChecklistChanged,
                ),
                const SizedBox(height: 24),

                // Foto creativa
                _buildPhotoSection(
                  context: context,
                  label: 'Foto creativa',
                  isUploaded: creativeUploaded,
                  fileName: 'Creativa.png',
                  photoLabel: 'foto_creativa',
                  onChanged: onCreativeChanged,
                ),
                const SizedBox(height: 24),

                // Google Maps link (read-only button)
                if (googleMapsLink != null && googleMapsLink!.isNotEmpty) ...[
                  const FlowSectionLabel(label: 'Link Google Maps · Ubicación de entrega'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E9EB)),
                    ),
                    child: Text(
                      googleMapsLink!.length > 50
                          ? '${googleMapsLink!.substring(0, 50)}...'
                          : googleMapsLink!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF99AAB7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMaps(googleMapsLink!),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(
                        'Abrir Google Maps',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4FA4B5),
                        side: const BorderSide(color: Color(0xFF4FA4B5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Finalizar',
          isContinueEnabled: certificateUploaded && checklistUploaded && creativeUploaded,
        ),
      ],
    );
  }

  Widget _buildPhotoSection({
    required BuildContext context,
    required String label,
    required bool isUploaded,
    required String fileName,
    required String photoLabel,
    required Function(bool, String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowSectionLabel(label: label),
        const SizedBox(height: 12),
        isUploaded
            ? _uploadedPreview(fileName)
            : FlowUploadButton(
                text: 'Tomar foto',
                iconAsset: 'assets/CameraPlus.svg',
                onTap: () async {
                  final s3Key = await PhotoUploadHelper.pickAndUploadWithChoice(
                    taskId: taskId,
                    label: photoLabel,
                    context: context,
                  );
                  if (s3Key != null) {
                    onChanged(true, s3Key);
                  }
                },
              ),
      ],
    );
  }

  Widget _uploadedPreview(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC6F6D5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF23A26D), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF002B4B),
              ),
            ),
          ),
          const Icon(Icons.image_outlined, color: Color(0xFF99AAB7), size: 20),
        ],
      ),
    );
  }

  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
