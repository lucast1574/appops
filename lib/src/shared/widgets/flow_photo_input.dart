import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/photo_upload_helper.dart';
import '../../features/home/data/task_service.dart';
import 'flow_form_widgets.dart';

/// A standardized photo input widget that handles both the upload button
/// and the image preview with tagging.
///
/// While the photo is being uploaded the button shows a spinner + "Subiendo
/// foto..." so the operator knows the app is doing something. Tapping is
/// disabled during the upload to avoid double-taps that would launch the
/// camera twice.
///
/// When [photoId] is provided, any tag change is persisted to the backend
/// via PATCH /tasks/{taskId}/photos/{photoId}/tag/ so the backoffice can
/// see the operator's labels.
class FlowPhotoInput extends StatefulWidget {
  final String label;
  final int taskId;
  final String photoLabel;
  final String previewFileName;
  final bool isUploaded;
  final String? imagePath;
  final String? tag;
  /// Backend ID of the TaskPhoto record (returned by confirm_upload).
  /// When non-null, tag changes are synced to the backend automatically.
  final int? photoId;
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
    this.photoId,
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
  final TaskService _taskService = TaskService();

  Future<void> _handleTap() async {
    if (_isUploading) return;
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

  /// Notifies the parent and, if a [photoId] is known, persists the tag
  /// to the backend so the backoffice can see the operator's label.
  void _handleTagChanged(String? newTag) {
    widget.onTagChanged(newTag);
    final int? photoId = widget.photoId;
    if (photoId != null) {
      _taskService.updatePhotoTag(
        widget.taskId,
        photoId: photoId,
        tag: newTag ?? '',
      ).catchError((e) {
        debugPrint('[FlowPhotoInput] updatePhotoTag failed: $e');
      });
    }
  }

  void _showImageDialog(BuildContext context) {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.imagePath!.startsWith('http')
                    ? Image.network(
                        widget.imagePath!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          );
                        },
                      )
                    : Image.file(
                        File(widget.imagePath!),
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FlowSectionLabel(label: widget.label),
            if (widget.isUploaded && widget.imagePath != null && widget.imagePath!.isNotEmpty)
              GestureDetector(
                onTap: () => _showImageDialog(context),
                child: Text(
                  'Ver imagen',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF4FA4B5),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        widget.isUploaded
            ? FlowImagePreview(
                fileName: widget.previewFileName,
                imagePath: widget.imagePath,
                tag: widget.tag,
                onDeleteImage: () => widget.onChanged(false, null),
                onDeleteTag: () => _handleTagChanged(null),
                onTagAdded: (val) => _handleTagChanged(val),
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
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF002B4B)),
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
                            SvgPicture.asset(widget.iconAsset!, width: 32, height: 32),
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
