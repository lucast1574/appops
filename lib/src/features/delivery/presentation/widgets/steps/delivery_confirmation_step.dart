import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class DeliveryConfirmationStep extends StatelessWidget {
  final bool? deliverVehicle;
  final bool clientPhotoUploaded; final String? clientPhotoTag;
  final bool checklistPhotoUploaded; final String? checklistPhotoTag;
  final bool actaUploaded; final String? actaTag;
  final TextEditingController deliveryTimeController;
  final bool? checklist2Uploaded; final String? checklist2Tag;
  final Function(bool) onDeliverVehicleChanged;
  final Function(bool) onClientPhotoUploadedChanged; final Function(String?) onClientPhotoTagChanged;
  final Function(bool) onChecklistPhotoUploadedChanged; final Function(String?) onChecklistPhotoTagChanged;
  final Function(bool) onActaUploadedChanged; final Function(String?) onActaTagChanged;
  final Function(bool) onChecklist2UploadedChanged; final Function(String?) onChecklist2TagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DeliveryConfirmationStep({
    super.key,
    this.deliverVehicle,
    required this.clientPhotoUploaded, this.clientPhotoTag,
    required this.checklistPhotoUploaded, this.checklistPhotoTag,
    required this.actaUploaded, this.actaTag,
    required this.deliveryTimeController,
    this.checklist2Uploaded, this.checklist2Tag,
    required this.onDeliverVehicleChanged,
    required this.onClientPhotoUploadedChanged, required this.onClientPhotoTagChanged,
    required this.onChecklistPhotoUploadedChanged, required this.onChecklistPhotoTagChanged,
    required this.onActaUploadedChanged, required this.onActaTagChanged,
    required this.onChecklist2UploadedChanged, required this.onChecklist2TagChanged,
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
                FlowYesNoQuestion(question: '¿Le entrega vehículo?', currentValue: deliverVehicle, onChanged: onDeliverVehicleChanged),
                const SizedBox(height: 24),
                _uploadSection('Foto de entrega (al cliente)*', clientPhotoUploaded, 'Imagen-x122.png', clientPhotoTag, onClientPhotoUploadedChanged, onClientPhotoTagChanged),
                const SizedBox(height: 24),
                _uploadSection('Foto del checklist*', checklistPhotoUploaded, 'Checklist.png', checklistPhotoTag, onChecklistPhotoUploadedChanged, onChecklistPhotoTagChanged),
                const SizedBox(height: 24),
                _uploadSection('Acta de entrega*', actaUploaded, 'acta_de_entrega.png', actaTag, onActaUploadedChanged, onActaTagChanged),
                const SizedBox(height: 24),
                _label('Hora efectiva de entrega'), const SizedBox(height: 8),
                _readOnly(Text(deliveryTimeController.text.isEmpty ? '---' : deliveryTimeController.text, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 24),
                _uploadSection('Foto checklist*', checklist2Uploaded ?? false, 'checklist2.png', checklist2Tag, onChecklist2UploadedChanged, onChecklist2TagChanged),
              ],
            ),
          ),
        ),
        FlowStepNavigation(onBack: onBack, onContinue: onContinue),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnly(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: child);

  Widget _uploadSection(String label, bool uploaded, String fileName, String? tag, Function(bool) onUploadChanged, Function(String?) onTagChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      FlowSectionLabel(label: label), const Spacer(),
      if (!uploaded) Text('Sin imagen', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7))),
    ]),
    const SizedBox(height: 12),
    uploaded
        ? FlowImagePreview(fileName: fileName, tag: tag, onDeleteImage: () { onUploadChanged(false); onTagChanged(null); }, onDeleteTag: () => onTagChanged(null), onTagAdded: (val) => onTagChanged(val))
        : FlowUploadButton(text: 'Tomar foto', iconAsset: 'assets/CameraPlus.svg', onTap: () => onUploadChanged(true)),
  ]);
}
