import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/chat_inbox_service.dart';
import 'chat_page.dart';

/// Per-task chat inbox: list every thread the operario participates in.
/// On tap it pushes [ChatPage].
class ChatInboxPage extends StatefulWidget {
  const ChatInboxPage({super.key});

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {
  static const _pollInterval = Duration(seconds: 15);

  final ChatInboxService _service = ChatInboxService();
  Timer? _pollTimer;
  bool _loading = true;
  List<Map<String, dynamic>> _threads = [];

  @override
  void initState() {
    super.initState();
    _refresh();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final items = await _service.list();
      if (!mounted) return;
      setState(() {
        _threads = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _fmtTime(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final sameDay = d.year == now.year && d.month == now.month && d.day == now.day;
      String two(int v) => v.toString().padLeft(2, '0');
      if (sameDay) return '${two(d.hour)}:${two(d.minute)}';
      return '${two(d.day)}/${two(d.month)}';
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
        title: Text(
          'Conversaciones',
          style: GoogleFonts.inter(
            color: const Color(0xFF002B4B),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E9EB).withValues(alpha: 0.5), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF4FA4B5),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF4FA4B5)));
    }
    if (_threads.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(Icons.forum_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Sin conversaciones',
              style: GoogleFonts.inter(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Los chats aparecerán cuando coordines con tu supervisor sobre una tarea.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _threads.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _buildTile(_threads[i]),
    );
  }

  Widget _buildTile(Map<String, dynamic> t) {
    final taskId = t['task_id'] as int? ?? 0;
    final meta = (t['task_meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final lastMessage = (t['last_message'] as Map?)?.cast<String, dynamic>();
    final unread = (t['unread_count'] as int?) ?? 0;
    final typeName = (meta['type'] is Map ? (meta['type'] as Map)['name'] as String? : null) ?? 'Tarea';
    final placa = meta['placa'] as String? ?? '';
    final clientName = meta['client_name'] as String? ?? '';
    final scheduledDate = meta['scheduled_date'] as String? ?? '';
    final isExtra = meta['is_extra'] == true;

    final subtitleBits = <String>[
      if (clientName.isNotEmpty) clientName else if (placa.isNotEmpty) placa,
      if (scheduledDate.isNotEmpty) scheduledDate,
    ];
    final preview = (lastMessage?['body'] as String?) ?? 'Sin mensajes aún';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(taskId: taskId, taskTitle: typeName),
            ),
          );
          if (mounted) _refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FA4B5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  _iconForSlug(meta['type'] is Map ? (meta['type'] as Map)['slug'] as String? : null),
                  width: 22, height: 22,
                  colorFilter: const ColorFilter.mode(Color(0xFF4FA4B5), BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            typeName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002B4B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isExtra) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                            ),
                            child: Text(
                              'EXTRA',
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        Text(
                          _fmtTime(t['last_message_at'] as String? ?? t['created_at'] as String?),
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    if (subtitleBits.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleBits.join(' · '),
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: unread > 0 ? const Color(0xFF002B4B) : Colors.grey.shade500,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (unread > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _iconForSlug(String? slug) {
    switch (slug) {
      case 'verificacion':       return 'assets/check.svg';
      case 'recupero':           return 'assets/car.svg';
      case 'entrega':            return 'assets/entrega.svg';
      case 'conversion':         return 'assets/GasPump.svg';
      case 'traslado':           return 'assets/traslado.svg';
      case 'verificar_vehiculo': return 'assets/verificar.svg';
      case 'notaria':            return 'assets/notaria.svg';
      case 'gestiones':          return 'assets/gestiones.svg';
      default:                   return 'assets/List.svg';
    }
  }
}
