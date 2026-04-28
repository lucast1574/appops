import '../../../core/network/api_client.dart';

class ChatInboxService {
  final ApiClient _api = ApiClient();

  /// Returns the threads visible to the current user, with metadata
  /// for the inbox tile (last message preview + unread count + task type).
  Future<List<Map<String, dynamic>>> list() async {
    final res = await _api.dio.get('/chat/inbox/');
    final data = res.data as Map<String, dynamic>;
    return (data['items'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
