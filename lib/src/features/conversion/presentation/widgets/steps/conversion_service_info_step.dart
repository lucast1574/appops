import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

/// Step 1: "Información de servicio"
/// Shows scheduled date, start/end time, placa, service type, conversion center,
/// address and a Google Maps button.
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
    final String conversionCenter = metadata['conversion_center'] ?? metadata['location'] ?? 'No especificado';
    final String address = task['address'] ?? '';
    final String mapsLink = task['google_maps_link']?.toString() ?? metadata['google_maps_link']?.toString() ?? '';
    final String scheduledDate = task['scheduled_date'] ?? '';
    final String startTime = _formatTime(task['start_time']);
    final String endTime = _formatTime(task['end_time']);

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

                // Scheduled Date & Time row
                if (scheduledDate.isNotEmpty) ...[
                  const FlowSectionLabel(label: 'Fecha'),
                  const SizedBox(height: 8),
                  _readOnlyField(scheduledDate),
                  const SizedBox(height: 24),
                ],

                if (startTime.isNotEmpty || endTime.isNotEmpty) ...[
                  Row(
                    children: [
                      if (startTime.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FlowSectionLabel(label: 'Hora inicio'),
                              const SizedBox(height: 8),
                              _readOnlyField(startTime),
                            ],
                          ),
                        ),
                      if (startTime.isNotEmpty && endTime.isNotEmpty)
                        const SizedBox(width: 16),
                      if (endTime.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FlowSectionLabel(label: 'Hora fin'),
                              const SizedBox(height: 8),
                              _readOnlyField(endTime),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Placa (read-only)
                const FlowSectionLabel(label: 'Placa'),
                const SizedBox(height: 8),
                _readOnlyField(placa),
                const SizedBox(height: 24),

                // Tipo de servicio (read-only, set by backoffice)
                const FlowSectionLabel(label: 'Tipo de servicio'),
                const SizedBox(height: 8),
                _readOnlyField(serviceType),
                const SizedBox(height: 24),

                // Taller / Centro de conversión
                const FlowSectionLabel(label: 'Taller / Centro de conversión'),
                const SizedBox(height: 8),
                _readOnlyField(conversionCenter),
                const SizedBox(height: 24),

                // Dirección and Google Maps button
                if (address.isNotEmpty) ...[
                  FlowAddressDisplay(
                    label: 'Ubicación de conversión',
                    address: address,
                    mapsLink: mapsLink,
                    onOpenMaps: () => _launchMaps(mapsLink),
                  ),
                  const SizedBox(height: 24),
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

  Future<void> _launchMaps(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }
}
