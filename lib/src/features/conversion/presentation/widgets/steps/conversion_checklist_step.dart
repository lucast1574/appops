import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

/// Step 3: Upload the checklist photo.
class ConversionChecklistStep extends StatelessWidget {
  final int taskId;
  final bool uploaded;
  final String? tag;
  final String? imagePath;
  final Function(bool, dynamic) onChanged;
  final Function(String?) onTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionChecklistStep({
    super.key,
    required this.taskId,
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
                  label: 'Foto del checklist *',
                  taskId: taskId,
                  photoLabel: 'checklist',
                  previewFileName: 'Checklist.png',
                  isUploaded: uploaded,
                  imagePath: imagePath,
                  tag: tag,
                  onChanged: onChanged,
                  onTagChanged: onTagChanged,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Finalizar',
          isContinueEnabled: uploaded,
        ),
      ],
    );
  }
}
