import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationUploadButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isFullWidth;
  final VoidCallback? onTap;

  const VerificationUploadButton({
    super.key,
    required this.text,
    required this.icon,
    this.isFullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFB9DBE1)),
        ),
        child: Row(
          mainAxisAlignment: isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF002B4B), size: 24),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF002B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
