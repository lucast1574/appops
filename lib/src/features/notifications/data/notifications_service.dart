import '../../../core/network/api_client.dart';

/// HTTP client for the in-app notifications endpoints
/// (`GET /api/v1/notifications/`, etc).
///
/// All methods return raw `Map<String, dynamic>` / `List` like the rest
/// of the codebase to keep this drop-in friendly without freezed.
class NotificationsService {
  final ApiClient _api = ApiClient();

  /// Fetch a page of notifications for the current user.
  /// Set [unreadOnly] to limit to unread items.
  Future<List<Map<String, dynamic>>> list({
    bool unreadOnly = false,
    int limit = 50,
    int? beforeId,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (unreadOnly) params['unread_only'] = 1;
    if (beforeId != null) params['before_id'] = beforeId;

    final res = await _api.dio.get('/notifications/', queryParameters: params);
    final data = res.data as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return items;
  }

  /// Number of unread notifications — used for the bell badge.
  Future<int> unreadCount() async {
    final res = await _api.dio.get('/notifications/unread-count/');
    final data = res.data as Map<String, dynamic>;
    return (data['unread'] ?? 0) as int;
  }

  /// Mark one notification as read.
  Future<Map<String, dynamic>> markRead(int id) async {
    final res = await _api.dio.post('/notifications/$id/read/');
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Mark every unread notification of the user as read.
  Future<int> markAllRead() async {
    final res = await _api.dio.post('/notifications/mark-all-read/');
    final data = res.data as Map<String, dynamic>;
    return (data['updated'] ?? 0) as int;
  }

  /// Permanently delete a notification.
  Future<void> remove(int id) async {
    await _api.dio.delete('/notifications/$id/');
  }
}
