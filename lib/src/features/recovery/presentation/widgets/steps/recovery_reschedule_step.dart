import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class RecoveryRescheduleStep extends StatelessWidget {
  final int taskId;
  final bool isPhotoUploaded;
  final String? photoPath;
  final String? photoTag;
  final Function(bool, dynamic) onPhotoChanged;
  final Function(String?) onPhotoTagChanged;
  final String? selectedReason;
  final List<String> reasons;
  final Function(String?) onReasonChanged;
  final TextEditingController observationsController;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryRescheduleStep({
    super.key,
    required this.taskId,
    required this.isPhotoUploaded,
    this.photoPath,
    this.photoTag,
    required this.onPhotoChanged,
    required this.onPhotoTagChanged,
    this.selectedReason,
    required this.reasons,
    required this.onReasonChanged,
    required this.observationsController,
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
                  'Recupero no efectuado',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),

                // Photo Input
                FlowPhotoInput(
                  label: 'Foto*',
                  taskId: taskId,
                  photoLabel: 'reschedule_photo',
                  previewFileName: 'foto_reschedule.png',
                  isUploaded: isPhotoUploaded,
                  imagePath: photoPath,
                  tag: photoTag,
                  onChanged: onPhotoChanged,
                  onTagChanged: onPhotoTagChanged,
                ),
                const SizedBox(height: 24),

                // Reason dropdown
                _label('Motivo'),
                const SizedBox(height: 8),
                _dropdown(
                  value: selectedReason,
                  hint: 'Seleccionar motivo',
                  items: reasons,
                  onChanged: onReasonChanged,
                ),
                const SizedBox(height: 24),

                // Observations textarea
                _label('Observaciones'),
                const SizedBox(height: 8),
                TextField(
                  controller: observationsController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Agregar observaciones',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
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
          buttonText: 'Finalizar',
          isContinueEnabled: isPhotoUploaded && selectedReason != null,
        ),
      ],
    );
  }

  Widget _label(String t) => Text(
        t,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      );

  Widget _dropdown({
    String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) =>
      Container(
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
            hint: Text(
              hint,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
            isExpanded: true,
            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
