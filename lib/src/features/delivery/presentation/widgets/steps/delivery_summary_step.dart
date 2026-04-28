import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class DeliverySummaryStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final String? clientName;
  final String? clientDni;
  final bool? deliverVehicle;
  final bool clientPhotoUploaded;
  final bool checklistPhotoUploaded;
  final bool actaUploaded;
  final int checklistChecked;
  final int checklistTotal;
  final int observationsCount;
  final bool hasOperarioSignature;
  final bool hasClientSignature;
  final String? effectiveTime;
  final Map<String, String> sectionCounts;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditDeliveryInfo;
  final VoidCallback onEditConfirmation;
  final VoidCallback onEditChecklist;
  final VoidCallback onEditInventory;
  final VoidCallback onEditInspection;
  final VoidCallback onEditSignatures;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const DeliverySummaryStep({
    super.key,
    required this.task,
    this.clientName, this.clientDni, this.deliverVehicle,
    this.effectiveTime,
    required this.clientPhotoUploaded, required this.checklistPhotoUploaded,
    required this.actaUploaded,
    required this.checklistChecked, required this.checklistTotal,
    required this.observationsCount,
    required this.sectionCounts,
    required this.hasOperarioSignature, required this.hasClientSignature,
    required this.onEditTaskInfo, required this.onEditDeliveryInfo,
    required this.onEditConfirmation, required this.onEditChecklist,
    required this.onEditInventory,
    required this.onEditInspection,
    required this.onEditSignatures,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Resumen de tarea', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFEAEA), borderRadius: BorderRadius.circular(16)),
                      child: Text('Reportar', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFFF7171))),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FlowSummarySection(title: 'Información de la tarea', onEdit: onEditTaskInfo, children: [
                  FlowSummaryItem(label: 'Fecha', value: task['scheduled_date'] ?? '---'),
                  FlowSummaryItem(label: 'Hora de entrega', value: task['start_time'] ?? '---'),
                  FlowSummaryItem(label: 'Marca de carro', value: task['marca'] ?? '---', secondLabel: 'Modelo', secondValue: task['modelo'] ?? '---'),
                  FlowSummaryItem(label: 'Tipo de vehículo', value: task['vehicle_type'] ?? '---'),
                  FlowSummaryItem(label: 'Placa', value: task['placa'] ?? '---', secondLabel: 'Tipo', secondValue: 'Blanca'), // Placeholder for "Tipo" if needed
                  FlowSummaryItem(label: 'Dirección', value: task['address'] ?? '---'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Información de la entrega', onEdit: onEditDeliveryInfo, children: [
                  FlowSummaryItem(label: 'Nombre del cliente', value: clientName ?? '---'),
                  FlowSummaryItem(label: 'DNI del cliente', value: clientDni ?? '---'),
                  FlowSummaryItem(label: '¿Se entregó vehículo?', value: deliverVehicle == true ? 'Si' : deliverVehicle == false ? 'No' : '---'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Confirmación entrega', onEdit: onEditConfirmation, children: [
                  FlowSummaryStatus(label: 'Foto de entrega (al cliente)', isComplete: clientPhotoUploaded),
                  FlowSummaryItem(label: 'Hora efectiva de entrega', value: effectiveTime ?? '---'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Listado Inventario', onEdit: onEditInventory, children: [
                  FlowSummaryStatus(label: 'Datos Generales', isComplete: true), // Assuming if they reached here, general data was done
                  FlowSummaryItem(label: 'Entrega y Explicación de Documentación del Vehículo', value: sectionCounts['docs'] ?? '0/0'),
                  FlowSummaryItem(label: 'Instalaciones del Concesionario', value: sectionCounts['facilities'] ?? '0/0'),
                  FlowSummaryItem(label: 'Inspección del Vehículo', value: sectionCounts['inspection'] ?? '0/0'),
                  FlowSummaryItem(label: 'Detalle de Inventario', value: sectionCounts['inventory'] ?? '0/0'),
                  FlowSummaryItem(label: 'Descripción General', value: sectionCounts['general'] ?? '0/0'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Inspección de Vehículo', onEdit: onEditInspection, children: [
                  FlowSummaryItem(label: 'Observaciones registradas', value: '$observationsCount'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Firmas', onEdit: onEditSignatures, children: [
                  FlowSummaryStatus(label: 'Firma de operario', isComplete: hasOperarioSignature),
                  FlowSummaryStatus(label: 'Firma de cliente', isComplete: hasClientSignature),
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
