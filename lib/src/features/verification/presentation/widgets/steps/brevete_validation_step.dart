import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class BreveteValidationStep extends StatelessWidget {
  final int taskId;
  final bool isEcuador;

  final bool breveteFrontUploaded;
  final String? breveteFrontTag;
  final String? breveteFrontPath;
  final int? breveteFrontPhotoId;
  final bool breveteBackUploaded;
  final String? breveteBackTag;
  final String? breveteBackPath;
  final int? breveteBackPhotoId;

  final Function(bool, dynamic) onBreveteFrontUploadedChanged;
  final Function(String?) onBreveteFrontTagChanged;
  final Function(bool, dynamic) onBreveteBackUploadedChanged;
  final Function(String?) onBreveteBackTagChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const BreveteValidationStep({
    super.key,
    required this.taskId,
    this.isEcuador = false,
    required this.breveteFrontUploaded,
    this.breveteFrontTag,
    this.breveteFrontPath,
    this.breveteFrontPhotoId,
    required this.breveteBackUploaded,
    this.breveteBackTag,
    this.breveteBackPath,
    this.breveteBackPhotoId,
    required this.onBreveteFrontUploadedChanged,
    required this.onBreveteFrontTagChanged,
    required this.onBreveteBackUploadedChanged,
    required this.onBreveteBackTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool allUploaded = breveteFrontUploaded && breveteBackUploaded;
    final String docLabel = isEcuador ? 'Licencia de conducir' : 'Brevete';

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
                        Icons.drive_eta_outlined,
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
                            isEcuador ? 'Paso 2 de 3' : 'Paso 2 de 3',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF667085),
                            ),
                          ),
                          Text(
                            isEcuador ? 'Validación de Licencia de conducir' : 'Validación de Brevete',
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
                        label: '$docLabel Frontal',
                        taskId: taskId,
                        photoLabel: 'brevete_cliente',
                        previewFileName: 'Brevete-frontal.png',
                        isUploaded: breveteFrontUploaded,
                        imagePath: breveteFrontPath,
                        tag: breveteFrontTag,
                        photoId: breveteFrontPhotoId,
                        onChanged: onBreveteFrontUploadedChanged,
                        onTagChanged: onBreveteFrontTagChanged,
                      ),
                      const SizedBox(height: 16),
                      FlowPhotoInput(
                        label: '$docLabel Reverso',
                        taskId: taskId,
                        photoLabel: 'brevete_cliente_reverso',
                        previewFileName: 'Brevete-reverso.png',
                        isUploaded: breveteBackUploaded,
                        imagePath: breveteBackPath,
                        tag: breveteBackTag,
                        photoId: breveteBackPhotoId,
                        onChanged: onBreveteBackUploadedChanged,
                        onTagChanged: onBreveteBackTagChanged,
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
