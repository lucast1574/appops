import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class ManagementPaymentStep extends StatelessWidget {
  final String? fineType;
  final String? selectedMunicipality;
  final List<String> districts;
  final bool isEcuador;
  final Function(String?) onFineTypeChanged;
  final Function(String?) onSelectedMunicipalityChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ManagementPaymentStep({
    super.key,
    this.fineType,
    this.selectedMunicipality,
    this.districts = const [],
    this.isEcuador = false,
    required this.onFineTypeChanged,
    required this.onSelectedMunicipalityChanged,
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
                  'Información de pago',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                FlowSectionLabel(label: isEcuador ? 'Tipo de pago' : 'Tipo de multa'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: fineType,
                  hint: isEcuador ? 'Seleccionar tipo de pago' : 'Seleccionar tipo de multa',
                  items: isEcuador
                      ? const ['Multa ATU', 'Multa Municipal', 'SAT', 'MTC', 'SUNARP', 'Pago matriculación']
                      : const ['Multa ATU', 'Multa Municipal', 'SAT', 'MTC', 'SUNARP'],
                  onChanged: onFineTypeChanged,
                ),
                if (fineType == 'Multa Municipal') ...[
                  const SizedBox(height: 16),
                  const FlowSectionLabel(label: 'Definir municipalidad'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: districts.contains(selectedMunicipality) ? selectedMunicipality : null,
                    hint: 'Seleccionar municipio',
                    items: districts,
                    onChanged: onSelectedMunicipalityChanged,
                  ),
                ],
                if (isEcuador && fineType == 'Pago matriculación') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFCC02), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFFB07800), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El pago de matriculación se realiza en físico (no es una multa).',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A5200)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildDropdown({
    String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
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
}
