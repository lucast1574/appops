import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../notifications/data/notifications_service.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotificationBell;
  final Color headerColor;
  final Color dividerColor;
  final double? titleSize;

  final Future<void> Function()? onNotificationTap;

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
  final NotificationsService _service = NotificationsService();
  Timer? _pollTimer;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showNotificationBell) {
      _refresh();
      // Cheap polling — the unread count is a single integer, fine to
      // ask every 60s. We pause when off-screen via AppLifecycle if we
      // ever need to, but most operario sessions are short-lived.
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
      final n = await _service.unreadCount();
      if (!mounted) return;
      setState(() => _unread = n);
    } catch (_) {
      // Silent fail — keep last known value.
    }
  }

  Future<void> _handleTap() async {
    final cb = widget.onNotificationTap;
    if (cb != null) {
      await cb();
    }
    // After visiting the screen the badge may have changed (user could
    // have marked things read), refresh once we come back.
    if (mounted) _refresh();
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
        if (widget.showNotificationBell)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: _handleTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(
                    'assets/Bell.svg',
                    colorFilter: ColorFilter.mode(widget.headerColor, BlendMode.srcIn),
                    width: 24,
                    height: 24,
                  ),
                  if (_unread > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18, minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _unread > 99 ? '99+' : '$_unread',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
