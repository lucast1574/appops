import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class RecoveryDocsStep extends StatelessWidget {
  final bool tarjetaPropiedadUploaded; final String? tarjetaPropiedadTag;
  final bool soatUploaded; final String? soatTag;
  final bool revisionTecnicaUploaded; final String? revisionTecnicaTag;
  final bool actaRecuperoUploaded; final String? actaRecuperoTag;

  // Checklist items
  final bool? tieneLlaveOriginal;
  final bool? tieneLlaveRepuesto;
  final bool? tieneGata;
  final bool? tieneLlantaRepuesto;
  final bool? tieneExtintor;
  final bool? tieneTriangulo;
  final bool? tieneManualConductor;

  final Function(bool) onTarjetaUploadedChanged; final Function(String?) onTarjetaTagChanged;
  final Function(bool) onSoatUploadedChanged; final Function(String?) onSoatTagChanged;
  final Function(bool) onRevisionUploadedChanged; final Function(String?) onRevisionTagChanged;
  final Function(bool) onActaUploadedChanged; final Function(String?) onActaTagChanged;
  final Function(bool) onLlaveOriginalChanged;
  final Function(bool) onLlaveRepuestoChanged;
  final Function(bool) onGataChanged;
  final Function(bool) onLlantaRepuestoChanged;
  final Function(bool) onExtintorChanged;
  final Function(bool) onTrianguloChanged;
  final Function(bool) onManualConductorChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryDocsStep({
    super.key,
    required this.tarjetaPropiedadUploaded, this.tarjetaPropiedadTag,
    required this.soatUploaded, this.soatTag,
    required this.revisionTecnicaUploaded, this.revisionTecnicaTag,
    required this.actaRecuperoUploaded, this.actaRecuperoTag,
    this.tieneLlaveOriginal, this.tieneLlaveRepuesto, this.tieneGata,
    this.tieneLlantaRepuesto, this.tieneExtintor, this.tieneTriangulo, this.tieneManualConductor,
    required this.onTarjetaUploadedChanged, required this.onTarjetaTagChanged,
    required this.onSoatUploadedChanged, required this.onSoatTagChanged,
    required this.onRevisionUploadedChanged, required this.onRevisionTagChanged,
    required this.onActaUploadedChanged, required this.onActaTagChanged,
    required this.onLlaveOriginalChanged, required this.onLlaveRepuestoChanged,
    required this.onGataChanged, required this.onLlantaRepuestoChanged,
    required this.onExtintorChanged, required this.onTrianguloChanged, required this.onManualConductorChanged,
    required this.onBack, required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Documentación y accesorios', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                _uploadSection('Tarjeta de propiedad*', tarjetaPropiedadUploaded, 'tarjeta.png', tarjetaPropiedadTag, onTarjetaUploadedChanged, onTarjetaTagChanged),
                const SizedBox(height: 20),
                _uploadSection('SOAT*', soatUploaded, 'soat.png', soatTag, onSoatUploadedChanged, onSoatTagChanged),
                const SizedBox(height: 20),
                _uploadSection('Revisión técnica*', revisionTecnicaUploaded, 'revision_tecnica.png', revisionTecnicaTag, onRevisionUploadedChanged, onRevisionTagChanged),
                const SizedBox(height: 20),
                _uploadSection('Acta de recupero*', actaRecuperoUploaded, 'acta_recupero.png', actaRecuperoTag, onActaUploadedChanged, onActaTagChanged),
                const SizedBox(height: 32),
                Text('Inventario rápido', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 4),
                Text('Verificar presencia de los siguientes elementos:', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF668093))),
                const SizedBox(height: 16),
                FlowYesNoQuestion(question: 'Llave original', currentValue: tieneLlaveOriginal, onChanged: onLlaveOriginalChanged),
                const SizedBox(height: 12),
                FlowYesNoQuestion(question: 'Llave de repuesto', currentValue: tieneLlaveRepuesto, onChanged: onLlaveRepuestoChanged),
                const SizedBox(height: 12),
                FlowYesNoQuestion(question: 'Gata', currentValue: tieneGata, onChanged: onGataChanged),
                const SizedBox(height: 12),
                FlowYesNoQuestion(question: 'Llanta de repuesto', currentValue: tieneLlantaRepuesto, onChanged: onLlantaRepuestoChanged),
                const SizedBox(height: 12),
                FlowYesNoQuestion(question: 'Extintor', currentValue: tieneExtintor, onChanged: onExtintorChanged),
                const SizedBox(height: 12),
                FlowYesNoQuestion(question: 'Triángulo de seguridad', currentValue: tieneTriangulo, onChanged: onTrianguloChanged),
                const SizedBox(height: 12),
                FlowYesNoQuestion(question: 'Manual del conductor', currentValue: tieneManualConductor, onChanged: onManualConductorChanged),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(onBack: onBack, onContinue: onContinue, buttonText: 'Finalizar'),
      ],
    );
  }

  Widget _uploadSection(String label, bool uploaded, String fileName, String? tag, Function(bool) onUploadChanged, Function(String?) onTagChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [FlowSectionLabel(label: label), const Spacer(), if (!uploaded) Text('Sin imagen', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7)))]),
    const SizedBox(height: 12),
    uploaded
        ? FlowImagePreview(fileName: fileName, tag: tag, onDeleteImage: () { onUploadChanged(false); onTagChanged(null); }, onDeleteTag: () => onTagChanged(null), onTagAdded: (val) => onTagChanged(val))
        : GestureDetector(
            onTap: () => onUploadChanged(true),
            child: Container(
              width: double.infinity,
              height: 88,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0F3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFB9DBE1).withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/CameraPlus.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tomar foto',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ],
              ),
            ),
          ),
  ]);
}
