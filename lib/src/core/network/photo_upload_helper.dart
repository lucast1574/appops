import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/home/data/task_service.dart';

/// Helper for picking images and uploading them to S3 via presigned URLs.
class PhotoUploadHelper {
  static final TaskService _taskService = TaskService();
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from camera or gallery, upload to S3, and confirm.
  /// Returns the s3_key on success, or null on failure/cancel.
  static Future<String?> pickAndUpload({
    required int taskId,
    required String label,
    String tag = '',
    ImageSource source = ImageSource.camera,
  }) async {
    try {
      // 1. Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null) return null; // User cancelled

      // 2. Request presigned URL from backend
      final String contentType = _getContentType(image.path);
      final urlData = await _taskService.requestUploadUrl(
        taskId,
        label: label,
        contentType: contentType,
      );
      final String uploadUrl = urlData['upload_url'];
      final String s3Key = urlData['s3_key'];

      // 3. Upload to S3
      final Uint8List bytes = await image.readAsBytes();
      await Dio().put(
        uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
        ),
      );

      // 4. Confirm upload in backend
      await _taskService.confirmUpload(
        taskId,
        s3Key: s3Key,
        label: label,
        tag: tag,
      );

      return s3Key;
    } catch (e) {
      // Log error but don't crash
      assert(() {
        // ignore: avoid_print
        print('[PhotoUpload] Error: $e');
        return true;
      }());
      return null;
    }
  }

  /// Show a bottom sheet to choose between camera and gallery.
  static Future<String?> pickAndUploadWithChoice({
    required int taskId,
    required String label,
    String tag = '',
    required dynamic context, // BuildContext
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4FA4B5)),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF4FA4B5)),
                title: const Text('Elegir de galer\u00eda'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return null;

    return pickAndUpload(
      taskId: taskId,
      label: label,
      tag: tag,
      source: source,
    );
  }

  static String _getContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }
}
