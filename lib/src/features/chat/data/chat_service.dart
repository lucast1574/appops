import '../../../core/network/api_client.dart';

/// Per-task chat client. Polling-based; the page calls [listMessages]
/// every ~8s while it's open.
class ChatService {
  final ApiClient _api = ApiClient();

  Future<List<Map<String, dynamic>>> listMessages(
    int taskId, {
    int? afterId,
    int limit = 100,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (afterId != null) params['after_id'] = afterId;
    final res = await _api.dio.get(
      '/chat/threads/$taskId/messages/',
      queryParameters: params,
    );
    final data = res.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> sendMessage(int taskId, String body) async {
    final res = await _api.dio.post(
      '/chat/threads/$taskId/messages/',
      data: {'body': body},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> markRead(int taskId) async {
    await _api.dio.post('/chat/threads/$taskId/read/');
  }
}
