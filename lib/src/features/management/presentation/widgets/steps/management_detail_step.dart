import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class ManagementDetailStep extends StatelessWidget {
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final TextEditingController motivoController;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ManagementDetailStep({
    super.key,
    required this.startTimeController,
    required this.endTimeController,
    required this.motivoController,
    required this.onBack,
    required this.onContinue,
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
                Text(
                  'Detalle gestión',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader('Hora inicio'),
                          const SizedBox(height: 8),
                          _buildTimeField(context, startTimeController, '16:00'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader('Hora fin'),
                          const SizedBox(height: 8),
                          _buildTimeField(context, endTimeController, '18:00'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildHeader('Motivo'),
                const SizedBox(height: 8),
                TextField(
                  controller: motivoController,
                  maxLines: 5,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Describe el motivo o incidente...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
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
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  }

  Widget _buildTimeField(BuildContext context, TextEditingController controller, String hint) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
            ),
          ),
        ),
      ),
    );
  }
}
