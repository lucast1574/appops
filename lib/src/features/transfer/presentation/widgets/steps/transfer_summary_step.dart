import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class TransferSummaryStep extends StatelessWidget {
  final String? placa;
  final String? originLocation;
  final String? destinationLocation;
  final bool exitPhotoUploaded;
  final bool kmStartPhotoUploaded;
  final bool deliveryPhotoUploaded;
  final bool kmEndPhotoUploaded;
  final String? deliveryName;
  final String? selectedMarca;
  final String? selectedModelo;
  final String? selectedColor;
  final String? unitType;
  final String? km;
  final String? selectedConversion;
  final String? selectedFuelLevel;
  final bool? bloqueoDesbloqueo;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditTransferInfo;
  final VoidCallback onEditDeliveryInfo;
  final VoidCallback onEditChecklist;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const TransferSummaryStep({
    super.key,
    this.placa, this.originLocation, this.destinationLocation,
    required this.exitPhotoUploaded, required this.kmStartPhotoUploaded,
    required this.deliveryPhotoUploaded, required this.kmEndPhotoUploaded,
    this.deliveryName, this.selectedMarca, this.selectedModelo, this.selectedColor,
    this.unitType, this.km, this.selectedConversion, this.selectedFuelLevel, this.bloqueoDesbloqueo,
    required this.onEditTaskInfo, required this.onEditTransferInfo,
    required this.onEditDeliveryInfo, required this.onEditChecklist,
    required this.onEditAll, required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Resumen de tarea', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 32),
                FlowSummarySection(title: 'Información de la tarea', onEdit: onEditTaskInfo, children: [
                  const FlowSummaryItem(label: 'Fecha', value: 'Miércoles, 18 de marzo de 2026'),
                  FlowSummaryItem(label: 'Placa', value: placa ?? 'ABC-392'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Información de traslado', onEdit: onEditTransferInfo, children: [
                  FlowSummaryItem(label: 'Ubicación de inicio traslado', value: originLocation ?? '---'),
                  FlowSummaryItem(label: 'Ubicación final de traslado', value: destinationLocation ?? '---'),
                  FlowSummaryStatus(label: 'Salida de vehículo', isComplete: exitPhotoUploaded),
                  FlowSummaryStatus(label: 'Kilometraje vehículo (inicio)', isComplete: kmStartPhotoUploaded),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Información de entrega', onEdit: onEditDeliveryInfo, children: [
                  FlowSummaryStatus(label: 'Foto vehículo punto de entrega', isComplete: deliveryPhotoUploaded),
                  FlowSummaryStatus(label: 'Kilometraje vehículo (final)', isComplete: kmEndPhotoUploaded),
                  FlowSummaryItem(label: 'Nombre a quien entrega', value: deliveryName ?? '---'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Listado de entrega', onEdit: onEditChecklist, children: [
                  FlowSummaryItem(label: 'Marca', value: selectedMarca ?? '---'),
                  FlowSummaryItem(label: 'Modelo', value: selectedModelo ?? '---'),
                  FlowSummaryItem(label: 'Color', value: selectedColor ?? '---'),
                  FlowSummaryItem(label: 'Tipo de unidad', value: unitType ?? '---'),
                  FlowSummaryItem(label: 'Kilometraje', value: km ?? '---'),
                  FlowSummaryItem(label: 'Conversión', value: selectedConversion ?? '---'),
                  FlowSummaryItem(label: 'Nivel de combustible', value: selectedFuelLevel ?? '---'),
                  FlowSummaryItem(label: 'Pruebas de bloqueo / desbloqueo', value: bloqueoDesbloqueo == true ? 'Si' : bloqueoDesbloqueo == false ? 'No' : '---'),
                ]),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E9EB)))),
          child: Row(children: [
            Expanded(flex: 1, child: SizedBox(height: 48, child: OutlinedButton(onPressed: onEditAll, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFCCD4DB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Editar', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold))))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: SizedBox(height: 48, child: ElevatedButton(onPressed: onSend, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27A376), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: Text('Enviar registro', style: GoogleFonts.inter(fontWeight: FontWeight.bold))))),
          ]),
        ),
      ],
    );
  }
}
