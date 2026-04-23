import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class NotaryReceiveDocsStep extends StatelessWidget {
  final int taskId;
  final bool photoUploaded;
  final String? photoTag;
  final String? photoPath;
  final Function(bool, dynamic) onPhotoUploadedChanged;
  final Function(String?) onPhotoTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const NotaryReceiveDocsStep({
    super.key,
    required this.taskId,
    required this.photoUploaded,
    this.photoTag,
    this.photoPath,
    required this.onPhotoUploadedChanged,
    required this.onPhotoTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recibir documentos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                FlowPhotoInput(
                  label: 'Foto documentos recibidos:',
                  taskId: taskId,
                  photoLabel: 'notaria_recibe',
                  previewFileName: 'documentos.png',
                  isUploaded: photoUploaded,
                  imagePath: photoPath,
                  tag: photoTag,
                  onChanged: onPhotoUploadedChanged,
                  onTagChanged: onPhotoTagChanged,
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          isContinueEnabled: photoUploaded,
        ),
      ],
    );
  }
}
