import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class VehicleVerificationDetailStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool? isVisible;
  final TextEditingController observationsController;
  final Function(bool) onVisibleChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const VehicleVerificationDetailStep({
    super.key,
    required this.task,
    this.isVisible,
    required this.observationsController,
    required this.onVisibleChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final String scheduledDate = task['scheduled_date'] ?? '—';
    final String address = task['address'] ?? '—';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header('Fecha'),
                const SizedBox(height: 8),
                _readOnly(Text(scheduledDate, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 16),
                _header('Ubicación de verificación'),
                const SizedBox(height: 8),
                _readOnly(Text(address, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 24),
                Text('Detalle de verificación', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                FlowYesNoQuestion(
                  question: '¿El vehículo es visible y fácil de ubicar?',
                  currentValue: isVisible,
                  onChanged: onVisibleChanged,
                ),
                const SizedBox(height: 24),
                _header('Observaciones'),
                const SizedBox(height: 8),
                TextField(
                  controller: observationsController,
                  maxLines: 5,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: InputDecoration(
                    hintText: 'Escribe tus observaciones aquí...',
                    hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                    filled: true, fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Próximo',
          isContinueEnabled: isVisible != null,
        ),
      ],
    );
  }

  Widget _header(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnly(Widget child) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
    child: child,
  );
}
