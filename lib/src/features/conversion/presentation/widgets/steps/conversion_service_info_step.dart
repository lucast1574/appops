import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

/// Step 2: "Información de servicio"
/// Shows placa + service type (read-only, from backoffice) + Google Maps button.
/// The operario cannot change the service type — it was set when the task was
/// created in the backoffice.
class ConversionServiceInfoStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionServiceInfoStep({
    super.key,
    required this.task,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final String placa = task['placa'] ?? '—';
    final metadata = task['metadata'] as Map<String, dynamic>? ?? {};
    final String serviceType = metadata['service_type'] ?? 'No especificado';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de servicio',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),

                // Placa (read-only)
                const FlowSectionLabel(label: 'Placa'),
                const SizedBox(height: 8),
                _readOnlyField(placa),

                const SizedBox(height: 24),

                // Tipo de servicio (read-only, set by backoffice)
                const FlowSectionLabel(label: 'Tipo de servicio'),
                const SizedBox(height: 12),
                _readOnlyField(serviceType),

                const SizedBox(height: 24),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }

  Widget _readOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: const Color(0xFF002B4B),
        ),
      ),
    );
  }
}
