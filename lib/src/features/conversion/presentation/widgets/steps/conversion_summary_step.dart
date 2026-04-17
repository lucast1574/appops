import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';
import '../../../../home/data/task_service.dart';

/// Step 4: "Resumen de tarea" — read-only summary before sending.
/// All data comes from the real task + locally collected upload state.
class ConversionSummaryStep extends StatelessWidget {
  final Map<String, dynamic> task;

  // Upload status (from parent state)
  final bool certificateUploaded;
  final bool checklistUploaded;
  final bool creativeUploaded;

  // Edit callbacks (go back to specific step)
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditServiceInfo;
  final VoidCallback onEditResult;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const ConversionSummaryStep({
    super.key,
    required this.task,
    required this.certificateUploaded,
    required this.checklistUploaded,
    required this.creativeUploaded,
    required this.onEditTaskInfo,
    required this.onEditServiceInfo,
    required this.onEditResult,
    required this.onEditAll,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    // Extract from task
    final String scheduledDate = task['scheduled_date'] ?? '—';
    final String placa = task['placa'] ?? '—';
    final String startTime = TaskService.formatTime(task['start_time'] as String?) ;
    final String endTime = TaskService.formatTime(task['end_time'] as String?);
    final metadata = task['metadata'] as Map<String, dynamic>? ?? {};
    final String serviceType = metadata['service_type'] ?? 'No especificado';
    final String? mapsLink = task['google_maps_link'] as String?;
    final String address = task['address'] ?? '';

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

                // ---- Información de la tarea ----
                FlowSummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: [
                    FlowSummaryItem(
                      label: 'Fecha',
                      value: scheduledDate,
                    ),
                    FlowSummaryItem(
                      label: 'Placa',
                      value: placa,
                    ),
                    FlowSummaryItem(
                      label: 'Hora inicio',
                      value: startTime.isNotEmpty ? startTime : '—',
                      secondLabel: 'Hora fin',
                      secondValue: endTime.isNotEmpty ? endTime : '—',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ---- Información de servicio ----
                FlowSummarySection(
                  title: 'Información de servicio',
                  onEdit: onEditServiceInfo,
                  children: [
                    FlowSummaryItem(
                      label: 'Tipo de servicio',
                      value: serviceType,
                    ),
                    if (address.isNotEmpty)
                      FlowSummaryItem(
                        label: 'Ubicación de entrega',
                        value: address,
                      ),
                    FlowSummaryStatus(
                      label: 'Link Google Maps · Ubicación de entrega',
                      isComplete: mapsLink != null && mapsLink.isNotEmpty,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ---- Resultado conversión ----
                FlowSummarySection(
                  title: 'Resultado conversión',
                  onEdit: onEditResult,
                  children: [
                    FlowSummaryStatus(
                      label: 'Certificado de conversión',
                      isComplete: certificateUploaded,
                    ),
                    FlowSummaryStatus(
                      label: 'Foto del checklist',
                      isComplete: checklistUploaded,
                    ),
                    FlowSummaryStatus(
                      label: 'Foto creativa',
                      isComplete: creativeUploaded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ---- Footer ----
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
