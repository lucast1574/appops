import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class DocumentValidationStep extends StatelessWidget {
  final bool dniUploaded;
  final String? dniTag;
  final bool breveteUploaded;
  final String? breveteTag;
  final bool reciboUploaded;
  final String? reciboTag;
  final Function(bool) onDniUploadedChanged;
  final Function(String?) onDniTagChanged;
  final Function(bool) onBreveteUploadedChanged;
  final Function(String?) onBreveteTagChanged;
  final Function(bool) onReciboUploadedChanged;
  final Function(String?) onReciboTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DocumentValidationStep({
    super.key,
    required this.dniUploaded,
    this.dniTag,
    required this.breveteUploaded,
    this.breveteTag,
    required this.reciboUploaded,
    this.reciboTag,
    required this.onDniUploadedChanged,
    required this.onDniTagChanged,
    required this.onBreveteUploadedChanged,
    required this.onBreveteTagChanged,
    required this.onReciboUploadedChanged,
    required this.onReciboTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    bool allUploaded = dniUploaded && breveteUploaded && reciboUploaded;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validación de documentos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                _buildValidationSection(
                  'DNI',
                  isUploaded: dniUploaded,
                  child: dniUploaded
                      ? FlowImagePreview(
                          fileName: 'Imagen-x122.png',
                          tag: dniTag,
                          onDeleteImage: () {
                            onDniUploadedChanged(false);
                            onDniTagChanged(null);
                          },
                          onDeleteTag: () => onDniTagChanged(null),
                          onTagAdded: (val) => onDniTagChanged(val),
                        )
                      : FlowUploadButton(
                          text: 'Tomar foto',
                          iconAsset: 'assets/CameraPlus.svg',
                          onTap: () => onDniUploadedChanged(true),
                        ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  'Brevete',
                  isUploaded: breveteUploaded,
                  child: breveteUploaded
                      ? FlowImagePreview(
                          fileName: 'Brevete-scan.png',
                          tag: breveteTag,
                          onDeleteImage: () {
                            onBreveteUploadedChanged(false);
                            onBreveteTagChanged(null);
                          },
                          onDeleteTag: () => onBreveteTagChanged(null),
                          onTagAdded: (val) => onBreveteTagChanged(val),
                        )
                      : FlowUploadButton(
                          text: 'Tomar foto',
                          iconAsset: 'assets/CameraPlus.svg',
                          onTap: () => onBreveteUploadedChanged(true),
                        ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  'Recibo de servicios',
                  isUploaded: reciboUploaded,
                  child: reciboUploaded
                      ? FlowImagePreview(
                          fileName: 'Recibo-digital.png',
                          tag: reciboTag,
                          onDeleteImage: () {
                            onReciboUploadedChanged(false);
                            onReciboTagChanged(null);
                          },
                          onDeleteTag: () => onReciboTagChanged(null),
                          onTagAdded: (val) => onReciboTagChanged(val),
                        )
                      : FlowUploadButton(
                          text: 'Tomar foto',
                          iconAsset: 'assets/CameraPlus.svg',
                          onTap: () => onReciboUploadedChanged(true),
                        ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          isContinueEnabled: allUploaded,
        ),
      ],
    );
  }

  Widget _buildValidationSection(String title, {required Widget child, bool isUploaded = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
