import 'dart:developer' as developer;
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
  ///
  /// Memory-conscious flow (for low-end Android: 2 GB RAM, ~64 MB heap):
  ///  - image_picker resizes to <=1600x1600 q75 inside the platform plugin
  ///    (native, off-heap), so the Dart side only ever sees a ~250 KB JPEG.
  ///  - We stream the file to S3 with Dio (no full readAsBytes) so we never
  ///    hold the encoded payload AND a decoded bitmap at the same time.
  ///
  /// We deliberately do NOT delete image_picker's tmp file after the upload:
  /// the UI keeps showing the picked photo via Image.file(localPath) until
  /// the user navigates away, and image_picker's cache lives under the app's
  /// own cacheDir which Android trims automatically when storage is low.
  static Future<Map<String, String>?> pickAndUpload({
    required int taskId,
    required String label,
    String tag = '',
  }) async {
    const ImageSource source = ImageSource.camera;
    try {
      // 1. Pick image. Smaller bounds + lower quality means the camera plugin
      // hands us a ~250 KB JPEG instead of a 1-2 MB one. This is the single
      // biggest knob for memory pressure on cheap devices, because the decoded
      // ARGB bitmap is width * height * 4 bytes (1920^2*4 = 14.7 MB,
      // 1600^2*4 = 10.2 MB).
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 75,
      );
      if (image == null) return null; // User cancelled

      // 2. Request presigned URL from backend
      final String contentType = _getContentType(image.path);
      final File sourceFile = File(image.path);
      final int fileLength = await sourceFile.length();
      _log('Picked image path=${image.path} bytes=$fileLength');

      final urlData = await _taskService.requestUploadUrl(
        taskId,
        label: label,
        contentType: contentType,
      );
      final String uploadUrl = urlData['upload_url'];
      final String s3Key = urlData['s3_key'];

      // 3. Upload to S3 (PUT presigned). Stream the file instead of
      // readAsBytes() so we don't hold the full payload in the Dart heap.
      // Dio with a Stream<List<int>> + an explicit Content-Length is the
      // shape AWS S3 expects for presigned PUTs (chunked transfer-encoding
      // is rejected with 501).
      final s3Response = await Dio().put(
        uploadUrl,
        data: sourceFile.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            Headers.contentLengthHeader: fileLength,
          },
          // Treat any non-2xx as failure so we don't silently move on
          // and "confirm" a phantom S3 object.
          validateStatus: (status) => status != null && status >= 200 && status < 300,
        ),
      );
      _log('S3 PUT OK status=${s3Response.statusCode} key=$s3Key bytes=$fileLength');

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
        'photoId': confirm['id']?.toString() ?? '',
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

      // Stream from disk; see pickAndUpload for the same rationale.
      final File sourceFile = File(filePath);
      final int fileLength = await sourceFile.length();
      await Dio().put(
        uploadUrl,
        data: sourceFile.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            Headers.contentLengthHeader: fileLength,
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
