import '../../../core/network/api_client.dart';

class ChatUnreadService {
  final ApiClient _api = ApiClient();

  /// Total unread chat messages across every visible thread.
  Future<int> unreadCount() async {
    final res = await _api.dio.get('/chat/unread-count/');
    final data = res.data as Map<String, dynamic>;
    return (data['unread'] ?? 0) as int;
  }
}
