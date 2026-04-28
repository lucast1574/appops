import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/chat_service.dart';

/// Per-task chat between operario and supervisors.
///
/// Polls every 8 seconds while open. Uses optimistic append on send.
class ChatPage extends StatefulWidget {
  final int taskId;
  final String? taskTitle;

  const ChatPage({super.key, required this.taskId, this.taskTitle});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _pollInterval = Duration(seconds: 8);

  final ChatService _service = ChatService();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Timer? _pollTimer;
  bool _loading = true;
  bool _sending = false;
  int? _currentUserId;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Try to read user_id from secure storage. If not there, fall back
    // to id 0 (server still works; bubbles will just not be styled as "me").
    try {
      final raw = await _storage.read(key: 'user_id');
      if (raw != null) _currentUserId = int.tryParse(raw);
    } catch (_) {}
    await _refresh(initial: true);
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool initial = false}) async {
    try {
      final after = initial ? null : (_messages.isNotEmpty ? _messages.last['id'] as int? : null);
      final fresh = await _service.listMessages(
        widget.taskId,
        afterId: after,
        limit: initial ? 200 : 100,
      );
      if (!mounted) return;
      setState(() {
        if (initial) {
          _messages = fresh;
        } else if (fresh.isNotEmpty) {
          _messages = [..._messages, ...fresh];
        }
        _loading = false;
      });
      if (fresh.any((m) => m['sender_id'] != _currentUserId)) {
        try { await _service.markRead(widget.taskId); } catch (_) {}
      }
      if (initial || fresh.isNotEmpty) _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final msg = await _service.sendMessage(widget.taskId, body);
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, msg];
        _input.clear();
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el mensaje')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
      String two(int v) => v.toString().padLeft(2, '0');
      if (sameDay) {
        return '${two(d.hour)}:${two(d.minute)}';
      }
      return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF002B4B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chat',
              style: GoogleFonts.inter(
                color: const Color(0xFF002B4B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.taskTitle != null && widget.taskTitle!.isNotEmpty)
              Text(
                widget.taskTitle!,
                style: GoogleFonts.inter(
                  color: const Color(0xFF99AAB7),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E9EB).withValues(alpha: 0.6), height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4FA4B5)));
    }
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Aún no hay mensajes',
                style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Escribe a tu supervisor cualquier duda sobre la tarea.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(Map<String, dynamic> m) {
    final isMe = m['sender_id'] == _currentUserId;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final senderName = (m['sender_name'] as String?) ?? '';
    final body = (m['body'] as String?) ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              isMe ? 'Tú · ${_formatTime(m['created_at'])}' :
                     '${senderName.isNotEmpty ? senderName : "Supervisor"} · ${_formatTime(m['created_at'])}',
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 2),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF4FA4B5) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe ? null : Border.all(color: const Color(0xFFE5E9EB)),
              ),
              child: Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isMe ? Colors.white : const Color(0xFF002B4B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF1F4F6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF4FA4B5),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sending ? null : _send,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _sending
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
