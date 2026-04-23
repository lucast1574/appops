import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class NotarySummaryStep extends StatelessWidget {
  final String? selectedPickupNotary;
  final String? selectedDeliveryNotary;
  final bool receivePhotoUploaded;
  final String? receiverName;
  final bool deliverPhotoUploaded;
  final String? deliveryName;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditReceive;
  final VoidCallback onEditDeliver;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const NotarySummaryStep({
    super.key,
    this.selectedPickupNotary,
    this.selectedDeliveryNotary,
    required this.receivePhotoUploaded,
    this.receiverName,
    required this.deliverPhotoUploaded,
    this.deliveryName,
    required this.onEditTaskInfo,
    required this.onEditReceive,
    required this.onEditDeliver,
    required this.onEditAll,
    required this.onSend,
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
                Center(
                  child: Text(
                    'Resumen de tarea',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FlowSummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: [
                    FlowSummaryItem(
                      label: 'Ubicación de recibida de documentos',
                      value: selectedPickupNotary ?? '---',
                    ),
                    FlowSummaryItem(
                      label: 'Ubicación de entrega de documentos',
                      value: selectedDeliveryNotary ?? '---',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Recibir documentos',
                  onEdit: onEditReceive,
                  children: [
                    FlowSummaryStatus(
                      label: 'Foto documentos recibidos',
                      isComplete: receivePhotoUploaded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Entrega de documentos',
                  onEdit: onEditDeliver,
                  children: [
                    FlowSummaryStatus(
                      label: 'Foto persona recibiendo documento',
                      isComplete: deliverPhotoUploaded,
                    ),
                    FlowSummaryItem(
                      label: 'Nombre de quien recibe',
                      value: deliveryName != null && deliveryName!.isNotEmpty
                          ? deliveryName!
                          : '---',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E9EB))),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onEditAll,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCD4DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Editar',
                      style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27A376),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Enviar registro',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
