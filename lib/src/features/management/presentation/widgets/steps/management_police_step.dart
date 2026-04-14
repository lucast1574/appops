import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class ManagementPoliceStep extends StatelessWidget {
  final TextEditingController comisariaController;
  final TextEditingController expedienteController;
  final TextEditingController motivoController;
  final bool constanciaUploaded;
  final String? constanciaTag;
  final Function(bool) onConstanciaUploadedChanged;
  final Function(String?) onConstanciaTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ManagementPoliceStep({
    super.key,
    required this.comisariaController,
    required this.expedienteController,
    required this.motivoController,
    required this.constanciaUploaded,
    this.constanciaTag,
    required this.onConstanciaUploadedChanged,
    required this.onConstanciaTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalle gestión',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                _buildHeader('Comisaría'),
                const SizedBox(height: 8),
                _buildTextField(comisariaController, 'Nombre de la comisaría'),
                const SizedBox(height: 16),
                _buildHeader('Número de expediente'),
                const SizedBox(height: 8),
                _buildTextField(expedienteController, 'Número de expediente'),
                const SizedBox(height: 16),
                _buildHeader('Motivo'),
                const SizedBox(height: 8),
                TextField(
                  controller: motivoController,
                  maxLines: 4,
                  style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                  decoration: _inputDecoration('Descripción del trámite...'),
                ),
                const SizedBox(height: 24),
                const FlowSectionLabel(label: 'Constancia / Documento'),
                const SizedBox(height: 12),
                constanciaUploaded
                    ? FlowImagePreview(
                        fileName: 'constancia.png',
                        tag: constanciaTag,
                        onDeleteImage: () {
                          onConstanciaUploadedChanged(false);
                          onConstanciaTagChanged(null);
                        },
                        onDeleteTag: () => onConstanciaTagChanged(null),
                        onTagAdded: (val) => onConstanciaTagChanged(val),
                      )
                    : FlowUploadButton(
                        text: 'Tomar foto',
                        iconAsset: 'assets/CameraPlus.svg',
                        onTap: () => onConstanciaUploadedChanged(true),
                      ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
          buttonText: 'Finalizar',
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
    );
  }
}
