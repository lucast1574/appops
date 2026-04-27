import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';


class TransferInventoryStep extends StatelessWidget {
  final Map<String, Map<String, dynamic>> inventoryValues;
  final Function(String, Map<String, dynamic>) onInventoryChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferInventoryStep({
    super.key,
    required this.inventoryValues,
    required this.onInventoryChanged,
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

                _section('Entrega y Explicación de Documentación', [
                  'Pasaporte de garantía y mantenimiento',
                  'Placas de rodaje y tercera placa',
                  'Manual del conductor',
                  'Conversión GNV/GLP',
                  'Certificado de Revisión técnica',
                ]),

                _section('Inspección del Vehículo', [
                  'Limpieza y estado exterior',
                  'Limpieza y estado interior',
                  'Presión de llantas y niveles',
                ]),

                _section('Detalle de Inventario', [
                  'Antena',
                  'Gata',
                  'Seguro de aros',
                  'Segunda llave',
                  'Encendedor',
                  'Cenicero',
                  'Tapas de ruedas',
                  'Llanta de repuesto',
                  'Kit de emergencia',
                ]),
                
                _section('Descripción General', [
                  'Llave inteligente',
                  'Sistema antirrobo',
                  'Aire acondicionado',
                  'Espejos exteriores',
                  'Cámara de retroceso',
                ]),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: () {
            if (_isComplete) {
              onContinue();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, marque todos los ítems del inventario antes de continuar.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        ),
      ],
    );
  }

  bool get _isComplete {
    final allItems = [
      'Pasaporte de garantía y mantenimiento',
      'Placas de rodaje y tercera placa',
      'Manual del conductor',
      'Conversión GNV/GLP',
      'Certificado de Revisión técnica',
      'Limpieza y estado exterior',
      'Limpieza y estado interior',
      'Presión de llantas y niveles',
      'Antena',
      'Gata',
      'Seguro de aros',
      'Segunda llave',
      'Encendedor',
      'Cenicero',
      'Tapas de ruedas',
      'Llanta de repuesto',
      'Kit de emergencia',
      'Llave inteligente',
      'Sistema antirrobo',
      'Aire acondicionado',
      'Espejos exteriores',
      'Cámara de retroceso',
    ];
    return allItems.every((item) => inventoryValues[item]?['value'] != null);
  }

  Widget _section(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF668093))),
        ),
        ...items.map((item) => _inventoryItem(item)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _inventoryItem(String label) {
    final Map<String, dynamic> data = inventoryValues[label] ?? {'value': null, 'obs': ''};
    final bool? value = data['value'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B)))),
              const SizedBox(width: 12),
              // NO Button
              GestureDetector(
                onTap: () => onInventoryChanged(label, {...data, 'value': false}),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: value == false ? const Color(0xFFFFEBEE) : Colors.white,
                    border: Border.all(color: value == false ? const Color(0xFFE53935) : const Color(0xFFCCD4DB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('No', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: value == false ? const Color(0xFFE53935) : const Color(0xFF668093))),
                ),
              ),
              const SizedBox(width: 8),
              // YES Button
              GestureDetector(
                onTap: () => onInventoryChanged(label, {...data, 'value': true}),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: value == true ? const Color(0xFFE0F2F1) : Colors.white,
                    border: Border.all(color: value == true ? const Color(0xFF00897B) : const Color(0xFFCCD4DB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Si', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: value == true ? const Color(0xFF00897B) : const Color(0xFF668093))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
