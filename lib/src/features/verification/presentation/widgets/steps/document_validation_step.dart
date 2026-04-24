import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class DocumentValidationStep extends StatelessWidget {
  final int taskId;
  final bool dniUploaded;
  final String? dniTag;
  final String? dniPath;
  final bool breveteUploaded;
  final String? breveteTag;
  final String? brevetePath;
  final bool reciboUploaded;
  final String? reciboTag;
  final String? reciboPath;
  final Function(bool, dynamic) onDniUploadedChanged;
  final Function(String?) onDniTagChanged;
  final Function(bool, dynamic) onBreveteUploadedChanged;
  final Function(String?) onBreveteTagChanged;
  final Function(bool, dynamic) onReciboUploadedChanged;
  final Function(String?) onReciboTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DocumentValidationStep({
    super.key,
    required this.taskId,
    required this.dniUploaded,
    this.dniTag,
    this.dniPath,
    required this.breveteUploaded,
    this.breveteTag,
    this.brevetePath,
    required this.reciboUploaded,
    this.reciboTag,
    this.reciboPath,
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
                  child: FlowPhotoInput(
                    label: 'DNI/INE',
                    taskId: taskId,
                    photoLabel: 'dni_cliente',
                    previewFileName: 'Imagen-x122.png',
                    isUploaded: dniUploaded,
                    imagePath: dniPath,
                    tag: dniTag,
                    onChanged: onDniUploadedChanged,
                    onTagChanged: onDniTagChanged,
                  ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  child: FlowPhotoInput(
                    label: 'Brevete',
                    taskId: taskId,
                    photoLabel: 'brevete_cliente',
                    previewFileName: 'Brevete-scan.png',
                    isUploaded: breveteUploaded,
                    imagePath: brevetePath,
                    tag: breveteTag,
                    onChanged: onBreveteUploadedChanged,
                    onTagChanged: onBreveteTagChanged,
                  ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  child: FlowPhotoInput(
                    label: 'Recibo de servicios',
                    taskId: taskId,
                    photoLabel: 'recibo_servicios',
                    previewFileName: 'Recibo-digital.png',
                    isUploaded: reciboUploaded,
                    imagePath: reciboPath,
                    tag: reciboTag,
                    onChanged: onReciboUploadedChanged,
                    onTagChanged: onReciboTagChanged,
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
