import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotificationBell;
  final Color headerColor;
  final Color dividerColor;
  final double? titleSize;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showNotificationBell = false,
    this.headerColor = const Color(0xFF002B4B),
    this.dividerColor = const Color(0xFFD2DADF),
    this.titleSize,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          color: headerColor,
          fontSize: titleSize,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Center(
        child: SvgPicture.asset(
          'assets/List.svg',
          colorFilter: ColorFilter.mode(headerColor, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
      ),
      actions: [
        if (showNotificationBell)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SvgPicture.asset(
              'assets/Bell.svg',
              colorFilter: ColorFilter.mode(headerColor, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: dividerColor,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}
