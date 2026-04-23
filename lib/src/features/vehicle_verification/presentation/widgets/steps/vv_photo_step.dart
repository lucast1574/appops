import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

/// Step 3: Take a photo of the vehicle.
class VehicleVerificationPhotoStep extends StatelessWidget {
  final String title;
  final String label;
  final String photoLabel;
  final int taskId;
  final bool uploaded;
  final String? tag;
  final String? imagePath;
  final Function(bool, dynamic) onChanged;
  final Function(String?) onTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const VehicleVerificationPhotoStep({
    super.key,
    required this.title,
    required this.label,
    required this.photoLabel,
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
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                FlowPhotoInput(
                  label: label,
                  taskId: taskId,
                  photoLabel: photoLabel,
                  previewFileName: 'Vehiculo.png',
                  isUploaded: uploaded,
                  imagePath: imagePath,
                  tag: tag,
                  onChanged: onChanged,
                  onTagChanged: onTagChanged,
                ),
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
}
