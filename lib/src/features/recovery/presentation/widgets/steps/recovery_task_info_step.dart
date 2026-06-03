import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

class RecoveryTaskInfoStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onContinue;

  const RecoveryTaskInfoStep({
    super.key,
    required this.task,
    required this.onContinue,
  });

  Future<void> _makeCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      try {
        await launchUrl(launchUri);
      } catch (e) {
        debugPrint('Could not launch phone dialer: $e');
      }
    }
  }

  Future<void> _launchMaps(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String scheduledDate = task['scheduled_date'] ?? '';
    final String startTime = task['start_time'] != null ? task['start_time'].toString().substring(0, 5) : '';
    final String endTime = task['end_time'] != null ? task['end_time'].toString().substring(0, 5) : '';
    final String estimatedTime = (startTime.isNotEmpty && endTime.isNotEmpty) ? '$startTime - $endTime' : '';
    final String address = task['address'] ?? '';
    final String placa = task['placa'] ?? '';
    final String clientName = task['client_name'] ?? '';
    final String clientDni = task['client_dni'] ?? '';
    final String marca = task['marca'] ?? '';
    final String modelo = task['modelo'] ?? '';
    final String color = task['color'] ?? '';
    final String vehicleType = task['vehicle_type'] ?? '';
    final String observations = task['observations'] ?? '';

    final metadata = task['metadata'] as Map<String, dynamic>? ?? {};
    final String mapsLink = task['google_maps_link']?.toString() ?? metadata['google_maps_link']?.toString() ?? '';

    final vehicleParts = <String>[
      if (marca.isNotEmpty) marca,
      if (modelo.isNotEmpty) modelo,
      if (color.isNotEmpty) color,
      if (vehicleType.isNotEmpty) vehicleType,
    ];
    final String vehicleInfo = vehicleParts.join(' \u00b7 ');

    final String op1 = task['assigned_to'] != null 
        ? "${task['assigned_to']['first_name'] ?? ''} ${task['assigned_to']['last_name'] ?? ''}".trim()
        : '';

    final String op2 = task['assigned_to_2'] != null 
        ? "${task['assigned_to_2']['first_name'] ?? ''} ${task['assigned_to_2']['last_name'] ?? ''}".trim()
        : '';

    final String phone = task['client_phone'] ?? '';
    final String phoneAval = task['aval_phone'] ?? '';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de la tarea',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),

                if (clientName.isNotEmpty) ...[
                  _header('Cliente'),
                  const SizedBox(height: 8),
                  _value(
                    Text(
                      clientName,
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (clientDni.isNotEmpty) ...[
                  _header('DNI/INE cliente'),
                  const SizedBox(height: 8),
                  _value(
                    Text(
                      clientDni,
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (placa.isNotEmpty) ...[
                  _header('Placa'),
                  const SizedBox(height: 8),
                  _value(
                    Text(
                      placa,
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (vehicleInfo.isNotEmpty) ...[
                  _header('Vehículo'),
                  const SizedBox(height: 8),
                  _value(
                    Text(
                      vehicleInfo,
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (op1.isNotEmpty) ...[
                  _header('Operador 1 (Tú)'),
                  const SizedBox(height: 8),
                  _value(
                    Text(
                      op1,
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (op2.isNotEmpty) ...[
                  _header('Operador 2'),
                  const SizedBox(height: 8),
                  _value(
                    Text(
                      op2,
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (scheduledDate.isNotEmpty) ...[
                  _header('Fecha'),
                  const SizedBox(height: 8),
                  _value(
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheduledDate,
                            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                          ),
                        ),
                        const Icon(Icons.check, color: Color(0xFF27A376), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (estimatedTime.isNotEmpty) ...[
                  _header('Hora Estimada'),
                  const SizedBox(height: 8),
                  _value(
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            estimatedTime,
                            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                          ),
                        ),
                        const Icon(Icons.access_time, color: Color(0xFF27A376), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (address.isNotEmpty || mapsLink.isNotEmpty) ...[
                  FlowAddressDisplay(
                    label: 'Ubicación',
                    address: address,
                    mapsLink: mapsLink,
                    onOpenMaps: () => _launchMaps(mapsLink),
                  ),
                  const SizedBox(height: 16),
                ],

                if (phone.isNotEmpty) ...[
                  _header('Teléfono'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _value(
                          Text(
                            phone,
                            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _callButton(phone),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (phoneAval.isNotEmpty) ...[
                  _header('Teléfono aval'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _value(
                          Text(
                            phoneAval,
                            style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _callButton(phoneAval),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (observations.isNotEmpty) ...[
                  _header('Motivo de Recupero'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4FA4B5).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Color(0xFF4FA4B5)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            observations,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E9EB))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27A376),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: Text(
                'Comenzar tarea',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(String t) => Text(
        t,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)),
      );

  Widget _value(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E9EB)),
        ),
        child: child,
      );

  Widget _callButton(String phone) => SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _makeCall(phone),
          icon: const Icon(Icons.phone, size: 16, color: Colors.white),
          label: Text(
            'Llamar',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27A376),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      );
}
