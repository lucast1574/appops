import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class TransferChecklistStep extends StatelessWidget {
  final String? placa;
  final String? date;
  final String? clientName;
  
  // Datos generales
  final String? selectedMarca;
  final String? selectedModelo;
  final String? selectedColor;
  final String? unitType;
  final TextEditingController kmController;
  final String? selectedConversion;
  final String? selectedFuelLevel;
  final bool? bloqueoDesbloqueo;

  // All checkbox sections — stored as Map<String, bool>
  final Map<String, bool> checklistValues;
  final Function(String, bool) onChecklistChanged;

  // Dropdowns
  final Function(String?) onMarcaChanged;
  final Function(String?) onModeloChanged;
  final Function(String?) onColorChanged;
  final Function(String) onUnitTypeChanged;
  final Function(String?) onConversionChanged;
  final Function(String?) onFuelLevelChanged;
  final Function(bool) onBloqueoDesbloqueoChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferChecklistStep({
    super.key,
    this.placa, this.date, this.clientName,
    this.selectedMarca, this.selectedModelo, this.selectedColor,
    this.unitType, required this.kmController,
    this.selectedConversion, this.selectedFuelLevel, this.bloqueoDesbloqueo,
    required this.checklistValues, required this.onChecklistChanged,
    required this.onMarcaChanged, required this.onModeloChanged, required this.onColorChanged,
    required this.onUnitTypeChanged,
    required this.onConversionChanged, required this.onFuelLevelChanged,
    required this.onBloqueoDesbloqueoChanged,
    required this.onBack, required this.onContinue,
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
                Center(child: Text('Listado Inventario', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 8),
                _sectionSubtitle('Datos Generales'),
                const SizedBox(height: 16),

                _readOnlyField('Nombre del cliente', clientName ?? '---'),
                const SizedBox(height: 16),
                _readOnlyField('Fecha', date ?? '---'),
                const SizedBox(height: 16),
                _readOnlyField('Placa', placa ?? '---'),
                const SizedBox(height: 16),
                _readOnlyField('Marca', selectedMarca ?? '---'),
                const SizedBox(height: 16),
                _readOnlyField('Modelo', selectedModelo ?? '---'),
                const SizedBox(height: 16),
                _readOnlyField('Color', selectedColor ?? '---'),
                const SizedBox(height: 16),

                _label('Kilometraje'),
                const SizedBox(height: 8),
                _textField(kmController, 'Ingresar kms actuales'),
                const SizedBox(height: 16),
                _label('Conversión'),
                const SizedBox(height: 8),
                _dropdown(value: selectedConversion, hint: 'Seleccionar tipo de conversión', items: const ['GNV', 'Revisión técnica'], onChanged: onConversionChanged),
                const SizedBox(height: 16),
                _label('Nivel de combustible'),
                const SizedBox(height: 8),
                _dropdown(value: selectedFuelLevel, hint: 'Seleccionar nivel de combustible', items: const ['Vacío', '1/4', '1/2', '3/4', 'Lleno'], onChanged: onFuelLevelChanged),
                const SizedBox(height: 16),

                FlowYesNoQuestion(
                  question: 'Prueba de bloqueo / desbloqueo efectiva',
                  currentValue: bloqueoDesbloqueo,
                  onChanged: onBloqueoDesbloqueoChanged,
                  isReversed: true,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Continuar',
          isContinueEnabled: kmController.text.isNotEmpty &&
              selectedConversion != null &&
              selectedFuelLevel != null &&
              bloqueoDesbloqueo != null,
        ),
      ],
    );
  }

  Widget _sectionSubtitle(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF668093), fontStyle: FontStyle.italic));
  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnlyField(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label(label), const SizedBox(height: 8),
    Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: Text(value, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
  ]);

  Widget _dropdown({String? value, required String hint, required List<String> items, required Function(String?) onChanged}) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: items.contains(value) ? value : null, hint: Text(hint, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF99AAB7).withValues(alpha: 0.5))), icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)), isExpanded: true, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged)),
  );
  Widget _textField(TextEditingController c, String hint) => TextField(controller: c, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB)))));
}
