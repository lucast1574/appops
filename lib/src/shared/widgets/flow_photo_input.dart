import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/photo_upload_helper.dart';
import 'flow_form_widgets.dart';

/// A standardized photo input widget that handles both the upload button
/// and the image preview with tagging.
///
/// While the photo is being uploaded the button shows a spinner + "Subiendo
/// foto..." so the operator knows the app is doing something. Tapping is
/// disabled during the upload to avoid double-taps that would launch the
/// camera twice.
class FlowPhotoInput extends StatefulWidget {
  final String label;
  final int taskId;
  final String photoLabel;
  final String previewFileName;
  final bool isUploaded;
  final String? imagePath;
  final String? tag;
  final Function(bool, dynamic) onChanged;
  final Function(String?) onTagChanged;
  final String? iconAsset;
  final String buttonText;

  const FlowPhotoInput({
    super.key,
    required this.label,
    required this.taskId,
    required this.photoLabel,
    required this.previewFileName,
    required this.isUploaded,
    this.imagePath,
    this.tag,
    required this.onChanged,
    required this.onTagChanged,
    this.iconAsset = 'assets/CameraPlus.svg',
    this.buttonText = 'Tomar foto',
  });

  @override
  State<FlowPhotoInput> createState() => _FlowPhotoInputState();
}

class _FlowPhotoInputState extends State<FlowPhotoInput> {
  bool _isUploading = false;

  Future<void> _handleTap() async {
    if (_isUploading) return; // ignore double-taps
    setState(() => _isUploading = true);
    try {
      final result = await PhotoUploadHelper.pickAndUploadWithChoice(
        taskId: widget.taskId,
        label: widget.photoLabel,
        context: context,
      );
      if (!mounted) return;
      if (result != null) {
        widget.onChanged(true, result);
      } else {
        // result == null means either the user cancelled the camera (silent)
        // or the upload failed (logged via developer.log). Show a snackbar
        // so the operator at least gets *some* feedback instead of nothing.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo subir la foto. Intenta de nuevo.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowSectionLabel(label: widget.label),
        const SizedBox(height: 12),
        widget.isUploaded
            ? FlowImagePreview(
                fileName: widget.previewFileName,
                imagePath: widget.imagePath,
                tag: widget.tag,
                onDeleteImage: () => widget.onChanged(false, null),
                onDeleteTag: () => widget.onTagChanged(null),
                onTagAdded: (val) => widget.onTagChanged(val),
              )
            : GestureDetector(
                onTap: _handleTap,
                child: Container(
                  width: double.infinity,
                  height: 88,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isUploading
                        ? const Color(0xFFD6E7EB)
                        : const Color(0xFFE3F0F3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFB9DBE1).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _isUploading
                        ? [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF002B4B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Subiendo foto...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF002B4B),
                              ),
                            ),
                          ]
                        : [
                            SvgPicture.asset(
                              widget.iconAsset!,
                              width: 32,
                              height: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.buttonText,
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
      ],
    );
  }
}
