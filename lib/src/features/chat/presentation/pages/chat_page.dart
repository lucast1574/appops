import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  String? _currentUserPhoto;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Try to read user data from secure storage.
    try {
      final raw = await _storage.read(key: 'user_data');
      if (raw != null) {
        final Map<String, dynamic> user = jsonDecode(raw);
        if (user.containsKey('id')) {
          _currentUserId = user['id'] as int?;
        }
        if (user.containsKey('profile_picture')) {
          _currentUserPhoto = user['profile_picture']?.toString();
        }
      }
    } catch (_) {
      // If user_data is not JSON or other error, fallback
    }
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
        scrolledUnderElevation: 0,
        centerTitle: false,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF002B4B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat de Tarea',
              style: GoogleFonts.inter(
                color: const Color(0xFF002B4B),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.taskTitle != null && widget.taskTitle!.isNotEmpty)
              Text(
                widget.taskTitle!,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFF002B4B)));
    }
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chat_bubble_outline_rounded, size: 40, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Text(
                'Sin mensajes aún',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Comienza la conversación con tu supervisor sobre esta tarea.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildBubble(_messages[i]),
    );
  }

  Widget _buildBubble(Map<String, dynamic> m) {
    final isSystem = m['is_system'] ?? false;
    if (isSystem) {
      final body = (m['body'] as String?) ?? '';
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.computer,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    body,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMe = m['sender_id'] == _currentUserId;
    final senderName = (m['sender_name'] as String?) ?? '';
    final senderPhoto = (m['sender_profile_picture'] ?? m['sender_photo_url'] ?? m['profile_picture'] as String?)?.toString();
    final body = (m['body'] as String?) ?? '';
    final time = _formatTime(m['created_at']);

    // Get my photo if isMe
    final photoUrl = isMe ? _currentUserPhoto : senderPhoto;

    // Get initials for avatar fallback
    String initials = 'S';
    if (senderName.isNotEmpty) {
      final parts = senderName.trim().split(' ');
      if (parts.length > 1) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    } else if (isMe) {
      initials = 'YO';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(
                          initials,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe && senderName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          senderName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF002B4B) : Colors.white,
                          gradient: isMe ? const LinearGradient(
                            colors: [Color(0xFF003D6B), Color(0xFF002B4B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ) : null,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: isMe ? null : Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              body,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.4,
                                color: isMe ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isMe ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF002B4B),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Text(
                          initials,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFB),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: Color(0xFF002B4B),
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF003D6B), Color(0xFF002B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _sending ? null : _send,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
