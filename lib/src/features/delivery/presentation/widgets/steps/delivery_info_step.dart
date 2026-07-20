import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class DeliveryInfoStep extends StatelessWidget {
  final int taskId;
  final TextEditingController clientNameController;
  final TextEditingController dniController;
  final bool? deliverVehicle;
  final Function(bool) onDeliverVehicleChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;
  final bool isReversed;

  const DeliveryInfoStep({
    super.key,
    required this.taskId,
    required this.clientNameController, required this.dniController,
    this.deliverVehicle,
    required this.onDeliverVehicleChanged,
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
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: onContinue,
          isContinueEnabled: deliverVehicle != null,
        ),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnlyField(String text) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: Text(text, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))));
}
