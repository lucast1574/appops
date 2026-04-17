import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';
import '../../../../home/data/task_service.dart';

/// Step 4: Summary before sending.
class VehicleVerificationSummaryStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool? isVisible;
  final String observations;
  final bool photoUploaded;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditDetail;
  final VoidCallback onEditPhoto;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const VehicleVerificationSummaryStep({
    super.key,
    required this.task,
    this.isVisible,
    required this.observations,
    required this.photoUploaded,
    required this.onEditTaskInfo,
    required this.onEditDetail,
    required this.onEditPhoto,
    required this.onEditAll,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final String scheduledDate = task['scheduled_date'] ?? '—';
    final String address = task['address'] ?? '—';
    final String placa = task['placa'] ?? '';
    final String startTime = TaskService.formatTime(task['start_time'] as String?);

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
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
                  ),
                ),
                const SizedBox(height: 32),
                FlowSummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: [
                    FlowSummaryItem(label: 'Fecha', value: scheduledDate),
                    if (startTime.isNotEmpty)
                      FlowSummaryItem(label: 'Hora', value: startTime),
                    FlowSummaryItem(label: 'Ubicación de verificación', value: address),
                    if (placa.isNotEmpty)
                      FlowSummaryItem(label: 'Placa', value: placa),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Detalle de verificación',
                  onEdit: onEditDetail,
                  children: [
                    FlowSummaryStatus(
                      label: '¿El vehículo es visible y fácil de ubicar?',
                      isComplete: isVisible == true,
                    ),
                    if (observations.isNotEmpty)
                      FlowSummaryItem(label: 'Observaciones', value: observations),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Foto del vehículo',
                  onEdit: onEditPhoto,
                  children: [
                    FlowSummaryStatus(
                      label: 'Foto del vehículo',
                      isComplete: photoUploaded,
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
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onEditAll,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCCD4DB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Editar', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold)),
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
                    child: Text('Enviar registro', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
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
