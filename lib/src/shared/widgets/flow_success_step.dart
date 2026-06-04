import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlowSuccessStep extends StatelessWidget {
  final VoidCallback onBackToStart;
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final Widget? iconWidget;
  final Color? color;
  final bool isReschedule;

  const FlowSuccessStep({
    super.key,
    required this.onBackToStart,
    this.title = 'Tarea enviada',
    this.subtitle = 'Tus datos se enviaron correctamente. La tarea queda pendiente de la revisión del supervisor.',
    this.buttonText = 'Volver al inicio',
    this.icon = Icons.check,
    this.iconWidget,
    this.color,
    this.isReschedule = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? (isReschedule ? const Color(0xFF4FA4B5) : const Color(0xFF27A376));

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
              ),
              child: iconWidget ?? Icon(icon, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF002B4B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onBackToStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
