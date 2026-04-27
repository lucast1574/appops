import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class DeliveryInfoStep extends StatelessWidget {
  final TextEditingController clientNameController;
  final TextEditingController dniController;
  final bool? deliverVehicle;
  final bool dniPhotoUploaded;
  final String? dniPhotoTag;
  final Function(bool) onDeliverVehicleChanged;
  final Function(bool) onDniPhotoUploadedChanged;
  final Function(String?) onDniPhotoTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DeliveryInfoStep({
    super.key,
    required this.clientNameController, required this.dniController,
    this.deliverVehicle,
    required this.dniPhotoUploaded, this.dniPhotoTag,
    required this.onDeliverVehicleChanged,
    required this.onDniPhotoUploadedChanged, required this.onDniPhotoTagChanged,
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
                Text('Información de la entrega', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                _label('Nombre del cliente'), const SizedBox(height: 8),
                _textField(clientNameController, 'Juan Cruz'),
                const SizedBox(height: 16),
                _label('DNI del cliente'), const SizedBox(height: 8),
                _textField(dniController, '1231231231'),
                const SizedBox(height: 24),
                FlowYesNoQuestion(question: '¿Le entrega vehículo?', currentValue: deliverVehicle, onChanged: onDeliverVehicleChanged),
                const SizedBox(height: 24),
                Row(children: [
                  const FlowSectionLabel(label: 'DNI'),
                  const Spacer(),
                  if (!dniPhotoUploaded) Text('Sin imagen', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7))),
                ]),
                const SizedBox(height: 12),
                dniPhotoUploaded
                    ? FlowImagePreview(fileName: 'Imagen-x122.png', tag: dniPhotoTag, onDeleteImage: () { onDniPhotoUploadedChanged(false); onDniPhotoTagChanged(null); }, onDeleteTag: () => onDniPhotoTagChanged(null), onTagAdded: (val) => onDniPhotoTagChanged(val))
                    : Row(children: [
                        Expanded(child: FlowUploadButton(text: 'Tomar foto', iconAsset: 'assets/CameraPlus.svg', onTap: () => onDniPhotoUploadedChanged(true))),
                        const SizedBox(width: 12),
                        Expanded(child: GestureDetector(
                          onTap: () => onDniPhotoUploadedChanged(true),
                          child: Container(height: 88, decoration: BoxDecoration(color: const Color(0xFFE3F0F3), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFB9DBE1).withValues(alpha: 0.5))),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.upload_file, size: 32, color: Color(0xFF002B4B)),
                              const SizedBox(height: 8),
                              Text('Subir archivo', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF002B4B))),
                            ]),
                          ),
                        )),
                      ]),
              ],
            ),
          ),
        ),
        FlowStepNavigation(onBack: onBack, onContinue: onContinue),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _textField(TextEditingController c, String hint) => TextField(controller: c, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF002B4B)))));
}
