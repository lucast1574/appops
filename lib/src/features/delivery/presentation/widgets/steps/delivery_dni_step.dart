import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class DeliveryDniStep extends StatelessWidget {
  final int taskId;
  final bool dniFrontPhotoUploaded;
  final String? dniFrontPhotoTag;
  final String? dniFrontPhotoPath;
  final Function(bool, dynamic) onDniFrontPhotoUploadedChanged;
  final Function(String?) onDniFrontPhotoTagChanged;

  final bool dniBackPhotoUploaded;
  final String? dniBackPhotoTag;
  final String? dniBackPhotoPath;
  final Function(bool, dynamic) onDniBackPhotoUploadedChanged;
  final Function(String?) onDniBackPhotoTagChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DeliveryDniStep({
    super.key,
    required this.taskId,
    required this.dniFrontPhotoUploaded, this.dniFrontPhotoTag, this.dniFrontPhotoPath,
    required this.onDniFrontPhotoUploadedChanged, required this.onDniFrontPhotoTagChanged,
    required this.dniBackPhotoUploaded, this.dniBackPhotoTag, this.dniBackPhotoPath,
    required this.onDniBackPhotoUploadedChanged, required this.onDniBackPhotoTagChanged,
    required this.onBack, required this.onContinue,
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
                Text('DNI del cliente (Opcional)', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 8),
                Text('Sube la foto del DNI del cliente si está disponible. Este paso no es obligatorio.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF666666))),
                const SizedBox(height: 24),
                FlowPhotoInput(
                  label: 'DNI Frontal',
                  taskId: taskId,
                  photoLabel: 'dni_frontal',
                  previewFileName: 'DNI-frontal.png',
                  isUploaded: dniFrontPhotoUploaded,
                  imagePath: dniFrontPhotoPath,
                  tag: dniFrontPhotoTag,
                  onChanged: onDniFrontPhotoUploadedChanged,
                  onTagChanged: onDniFrontPhotoTagChanged,
                ),
                const SizedBox(height: 16),
                FlowPhotoInput(
                  label: 'DNI Reverso',
                  taskId: taskId,
                  photoLabel: 'dni_reverso',
                  previewFileName: 'DNI-reverso.png',
                  isUploaded: dniBackPhotoUploaded,
                  imagePath: dniBackPhotoPath,
                  tag: dniBackPhotoTag,
                  onChanged: onDniBackPhotoUploadedChanged,
                  onTagChanged: onDniBackPhotoTagChanged,
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: onContinue,
          isContinueEnabled: true,
        ),
      ],
    );
  }
}
