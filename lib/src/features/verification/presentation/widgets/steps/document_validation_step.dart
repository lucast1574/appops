import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/verification_upload_button.dart';
import '../shared/verification_step_navigation.dart';

class DocumentValidationStep extends StatelessWidget {
  final bool dniUploaded;
  final String? dniTag;
  final bool breveteUploaded;
  final String? breveteTag;
  final bool reciboUploaded;
  final String? reciboTag;
  final Function(bool) onDniUploadedChanged;
  final Function(String?) onDniTagChanged;
  final Function(bool) onBreveteUploadedChanged;
  final Function(String?) onBreveteTagChanged;
  final Function(bool) onReciboUploadedChanged;
  final Function(String?) onReciboTagChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DocumentValidationStep({
    super.key,
    required this.dniUploaded,
    this.dniTag,
    required this.breveteUploaded,
    this.breveteTag,
    required this.reciboUploaded,
    this.reciboTag,
    required this.onDniUploadedChanged,
    required this.onDniTagChanged,
    required this.onBreveteUploadedChanged,
    required this.onBreveteTagChanged,
    required this.onReciboUploadedChanged,
    required this.onReciboTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValidationSection(
                  'DNI',
                  isUploaded: dniUploaded,
                  child: dniUploaded
                      ? _buildImagePreview(
                          'Imagen-x122.png',
                          dniTag,
                          onDeleteImage: () {
                            onDniUploadedChanged(false);
                            onDniTagChanged(null);
                          },
                          onDeleteTag: () => onDniTagChanged(null),
                          onTagAdded: (val) => onDniTagChanged(val),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: VerificationUploadButton(
                                text: 'Tomar foto',
                                icon: Icons.add_a_photo_outlined,
                                onTap: () => onDniUploadedChanged(true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: VerificationUploadButton(
                                text: 'Subir archivo',
                                icon: Icons.file_upload_outlined,
                                onTap: () => onDniUploadedChanged(true),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  'Brevete',
                  isUploaded: breveteUploaded,
                  child: breveteUploaded
                      ? _buildImagePreview(
                          'Brevete-scan.png',
                          breveteTag,
                          onDeleteImage: () {
                            onBreveteUploadedChanged(false);
                            onBreveteTagChanged(null);
                          },
                          onDeleteTag: () => onBreveteTagChanged(null),
                          onTagAdded: (val) => onBreveteTagChanged(val),
                        )
                      : VerificationUploadButton(
                          text: 'Tomar foto',
                          icon: Icons.add_a_photo_outlined,
                          isFullWidth: true,
                          onTap: () => onBreveteUploadedChanged(true),
                        ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  'Recibo de servicios',
                  isUploaded: reciboUploaded,
                  child: reciboUploaded
                      ? _buildImagePreview(
                          'Recibo-digital.png',
                          reciboTag,
                          onDeleteImage: () {
                            onReciboUploadedChanged(false);
                            onReciboTagChanged(null);
                          },
                          onDeleteTag: () => onReciboTagChanged(null),
                          onTagAdded: (val) => onReciboTagChanged(val),
                        )
                      : VerificationUploadButton(
                          text: 'Tomar foto',
                          icon: Icons.add_a_photo_outlined,
                          isFullWidth: true,
                          onTap: () => onReciboUploadedChanged(true),
                        ),
                ),
              ],
            ),
          ),
        ),
        VerificationStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }

  Widget _buildValidationSection(String title, {required Widget child, bool isUploaded = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
              ),
              if (isUploaded)
                Row(
                  children: [
                    Text(
                      'Ver imagen',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF002B4B), decoration: TextDecoration.underline),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, color: Color(0xFF27A376), size: 16),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildImagePreview(
    String fileName,
    String? tag, {
    required VoidCallback onDeleteImage,
    required VoidCallback onDeleteTag,
    required Function(String) onTagAdded,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFB9DBE1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_outlined, color: Color(0xFF002B4B))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFE35959)),
                onPressed: onDeleteImage,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        tag != null
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(tag, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF002B4B))),
                            backgroundColor: const Color(0xFFB9DBE1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                            deleteIcon: const Icon(Icons.close, size: 14, color: Color(0xFF002B4B)),
                            onDeleted: onDeleteTag,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : TextField(
                onSubmitted: onTagAdded,
                decoration: InputDecoration(
                  hintText: 'Agregar etiqueta',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF002B4B))),
                ),
              ),
      ],
    );
  }
}
