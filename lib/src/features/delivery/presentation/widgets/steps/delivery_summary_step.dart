import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class DeliverySummaryStep extends StatelessWidget {
  final String? clientName;
  final bool? deliverVehicle;
  final bool clientPhotoUploaded;
  final bool checklistPhotoUploaded;
  final bool actaUploaded;
  final String? deliveryTime;
  final int checklistChecked;
  final int checklistTotal;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditDeliveryInfo;
  final VoidCallback onEditConfirmation;
  final VoidCallback onEditChecklist;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const DeliverySummaryStep({
    super.key,
    this.clientName, this.deliverVehicle,
    required this.clientPhotoUploaded, required this.checklistPhotoUploaded,
    required this.actaUploaded, this.deliveryTime,
    required this.checklistChecked, required this.checklistTotal,
    required this.onEditTaskInfo, required this.onEditDeliveryInfo,
    required this.onEditConfirmation, required this.onEditChecklist,
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
                FlowSummarySection(title: 'Información de la tarea', onEdit: onEditTaskInfo, children: const [
                  FlowSummaryItem(label: 'Fecha', value: 'Miércoles, 18 de marzo de 2026'),
                  FlowSummaryItem(label: 'Hora de entrega', value: '14:00'),
                  FlowSummaryItem(label: 'Marca', value: 'Chevrolet', secondLabel: 'Modelo', secondValue: 'Optra'),
                  FlowSummaryItem(label: 'Tipo', value: 'Nuevo'),
                  FlowSummaryItem(label: 'Placa', value: 'ABC-392'),
                  FlowSummaryItem(label: 'Ubicación', value: 'Avenida Pedro de Osma 789 Calle Centenario'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Información de la entrega', onEdit: onEditDeliveryInfo, children: [
                  FlowSummaryItem(label: 'Nombre del cliente', value: clientName ?? 'Juan Cruz'),
                  FlowSummaryItem(label: 'DNI del cliente', value: '1231231231'),
                  FlowSummaryItem(label: '¿Le entrega vehículo?', value: deliverVehicle == true ? 'Si' : deliverVehicle == false ? 'No' : '---'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Confirmación entrega', onEdit: onEditConfirmation, children: [
                  FlowSummaryStatus(label: 'Foto de entrega (al cliente)', isComplete: clientPhotoUploaded),
                  FlowSummaryItem(label: 'Hora efectiva de entrega', value: deliveryTime ?? '16:00'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Listado Inventario', onEdit: onEditChecklist, children: [
                  FlowSummaryItem(label: 'Datos Generales', value: '●'),
                  FlowSummaryItem(label: 'Entrega y Explicación de Documentación del Vehículo', value: '$checklistChecked/$checklistTotal'),
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
