import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class TransferInfoStep extends StatelessWidget {
  final int taskId;
  final String placa;
  final String originLocation;
  final String? originMapsLink;
  final String destinationLocation;
  final String? destinationMapsLink;
  final bool exitPhotoUploaded;
  final String? exitPhotoTag;
  final String? exitPhotoPath;
  final bool kmStartPhotoUploaded;
  final String? kmStartPhotoTag;
  final String? kmStartPhotoPath;
  final Function(bool, dynamic) onExitPhotoUploadedChanged;
  final Function(String?) onExitPhotoTagChanged;
  final Function(bool, dynamic) onKmStartPhotoUploadedChanged;
  final Function(String?) onKmStartPhotoTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferInfoStep({
    super.key,
    required this.taskId,
    required this.placa,
    required this.originLocation, this.originMapsLink,
    required this.destinationLocation, this.destinationMapsLink,
    required this.exitPhotoUploaded, this.exitPhotoTag, this.exitPhotoPath,
    required this.kmStartPhotoUploaded, this.kmStartPhotoTag, this.kmStartPhotoPath,
    required this.onExitPhotoUploadedChanged, required this.onExitPhotoTagChanged,
    required this.onKmStartPhotoUploadedChanged, required this.onKmStartPhotoTagChanged,
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
                Text('Información de traslado', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                _readOnlyField('Placa', placa),
                const SizedBox(height: 16),
                FlowAddressDisplay(label: 'Ubicación de inicio traslado', address: originLocation, mapsLink: originMapsLink),
                const SizedBox(height: 16),
                FlowAddressDisplay(label: 'Ubicación final de traslado', address: destinationLocation, mapsLink: destinationMapsLink),
                const SizedBox(height: 24),
                _uploadSection('Salida de vehículo*', taskId, 'exit_photo', 'salida.png', exitPhotoUploaded, exitPhotoPath, exitPhotoTag, onExitPhotoUploadedChanged, onExitPhotoTagChanged),
                const SizedBox(height: 24),
                _uploadSection('Kilometraje vehículo (inicio)*', taskId, 'km_start_photo', 'km.png', kmStartPhotoUploaded, kmStartPhotoPath, kmStartPhotoTag, onKmStartPhotoUploadedChanged, onKmStartPhotoTagChanged),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: onContinue,
          isContinueEnabled: exitPhotoUploaded && kmStartPhotoUploaded,
        ),
      ],
    );
  }

  Widget _readOnlyField(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
    const SizedBox(height: 8),
    Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8FBFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: Text(value, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B).withValues(alpha: 0.8)))),
  ]);

  Widget _uploadSection(
    String label, 
    int taskId,
    String photoLabel,
    String previewFileName,
    bool uploaded, 
    String? imagePath,
    String? tag, 
    Function(bool, dynamic) onUploadChanged, 
    Function(String?) onTagChanged
  ) => FlowPhotoInput(
    label: label,
    taskId: taskId,
    photoLabel: photoLabel,
    previewFileName: previewFileName,
    isUploaded: uploaded,
    imagePath: imagePath,
    tag: tag,
    onChanged: onUploadChanged,
    onTagChanged: onTagChanged,
  );
}
