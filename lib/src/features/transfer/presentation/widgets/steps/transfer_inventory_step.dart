import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class TransferInventoryStep extends StatelessWidget {
  final String title;
  final Map<String, List<String>> sections;
  final Map<String, Map<String, dynamic>> inventoryValues;
  final Function(String, Map<String, dynamic>) onInventoryChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final bool isContinueEnabled;

  const TransferInventoryStep({
    super.key,
    required this.title,
    required this.sections,
    required this.inventoryValues,
    required this.onInventoryChanged,
    required this.onBack,
    required this.onContinue,
    required this.isContinueEnabled,
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
                Center(child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 24),

                ...sections.entries.map((entry) => _section(entry.key, entry.value)),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: onContinue,
          isContinueEnabled: isContinueEnabled,
        ),
      ],
    );
  }

  Widget _section(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                ),
                _headerCell('No'),
                _headerCell('Si'),
              ],
            ),
            ...items.map((item) => _inventoryRow(item)),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _headerCell(String text) => Container(
    height: 48,
    alignment: Alignment.center,
    child: Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
  );

  TableRow _inventoryRow(String label) {
    final Map<String, dynamic> data = inventoryValues[label] ?? {'value': null, 'obs': ''};
    final bool? value = data['value'];

    // Conditional disabling logic
    bool isDisabled = false;
    bool isChild = false;
    if (label == 'Simple' || label == 'Con control') {
      isDisabled = inventoryValues['Segunda llave de contacto']?['value'] != true;
      isChild = true;
    } else if ([
      'Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas'
    ].contains(label)) {
      isDisabled = inventoryValues['Kit de emergencia:']?['value'] != true;
      isChild = true;
    } else if (['Cinturones', 'Bolsas de aire', 'Seguro de niños'].contains(label)) {
      isDisabled = inventoryValues['Seguridad']?['value'] != true;
      isChild = true;
    }

    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E9EB))),
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 16.0, 
            bottom: 16.0, 
            left: isChild ? 24.0 : 0.0 // Indentation for children
          ),
          child: Text(
            isChild ? '• $label' : label, 
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: isDisabled ? const Color(0xFFCCD4DB) : const Color(0xFF002B4B),
              fontWeight: isChild ? FontWeight.normal : FontWeight.w500,
            )
          ),
        ),
        // NO Column
        _valueCell(label, false, value == false, isDisabled),
        // YES Column
        _valueCell(label, true, value == true, isDisabled),
      ],
    );
  }

  Widget _valueCell(String label, bool cellValue, bool isActive, bool isDisabled) {
    return GestureDetector(
      onTap: isDisabled ? null : () {
        final current = inventoryValues[label] ?? {'value': null, 'obs': ''};
        onInventoryChanged(label, {...current, 'value': cellValue});
      },
      child: Container(
        height: 56,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDisabled 
            ? const Color(0xFFF8F9FA)
            : (isActive 
                ? (cellValue ? const Color(0xFF27A376) : const Color(0xFFFF7171)) 
                : Colors.white),
          border: Border.all(
            color: isDisabled 
              ? const Color(0xFFE5E9EB)
              : (isActive ? (cellValue ? const Color(0xFF27A376) : const Color(0xFFFF7171)) : const Color(0xFFCCD4DB))
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
