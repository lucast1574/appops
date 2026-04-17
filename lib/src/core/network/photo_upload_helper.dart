import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/home/data/task_service.dart';

/// Helper for picking images and uploading them to S3 via presigned URLs.
class PhotoUploadHelper {
  static final TaskService _taskService = TaskService();
  static final ImagePicker _picker = ImagePicker();

  /// Take a photo with the camera, upload to S3, and confirm.
  /// Returns a Map with {'s3Key': string, 'localPath': string} on success, or null on failure.
  static Future<Map<String, String>?> pickAndUpload({
    required int taskId,
    required String label,
    String tag = '',
  }) async {
    const ImageSource source = ImageSource.camera;
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

      return {
        's3Key': s3Key,
        'localPath': image.path,
      };
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

  /// Take a photo with the camera and upload it.
  /// Always uses camera — no gallery option (policy: all photos must be
  /// taken on-site by the operario, not uploaded from storage).
  static Future<Map<String, String>?> pickAndUploadWithChoice({
    required int taskId,
    required String label,
    String tag = '',
    required dynamic context, // BuildContext
  }) async {
    return pickAndUpload(taskId: taskId, label: label, tag: tag);
  }

  static String _getContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }
}
