import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class VehicleVerificationSummaryStep extends StatelessWidget {
  final bool? isVisible;
  final String? observations;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditDetail;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const VehicleVerificationSummaryStep({
    super.key,
    this.isVisible,
    this.observations,
    required this.onEditTaskInfo,
    required this.onEditDetail,
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
                Center(child: Text('Resumen de tarea', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 32),
                FlowSummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: const [
                    FlowSummaryItem(label: 'Fecha', value: 'Miércoles, 18 de marzo de 2026'),
                    FlowSummaryItem(label: 'Ubicación de verificación', value: 'Avenida Pedro de Osma 789 Calle Centenario 156'),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Detalle de verificación',
                  onEdit: onEditDetail,
                  children: [
                    FlowSummaryItem(label: '¿El vehículo es visible y fácil de ubicar?', value: isVisible == true ? 'Si' : isVisible == false ? 'No' : '---'),
                    FlowSummaryItem(label: 'Observaciones', value: observations != null && observations!.isNotEmpty ? observations! : '---'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E9EB)))),
          child: Row(
            children: [
              Expanded(flex: 1, child: SizedBox(height: 48, child: OutlinedButton(
                onPressed: onEditAll,
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFCCD4DB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('Editar', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold)),
              ))),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: SizedBox(height: 48, child: ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27A376), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                child: Text('Enviar registro', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ))),
            ],
          ),
        ),
      ],
    );
  }
}
