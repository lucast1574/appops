import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'flow_step_navigation.dart';
import 'flow_form_widgets.dart';

class FlowRescheduleFormStep extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool? yesNoValue;
  final Function(bool)? onYesNoChanged;
  final String? selectedReason;
  final List<String> reasons;
  final Function(String?) onReasonChanged;
  final TextEditingController observationsController;
  final VoidCallback? onBack;
  final VoidCallback onFinalizar;
  final bool isReversed;
  final bool showBackButton;

  const FlowRescheduleFormStep({
    super.key,
    required this.title,
    this.subtitle,
    this.yesNoValue,
    this.onYesNoChanged,
    this.selectedReason,
    required this.reasons,
    required this.onReasonChanged,
    required this.observationsController,
    this.onBack,
    required this.onFinalizar,
    this.isReversed = true,
    this.showBackButton = true,
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
                Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(subtitle!, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF667085))),
                ],
                const SizedBox(height: 24),
                if (onYesNoChanged != null) ...[
                  FlowYesNoQuestion(
                    question: '¿Se entregó vehículo?',
                    currentValue: yesNoValue,
                    onChanged: onYesNoChanged!,
                    isReversed: isReversed,
                  ),
                  const SizedBox(height: 24),
                ],
                _label('Motivo'), const SizedBox(height: 8),
                _dropdown(
                  value: selectedReason,
                  hint: 'Seleccionar motivo',
                  items: reasons,
                  onChanged: onReasonChanged,
                ),
                const SizedBox(height: 24),
                _label('Observaciones'), const SizedBox(height: 8),
                TextField(
                  controller: observationsController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Agregar observaciones',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
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
          onBack: showBackButton ? onBack : null,
          onContinue: onFinalizar,
          buttonText: 'Finalizar',
          isContinueEnabled: selectedReason != null,
        ),
      ],
    );
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));

  Widget _dropdown({String? value, required String hint, required List<String> items, required Function(String?) onChanged}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E9EB)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF99AAB7).withValues(alpha: 0.5))),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
        isExpanded: true,
        style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
        items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
