import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../notifications/data/notifications_service.dart';
import '../../../chat/data/chat_unread_service.dart';
import '../../../chat/presentation/pages/chat_inbox_page.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotificationBell;
  final Color headerColor;
  final Color dividerColor;
  final double? titleSize;

  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotificationBell = false,
    this.headerColor = const Color(0xFF002B4B),
    this.dividerColor = const Color(0xFFD2DADF),
    this.titleSize,
    this.onNotificationTap,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final NotificationsService _notifService = NotificationsService();
  final ChatUnreadService _chatService = ChatUnreadService();
  Timer? _pollTimer;
  int _unreadNotifs = 0;
  int _unreadChats = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showNotificationBell) {
      _refresh();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) => _refresh(),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final n = await _notifService.unreadCount();
      if (!mounted) return;
      setState(() => _unreadNotifs = n);
    } catch (_) {}
    try {
      final c = await _chatService.unreadCount();
      if (!mounted) return;
      setState(() => _unreadChats = c);
    } catch (_) {}
  }

  Future<void> _handleNotifTap() async {
    final cb = widget.onNotificationTap;
    if (cb != null) cb();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) _refresh();
  }

  Future<void> _handleChatTap() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatInboxPage()),
    );
    if (mounted) _refresh();
  }

  Widget _buildBadge(int n, Color color) {
    return Positioned(
      top: -6, right: -8,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          n > 99 ? '99+' : '$n',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: widget.headerColor,
          fontSize: widget.titleSize,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Center(
        child: SvgPicture.asset(
          'assets/List.svg',
          colorFilter: ColorFilter.mode(widget.headerColor, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
      ),
      actions: [
        if (widget.showNotificationBell) ...[
          // Chat icon (right next to the bell)
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: GestureDetector(
              onTap: _handleChatTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: widget.headerColor,
                    size: 24,
                  ),
                  if (_unreadChats > 0)
                    _buildBadge(_unreadChats, const Color(0xFF4FA4B5)),
                ],
              ),
            ),
          ),
          // Notification bell
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _handleNotifTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/Bell.svg',
                    colorFilter: ColorFilter.mode(widget.headerColor, BlendMode.srcIn),
                    width: 24,
                    height: 24,
                  ),
                  if (_unreadNotifs > 0)
                    _buildBadge(_unreadNotifs, const Color(0xFFE53935)),
                ],
              ),
            ),
          ),
        ],
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: widget.dividerColor,
          height: 1.0,
        ),
      ),
    );
  }
}
