import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class NotaryReceiveDocsStep extends StatelessWidget {
  final bool photoUploaded;
  final String? photoTag;
  final TextEditingController receiverNameController;
  final Function(bool) onPhotoUploadedChanged;
  final Function(String?) onPhotoTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const NotaryReceiveDocsStep({
    super.key,
    required this.photoUploaded,
    this.photoTag,
    required this.receiverNameController,
    required this.onPhotoUploadedChanged,
    required this.onPhotoTagChanged,
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
                  'Recibir documentos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      'Foto documentos recibidos:',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                    const Spacer(),
                    if (!photoUploaded)
                      Text(
                        'Sin imagen',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF99AAB7),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                photoUploaded
                    ? FlowImagePreview(
                        fileName: 'documentos.png',
                        tag: photoTag,
                        onDeleteImage: () {
                          onPhotoUploadedChanged(false);
                          onPhotoTagChanged(null);
                        },
                        onDeleteTag: () => onPhotoTagChanged(null),
                        onTagAdded: (val) => onPhotoTagChanged(val),
                      )
                    : FlowUploadButton(
                        text: 'Tomar foto',
                        iconAsset: 'assets/CameraPlus.svg',
                        onTap: () => onPhotoUploadedChanged(true),
                      ),
                const SizedBox(height: 24),
                Text(
                  'Nombre de quien recibe',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: receiverNameController,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF002B4B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Foto persona',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF002B4B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }
}
