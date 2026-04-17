import '../../../core/network/api_client.dart';

/// Task service — connects to the Django backend.
/// Every operario only sees their own tasks
/// (backend filters by assigned_to=request.user).
class TaskService {
  final ApiClient _api = ApiClient();

  // ---------------------------------------------------------------
  // Task list (GET /tasks/)
  // ---------------------------------------------------------------

  /// Fetch tasks assigned to the current operario.
  /// Optional filters: [status], [mainStatus], [type], [date].
  Future<List<Map<String, dynamic>>> getMyTasks({
    String? status,
    String? mainStatus,
    String? type,
    String? date,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (mainStatus != null) params['main_status'] = mainStatus;
    if (type != null) params['type'] = type;
    if (date != null) params['date'] = date;

    final response = await _api.dio.get(
      '/tasks/',
      queryParameters: params,
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Fetch today's tasks for the operario.
  Future<List<Map<String, dynamic>>> getTodayTasks() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getMyTasks(date: dateStr);
  }

  // ---------------------------------------------------------------
  // Task detail (GET /tasks/{id}/)
  // ---------------------------------------------------------------

  /// Fetch full task detail including photos and result.
  Future<Map<String, dynamic>> getTaskDetail(int taskId) async {
    final response = await _api.dio.get('/tasks/$taskId/');
    return Map<String, dynamic>.from(response.data);
  }

  // ---------------------------------------------------------------
  // Task actions
  // ---------------------------------------------------------------

  /// Start a task (marks it as in_progress).
  Future<Map<String, dynamic>> startTask(int taskId) async {
    final response = await _api.dio.post('/tasks/$taskId/start/');
    return Map<String, dynamic>.from(response.data);
  }

  /// Submit completed task with result data.
  Future<Map<String, dynamic>> submitTask(
    int taskId, {
    Map<String, dynamic> resultData = const {},
    Map<String, dynamic> checklistData = const {},
    String observations = '',
  }) async {
    final response = await _api.dio.post(
      '/tasks/$taskId/submit/',
      data: {
        'result_data': resultData,
        'checklist_data': checklistData,
        'observations': observations,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  /// Reschedule a task (e.g., nobody home during verification).
  Future<Map<String, dynamic>> rescheduleTask(
    int taskId, {
    String reason = '',
  }) async {
    final response = await _api.dio.post(
      '/tasks/$taskId/reschedule/',
      data: {'reason': reason},
    );
    return Map<String, dynamic>.from(response.data);
  }

  // ---------------------------------------------------------------
  // Photo uploads (S3 presigned URLs)
  // ---------------------------------------------------------------

  /// Request a presigned S3 URL for uploading a photo.
  /// Returns { 'upload_url': String, 's3_key': String }.
  Future<Map<String, dynamic>> requestUploadUrl(
    int taskId, {
    required String label,
    String contentType = 'image/jpeg',
  }) async {
    final response = await _api.dio.post(
      '/tasks/$taskId/photos/request-url/',
      data: {
        'label': label,
        'content_type': contentType,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  /// Confirm that a photo was uploaded to S3.
  Future<Map<String, dynamic>> confirmUpload(
    int taskId, {
    required String s3Key,
    required String label,
    String tag = '',
  }) async {
    final response = await _api.dio.post(
      '/tasks/$taskId/photos/confirm/',
      data: {
        's3_key': s3Key,
        'label': label,
        'tag': tag,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------

  /// Map task type slug to display icon asset.
  static String getIconForType(String? slug) {
    switch (slug) {
      case 'verificacion':
        return 'assets/check.svg';
      case 'recupero':
        return 'assets/car.svg';
      case 'entrega':
        return 'assets/entrega.svg';
      case 'conversion':
        return 'assets/GasPump.svg';
      case 'traslado':
        return 'assets/traslado.svg';
      case 'verificar_vehiculo':
        return 'assets/verificar.svg';
      case 'notaria':
        return 'assets/notaria.svg';
      case 'gestiones':
        return 'assets/gestiones.svg';
      default:
        return 'assets/check.svg';
    }
  }

  /// Map backend status to Spanish display label.
  static String getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'in_progress':
        return 'En curso';
      case 'completed':
        return 'Completada';
      case 'rejected':
        return 'Rechazada';
      case 'rescheduled':
        return 'Reprogramada';
      default:
        return status ?? '';
    }
  }

  /// Format time from "HH:MM:SS" to "HH:MM".
  static String formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }
}
