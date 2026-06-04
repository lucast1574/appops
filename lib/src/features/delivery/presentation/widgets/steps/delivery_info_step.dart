import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class DeliveryInfoStep extends StatelessWidget {
  final int taskId;
  final TextEditingController clientNameController;
  final TextEditingController dniController;
  final bool? deliverVehicle;
  final Function(bool) onDeliverVehicleChanged;

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
  final bool isReversed;

  const DeliveryInfoStep({
    super.key,
    required this.taskId,
    required this.clientNameController, required this.dniController,
    this.deliverVehicle,
    required this.onDeliverVehicleChanged,
    required this.dniFrontPhotoUploaded, this.dniFrontPhotoTag, this.dniFrontPhotoPath,
    required this.onDniFrontPhotoUploadedChanged, required this.onDniFrontPhotoTagChanged,
    required this.dniBackPhotoUploaded, this.dniBackPhotoTag, this.dniBackPhotoPath,
    required this.onDniBackPhotoUploadedChanged, required this.onDniBackPhotoTagChanged,
    required this.onBack, required this.onContinue,
    this.isReversed = false,
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
                _readOnlyField(clientNameController.text.isEmpty ? '---' : clientNameController.text),
                const SizedBox(height: 16),
                _label('DNI del cliente'), const SizedBox(height: 8),
                _readOnlyField(dniController.text.isEmpty ? '---' : dniController.text),
                const SizedBox(height: 24),
                FlowYesNoQuestion(question: '¿Se entregó vehículo?', currentValue: deliverVehicle, onChanged: onDeliverVehicleChanged, isReversed: isReversed),
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
          isContinueEnabled: (deliverVehicle == false) || (deliverVehicle == true && dniFrontPhotoUploaded && dniBackPhotoUploaded),
        ),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnlyField(String text) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: Text(text, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))));
}
