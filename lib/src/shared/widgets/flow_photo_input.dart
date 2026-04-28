import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/photo_upload_helper.dart';
import 'flow_form_widgets.dart';

/// A standardized photo input widget that handles both the upload button 
/// and the image preview with tagging.
class FlowPhotoInput extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowSectionLabel(label: label),
        const SizedBox(height: 12),
        isUploaded
            ? FlowImagePreview(
                fileName: previewFileName,
                imagePath: imagePath,
                tag: tag,
                onDeleteImage: () => onChanged(false, null),
                onDeleteTag: () => onTagChanged(null),
                onTagAdded: (val) => onTagChanged(val),
              )
            : GestureDetector(
                onTap: () async {
                  final result = await PhotoUploadHelper.pickAndUploadWithChoice(
                    taskId: taskId,
                    label: photoLabel,
                    context: context,
                  );
                  if (result != null) {
                    onChanged(true, result);
                  }
                },
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
                        iconAsset!,
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        buttonText,
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
