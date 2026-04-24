import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'flow_photo_input.dart';

class VehicleObservation {
  final String id;
  final String part;
  final Offset? position; // Position relative to the part widget (0.0 to 1.0)
  String type;
  String description;
  List<String?> photos;

  VehicleObservation({
    required this.id,
    required this.part,
    this.position,
    this.type = '',
    this.description = '',
    this.photos = const [null, null, null],
  });

  VehicleObservation copyWith({
    String? type,
    String? description,
    List<String?>? photos,
    Offset? position,
  }) {
    return VehicleObservation(
      id: id,
      part: part,
      position: position ?? this.position,
      type: type ?? this.type,
      description: description ?? this.description,
      photos: photos ?? this.photos,
    );
  }
}

class VehicleInspectionWidget extends StatefulWidget {
  final int taskId;
  final Function(List<VehicleObservation>) onObservationsChanged;
  final List<VehicleObservation> initialObservations;

  const VehicleInspectionWidget({
    super.key,
    required this.taskId,
    required this.onObservationsChanged,
    this.initialObservations = const [],
  });

  @override
  State<VehicleInspectionWidget> createState() => _VehicleInspectionWidgetState();
}

class _VehicleInspectionWidgetState extends State<VehicleInspectionWidget> {
  late List<VehicleObservation> _observations;
  String? _expandedObservationId;

  @override
  void initState() {
    super.initState();
    _observations = List.from(widget.initialObservations);
  }

  void _addObservation(String part, {Offset? position}) {
    setState(() {
      final newObs = VehicleObservation(
        id: const Uuid().v4(),
        part: part,
        position: position,
      );
      _observations.add(newObs);
      _expandedObservationId = newObs.id;
    });
    widget.onObservationsChanged(_observations);
  }

  void _removeObservation(String id) {
    setState(() {
      _observations.removeWhere((obs) => obs.id == id);
      if (_expandedObservationId == id) {
        _expandedObservationId = null;
      }
    });
    widget.onObservationsChanged(_observations);
  }

  void _updateObservation(String id, VehicleObservation updatedObs) {
    setState(() {
      final index = _observations.indexWhere((obs) => obs.id == id);
      if (index != -1) {
        _observations[index] = updatedObs;
      }
    });
    widget.onObservationsChanged(_observations);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Observaciones del vehículo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 16),
        _buildVehicleDiagram(),
        const SizedBox(height: 24),
        _buildObservationsList(),
      ],
    );
  }

  Widget _buildVehicleDiagram() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Above view (Left)
              Expanded(
                flex: 1,
                child: _buildPartItem('Superior', 'assets/above.svg'),
              ),
              const SizedBox(width: 12),
              // Sides (Right)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildPartItem('Lateral Izquierdo', 'assets/side left.svg'),
                    const SizedBox(height: 12),
                    _buildPartItem('Lateral Derecho', 'assets/side right.svg'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Front (Left)
              Expanded(
                child: _buildPartItem('Frontal', 'assets/front.svg'),
              ),
              const SizedBox(width: 12),
              // Rear (Right)
              Expanded(
                child: _buildPartItem('Posterior', 'assets/rear.svg'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartItem(String label, String assetPath) {
    final observationsForPart = _observations.where((obs) => obs.part == label).toList();
    final hasObservations = observationsForPart.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            final double relX = details.localPosition.dx / constraints.maxWidth;
            final double relY = details.localPosition.dy / constraints.maxHeight;
            _addObservation(label, position: Offset(relX, relY));
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasObservations ? const Color(0xFF4FA4B5) : const Color(0xFFE5E9EB),
                    width: hasObservations ? 2 : 1,
                  ),
                  boxShadow: [
                    if (hasObservations)
                      BoxShadow(
                        color: const Color(0xFF4FA4B5).withValues(alpha: 0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: SvgPicture.asset(
                  assetPath,
                  height: 100,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF002B4B),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // Render precise markers
              ...observationsForPart.map((obs) {
                if (obs.position == null) return const SizedBox.shrink();
                
                final index = _observations.indexOf(obs) + 1;
                final isExpanded = _expandedObservationId == obs.id;

                return Positioned(
                  left: (obs.position!.dx * constraints.maxWidth) - 12,
                  top: (obs.position!.dy * constraints.maxHeight) - 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isExpanded ? const Color(0xFF002B4B) : const Color(0xFF4FA4B5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildObservationsList() {
    if (_observations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Toque una parte del vehículo para agregar una observación',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF99AAB7),
            ),
          ),
        ),
      );
    }
    return Column(
      children: _observations.map((obs) => _buildObservationItem(obs)).toList(),
    );
  }

  Widget _buildObservationItem(VehicleObservation obs) {
    final isExpanded = _expandedObservationId == obs.id;
    final index = _observations.indexOf(obs) + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF4FA4B5) : const Color(0xFFE5E9EB),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _expandedObservationId = isExpanded ? null : obs.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FA4B5).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4FA4B5)),
                    ),
                    child: Text(
                      '$index',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4FA4B5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          obs.part,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF002B4B),
                          ),
                        ),
                        if (obs.type.isNotEmpty)
                          Text(
                            obs.type,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF4FA4B5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/Trash.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFE35959),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () => _removeObservation(obs.id),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF002B4B),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Tipo de observación',
                    value: obs.type.isEmpty ? null : obs.type,
                    items: ['Rayadura', 'Abolladura', 'Rotura', 'Mancha', 'Otro'],
                    onChanged: (val) {
                      _updateObservation(obs.id, obs.copyWith(type: val));
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Describa el daño u observación...',
                      filled: true,
                      fillColor: const Color(0xFFF8FBFC),
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                      ),
                    ),
                    onChanged: (val) {
                      _updateObservation(obs.id, obs.copyWith(description: val));
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fotos de la observación (Máx. 3)',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPhotoSection(obs),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF002B4B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E9EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Seleccionar tipo', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF99AAB7))),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B))),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(VehicleObservation obs) {
    return Column(
      children: [
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FlowPhotoInput(
              label: 'Foto ${i + 1}',
              taskId: widget.taskId,
              photoLabel: 'obs_${obs.id}_$i',
              previewFileName: 'Foto_Obs_${obs.part}_$i.jpg',
              isUploaded: obs.photos[i] != null,
              imagePath: obs.photos[i],
              onChanged: (uploaded, path) {
                final newPhotos = List<String?>.from(obs.photos);
                newPhotos[i] = uploaded ? path as String : null;
                _updateObservation(obs.id, obs.copyWith(photos: newPhotos));
              },
              onTagChanged: (_) {},
            ),
          ),
      ],
    );
  }
}
