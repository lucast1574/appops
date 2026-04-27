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
                Center(child: Text('Listado de entrega', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 8),
                _sectionSubtitle('Datos Generales'),
                const SizedBox(height: 16),

                _readOnlyField('Fecha', date ?? '---'),
                const SizedBox(height: 16),
                _readOnlyField('Placa', placa ?? '---'),
                const SizedBox(height: 16),
                _label('Nombre del cliente'),
                const SizedBox(height: 8),
                _readOnlyField('Cliente', clientName ?? '---'),
                const SizedBox(height: 16),

                _label('Marca'),
                const SizedBox(height: 8),
                _dropdown(value: selectedMarca, hint: 'Seleccionar marca', items: const ['Toyota', 'Hyundai', 'Kia', 'Nissan', 'Suzuki', 'Chevrolet'], onChanged: onMarcaChanged),
                const SizedBox(height: 16),
                _label('Modelo'),
                const SizedBox(height: 8),
                _dropdown(value: selectedModelo, hint: 'Seleccionar modelo', items: const ['Corolla', 'Yaris', 'Tucson', 'Sportage', 'Swift', 'Sail'], onChanged: onModeloChanged),
                const SizedBox(height: 16),
                _label('Color'),
                const SizedBox(height: 8),
                _dropdown(value: selectedColor, hint: 'Seleccionar color', items: const ['Blanco', 'Negro', 'Gris', 'Rojo', 'Azul', 'Plateado'], onChanged: onColorChanged),
                const SizedBox(height: 16),

                _label('Tipo de unidad'),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: FlowToggleOption(text: '0 km', isActive: unitType == '0 km', onTap: () => onUnitTypeChanged('0 km'))),
                  const SizedBox(width: 12),
                  Expanded(child: FlowToggleOption(text: 'Semi nuevo', isActive: unitType == 'Semi nuevo', onTap: () => onUnitTypeChanged('Semi nuevo'))),
                ]),
                const SizedBox(height: 16),

                _label('Kilometraje'),
                const SizedBox(height: 8),
                _textField(kmController, 'Ingresar kms actuales'),
                const SizedBox(height: 16),
                _label('Conversión'),
                const SizedBox(height: 8),
                _dropdown(value: selectedConversion, hint: 'Seleccionar tipo de conversión', items: const ['GLP', 'GNV', 'Ninguna'], onChanged: onConversionChanged),
                const SizedBox(height: 16),
                _label('Nivel de combustible'),
                const SizedBox(height: 8),
                _dropdown(value: selectedFuelLevel, hint: 'Seleccionar nivel de combustible', items: const ['Vacío', '1/4', '1/2', '3/4', 'Lleno'], onChanged: onFuelLevelChanged),
                const SizedBox(height: 16),

                FlowYesNoQuestion(
                  question: 'Prueba de bloqueo / desbloqueo efectiva',
                  currentValue: bloqueoDesbloqueo,
                  onChanged: onBloqueoDesbloqueoChanged,
                ),

                const SizedBox(height: 32),
                _divider(),

                // === SECTION: Entrega y Explicación de Documentación del Vehículo ===
                _sectionSubtitle('Entrega y Explicación de Documentación del Vehículo'),
                const SizedBox(height: 16),
                ..._buildCheckboxGroup([
                  'Prueba de bloqueo / desbloqueo efectiva',
                  'Pasaporte de garantía y mantenimiento',
                  'Placas de rodaje y tercera placa',
                  'Manual del conductor',
                  'Conversión GNV/GLP – Pasaporte de proveedor',
                  'Certificado de Revisión técnica complementaria vigente',
                ]),

                _divider(),

                // === SECTION: Instalaciones del Concesionario ===
                _sectionSubtitle('Instalaciones del Concesionario'),
                const SizedBox(height: 16),
                ..._buildCheckboxGroup([
                  'Explicación de talleres',
                  'Explicación para agendar cita',
                  'Explicación de activación GNV/GLP',
                ]),

                _divider(),

                // === SECTION: Inspección del Vehículo ===
                _sectionSubtitle('Inspección del Vehículo'),
                const SizedBox(height: 16),
                ..._buildCheckboxGroup([
                  'Limpieza y estado exterior del vehículo',
                  'Limpieza y estado interior del vehículo',
                  'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)',
                ]),

                _divider(),

                // === SECTION: Detalle de Inventario ===
                _sectionSubtitle('Detalle de Inventario'),
                const SizedBox(height: 16),
                ..._buildCheckboxGroup([
                  'Antena',
                  'Gata',
                  'Seguro de aros',
                  'Segunda llave de contacto',
                ]),
                _subItem('Simple'),
                _subItem('Con control'),
                ..._buildCheckboxGroup([
                  'Encendedor',
                  'Cenicero',
                  'Tapas de ruedas',
                  'Tapas de remolque',
                  'Dado de seguro de ruedas',
                  'Llanta de repuesto',
                  'Equipo multimedia',
                  'Pisos: Hule / Alfombra',
                ]),
                _checkboxItem('Kit de emergencia:'),
                _subItem('Extintor'),
                _subItem('Triángulo o cono de seguridad'),
                _subItem('Botiquín'),
                _subItem('Linterna'),
                _subItem('Cintas reflectivas'),

                _divider(),

                // === SECTION: Descripción General ===
                _sectionSubtitle('Descripción General'),
                const SizedBox(height: 16),
                ..._buildCheckboxGroup([
                  'Llave inteligente',
                  'Sistema antirrobo – alarma',
                  'Bloqueo y desbloqueo de puertas',
                  'Paneles de puertas y maletera – controles',
                ]),
                _checkboxItem('Seguridad'),
                _subItem('Cinturones'),
                _subItem('Bolsas de aire'),
                _subItem('Seguro de niños'),
                ..._buildCheckboxGroup([
                  'Ventanas y retrovisores',
                  'Aire acondicionado',
                  'Plumillas delanteras y traseras',
                  'Luz direccional delantera izquierda',
                  'Luz direccional delantera derecha',
                  'Luz trasera izquierda',
                  'Luz trasera derecha',
                  'Sensor de retroceso posterior',
                  'Reloj',
                  'Tapasoles',
                  'Indicadores del tablero de instrumentos',
                  'Indicadores del nivel de gasolina y aceite',
                  'Sistema de audio y auxiliares',
                  'Espejos exteriores',
                  'Faro delantero izquierdo',
                  'Faro delantero derecho',
                  'Luz de placa',
                  'Emblemas',
                  'Accionamiento capot',
                  'Accionamiento de tapa de depósito de combustible',
                  'Cámara de retroceso',
                  'Navegador y bluetooth',
                  'Porta documentos',
                ]),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(onBack: onBack, onContinue: onContinue, buttonText: 'Finalizar'),
      ],
    );
  }

  List<Widget> _buildCheckboxGroup(List<String> items) {
    return items.map((item) => _checkboxItem(item)).toList();
  }

  Widget _checkboxItem(String label) {
    final bool value = checklistValues[label] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => onChecklistChanged(label, !value),
        child: Row(
          children: [
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B)))),
            const SizedBox(width: 12),
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF4FA4B5) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: value ? const Color(0xFF4FA4B5) : const Color(0xFFCCD4DB), width: 1.5),
              ),
              child: value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _subItem(String label) {
    final bool value = checklistValues[label] ?? false;
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, bottom: 8.0),
      child: InkWell(
        onTap: () => onChecklistChanged(label, !value),
        child: Row(
          children: [
            Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B)))),
            const SizedBox(width: 12),
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF4FA4B5) : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: value ? const Color(0xFF4FA4B5) : const Color(0xFFCCD4DB), width: 1.5),
              ),
              child: value ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Container(height: 1, color: const Color(0xFFE5E9EB)),
  );

  Widget _sectionSubtitle(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF668093), fontStyle: FontStyle.italic));
  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnlyField(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label(label), const SizedBox(height: 8),
    Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: Text(value, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
  ]);

  Widget _dropdown({String? value, required String hint, required List<String> items, required Function(String?) onChanged}) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, hint: Text(hint, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF99AAB7).withValues(alpha: 0.5))), icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)), isExpanded: true, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged)),
  );
  Widget _textField(TextEditingController c, String hint) => TextField(controller: c, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), keyboardType: TextInputType.number, decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB)))));
}
