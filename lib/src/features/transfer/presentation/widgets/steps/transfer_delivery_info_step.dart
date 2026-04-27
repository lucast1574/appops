import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class TransferDeliveryInfoStep extends StatelessWidget {
  final int taskId;
  final String placa;
  final String originLocation;
  final String destinationLocation;
  final bool deliveryPhotoUploaded;
  final String? deliveryPhotoTag;
  final String? deliveryPhotoPath;
  final bool kmEndPhotoUploaded;
  final String? kmEndPhotoTag;
  final String? kmEndPhotoPath;
  final TextEditingController deliveryNameController;
  final Function(bool, dynamic) onDeliveryPhotoUploadedChanged;
  final Function(String?) onDeliveryPhotoTagChanged;
  final Function(bool, dynamic) onKmEndPhotoUploadedChanged;
  final Function(String?) onKmEndPhotoTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferDeliveryInfoStep({
    super.key,
    required this.taskId,
    required this.placa, required this.originLocation, required this.destinationLocation,
    required this.deliveryPhotoUploaded, this.deliveryPhotoTag, this.deliveryPhotoPath,
    required this.kmEndPhotoUploaded, this.kmEndPhotoTag, this.kmEndPhotoPath,
    required this.deliveryNameController,
    required this.onDeliveryPhotoUploadedChanged, required this.onDeliveryPhotoTagChanged,
    required this.onKmEndPhotoUploadedChanged, required this.onKmEndPhotoTagChanged,
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
                Text('Información de entrega', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                _readOnlyField('Placa', placa),
                const SizedBox(height: 16),
                _readOnlyField('Ubicación de inicio traslado', originLocation),
                const SizedBox(height: 16),
                _readOnlyField('Ubicación final de traslado', destinationLocation),
                const SizedBox(height: 24),
                _uploadSection('Foto vehículo punto de entrega*', taskId, 'delivery_photo', 'entrega.png', deliveryPhotoUploaded, deliveryPhotoPath, deliveryPhotoTag, onDeliveryPhotoUploadedChanged, onDeliveryPhotoTagChanged),
                const SizedBox(height: 24),
                _uploadSection('Kilometraje vehículo (final)*', taskId, 'km_end_photo', 'km.png', kmEndPhotoUploaded, kmEndPhotoPath, kmEndPhotoTag, onKmEndPhotoUploadedChanged, onKmEndPhotoTagChanged),
                const SizedBox(height: 24),
                Text('Nombre a quien entrega', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
                const SizedBox(height: 8),
                TextField(
                  controller: deliveryNameController,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Juan Rodriguez', hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7)),
                    filled: true, fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF002B4B))),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: () {
            if (deliveryPhotoUploaded && kmEndPhotoUploaded && deliveryNameController.text.trim().isNotEmpty) {
              onContinue();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, complete todos los campos y fotos obligatorias.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        ),
      ],
    );
  }

  Widget _readOnlyField(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
    const SizedBox(height: 8),
    Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: Text(value, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
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
