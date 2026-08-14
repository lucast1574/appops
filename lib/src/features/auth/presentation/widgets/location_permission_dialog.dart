import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A branded bottom-sheet dialog that explains why the app needs "always"
/// location permission and guides the user step-by-step to grant it.
///
/// The dialog is fully mandatory: it cannot be dismissed via back button,
/// drag, or tap outside. The only way forward is the CTA.
///
/// Steps adapt to the host platform (Android vs iOS) because the native
/// settings screens look different on each.
class LocationPermissionDialog {
  const LocationPermissionDialog._();

  /// Shows the prominent disclosure modal for background location.
  /// Returns `true` if the user clicked "Aceptar y continuar", or `false` if "No ahora".
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
    return result ?? false;
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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
            const SizedBox(height: 20),

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
            const SizedBox(height: 16),

            // Title
            Text(
              'Ubicación en segundo plano',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF002B4A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Prominent Disclosure Box (Required by Google Play Policy)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF1D4ED8),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aviso importante de privacidad',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'LeasyOps recopila datos de ubicación para permitir el '
                    'seguimiento de operativas de campo, asignación de tareas '
                    'en tiempo real y verificación de vehículos, incluso cuando '
                    'la aplicación está cerrada o no está en uso.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E3A8A),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step-by-step instructions (platform-aware)
            _buildStepsCard(),
            const SizedBox(height: 16),

            // Highlighted target option
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Platform.isIOS ? 'Siempre' : 'Permitir todo el tiempo',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF002B4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Primary Consent CTA — Accept & Continue
            SizedBox(
              width: double.infinity,
              height: 52,
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
                  'Aceptar y continuar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary CTA — Decline / Not now
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                ),
                child: Text(
                  'No ahora',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
    final steps = Platform.isIOS ? _iosSteps() : _androidSteps();
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
          for (int i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildStep(
              number: '${i + 1}',
              text: steps[i].text,
              subtitle: steps[i].subtitle,
            ),
          ],
        ],
      ),
    );
  }

  /// Android flow: Settings page deeplink → Permissions → Location → Allow all the time.
  List<_Step> _androidSteps() => const [
        _Step(
          text: 'Toca "Permisos" en la pantalla que se abrirá',
          subtitle: '(Si ya ves "Ubicación", ve al paso 2)',
        ),
        _Step(text: 'Toca "Ubicación"'),
        _Step(text: 'Selecciona "Permitir todo el tiempo"'),
        _Step(text: 'Regresa a LeasyOps'),
      ];

  /// iOS flow: app Settings page → Ubicación → Siempre.
  /// On iOS we cannot deeplink directly to the location permission row,
  /// so we open the app's general Settings page.
  List<_Step> _iosSteps() => const [
        _Step(text: 'Toca "Ubicación" en la pantalla que se abrirá'),
        _Step(
          text: 'Selecciona "Siempre"',
          subtitle: '(la opción que permite usar la ubicación en segundo plano)',
        ),
        _Step(
          text: 'Activa "Ubicación precisa"',
          subtitle: '(si aparece, déjalo encendido)',
        ),
        _Step(text: 'Regresa a LeasyOps'),
      ];

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

class _Step {
  final String text;
  final String? subtitle;
  const _Step({required this.text, this.subtitle});
}