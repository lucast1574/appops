import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class VerificationSummaryStep extends StatelessWidget {
  final String? selectedRecipient;
  final String? selectedRelationship;
  final String? familiarName;
  final String? familiarDni;
  final bool isSignatureCaptured;
  final bool dniUploaded;
  final bool reciboUploaded;
  final bool breveteUploaded;
  final String? housingType;
  final bool? isGarageAtHome;
  final bool? hasCameras;
  final String? accessType;
  final bool? isRoofing;
  final bool? isBasement;
  final String? garageDirection;
  final String? streetAccessibility;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditRecipient;
  final VoidCallback onEditDocuments;
  final VoidCallback onEditHousing;
  final VoidCallback onEditGarage;
  final VoidCallback onEditAll;
  final Map<String, dynamic> task;
  final VoidCallback onSend;

  const VerificationSummaryStep({
    super.key,
    this.selectedRecipient,
    this.selectedRelationship,
    this.familiarName,
    this.familiarDni,
    this.isSignatureCaptured = false,
    required this.dniUploaded,
    required this.reciboUploaded,
    required this.breveteUploaded,
    this.housingType,
    this.isGarageAtHome,
    this.hasCameras,
    this.accessType,
    this.isRoofing,
    this.isBasement,
    this.garageDirection,
    this.streetAccessibility,
    required this.onEditTaskInfo,
    required this.onEditRecipient,
    required this.onEditDocuments,
    required this.onEditHousing,
    required this.onEditGarage,
    required this.onEditAll,
    required this.task,
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
                    'Resumen de Verificación Domiciliaria',
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
                    FlowSummaryItem(label: 'Cliente', value: task['client_name'] ?? '---'),
                    FlowSummaryItem(
                      label: 'Hora inicio', 
                      value: _formatTime(task['start_time']), 
                      secondLabel: 'Hora fin', 
                      secondValue: _formatTime(task['end_time'])
                    ),
                    FlowSummaryItem(label: 'Dirección', value: task['address'] ?? '---'),
                    FlowSummaryItem(label: 'DNI/INE cliente', value: task['client_dni'] ?? '---'),
                    FlowSummaryItem(label: 'Observaciones', value: task['observations']?.toString().isNotEmpty == true ? task['observations'] : 'Sin observaciones'),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: '¿Quién te recibió?',
                  onEdit: onEditRecipient,
                  children: [
                    FlowSummaryStatus(label: selectedRecipient ?? '---', isComplete: true),
                    if (selectedRecipient == 'Familiar') ...[
                      FlowSummaryItem(label: 'DNI/INE del familiar', value: familiarDni ?? '---'),
                      FlowSummaryItem(label: 'Nombre completo', value: familiarName ?? '---'),
                      FlowSummaryItem(label: 'Parentesco con el cliente', value: selectedRelationship ?? '---'),
                      FlowSummaryStatus(label: 'Firma de familiar', isComplete: isSignatureCaptured),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Validación de documentos',
                  onEdit: onEditDocuments,
                  children: [
                    FlowSummaryStatus(label: 'DNI/INE', isComplete: dniUploaded),
                    FlowSummaryStatus(label: 'Recibo de servicios', isComplete: reciboUploaded),
                    FlowSummaryStatus(label: 'Brevete', isComplete: breveteUploaded),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Tipo de vivienda',
                  onEdit: onEditHousing,
                  children: [
                    FlowSummaryItem(label: 'Tipo de vivienda', value: housingType ?? '---'),
                    FlowSummaryItem(label: '¿Vivienda es también la cochera?', value: isGarageAtHome == true ? 'Si' : 'No'),
                    const FlowSummaryStatus(label: 'Foto de la vivienda / fachada', isComplete: true),
                    const FlowSummaryStatus(label: 'Link Google Maps · Ubicación de vivienda', isComplete: true),
                  ],
                ),
                const SizedBox(height: 24),
                FlowSummarySection(
                  title: 'Cochera',
                  onEdit: onEditGarage,
                  children: [
                    FlowSummaryStatus(label: '¿Cochera cuenta con cámara de vigilancia?', isComplete: hasCameras == true),
                    const FlowSummaryStatus(label: 'Foto de la cámara de vigilancia', isComplete: true),
                    FlowSummaryItem(label: 'Tipo de via de acceso a la cochera', value: accessType ?? '---'),
                    FlowSummaryItem(label: 'Cochera es techada?', value: isRoofing == true ? 'Si' : 'No'),
                    const FlowSummaryStatus(label: 'Foto de la cochera', isComplete: true),
                    FlowSummaryItem(label: 'Cochera se ubica en sótano', value: isBasement == true ? 'Si' : 'No'),
                    const FlowSummaryStatus(label: 'Foto de la cochera', isComplete: true),
                    FlowSummaryItem(label: 'Hacia dónde da la cochera?', value: garageDirection ?? '---'),
                    const FlowSummaryStatus(label: 'Foto de calle / condominio', isComplete: true),
                    FlowSummaryItem(label: 'Accesibilidad de la calle', value: streetAccessibility ?? '---'),
                    const FlowSummaryStatus(label: 'Foto accesibilidad de la calle', isComplete: true),
                    const SizedBox(height: 12),
                    Text(
                      'En caso de que la cochera no quede en el domicilio se debe adjuntar 3 fotos más',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF99AAB7)),
                    ),
                    const SizedBox(height: 8),
                    const FlowSummaryStatus(label: 'Foto 1', isComplete: false),
                    const FlowSummaryStatus(label: 'Foto 2', isComplete: false),
                    const FlowSummaryStatus(label: 'Foto 3', isComplete: false),
                    const FlowSummaryStatus(label: 'Link Google Maps · Ubicación de cochera', isComplete: true),
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

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '---';
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }
}
