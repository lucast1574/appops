import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class ConversionServiceInfoStep extends StatelessWidget {
  final String? selectedServiceType;
  final String? selectedLocation;
  final Function(String) onServiceTypeChanged;
  final Function(String?) onLocationChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionServiceInfoStep({
    super.key,
    this.selectedServiceType,
    this.selectedLocation,
    required this.onServiceTypeChanged,
    required this.onLocationChanged,
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
                  'Información de servicio',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                const FlowSectionLabel(label: 'Placa'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9EB)),
                  ),
                  child: Text(
                    'ABC 392',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const FlowSectionLabel(label: 'Tipo de servicio'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FlowToggleOption(
                        text: 'Revisión Técnica',
                        isActive: selectedServiceType == 'Revisión Técnica',
                        onTap: () => onServiceTypeChanged('Revisión Técnica'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FlowToggleOption(
                        text: 'GNV',
                        isActive: selectedServiceType == 'GNV',
                        onTap: () => onServiceTypeChanged('GNV'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const FlowSectionLabel(label: 'Ubicación'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E9EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLocation,
                      hint: Text(
                        'Seleccionar ubicación',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
                      isExpanded: true,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF002B4B),
                      ),
                      items: ['Lima Centro', 'Lima Norte', 'Lima Sur', 'Callao']
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: onLocationChanged,
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
          isContinueEnabled: selectedServiceType != null,
        ),
      ],
    );
  }
}
