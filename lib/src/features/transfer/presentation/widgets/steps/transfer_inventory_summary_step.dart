import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class TransferInventorySummaryStep extends StatelessWidget {
  final Map<String, Map<String, dynamic>> inventoryValues;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferInventorySummaryStep({
    super.key,
    required this.inventoryValues,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final sections = {
      'Entrega y Explicación de Documentación del Vehículo': [
        'Prueba de bloqueo / desbloqueo efectiva',
        'Pasaporte de garantía y mantenimiento',
        'Placas de rodaje y tercera placa',
        'Manual del conductor',
        'Conversión GNV/GLP – Pasaporte de proveedor',
        'Certificado de Revisión técnica complementaria vigente',
      ],
      'Instalaciones del Concesionario': [
        'Explicación de talleres',
        'Explicación para agendar cita',
        'Explicación de activación GNV/GLP',
      ],
      'Inspección del Vehículo': [
        'Limpieza y estado exterior del vehículo',
        'Limpieza y estado interior del vehículo',
        'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)',
      ],
      'Detalle de Inventario': [
        'Antena', 'Gata', 'Seguro de aros', 'Segunda llave de contacto', 
        'Simple', 'Con control', 'Encendedor', 'Cenicero', 'Tapas de ruedas', 
        'Tapas de remolque', 'Dado de seguro de ruedas', 'Llanta de repuesto', 
        'Equipo multimedia', 'Pisos: Hule / Alfombra', 'Kit de emergencia:',
        'Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas',
      ],
      'Descripción General': [
        'Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas',
        'Paneles de puertas y maletera – controles', 'Seguridad', 'Cinturones',
        'Bolsas de aire', 'Seguro de niños', 'Ventanas y retrovisores',
        'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda',
        'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha',
        'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos',
        'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares',
        'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho',
        'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible',
        'Cámara de retroceso', 'Navegador and bluetooth', 'Porta documentos',
      ],
    };

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Resumen de Inventario', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
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
          isContinueEnabled: true,
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

    bool isChild = false;
    if (label == 'Simple' || label == 'Con control') {
      isChild = true;
    } else if ([
      'Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas'
    ].contains(label)) {
      isChild = true;
    } else if (['Cinturones', 'Bolsas de aire', 'Seguro de niños'].contains(label)) {
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
            left: isChild ? 24.0 : 0.0 
          ),
          child: Text(
            isChild ? '• $label' : label, 
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: const Color(0xFF002B4B),
              fontWeight: isChild ? FontWeight.normal : FontWeight.w500,
            )
          ),
        ),
        _valueCell(value == false, false),
        _valueCell(value == true, true),
      ],
    );
  }

  Widget _valueCell(bool isActive, bool isSi) {
    return Container(
      height: 56,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isActive 
          ? (isSi ? const Color(0xFF27A376) : const Color(0xFFFF7171)) 
          : Colors.white,
        border: Border.all(
          color: isActive ? (isSi ? const Color(0xFF27A376) : const Color(0xFFFF7171)) : const Color(0xFFCCD4DB)
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
