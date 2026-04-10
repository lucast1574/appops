import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A branded bottom-sheet dialog that explains why the app needs "always"
/// location permission and guides the user step-by-step to grant it.
///
/// The dialog is fully mandatory: it cannot be dismissed via back button,
/// drag, or tap outside. The only way forward is the CTA.
class LocationPermissionDialog {
  const LocationPermissionDialog._();

  /// Shows the mandatory dialog. Always returns `true` because the only
  /// available action is the primary CTA.
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PopScope(
        canPop: false,
        child: _DialogContent(),
      ),
    );
    return result ?? true;
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator (decorative)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD2DADF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF4FA4B5).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF4FA4B5),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Ubicación requerida',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF002B4A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'LeasyOps necesita acceder a tu ubicación en todo '
              'momento para funcionar correctamente.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF668093),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Step-by-step instructions
            _buildStepsCard(),
            const SizedBox(height: 20),

            // Highlighted target option
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF4FA4B5).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4FA4B5).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.radio_button_checked,
                    color: Color(0xFF4FA4B5),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Permitir todo el tiempo',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002B4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary CTA — the ONLY way out
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B4A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Ir a Configuración',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sigue estos pasos:',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF002B4A),
            ),
          ),
          const SizedBox(height: 12),
          _buildStep(
            number: '1',
            text: 'Toca "Permisos" en la pantalla que se abrirá',
            subtitle: '(Si ya ves "Ubicación", ve al paso 2)',
          ),
          const SizedBox(height: 10),
          _buildStep(
            number: '2',
            text: 'Toca "Ubicación"',
          ),
          const SizedBox(height: 10),
          _buildStep(
            number: '3',
            text: 'Selecciona "Permitir todo el tiempo"',
          ),
          const SizedBox(height: 10),
          _buildStep(
            number: '4',
            text: 'Regresa a LeasyOps',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String text,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF4FA4B5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                  height: 1.4,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
