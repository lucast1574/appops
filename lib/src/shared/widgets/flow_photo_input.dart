import 'package:flutter/material.dart';
import '../../core/network/photo_upload_helper.dart';
import 'flow_form_widgets.dart';
import 'flow_upload_button.dart';

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
            : FlowUploadButton(
                text: buttonText,
                iconAsset: iconAsset!,
                onTap: () async {
                  final result = await PhotoUploadHelper.pickAndUploadWithChoice(
                    taskId: taskId,
                    label: photoLabel,
                    context: context,
                  );
                  if (result != null) onChanged(true, result);
                },
              ),
      ],
    );
  }
}
