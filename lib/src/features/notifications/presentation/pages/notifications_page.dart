import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../data/notifications_service.dart';

/// Real notifications screen.
///
/// Pulls `/api/v1/notifications/` on mount and on pull-to-refresh,
/// renders cards by `kind`, lets the user mark them read or delete
/// them, and exposes a "marcar todas como leídas" affordance in the
/// app bar.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationsService _service = NotificationsService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.list(limit: 50);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las notificaciones.';
        _loading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    final hasUnread = _items.any((n) => n['is_read'] == false);
    if (!hasUnread) return;
    setState(() {
      _items = _items.map((n) => {...n, 'is_read': true}).toList();
    });
    try {
      await _service.markAllRead();
    } catch (_) {
      // Swallow; UI optimism is fine — next refresh will reconcile.
    }
  }

  Future<void> _markRead(Map<String, dynamic> n) async {
    if (n['is_read'] == true) return;
    final id = n['id'] as int;
    setState(() {
      _items = _items
          .map((x) => x['id'] == id ? {...x, 'is_read': true} : x)
          .toList();
    });
    try {
      await _service.markRead(id);
    } catch (_) {
      // No rollback — the next refresh will fix it if it failed.
    }
  }

  Future<void> _remove(Map<String, dynamic> n) async {
    final id = n['id'] as int;
    final removed = _items.firstWhere((x) => x['id'] == id, orElse: () => {});
    setState(() {
      _items = _items.where((x) => x['id'] != id).toList();
    });
    try {
      await _service.remove(id);
    } catch (_) {
      // Restore on failure.
      if (removed.isNotEmpty) {
        setState(() => _items = [removed, ..._items]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => n['is_read'] == false).length;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF002B4B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificaciones',
          style: GoogleFonts.inter(
            color: const Color(0xFF002B4B),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Marcar todas',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4FA4B5),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E9EB).withValues(alpha: 0.5),
            height: 1,
          ),
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
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4FA4B5)),
      );
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.red.shade400),
              ),
            ),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(Icons.notifications_off_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Sin notificaciones por ahora',
              style: GoogleFonts.inter(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Te avisaremos cuando haya algo nuevo.',
              style: GoogleFonts.inter(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _NotificationCard(
        notification: _items[i],
        onTap: () => _markRead(_items[i]),
        onDismiss: () => _remove(_items[i]),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final kind = (notification['kind'] ?? 'system') as String;
    final isRead = notification['is_read'] == true;
    final title = (notification['title'] ?? '') as String;
    final body = (notification['body'] ?? '') as String;
    final createdAt = notification['created_at'] as String?;
    final data = (notification['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final isExtra = data['is_extra'] == true;

    final accent = _accentForKind(kind);
    final iconAsset = _iconAssetForKind(kind, data);

    return Dismissible(
      key: ValueKey(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade400),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : accent.withValues(alpha: 0.06),
            border: Border.all(
              color: isRead
                  ? const Color(0xFFE5E9EB).withValues(alpha: 0.6)
                  : accent.withValues(alpha: 0.35),
              width: isRead ? 1 : 1.2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: iconAsset != null
                    ? SvgPicture.asset(
                        iconAsset,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                      )
                    : Icon(_iconForKind(kind), color: accent, size: 22),
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
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF002B4B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.35,
                          color: const Color(0xFF6B7B85),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatRelative(createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        if (isExtra) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'EXTRA',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
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

  // ----- helpers -----------------------------------------------------

  static Color _accentForKind(String kind) {
    switch (kind) {
      case 'task.assigned':
        return const Color(0xFF4FA4B5);
      case 'task.reassigned':
        return const Color(0xFF6366F1);
      case 'task.rescheduled':
        return const Color(0xFFF59E0B);
      case 'task.deleted':
        return const Color(0xFFE53935);
      case 'task.started':
        return const Color(0xFF9C27B0);
      case 'task.completed':
        return const Color(0xFF23A26D);
      case 'task.rejected':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF4FA4B5);
    }
  }

  static IconData _iconForKind(String kind) {
    switch (kind) {
      case 'task.assigned':
        return Icons.assignment_outlined;
      case 'task.reassigned':
        return Icons.swap_horiz;
      case 'task.rescheduled':
        return Icons.schedule;
      case 'task.deleted':
        return Icons.cancel_outlined;
      case 'task.started':
        return Icons.play_arrow;
      case 'task.completed':
        return Icons.check_circle_outline;
      case 'task.rejected':
        return Icons.error_outline;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  /// Map task type slug → SVG asset that already lives in /assets/.
  static String? _iconAssetForKind(String kind, Map<String, dynamic> data) {
    final slug = data['task_type_slug'] as String?;
    if (slug == null) return null;
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
        return null;
    }
  }

  static String _formatRelative(String? iso) {
    if (iso == null) return '';
    DateTime? dt;
    try {
      dt = DateTime.parse(iso).toLocal();
    } catch (_) {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return DateFormat('d MMM, HH:mm', 'es').format(dt);
  }
}
