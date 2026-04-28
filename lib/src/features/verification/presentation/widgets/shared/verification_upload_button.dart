import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationUploadButton extends StatelessWidget {
  final String text;
  final String iconAsset;
  final VoidCallback? onTap;

  const VerificationUploadButton({
    super.key,
    required this.text,
    required this.iconAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 88,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F0F3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB9DBE1).withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 32,
              height: 32,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF002B4B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
