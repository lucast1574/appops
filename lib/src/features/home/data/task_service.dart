import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

/// Tiny in-memory cache entry for dashboard tasks.
/// Keeps the previous response for [TaskService._cacheTtl] so reopening the
/// dashboard from another page doesn't trigger a fresh roundtrip.
class _TasksCacheEntry {
  _TasksCacheEntry(this.key, this.value, this.expiresAt);
  final String key;
  final List<Map<String, dynamic>> value;
  final DateTime expiresAt;
  bool get isFresh => DateTime.now().isBefore(expiresAt);
}

/// Task service — connects to the Django backend.
/// Every operario only sees their own tasks
/// (backend filters by assigned_to=request.user).
class TaskService {
  final ApiClient _api = ApiClient();

  // ---------------------------------------------------------------
  // Lightweight cache for repeated GET /tasks/ calls. The dashboard
  // hits this endpoint on every push/pop, which used to refetch the
  // entire active task list (potentially hundreds of rows). 30 s of
  // freshness keeps the UI snappy without showing stale data.
  // ---------------------------------------------------------------
  static const Duration _cacheTtl = Duration(seconds: 30);
  _TasksCacheEntry? _tasksCache;

  /// Force-invalidate the cache (call after start/submit/reschedule).
  void invalidateTasksCache() {
    _tasksCache = null;
  }

  // ---------------------------------------------------------------
  // Task list (GET /tasks/)
  // ---------------------------------------------------------------

  /// Fetch tasks assigned to the current operario.
  /// Optional filters: [status], [mainStatus], [type], [date].
  /// By default the backend already excludes completed/rejected/cancelled
  /// (set [includeHistory] true to bypass that and ask for everything).
  Future<List<Map<String, dynamic>>> getMyTasks({
    String? status,
    String? mainStatus,
    String? type,
    String? date,
    bool includeHistory = false,
    bool useCache = true,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (mainStatus != null) params['main_status'] = mainStatus;
    if (type != null) params['type'] = type;
    if (date != null) params['date'] = date;
    if (includeHistory) params['include_history'] = '1';

    // Cache key includes the filters so different views don't collide.
    final cacheKey = params.entries
        .map((e) => '${e.key}=${e.value}')
        .toList()
      ..sort();
    final keyStr = cacheKey.join('&');

    if (useCache && _tasksCache != null &&
        _tasksCache!.key == keyStr && _tasksCache!.isFresh) {
      return _tasksCache!.value;
    }

    final response = await _api.dio.get(
      '/tasks/',
      queryParameters: params,
    );
    final data = List<Map<String, dynamic>>.from(response.data);
    _tasksCache = _TasksCacheEntry(
      keyStr, data, DateTime.now().add(_cacheTtl),
    );
    return data;
  }

  /// Paginated historical tasks (completed/rejected/cancelled).
  /// Use [page] starting at 1. Backend caps page_size at 100.
  /// Returns the raw payload: { count, page, page_size, has_next, items }.
  Future<Map<String, dynamic>> getTaskHistory({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? since,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'page_size': '$pageSize',
    };
    if (type != null) params['type'] = type;
    if (since != null) params['since'] = since;

    final response = await _api.dio.get(
      '/tasks/history/',
      queryParameters: params,
    );
    return Map<String, dynamic>.from(response.data);
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
    invalidateTasksCache();
    return Map<String, dynamic>.from(response.data);
  }

  /// Save intermediate progress (step and draft data).
  Future<Map<String, dynamic>> updateProgress(
    int taskId, {
    int? currentStep,
    Map<String, dynamic> draftData = const {},
  }) async {
    final data = <String, dynamic>{
      'draft_data': draftData,
    };
    if (currentStep != null) data['current_step'] = currentStep;

    final response = await _api.dio.post(
      '/tasks/$taskId/progress/',
      data: data,
    );
    return Map<String, dynamic>.from(response.data);
  }

  /// Submit completed task with result data.
  Future<Map<String, dynamic>> submitTask(
    int taskId, {
    Map<String, dynamic> resultData = const {},
    Map<String, dynamic> checklistData = const {},
    dynamic observations,
    Map<String, dynamic> signatures = const {},
  }) async {
    final response = await _api.dio.post(
      '/tasks/$taskId/submit/',
      data: {
        'result_data': resultData,
        'checklist_data': checklistData,
        'observations': observations,
        'signatures': signatures,
      },
    );
    invalidateTasksCache();
    return Map<String, dynamic>.from(response.data);
  }

  /// Reschedule a task (e.g., nobody home during verification).
  Future<Map<String, dynamic>> rescheduleTask(
    int taskId, {
    String reason = '',
    Map<String, dynamic>? resultData,
    Map<String, dynamic>? checklistData,
  }) async {
    final response = await _api.dio.post(
      '/tasks/$taskId/reschedule/',
      data: {
        'reason': reason,
        'result_data': resultData,
        'checklist_data': checklistData,
      }..removeWhere((_, value) => value == null),
    );
    invalidateTasksCache();
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

  /// Update the tag of an already-uploaded photo.
  /// Called after the operario types/changes the tag field.
  Future<void> updatePhotoTag(
    int taskId, {
    required int photoId,
    required String tag,
  }) async {
    await _api.dio.patch(
      '/tasks/$taskId/photos/$photoId/tag/',
      data: {'tag': tag},
    );
  }

  Future<void> uploadImageToS3(String url, List<int> bytes, {String contentType = 'image/png'}) async {
    // Use a fresh Dio instance to avoid sending the 'Authorization' header
    // from our ApiClient interceptor, which S3 rejects on presigned URLs.
    //
    // Do NOT set Content-Length manually: the backend signs the presigned
    // URL with only Content-Type as a signed header, so any manual
    // Content-Length that doesn't match the signed value (or that gets
    // double-set together with a streamed body) makes S3 reject the PUT
    // with 403 SignatureDoesNotMatch. Dio will set Content-Length itself
    // from the byte payload.
    await Dio().put(
      url,
      data: Uint8List.fromList(bytes),
      options: Options(
        headers: {
          'Content-Type': contentType,
        },
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
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
      case 'overdue':
        return '⚠ Atrasada';
      case 'missed':
        return '⛔ Faltante';
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
