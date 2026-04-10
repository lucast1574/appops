import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/summary_widgets.dart';

class VerificationSummaryStep extends StatelessWidget {
  final String? selectedRecipient;
  final String? selectedRelationship;
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
  final VoidCallback onSend;

  const VerificationSummaryStep({
    super.key,
    this.selectedRecipient,
    this.selectedRelationship,
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
                    'Resumen de verificación',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SummarySection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: const [
                    SummaryItem(label: 'Cliente', value: 'Juan Ortiz'),
                    SummaryItem(label: 'Hora inicio', value: '16:00', secondLabel: 'Hora fin', secondValue: '18:00'),
                    SummaryItem(label: 'Dirección', value: 'Avenida Pedro de Osma 789 Calle Centenario 156'),
                    SummaryItem(label: 'DNI cliente', value: '9999129912'),
                    SummaryItem(label: 'Observaciones', value: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
                  ],
                ),
                const SizedBox(height: 24),
                SummarySection(
                  title: '¿Quién te recibió?',
                  onEdit: onEditRecipient,
                  children: [
                    SummaryStatus(label: selectedRecipient ?? '---', isComplete: true),
                    if (selectedRecipient == 'Familiar') ...[
                      const SummaryItem(label: 'DNI del familiar', value: '9999129912'),
                      const SummaryItem(label: 'Nombre completo', value: 'Ana Ortiz'),
                      SummaryItem(label: 'Parentesco con el cliente', value: selectedRelationship ?? '---'),
                      const SummaryStatus(label: 'Firma de familiar', isComplete: true),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                SummarySection(
                  title: 'Validación de documentos',
                  onEdit: onEditDocuments,
                  children: [
                    SummaryStatus(label: 'DNI', isComplete: dniUploaded),
                    SummaryStatus(label: 'Recibo de servicios', isComplete: reciboUploaded),
                    SummaryStatus(label: 'Brevete', isComplete: breveteUploaded),
                  ],
                ),
                const SizedBox(height: 24),
                SummarySection(
                  title: 'Tipo de vivienda',
                  onEdit: onEditHousing,
                  children: [
                    SummaryItem(label: 'Tipo de vivienda', value: housingType ?? '---'),
                    SummaryItem(label: '¿Vivienda es también la cochera?', value: isGarageAtHome == true ? 'Si' : 'No'),
                    const SummaryStatus(label: 'Foto de la vivienda / fachada', isComplete: true),
                    const SummaryStatus(label: 'Link Google Maps · Ubicación de vivienda', isComplete: true),
                  ],
                ),
                const SizedBox(height: 24),
                SummarySection(
                  title: 'Cochera',
                  onEdit: onEditGarage,
                  children: [
                    SummaryStatus(label: '¿Cochera cuenta con cámara de vigilancia?', isComplete: hasCameras == true),
                    const SummaryStatus(label: 'Foto de la cámara de vigilancia', isComplete: true),
                    SummaryItem(label: 'Tipo de via de acceso a la cochera', value: accessType ?? '---'),
                    SummaryItem(label: 'Cochera es techada?', value: isRoofing == true ? 'Si' : 'No'),
                    const SummaryStatus(label: 'Foto de la cochera', isComplete: true),
                    SummaryItem(label: 'Cochera se ubica en sótano', value: isBasement == true ? 'Si' : 'No'),
                    const SummaryStatus(label: 'Foto de la cochera', isComplete: true),
                    SummaryItem(label: 'Hacia dónde da la cochera?', value: garageDirection ?? '---'),
                    const SummaryStatus(label: 'Foto de calle / condominio', isComplete: true),
                    SummaryItem(label: 'Accesibilidad de la calle', value: streetAccessibility ?? '---'),
                    const SummaryStatus(label: 'Foto accesibilidad de la calle', isComplete: true),
                    const SizedBox(height: 12),
                    Text(
                      'En caso de que la cochera no quede en el domicilio se debe adjuntar 3 fotos más',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF99AAB7)),
                    ),
                    const SizedBox(height: 8),
                    const SummaryStatus(label: 'Foto 1', isComplete: false),
                    const SummaryStatus(label: 'Foto 2', isComplete: false),
                    const SummaryStatus(label: 'Foto 3', isComplete: false),
                    const SummaryStatus(label: 'Link Google Maps · Ubicación de cochera', isComplete: true),
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
