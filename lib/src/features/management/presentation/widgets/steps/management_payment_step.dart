import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class ManagementPaymentStep extends StatelessWidget {
  final String? fineType;
  final String? selectedMunicipality;
  final List<String> districts;
  final Function(String?) onFineTypeChanged;
  final Function(String?) onSelectedMunicipalityChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ManagementPaymentStep({
    super.key,
    this.fineType,
    this.selectedMunicipality,
    this.districts = const [],
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
                const FlowSectionLabel(label: 'Tipo de multa'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: fineType,
                  hint: 'Seleccionar tipo de multa',
                  items: const ['Multa ATU', 'Multa Municipal', 'SAT', 'MTC', 'SUNARP'],
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
