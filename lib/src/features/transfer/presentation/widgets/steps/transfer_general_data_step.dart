import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class TransferGeneralDataStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dateController;
  final TextEditingController placaController;
  final String? selectedMarca;
  final String? selectedModelo;
  final String? selectedColor;
  final TextEditingController kmController;
  final String? selectedConversion;
  final String? selectedFuel;
  final bool? lockTestValue;

  final List<String> marcas;
  final List<String> modelos;
  final List<String> colores;
  final List<String> conversiones;
  final List<String> fuelLevels;

  final Function(String?) onMarcaChanged;
  final Function(String?) onModeloChanged;
  final Function(String?) onColorChanged;
  final Function(String?) onConversionChanged;
  final Function(String?) onFuelChanged;
  final Function(bool) onLockTestChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferGeneralDataStep({
    super.key,
    required this.nameController,
    required this.dateController,
    required this.placaController,
    required this.selectedMarca,
    required this.selectedModelo,
    required this.selectedColor,
    required this.kmController,
    required this.selectedConversion,
    required this.selectedFuel,
    required this.lockTestValue,
    required this.marcas,
    required this.modelos,
    required this.colores,
    required this.conversiones,
    required this.fuelLevels,
    required this.onMarcaChanged,
    required this.onModeloChanged,
    required this.onColorChanged,
    required this.onConversionChanged,
    required this.onFuelChanged,
    required this.onLockTestChanged,
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
                Center(child: Text('Listado Inventario', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 24),
                Text('Datos Generales', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF668093))),
                const SizedBox(height: 16),

                _inputLabel('Nombre del cliente'),
                _textField(nameController, 'Ingresar nombre'),

                _inputLabel('Fecha'),
                _textField(dateController, 'Seleccionar fecha', readOnly: true, onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                }),

                _inputLabel('Placa'),
                _textField(placaController, 'Ingresar placa'),

                _inputLabel('Marca'),
                _dropdown(selectedMarca, 'Seleccionar marca', marcas, onMarcaChanged),

                _inputLabel('Modelo'),
                _dropdown(selectedModelo, 'Seleccionar modelo', modelos, onModeloChanged),

                _inputLabel('Color'),
                _dropdown(selectedColor, 'Seleccionar color', colores, onColorChanged),

                _inputLabel('Kilometraje'),
                _textField(kmController, 'Ingresar numero de kilometros', keyboardType: TextInputType.number),

                _inputLabel('Conversión'),
                _dropdown(selectedConversion, 'Seleccionar tipo de conversión', conversiones, onConversionChanged),

                _inputLabel('Nivel de combustible'),
                _dropdown(selectedFuel, 'Seleccionar nivel de combustible', fuelLevels, onFuelChanged),

                const SizedBox(height: 24),
                Text('Prueba de bloqueo / desbloqueo efectiva', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF002B4B))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _toggleButton('No', lockTestValue == false, () => onLockTestChanged(false))),
                    const SizedBox(width: 12),
                    Expanded(child: _toggleButton('Si', lockTestValue == true, () => onLockTestChanged(true))),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: () {
            if (nameController.text.isNotEmpty && 
                dateController.text.isNotEmpty && 
                placaController.text.isNotEmpty &&
                selectedMarca != null &&
                selectedModelo != null &&
                selectedColor != null &&
                kmController.text.isNotEmpty &&
                selectedConversion != null &&
                selectedFuel != null &&
                lockTestValue != null) {
              onContinue();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, complete todos los campos obligatorios.'), backgroundColor: Colors.red),
              );
            }
          }
        ),
      ],
    );
  }

  Widget _inputLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
    child: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
  );

  Widget _textField(TextEditingController controller, String hint, {bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType}) => TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    keyboardType: keyboardType,
    style: GoogleFonts.inter(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
    ),
  );

  Widget _dropdown(String? value, String hint, List<String> items, Function(String?) onChanged) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE5E9EB)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF99AAB7))),
        isExpanded: true,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 14)))).toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _toggleButton(String text, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? (text == 'Si' ? const Color(0xFFE0F2F1) : const Color(0xFFFFEBEE)) : Colors.white,
        border: Border.all(color: active ? (text == 'Si' ? const Color(0xFF00897B) : const Color(0xFFE53935)) : const Color(0xFFCCD4DB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: active ? (text == 'Si' ? const Color(0xFF00897B) : const Color(0xFFE53935)) : const Color(0xFF668093))),
    ),
  );
}
