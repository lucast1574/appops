import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';
import '../../../../../core/network/photo_upload_helper.dart';

/// Step 3: Take a photo of the vehicle.
class VehicleVerificationPhotoStep extends StatelessWidget {
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
                  'Foto del vehículo',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                const FlowSectionLabel(label: 'Foto del vehículo *'),
                const SizedBox(height: 12),
                uploaded
                    ? FlowImagePreview(
                        fileName: 'Vehiculo.png',
                        imagePath: imagePath,
                        tag: tag,
                        onDeleteImage: () => onChanged(false, null),
                        onDeleteTag: () => onTagChanged(null),
                        onTagAdded: (val) => onTagChanged(val),
                      )
                    : FlowUploadButton(
                        text: 'Tomar foto',
                        iconAsset: 'assets/CameraPlus.svg',
                        onTap: () async {
                          final result = await PhotoUploadHelper.pickAndUploadWithChoice(
                            taskId: taskId,
                            label: 'foto_vehiculo',
                            context: context,
                          );
                          if (result != null) onChanged(true, result);
                        },
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
