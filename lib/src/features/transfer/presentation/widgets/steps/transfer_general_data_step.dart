import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class TransferGeneralDataStep extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController dateController;
  final TextEditingController placaController;
  final TextEditingController marcaController;
  final TextEditingController modeloController;
  final TextEditingController colorController;
  final TextEditingController kmController;
  final String? selectedConversion;
  final String? selectedFuel;
  final bool? lockTestValue;

  final List<String> conversiones;
  final List<String> fuelLevels;

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
    required this.marcaController,
    required this.modeloController,
    required this.colorController,
    required this.kmController,
    required this.selectedConversion,
    required this.selectedFuel,
    required this.lockTestValue,
    required this.conversiones,
    required this.fuelLevels,
    required this.onConversionChanged,
    required this.onFuelChanged,
    required this.onLockTestChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<TransferGeneralDataStep> createState() => _TransferGeneralDataStepState();
}

class _TransferGeneralDataStepState extends State<TransferGeneralDataStep> {
  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_rebuild);
    widget.dateController.addListener(_rebuild);
    widget.placaController.addListener(_rebuild);
    widget.marcaController.addListener(_rebuild);
    widget.modeloController.addListener(_rebuild);
    widget.colorController.addListener(_rebuild);
    widget.kmController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_rebuild);
    widget.dateController.removeListener(_rebuild);
    widget.placaController.removeListener(_rebuild);
    widget.marcaController.removeListener(_rebuild);
    widget.modeloController.removeListener(_rebuild);
    widget.colorController.removeListener(_rebuild);
    widget.kmController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  bool get _isFormValid => 
      widget.nameController.text.isNotEmpty && 
      widget.dateController.text.isNotEmpty && 
      widget.placaController.text.isNotEmpty &&
      widget.marcaController.text.isNotEmpty &&
      widget.modeloController.text.isNotEmpty &&
      widget.colorController.text.isNotEmpty &&
      widget.kmController.text.isNotEmpty &&
      widget.selectedConversion != null &&
      widget.selectedFuel != null &&
      widget.lockTestValue != null;

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
                _textField(widget.nameController, 'Ingresar nombre'),

                _inputLabel('Fecha'),
                _textField(widget.dateController, 'Seleccionar fecha', readOnly: true, onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    widget.dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                  }
                }),

                _inputLabel('Placa'),
                _textField(widget.placaController, 'Ingresar placa', readOnly: true),

                _inputLabel('Marca'),
                _textField(widget.marcaController, 'Ingresar marca', readOnly: true),

                _inputLabel('Modelo'),
                _textField(widget.modeloController, 'Ingresar modelo', readOnly: true),

                _inputLabel('Color'),
                _textField(widget.colorController, 'Ingresar color', readOnly: true),

                _inputLabel('Kilometraje'),
                _textField(widget.kmController, 'Ingresar numero de kilometros', keyboardType: TextInputType.number),

                _inputLabel('Conversión'),
                _dropdown(widget.selectedConversion, 'Seleccionar tipo de conversión', widget.conversiones, widget.onConversionChanged),

                _inputLabel('Nivel de combustible'),
                _dropdown(widget.selectedFuel, 'Seleccionar nivel de combustible', widget.fuelLevels, widget.onFuelChanged),

                const SizedBox(height: 24),
                Text('Prueba de bloqueo / desbloqueo efectiva', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF002B4B))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _toggleButton('No', widget.lockTestValue == false, () => widget.onLockTestChanged(false))),
                    const SizedBox(width: 12),
                    Expanded(child: _toggleButton('Si', widget.lockTestValue == true, () => widget.onLockTestChanged(true))),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: widget.onBack, 
          onContinue: widget.onContinue,
          isContinueEnabled: _isFormValid,
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
