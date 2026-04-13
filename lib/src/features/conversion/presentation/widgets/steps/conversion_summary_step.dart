import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class ConversionSummaryStep extends StatelessWidget {
  // Task info
  final String? selectedServiceType;
  final String? selectedLocation;

  // Result
  final bool certificateUploaded;
  final bool checklistPhotoUploaded;
  final bool fitoChecklistUploaded;
  final String? mapsLink;

  // Edit callbacks
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditServiceInfo;
  final VoidCallback onEditResult;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const ConversionSummaryStep({
    super.key,
    this.selectedServiceType,
    this.selectedLocation,
    required this.certificateUploaded,
    required this.checklistPhotoUploaded,
    required this.fitoChecklistUploaded,
    this.mapsLink,
    required this.onEditTaskInfo,
    required this.onEditServiceInfo,
    required this.onEditResult,
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

                // Información de la tarea
                FlowSummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: const [
                    FlowSummaryItem(
                      label: 'Fecha',
                      value: 'Miércoles, 18 de marzo de 2026',
                    ),
                    FlowSummaryItem(
                      label: 'Placa',
                      value: 'ABC 392',
                    ),
                    FlowSummaryItem(
                      label: 'Hora inicio',
                      value: '16:00',
                      secondLabel: 'Hora fin',
                      secondValue: '18:00',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Información de servicio
                FlowSummarySection(
                  title: 'Información de servicio',
                  onEdit: onEditServiceInfo,
                  children: [
                    FlowSummaryItem(
                      label: 'Tipo de servicio',
                      value: selectedServiceType ?? '---',
                    ),
                    FlowSummaryItem(
                      label: 'Ubicación',
                      value: selectedLocation ?? 'Gd. Av. Argentina',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Resultado conversión
                FlowSummarySection(
                  title: 'Resultado conversión',
                  onEdit: onEditResult,
                  children: [
                    FlowSummaryStatus(
                      label: 'Certificado de conversión?',
                      isComplete: certificateUploaded,
                    ),
                    FlowSummaryStatus(
                      label: 'Link Google Maps · Ubicación de entrega',
                      isComplete: mapsLink != null && mapsLink!.isNotEmpty,
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
