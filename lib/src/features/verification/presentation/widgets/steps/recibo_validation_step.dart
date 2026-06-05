import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class ReciboValidationStep extends StatelessWidget {
  final int taskId;

  final bool reciboFrontUploaded;
  final String? reciboFrontTag;
  final String? reciboFrontPath;
  final int? reciboFrontPhotoId;
  final bool reciboBackUploaded;
  final String? reciboBackTag;
  final String? reciboBackPath;
  final int? reciboBackPhotoId;

  final Function(bool, dynamic) onReciboFrontUploadedChanged;
  final Function(String?) onReciboFrontTagChanged;
  final Function(bool, dynamic) onReciboBackUploadedChanged;
  final Function(String?) onReciboBackTagChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ReciboValidationStep({
    super.key,
    required this.taskId,
    required this.reciboFrontUploaded,
    this.reciboFrontTag,
    this.reciboFrontPath,
    this.reciboFrontPhotoId,
    required this.reciboBackUploaded,
    this.reciboBackTag,
    this.reciboBackPath,
    this.reciboBackPhotoId,
    required this.onReciboFrontUploadedChanged,
    required this.onReciboFrontTagChanged,
    required this.onReciboBackUploadedChanged,
    required this.onReciboBackTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool allUploaded = reciboFrontUploaded && reciboBackUploaded;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator & Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FA4B5).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xFF4FA4B5),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paso 3 de 3',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF667085),
                            ),
                          ),
                          Text(
                            'Validación de Recibo de servicios',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Upload card
                _buildValidationSection(
                  child: Column(
                    children: [
                      FlowPhotoInput(
                        label: 'Recibo de servicios Frontal',
                        taskId: taskId,
                        photoLabel: 'recibo_servicios',
                        previewFileName: 'Recibo-frontal.png',
                        isUploaded: reciboFrontUploaded,
                        imagePath: reciboFrontPath,
                        tag: reciboFrontTag,
                        photoId: reciboFrontPhotoId,
                        onChanged: onReciboFrontUploadedChanged,
                        onTagChanged: onReciboFrontTagChanged,
                      ),
                      const SizedBox(height: 16),
                      FlowPhotoInput(
                        label: 'Recibo de servicios Reverso',
                        taskId: taskId,
                        photoLabel: 'recibo_servicios_reverso',
                        previewFileName: 'Recibo-reverso.png',
                        isUploaded: reciboBackUploaded,
                        imagePath: reciboBackPath,
                        tag: reciboBackTag,
                        photoId: reciboBackPhotoId,
                        onChanged: onReciboBackUploadedChanged,
                        onTagChanged: onReciboBackTagChanged,
                      ),
                    ],
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

  Widget _buildValidationSection({required Widget child}) {
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
      child: child,
    );
  }
}
