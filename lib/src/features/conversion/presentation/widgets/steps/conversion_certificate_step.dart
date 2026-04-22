import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

/// Step 2: Upload the conversion certificate photo.
class ConversionCertificateStep extends StatelessWidget {
  final int taskId;
  final String? googleMapsLink;
  final bool uploaded;
  final String? tag;
  final String? imagePath;
  final Function(bool, dynamic) onChanged;
  final Function(String?) onTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionCertificateStep({
    super.key,
    required this.taskId,
    this.googleMapsLink,
    required this.uploaded,
    this.tag,
    this.imagePath,
    required this.onChanged,
    required this.onTagChanged,
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
                FlowPhotoInput(
                  label: 'Certificado de conversión *',
                  taskId: taskId,
                  photoLabel: 'certificado_conversion',
                  previewFileName: 'Certificado.png',
                  isUploaded: uploaded,
                  imagePath: imagePath,
                  tag: tag,
                  onChanged: onChanged,
                  onTagChanged: onTagChanged,
                ),
                const SizedBox(height: 24),
                _buildMapsSection(),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          isContinueEnabled: uploaded,
        ),
      ],
    );
  }


  Widget _buildMapsSection() {
    if (googleMapsLink == null || googleMapsLink!.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            googleMapsLink!.length > 50 ? '${googleMapsLink!.substring(0, 50)}...' : googleMapsLink!,
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () async {
              final uri = Uri.parse(googleMapsLink!);
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.map_outlined, size: 18),
            label: Text('Abrir Google Maps', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4FA4B5),
              side: const BorderSide(color: Color(0xFF4FA4B5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
