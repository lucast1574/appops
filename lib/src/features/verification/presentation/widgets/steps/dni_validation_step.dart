import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class DniValidationStep extends StatelessWidget {
  final int taskId;
  final Map<String, dynamic> task;

  final bool dniFrontUploaded;
  final String? dniFrontTag;
  final String? dniFrontPath;
  final int? dniFrontPhotoId;
  final bool dniBackUploaded;
  final String? dniBackTag;
  final String? dniBackPath;
  final int? dniBackPhotoId;

  final Function(bool, dynamic) onDniFrontUploadedChanged;
  final Function(String?) onDniFrontTagChanged;
  final Function(bool, dynamic) onDniBackUploadedChanged;
  final Function(String?) onDniBackTagChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DniValidationStep({
    super.key,
    required this.taskId,
    required this.task,
    required this.dniFrontUploaded,
    this.dniFrontTag,
    this.dniFrontPath,
    this.dniFrontPhotoId,
    required this.dniBackUploaded,
    this.dniBackTag,
    this.dniBackPath,
    this.dniBackPhotoId,
    required this.onDniFrontUploadedChanged,
    required this.onDniFrontTagChanged,
    required this.onDniBackUploadedChanged,
    required this.onDniBackTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final clientName = task['client_name'] ?? 'Cliente';
    final clientDni = task['client_dni'] ?? '---';
    final bool allUploaded = dniFrontUploaded && dniBackUploaded;

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
                        Icons.badge_outlined,
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
                            'Paso 1 de 3',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF667085),
                            ),
                          ),
                          Text(
                            'Validación de DNI/INE',
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
                const SizedBox(height: 20),

                // Premium Client Details Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF002B4B),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Titular del documento',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF667085),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              clientName,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF002B4B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'DNI/INE: $clientDni',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF002B4B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upload card
                _buildValidationSection(
                  child: Column(
                    children: [
                      FlowPhotoInput(
                        label: 'DNI/INE Frontal',
                        taskId: taskId,
                        photoLabel: 'dni_cliente',
                        previewFileName: 'DNI-frontal.png',
                        isUploaded: dniFrontUploaded,
                        imagePath: dniFrontPath,
                        tag: dniFrontTag,
                        photoId: dniFrontPhotoId,
                        onChanged: onDniFrontUploadedChanged,
                        onTagChanged: onDniFrontTagChanged,
                      ),
                      const SizedBox(height: 16),
                      FlowPhotoInput(
                        label: 'DNI/INE Reverso',
                        taskId: taskId,
                        photoLabel: 'dni_cliente_reverso',
                        previewFileName: 'DNI-reverso.png',
                        isUploaded: dniBackUploaded,
                        imagePath: dniBackPath,
                        tag: dniBackTag,
                        photoId: dniBackPhotoId,
                        onChanged: onDniBackUploadedChanged,
                        onTagChanged: onDniBackTagChanged,
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
