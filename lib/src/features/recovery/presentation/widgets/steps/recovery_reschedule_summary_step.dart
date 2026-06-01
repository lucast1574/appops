import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class RecoveryRescheduleSummaryStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isPhotoUploaded;
  final String? selectedReason;
  final String observations;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditRescheduleInfo;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const RecoveryRescheduleSummaryStep({
    super.key,
    required this.task,
    required this.isPhotoUploaded,
    this.selectedReason,
    required this.observations,
    required this.onEditTaskInfo,
    required this.onEditRescheduleInfo,
    required this.onEditAll,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final String startTime = task['start_time'] != null ? task['start_time'].toString().substring(0, 5) : '';
    final String endTime = task['end_time'] != null ? task['end_time'].toString().substring(0, 5) : '';
    final String estimatedTime = (startTime.isNotEmpty && endTime.isNotEmpty) ? '$startTime - $endTime' : '';
    final String address = task['address'] ?? '';
    final String placa = task['placa'] ?? '';
    final String clientName = task['client_name'] ?? '';
    final String clientDni = task['client_dni'] ?? '';

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
                
                // Section 1: Task info (dynamic)
                FlowSummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: [
                    if (clientName.isNotEmpty)
                      FlowSummaryItem(label: 'Cliente', value: clientName),
                    if (clientDni.isNotEmpty)
                      FlowSummaryItem(label: 'DNI', value: clientDni),
                    if (placa.isNotEmpty)
                      FlowSummaryItem(label: 'Placa', value: placa),
                    if (estimatedTime.isNotEmpty)
                      FlowSummaryItem(
                        label: 'Hora inicio',
                        value: startTime,
                        secondLabel: 'Hora fin',
                        secondValue: endTime,
                      ),
                    if (address.isNotEmpty)
                      FlowSummaryItem(label: 'Dirección', value: address),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 2: Recupero efectuado -> No
                FlowSummarySection(
                  title: 'Recupero efectuado',
                  onEdit: onEditAll,
                  children: const [
                    FlowSummaryItem(label: 'Estado', value: 'No'),
                  ],
                ),
                const SizedBox(height: 24),

                // Section 3: Recupero no efectuado details
                FlowSummarySection(
                  title: 'Recupero no efectuado',
                  onEdit: onEditRescheduleInfo,
                  children: [
                    FlowSummaryStatus(label: 'Foto', isComplete: isPhotoUploaded),
                    FlowSummaryItem(label: 'Motivo', value: selectedReason ?? 'No especificado'),
                    FlowSummaryItem(
                      label: 'Observaciones',
                      value: observations.isNotEmpty ? observations : 'Sin observaciones',
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Editar',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF002B4B),
                        fontWeight: FontWeight.bold,
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
