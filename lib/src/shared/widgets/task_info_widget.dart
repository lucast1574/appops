import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'flow_form_widgets.dart';

/// Shared widget that displays task information from backend data.
/// Used as the first step in all 8 task flows.
class TaskInfoWidget extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onContinue;
  final String buttonText;
  /// Extra widgets to show before the observations field (e.g. notary-specific fields).
  final List<Widget> extraFields;

  final bool isSubmitting;
  const TaskInfoWidget({
    super.key,
    required this.task,
    required this.onContinue,
    this.buttonText = 'Comenzar tarea',
    this.extraFields = const [],
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    final type = task['type'] as Map<String, dynamic>?;
    final String typeName = type?['name'] ?? 'Tarea';
    final String scheduledDate = task['scheduled_date'] ?? '';
    final String startTime = _formatTime(task['start_time']);
    final String endTime = _formatTime(task['end_time']);
    final String address = task['address'] ?? '';
    final String clientName = task['client_name'] ?? '';
    final String clientDni = task['client_dni'] ?? '';
    final String placa = task['placa'] ?? '';
    final String marca = task['marca'] ?? '';
    final String modelo = task['modelo'] ?? '';
    final String color = task['color'] ?? '';
    final String observations = task['observations'] ?? '';

    // Type-specific metadata
    final metadata = task['metadata'] as Map<String, dynamic>? ?? {};
    final String managementType = metadata['management_type'] ?? '';
    final String pickupNotary = metadata['pickup_notary'] ?? '';
    final String deliveryNotary = metadata['delivery_notary'] ?? '';
    final String deliveryAddress = metadata['delivery_address'] ?? '';
    final String deliveryGoogleMapsLink = metadata['delivery_google_maps_link'] ?? '';
    final String origin = metadata['origin'] ?? '';
    final String originAddress = metadata['origin_address'] ?? address;
    final String originGoogleMapsLink =
        metadata['origin_google_maps_link']?.toString().isNotEmpty == true
            ? metadata['origin_google_maps_link'].toString()
            : metadata['google_maps_link']?.toString() ?? task['google_maps_link']?.toString() ?? '';
    
    final String destination = metadata['destination'] ?? '';
    final String destinationAddress = metadata['dest_address'] ?? '';
    final String destinationGoogleMapsLink = metadata['dest_google_maps_link'] ?? '';
    final String pickupGoogleMapsLink =
        metadata['pickup_google_maps_link']?.toString().isNotEmpty == true
            ? metadata['pickup_google_maps_link'].toString()
            : task['google_maps_link']?.toString() ?? '';

    final String serviceType = metadata['service_type'] ?? '';
    final String conversionLocation = metadata['conversion_center'] ?? metadata['location'] ?? '';
    final String typeSlug = type?['slug'] ?? '';
    final bool isTraslado = typeSlug == 'traslado';
    final bool isDelivery = typeSlug == 'entrega';

    // Primary Maps link (root or metadata)
    final String primaryMapsLink = task['google_maps_link']?.toString() ?? metadata['google_maps_link']?.toString() ?? '';

    // Build vehicle string
    final vehicleParts = <String>[
      if (marca.isNotEmpty) marca,
      if (modelo.isNotEmpty) modelo,
      if (color.isNotEmpty) color,
    ];
    final String vehicleInfo = vehicleParts.join(' \u00b7 ');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  typeName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),

                // Date
                if (scheduledDate.isNotEmpty) ...[
                  _buildHeader('Fecha'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheduledDate,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                        ),
                        SvgPicture.asset('assets/doble.svg', width: 10, height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Start / End time
                if (startTime.isNotEmpty || endTime.isNotEmpty)
                  Row(
                    children: [
                      if (startTime.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader('Hora inicio'),
                              const SizedBox(height: 8),
                              _buildValueContainer(
                                child: Text(startTime, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                              ),
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
                              _buildHeader('Hora fin'),
                              const SizedBox(height: 8),
                              _buildValueContainer(
                                child: Text(endTime, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                if (startTime.isNotEmpty || endTime.isNotEmpty)
                  const SizedBox(height: 16),

                // --- DELIVERY SPECIFIC FIELDS ---
                if (isDelivery) ...[
                  // Row for Hora de entrega and Tipo de vehículo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader('Hora de entrega'),
                            const SizedBox(height: 8),
                            _buildValueContainer(
                              child: Text(startTime.isNotEmpty ? startTime : '---', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader('Tipo de vehículo'),
                            const SizedBox(height: 8),
                            _buildValueContainer(
                              child: Text(task['vehicle_type']?.toString() ?? '---', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Marca / Modelo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader('Marca de carro'),
                            const SizedBox(height: 8),
                            _buildValueContainer(
                              child: Text(marca.isNotEmpty ? marca : '---', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader('Modelo'),
                            const SizedBox(height: 8),
                            _buildValueContainer(
                              child: Text(modelo.isNotEmpty ? modelo : '---', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Placa
                  _buildHeader('Placa'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Text(placa.isNotEmpty ? placa : '---', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF002B4B))),
                  ),
                  const SizedBox(height: 16),

                  // Ubicación de entrega
                  FlowAddressDisplay(
                    label: 'Ubicación de entrega',
                    address: address,
                    mapsLink: primaryMapsLink,
                    onOpenMaps: () => _launchMaps(primaryMapsLink),
                  ),
                  const SizedBox(height: 16),

                  // Nombre concesionario
                  _buildHeader('Nombre concesionario'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Text(metadata['dealership_name'] ?? '---', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // --- DEFAULT FIELDS (Traslado, Conversion, etc.) ---

                  // Address (only if not a specific task type that shows its own locations below)
                  if (address.isNotEmpty && pickupNotary.isEmpty && !isTraslado) ...[
                    FlowAddressDisplay(
                      label: 'Dirección',
                      address: address,
                      mapsLink: primaryMapsLink,
                      onOpenMaps: () => _launchMaps(primaryMapsLink),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Transfer origin/destination
                  if (isTraslado || origin.isNotEmpty || destination.isNotEmpty) ...[
                    if (isTraslado || origin.isNotEmpty) ...[
                      FlowAddressDisplay(
                        label: 'Ubicación de inicio traslado',
                        address: originAddress.isNotEmpty ? originAddress : origin,
                        mapsLink: originGoogleMapsLink,
                        onOpenMaps: () => _launchMaps(originGoogleMapsLink),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (isTraslado || destination.isNotEmpty) ...[
                      FlowAddressDisplay(
                        label: 'Ubicación final de traslado',
                        address: destinationAddress.isNotEmpty ? destinationAddress : destination,
                        mapsLink: destinationGoogleMapsLink,
                        onOpenMaps: () => _launchMaps(destinationGoogleMapsLink),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Notary fields
                  if (pickupNotary.isNotEmpty || deliveryNotary.isNotEmpty) ...[
                    if (pickupNotary.isNotEmpty) ...[
                      FlowAddressDisplay(
                        label: 'Lugar de recojo de documentos',
                        address: '$pickupNotary\n$address',
                        mapsLink: pickupGoogleMapsLink,
                        onOpenMaps: () => _launchMaps(pickupGoogleMapsLink),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (deliveryNotary.isNotEmpty) ...[
                      FlowAddressDisplay(
                        label: 'Lugar de entrega de documentos',
                        address: '$deliveryNotary\n$deliveryAddress',
                        mapsLink: deliveryGoogleMapsLink,
                        onOpenMaps: () => _launchMaps(deliveryGoogleMapsLink),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // Client name
                  if (clientName.isNotEmpty) ...[
                    _buildHeader('Nombre del cliente'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(clientName, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Client DNI
                  if (clientDni.isNotEmpty) ...[
                    _buildHeader('DNI/INE cliente'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(clientDni, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Placa
                  if (placa.isNotEmpty) ...[
                    _buildHeader('Placa'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(placa, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Vehicle info
                  if (vehicleInfo.isNotEmpty) ...[
                    _buildHeader('Veh\u00edculo'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(vehicleInfo, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Management type
                  if (managementType.isNotEmpty) ...[
                    _buildHeader('Tipo de gesti\u00f3n'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(managementType, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Conversion service type
                  if (serviceType.isNotEmpty) ...[
                    _buildHeader('Tipo de servicio'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(serviceType, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (conversionLocation.isNotEmpty) ...[
                    _buildHeader('Taller / Ubicaci\u00f3n'),
                    const SizedBox(height: 8),
                    _buildValueContainer(
                      child: Text(conversionLocation, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],

                // Extra fields (e.g. notary-specific, management sub-type)
                ...extraFields,

                // Observations (read-only if existing)
                if (observations.isNotEmpty) ...[
                  _buildHeader('Observaciones'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Text(observations, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF668093))),
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Bottom button
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
              onPressed: isSubmitting ? null : onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27A376),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      buttonText,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
      ),
    );
  }

  static Widget _buildValueContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: child,
    );
  }

  Future<void> _launchMaps(String url) async {
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
