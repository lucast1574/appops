import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../features/home/data/task_service.dart';

/// Centralised logger so upload errors are visible in release builds too
/// (assert(print) silently swallows them in release, which is what made
/// the original bug invisible to operators).
void _log(String msg) {
  developer.log(msg, name: 'PhotoUpload');
}

/// Helper for picking images and uploading them to S3 via presigned URLs.
class PhotoUploadHelper {
  static final TaskService _taskService = TaskService();
  static final ImagePicker _picker = ImagePicker();

  /// Take a photo with the camera, upload to S3, and confirm.
  /// Returns a Map with {'s3Key': string, 'localPath': string, 'downloadUrl': string} on success, or null on failure.
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

      // 3. Upload to S3 (PUT presigned). Send raw bytes; do NOT set
      // Content-Length manually because Dio handles it from the byte
      // payload. Manually setting it together with a streamed source
      // is what used to make S3 reject the request with a 403.
      final Uint8List bytes = await image.readAsBytes();
      final s3Response = await Dio().put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
          },
          // Treat any non-2xx as failure so we don't silently move on
          // and "confirm" a phantom S3 object.
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );
      _log('S3 PUT OK status=${s3Response.statusCode} key=$s3Key bytes=${bytes.length}');

      // 4. Confirm upload in backend
      final confirm = await _taskService.confirmUpload(
        taskId,
        s3Key: s3Key,
        label: label,
        tag: tag,
      );

      return {
        's3Key': s3Key,
        'localPath': image.path,
        'downloadUrl': confirm['download_url'] ?? '',
      };
    } on DioException catch (e) {
      _log('DioException uploading photo: status=${e.response?.statusCode} '
          'data=${e.response?.data} message=${e.message}');
      return null;
    } catch (e, st) {
      _log('Error uploading photo: $e\n$st');
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

  /// Upload an existing file (e.g. signature) to S3.
  /// Returns the download URL on success.
  static Future<String?> uploadFile({
    required int taskId,
    required String label,
    required String filePath,
  }) async {
    try {
      final String contentType = _getContentType(filePath);
      final urlData = await _taskService.requestUploadUrl(
        taskId,
        label: label,
        contentType: contentType,
      );
      final String uploadUrl = urlData['upload_url'];
      final String s3Key = urlData['s3_key'];

      final Uint8List bytes = await File(filePath).readAsBytes();
      await Dio().put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
          },
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );

      final confirm = await _taskService.confirmUpload(
        taskId,
        s3Key: s3Key,
        label: label,
      );

      return confirm['download_url'];
    } on DioException catch (e) {
      _log('DioException uploading file: status=${e.response?.statusCode} '
          'data=${e.response?.data} message=${e.message}');
      return null;
    } catch (e, st) {
      _log('Error uploading file: $e\n$st');
      return null;
    }
  }

  static String _getContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }
}
