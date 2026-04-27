import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'flow_photo_input.dart';
import 'flow_step_navigation.dart';

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
    String? part,
    String? type,
    String? description,
    List<String?>? photos,
    Offset? position,
  }) {
    return VehicleObservation(
      id: id,
      part: part ?? this.part,
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
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const VehicleInspectionWidget({
    super.key,
    required this.taskId,
    required this.onObservationsChanged,
    this.initialObservations = const [],
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<VehicleInspectionWidget> createState() => _VehicleInspectionWidgetState();
}

class _VehicleInspectionWidgetState extends State<VehicleInspectionWidget> {
  late List<VehicleObservation> _observations;
  VehicleObservation? _currentEditingObs;
  VehicleObservation? _selectedNewObs;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _observations = List.from(widget.initialObservations);
  }

  void _startAddingObservation(String part, {Offset? position}) {
    setState(() {
      _isFinished = false;
      _selectedNewObs = VehicleObservation(
        id: const Uuid().v4(),
        part: part,
        position: position,
      );
    });
  }

  void _editObservation(VehicleObservation obs) {
    setState(() {
      _currentEditingObs = obs.copyWith(); // Work on a copy
    });
  }

  void _saveObservation() {
    if (_currentEditingObs != null) {
      setState(() {
        final index = _observations.indexWhere((o) => o.id == _currentEditingObs!.id);
        if (index >= 0) {
          _observations[index] = _currentEditingObs!;
        } else {
          _observations.add(_currentEditingObs!);
        }
        _currentEditingObs = null;
      });
      widget.onObservationsChanged(_observations);
    }
  }

  void _cancelObservation() {
    setState(() {
      _currentEditingObs = null;
    });
  }

  void _deleteObservation(String id) {
    setState(() {
      _observations.removeWhere((o) => o.id == id);
      _currentEditingObs = null;
    });
    widget.onObservationsChanged(_observations);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentEditingObs != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        child: _buildDetailForm(),
      );
    }
    return _buildOverviewMap();
  }

  Widget _buildOverviewMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Observaciones',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE5E9EB), thickness: 1, height: 1),
                const SizedBox(height: 24),
        
        // --- MAP AREA ---
        Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildPartItem('Superior', 'assets/above.svg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildPartItem('Lateral Izquierdo', 'assets/side left.svg'),
                        const SizedBox(height: 16),
                        _buildPartItem('Lateral Derecho', 'assets/side right.svg'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPartItem('Frontal', 'assets/front.svg'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPartItem('Posterior', 'assets/rear.svg'),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // --- EXISTING OBSERVATIONS LIST ---
        if (_observations.isNotEmpty) ...[
          Text(
            'Observaciones registradas',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
          ),
          const SizedBox(height: 12),
          ..._observations.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final obs = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E9EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF4FA4B5),
                  radius: 14,
                  child: Text('$index', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                title: Text(obs.part, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text(obs.type.isEmpty ? 'Sin tipo' : obs.type, style: GoogleFonts.inter(fontSize: 12)),
                trailing: const Icon(Icons.edit, size: 18, color: Color(0xFF4FA4B5)),
                onTap: () => _editObservation(obs),
              ),
            );
          }),
        ],
      ],
    ),
  ),
),
        
        // --- BOTTOM ACTIONS (PINNED) ---
        Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: Text(
                  _observations.isEmpty 
                      ? 'El vehículo no presenta observaciones (daños o faltantes)'
                      : 'El vehículo no presenta más observaciones', 
                  style: GoogleFonts.inter(fontSize: 14)
                ),
                value: _isFinished,
                activeColor: const Color(0xFF27A376),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _isFinished = val ?? false;
                    if (_isFinished) {
                      _selectedNewObs = null; // Clear pending marker if they mark as finished
                    }
                  });
                },
              ),
                
              const SizedBox(height: 16),
              FlowStepNavigation(
                onBack: widget.onBack,
                onContinue: _selectedNewObs != null
                    ? () {
                        setState(() {
                          _currentEditingObs = _selectedNewObs;
                          _selectedNewObs = null;
                        });
                      }
                    : widget.onContinue,
                isContinueEnabled: _selectedNewObs != null || _isFinished,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartItem(String label, String assetPath) {
    final observationsForPart = _observations.where((obs) => obs.part == label).toList();
    final bool hasPending = _selectedNewObs != null && _selectedNewObs!.part == label;

    return Builder(
      builder: (context) {
        return GestureDetector(
          onTapDown: (details) {
            final box = context.findRenderObject() as RenderBox;
            final double relX = details.localPosition.dx / box.size.width;
            final double relY = details.localPosition.dy / box.size.height;
            _startAddingObservation(label, position: Offset(relX, relY));
          },
          child: Container(
            width: double.infinity,
            color: Colors.transparent, // Ensures the entire area is tappable
            child: CustomPaint(
              foregroundPainter: _VehicleMarkerPainter(
                observations: observationsForPart,
                allObservations: _observations,
                pendingObs: hasPending ? _selectedNewObs : null,
              ),
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailForm() {
    final obs = _currentEditingObs!;
    final index = _observations.indexWhere((o) => o.id == obs.id);
    final displayIndex = index >= 0 ? index + 1 : _observations.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)),
                  onPressed: _cancelObservation,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Observación $displayIndex',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
                ),
              ],
            ),
            if (index >= 0)
              TextButton.icon(
                onPressed: () => _deleteObservation(obs.id),
                icon: const Icon(Icons.delete, color: Color(0xFFE35959), size: 18),
                label: Text('Eliminar', style: GoogleFonts.inter(color: const Color(0xFFE35959))),
              ),
          ],
        ),
        const SizedBox(height: 24),
        
        _buildDropdownField(
          label: 'Seleccionar parte',
          value: obs.part,
          items: ['Superior', 'Lateral Izquierdo', 'Lateral Derecho', 'Frontal', 'Posterior'],
          onChanged: (val) {
            setState(() { _currentEditingObs = obs.copyWith(part: val); });
          },
        ),
        const SizedBox(height: 16),
        
        _buildDropdownField(
          label: 'Tipo de observación',
          value: obs.type.isEmpty ? null : obs.type,
          items: ['Rayadura', 'Abolladura', 'Rotura', 'Mancha', 'Faltante', 'Otro'],
          onChanged: (val) {
            setState(() { _currentEditingObs = obs.copyWith(type: val); });
          },
        ),
        const SizedBox(height: 16),
        
        Text('Observaciones', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF002B4B))),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: obs.description)..selection = TextSelection.fromPosition(TextPosition(offset: obs.description.length)),
          maxLines: 3,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Describa el detalle...',
            filled: true,
            fillColor: const Color(0xFFF8FBFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
          ),
          onChanged: (val) {
            _currentEditingObs!.description = val;
          },
        ),
        
        const SizedBox(height: 24),
        Text('Evidencia fotográfica (Máx. 3)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF002B4B))),
        const SizedBox(height: 12),
        ...List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FlowPhotoInput(
            label: 'Foto ${i + 1}',
            taskId: widget.taskId,
            photoLabel: 'obs_${obs.id}_$i',
            previewFileName: 'Foto_Obs_${obs.part}_$i.jpg',
            isUploaded: obs.photos[i] != null,
            imagePath: obs.photos[i],
            onChanged: (uploaded, path) {
              setState(() {
                final newPhotos = List<String?>.from(obs.photos);
                newPhotos[i] = uploaded ? path as String : null;
                _currentEditingObs = obs.copyWith(photos: newPhotos);
              });
            },
            onTagChanged: (_) {},
          ),
        )),
        
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saveObservation,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4FA4B5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Continuar', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String? value, required List<String> items, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E9EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              isExpanded: true,
              hint: Text(label, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF99AAB7))),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B))))).toList(),
              onChanged: (val) { if (val != null) onChanged(val); },
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleMarkerPainter extends CustomPainter {
  final List<VehicleObservation> observations;
  final List<VehicleObservation> allObservations;
  final VehicleObservation? pendingObs;

  _VehicleMarkerPainter({
    required this.observations,
    required this.allObservations,
    this.pendingObs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var obs in observations) {
      if (obs.position == null) continue;
      final center = Offset(obs.position!.dx * size.width, obs.position!.dy * size.height);
      
      // Draw confirmed marker
      canvas.drawCircle(center, 12, Paint()..color = const Color(0xFF4FA4B5));
      canvas.drawCircle(center, 12, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

      final index = allObservations.indexOf(obs) + 1;
      textPainter.text = TextSpan(
        text: '$index',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    if (pendingObs != null && pendingObs!.position != null) {
      final center = Offset(pendingObs!.position!.dx * size.width, pendingObs!.position!.dy * size.height);
      // Draw pending marker with official color and next sequence number
      canvas.drawCircle(center, 12, Paint()..color = const Color(0xFF4FA4B5));
      canvas.drawCircle(center, 12, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

      final index = allObservations.length + 1;
      textPainter.text = TextSpan(
        text: '$index',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _VehicleMarkerPainter oldDelegate) => true;
}

