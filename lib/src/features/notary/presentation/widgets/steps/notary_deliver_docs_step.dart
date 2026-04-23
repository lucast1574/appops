import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class NotaryDeliverDocsStep extends StatelessWidget {
  final int taskId;
  final bool photoUploaded;
  final String? photoTag;
  final String? photoPath;
  final TextEditingController deliveryNameController;
  final Function(bool, dynamic) onPhotoUploadedChanged;
  final Function(String?) onPhotoTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const NotaryDeliverDocsStep({
    super.key,
    required this.taskId,
    required this.photoUploaded,
    this.photoTag,
    this.photoPath,
    required this.deliveryNameController,
    required this.onPhotoUploadedChanged,
    required this.onPhotoTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    bool isContinueEnabled = photoUploaded && deliveryNameController.text.trim().isNotEmpty;

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
                  'Entrega de documentos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                FlowPhotoInput(
                  label: 'Foto persona recibiendo documento:',
                  taskId: taskId,
                  photoLabel: 'notaria_entrega',
                  previewFileName: 'recibe.png',
                  isUploaded: photoUploaded,
                  imagePath: photoPath,
                  tag: photoTag,
                  onChanged: onPhotoUploadedChanged,
                  onTagChanged: onPhotoTagChanged,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nombre de quien recibe',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deliveryNameController,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF002B4B),
                  ),
                  onChanged: (_) {
                    // This is a stateless widget, but the parent might rebuild on other changes.
                    // For immediate button state, parent should handle onChanged.
                  },
                  decoration: InputDecoration(
                    hintText: 'Juan Ramos',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF002B4B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Finalizar',
          isContinueEnabled: isContinueEnabled,
        ),
      ],
    );
  }
}
