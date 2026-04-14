import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class ManagementSummaryStep extends StatelessWidget {
  final String managementType;

  // Bloqueo/Desbloqueo
  final String? verificationResult;

  // Pago servicio
  final String? fineType;
  final String? municipality;
  final String? selectedMunicipality;

  // Apoyo oficina/taller
  final String? startTime;
  final String? endTime;
  final String? motivo;

  // Trámite policial
  final String? comisaria;
  final String? expediente;
  final String? policeMotivo;
  final bool constanciaUploaded;

  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditDetail;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const ManagementSummaryStep({
    super.key,
    required this.managementType,
    this.verificationResult,
    this.fineType,
    this.municipality,
    this.selectedMunicipality,
    this.startTime,
    this.endTime,
    this.motivo,
    this.comisaria,
    this.expediente,
    this.policeMotivo,
    this.constanciaUploaded = false,
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
                    const FlowSummaryItem(label: 'Fecha', value: 'Miércoles, 18 de marzo de 2026'),
                    FlowSummaryItem(label: 'Tipo de gestión', value: managementType),
                    if (managementType == 'Prueba de Bloqueo / Desbloqueo')
                      const FlowSummaryItem(label: 'Placa', value: 'EDZ-478'),
                    const FlowSummaryItem(
                      label: 'Ubicación de gestión',
                      value: 'Avenida Pedro de Osma 789 Calle Centenario 156',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailSection(),
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

  Widget _buildDetailSection() {
    switch (managementType) {
      case 'Prueba de Bloqueo / Desbloqueo':
        return FlowSummarySection(
          title: 'Resultado de la verificación',
          onEdit: onEditDetail,
          children: [
            FlowSummaryItem(label: 'Resultado de la verificación', value: verificationResult ?? '---'),
          ],
        );
      case 'Pago servicio':
        return FlowSummarySection(
          title: 'Información de pago',
          onEdit: onEditDetail,
          children: [
            FlowSummaryItem(label: 'Tipo de multa', value: fineType ?? '---'),
            FlowSummaryItem(label: 'Multa municipalidad', value: municipality ?? '---'),
            FlowSummaryItem(label: 'Municipio', value: selectedMunicipality ?? '---'),
          ],
        );
      case 'Trámite policial':
        return FlowSummarySection(
          title: 'Detalle gestión',
          onEdit: onEditDetail,
          children: [
            FlowSummaryItem(label: 'Comisaría', value: comisaria ?? '---'),
            FlowSummaryItem(label: 'Número de expediente', value: expediente ?? '---'),
            FlowSummaryItem(label: 'Motivo', value: policeMotivo ?? '---'),
            FlowSummaryStatus(label: 'Constancia / Documento', isComplete: constanciaUploaded),
          ],
        );
      case 'Apoyo oficina':
      case 'Apoyo taller':
        return FlowSummarySection(
          title: 'Detalle gestión',
          onEdit: onEditDetail,
          children: [
            FlowSummaryItem(
              label: 'Hora inicio',
              value: startTime ?? '---',
              secondLabel: 'Hora fin',
              secondValue: endTime ?? '---',
            ),
            FlowSummaryItem(label: 'Motivo', value: motivo ?? '---'),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
