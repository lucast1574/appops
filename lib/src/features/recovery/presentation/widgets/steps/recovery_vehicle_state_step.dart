import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class RecoveryVehicleStateStep extends StatelessWidget {
  final bool frontalPhotoUploaded; final String? frontalPhotoTag;
  final bool traseraPhotoUploaded; final String? traseraPhotoTag;
  final bool lateralIzqPhotoUploaded; final String? lateralIzqPhotoTag;
  final bool lateralDerPhotoUploaded; final String? lateralDerPhotoTag;
  final bool kmPhotoUploaded; final String? kmPhotoTag;
  final String? selectedFuelLevel;
  final bool? hasVisibleDamage;
  final TextEditingController damageDescController;
  final Function(bool) onFrontalUploadedChanged; final Function(String?) onFrontalTagChanged;
  final Function(bool) onTraseraUploadedChanged; final Function(String?) onTraseraTagChanged;
  final Function(bool) onLateralIzqUploadedChanged; final Function(String?) onLateralIzqTagChanged;
  final Function(bool) onLateralDerUploadedChanged; final Function(String?) onLateralDerTagChanged;
  final Function(bool) onKmUploadedChanged; final Function(String?) onKmTagChanged;
  final Function(String?) onFuelLevelChanged;
  final Function(bool) onHasVisibleDamageChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryVehicleStateStep({
    super.key,
    required this.frontalPhotoUploaded, this.frontalPhotoTag,
    required this.traseraPhotoUploaded, this.traseraPhotoTag,
    required this.lateralIzqPhotoUploaded, this.lateralIzqPhotoTag,
    required this.lateralDerPhotoUploaded, this.lateralDerPhotoTag,
    required this.kmPhotoUploaded, this.kmPhotoTag,
    this.selectedFuelLevel, this.hasVisibleDamage,
    required this.damageDescController,
    required this.onFrontalUploadedChanged, required this.onFrontalTagChanged,
    required this.onTraseraUploadedChanged, required this.onTraseraTagChanged,
    required this.onLateralIzqUploadedChanged, required this.onLateralIzqTagChanged,
    required this.onLateralDerUploadedChanged, required this.onLateralDerTagChanged,
    required this.onKmUploadedChanged, required this.onKmTagChanged,
    required this.onFuelLevelChanged, required this.onHasVisibleDamageChanged,
    required this.onBack, required this.onContinue,
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
                Text('Estado del vehículo', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                _uploadSection('Foto frontal del vehículo*', frontalPhotoUploaded, 'frontal.png', frontalPhotoTag, onFrontalUploadedChanged, onFrontalTagChanged),
                const SizedBox(height: 20),
                _uploadSection('Foto trasera del vehículo*', traseraPhotoUploaded, 'trasera.png', traseraPhotoTag, onTraseraUploadedChanged, onTraseraTagChanged),
                const SizedBox(height: 20),
                _uploadSection('Foto lateral izquierdo*', lateralIzqPhotoUploaded, 'lateral_izq.png', lateralIzqPhotoTag, onLateralIzqUploadedChanged, onLateralIzqTagChanged),
                const SizedBox(height: 20),
                _uploadSection('Foto lateral derecho*', lateralDerPhotoUploaded, 'lateral_der.png', lateralDerPhotoTag, onLateralDerUploadedChanged, onLateralDerTagChanged),
                const SizedBox(height: 20),
                _uploadSection('Kilometraje actual*', kmPhotoUploaded, 'km.png', kmPhotoTag, onKmUploadedChanged, onKmTagChanged),
                const SizedBox(height: 24),
                _label('Nivel de combustible'), const SizedBox(height: 8),
                _dropdown(value: selectedFuelLevel, hint: 'Seleccionar nivel', items: const ['Vacío', '1/4', '1/2', '3/4', 'Lleno'], onChanged: onFuelLevelChanged),
                const SizedBox(height: 24),
                FlowYesNoQuestion(question: '¿El vehículo presenta daños visibles?', currentValue: hasVisibleDamage, onChanged: onHasVisibleDamageChanged),
                if (hasVisibleDamage == true) ...[
                  const SizedBox(height: 16),
                  _label('Descripción de daños'), const SizedBox(height: 8),
                  TextField(
                    controller: damageDescController, maxLines: 4,
                    style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    decoration: InputDecoration(hintText: 'Describir los daños observados...', hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)), filled: true, fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(onBack: onBack, onContinue: onContinue),
      ],
    );
  }

  Widget _uploadSection(String label, bool uploaded, String fileName, String? tag, Function(bool) onUploadChanged, Function(String?) onTagChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [FlowSectionLabel(label: label), const Spacer(), if (!uploaded) Text('Sin imagen', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7)))]),
    const SizedBox(height: 12),
    uploaded
        ? FlowImagePreview(fileName: fileName, tag: tag, onDeleteImage: () { onUploadChanged(false); onTagChanged(null); }, onDeleteTag: () => onTagChanged(null), onTagAdded: (val) => onTagChanged(val))
        : FlowUploadButton(text: 'Tomar foto', iconAsset: 'assets/CameraPlus.svg', onTap: () => onUploadChanged(true)),
  ]);

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _dropdown({String? value, required String hint, required List<String> items, required Function(String?) onChanged}) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, hint: Text(hint, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF99AAB7).withValues(alpha: 0.5))), icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)), isExpanded: true, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged)),
  );
}
