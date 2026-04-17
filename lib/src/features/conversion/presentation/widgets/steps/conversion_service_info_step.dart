import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

/// Step 2: "Información de servicio"
/// Shows placa + service type (read-only, from backoffice) + Google Maps button.
/// The operario cannot change the service type — it was set when the task was
/// created in the backoffice.
class ConversionServiceInfoStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const ConversionServiceInfoStep({
    super.key,
    required this.task,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final String placa = task['placa'] ?? '—';
    final metadata = task['metadata'] as Map<String, dynamic>? ?? {};
    final String serviceType = metadata['service_type'] ?? 'No especificado';
    final String? mapsLink = task['google_maps_link'] as String?;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de servicio',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),

                // Placa (read-only)
                const FlowSectionLabel(label: 'Placa'),
                const SizedBox(height: 8),
                _readOnlyField(placa),

                const SizedBox(height: 24),

                // Tipo de servicio (read-only, set by backoffice)
                const FlowSectionLabel(label: 'Tipo de servicio'),
                const SizedBox(height: 12),
                _readOnlyField(serviceType),

                const SizedBox(height: 24),

                // Google Maps — delivery location
                if (mapsLink != null && mapsLink.isNotEmpty) ...[
                  const FlowSectionLabel(label: 'Link Google Maps · Ubicación de entrega'),
                  const SizedBox(height: 8),
                  // Show the URL preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E9EB)),
                    ),
                    child: Text(
                      mapsLink.length > 50 ? '${mapsLink.substring(0, 50)}...' : mapsLink,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF99AAB7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Open button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _openMaps(mapsLink),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(
                        'Abrir Google Maps',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4FA4B5),
                        side: const BorderSide(color: Color(0xFF4FA4B5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack,
          onContinue: onContinue,
        ),
      ],
    );
  }

  Widget _readOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: const Color(0xFF002B4B),
        ),
      ),
    );
  }



  Future<void> _openMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
