import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class DeliveryConfirmationStep extends StatelessWidget {
  final int taskId;
  final bool? deliverVehicle;
  final bool clientPhotoUploaded; final String? clientPhotoTag; final String? clientPhotoPath;
  final bool checklistPhotoUploaded; final String? checklistPhotoTag; final String? checklistPhotoPath;
  final bool actaUploaded; final String? actaTag; final String? actaPhotoPath;
  final bool? checklist2Uploaded; final String? checklist2Tag; final String? checklist2PhotoPath;
  final Function(bool) onDeliverVehicleChanged;
  final Function(bool, dynamic) onClientPhotoUploadedChanged; final Function(String?) onClientPhotoTagChanged;
  final Function(bool, dynamic) onChecklistPhotoUploadedChanged; final Function(String?) onChecklistPhotoTagChanged;
  final Function(bool, dynamic) onActaUploadedChanged; final Function(String?) onActaTagChanged;
  final Function(bool, dynamic) onChecklist2UploadedChanged; final Function(String?) onChecklist2TagChanged;
  final TextEditingController effectiveTimeController;
  final VoidCallback onTimeChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DeliveryConfirmationStep({
    super.key,
    required this.taskId,
    this.deliverVehicle,
    required this.clientPhotoUploaded, this.clientPhotoTag, this.clientPhotoPath,
    required this.checklistPhotoUploaded, this.checklistPhotoTag, this.checklistPhotoPath,
    required this.actaUploaded, this.actaTag, this.actaPhotoPath,
    this.checklist2Uploaded, this.checklist2Tag, this.checklist2PhotoPath,
    required this.onDeliverVehicleChanged,
    required this.onClientPhotoUploadedChanged, required this.onClientPhotoTagChanged,
    required this.onChecklistPhotoUploadedChanged, required this.onChecklistPhotoTagChanged,
    required this.onActaUploadedChanged, required this.onActaTagChanged,
    required this.onChecklist2UploadedChanged, required this.onChecklist2TagChanged,
    required this.effectiveTimeController,
    required this.onTimeChanged,
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
                Text('Confirmación entrega', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                FlowYesNoQuestion(
                  question: '¿Se entregó vehículo?', 
                  currentValue: deliverVehicle, 
                  onChanged: (v) {}, // Locked in this step
                  isReversed: true,
                ),
                const SizedBox(height: 24),
                FlowPhotoInput(label: 'Foto de entrega (al cliente)', taskId: taskId, photoLabel: 'client_delivery_photo', previewFileName: 'Imagen-x122.png', isUploaded: clientPhotoUploaded, imagePath: clientPhotoPath, tag: clientPhotoTag, onChanged: onClientPhotoUploadedChanged, onTagChanged: onClientPhotoTagChanged),
                const SizedBox(height: 24),
                FlowPhotoInput(label: 'Foto del checklist*', taskId: taskId, photoLabel: 'checklist_photo', previewFileName: 'Checklist.png', isUploaded: checklistPhotoUploaded, imagePath: checklistPhotoPath, tag: checklistPhotoTag, onChanged: onChecklistPhotoUploadedChanged, onTagChanged: onChecklistPhotoTagChanged),
                const SizedBox(height: 24),
                FlowPhotoInput(label: 'Acta de entrega*', taskId: taskId, photoLabel: 'acta_photo', previewFileName: 'acta_de_entrega.png', isUploaded: actaUploaded, imagePath: actaPhotoPath, tag: actaTag, onChanged: onActaUploadedChanged, onTagChanged: onActaTagChanged),
                const SizedBox(height: 24),
                _label('Hora efectiva de entrega'), const SizedBox(height: 8),
                TextField(
                  controller: effectiveTimeController,
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF4FA4B5),
                              onPrimary: Colors.white,
                              onSurface: Color(0xFF002B4B),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      effectiveTimeController.text = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
                      onTimeChanged();
                    }
                  },
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Seleccionar hora',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                    suffixIcon: const Icon(Icons.access_time, color: Color(0xFF4FA4B5)),
                    filled: true,
                    fillColor: Colors.white,
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
          onContinue: onContinue,
          isContinueEnabled: clientPhotoUploaded && checklistPhotoUploaded && actaUploaded && effectiveTimeController.text.isNotEmpty,
        ),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));

}
