import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class RecoveryCarPhotosStep extends StatefulWidget {
  final int taskId;
  final List<Map<String, dynamic>> carPhotos;
  final ValueChanged<List<Map<String, dynamic>>> onCarPhotosChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryCarPhotosStep({
    super.key,
    required this.taskId,
    required this.carPhotos,
    required this.onCarPhotosChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<RecoveryCarPhotosStep> createState() => _RecoveryCarPhotosStepState();
}

class _RecoveryCarPhotosStepState extends State<RecoveryCarPhotosStep> {
  bool _isAdding = false;

  // New photo state
  bool _newPhotoIsUploaded = false;
  String? _newPhotoImagePath;
  String? _newPhotoTag;
  String? _newPhotoS3Key;
  dynamic _newPhotoPhotoId;

  void _resetNewPhotoState() {
    _newPhotoIsUploaded = false;
    _newPhotoImagePath = null;
    _newPhotoTag = null;
    _newPhotoS3Key = null;
    _newPhotoPhotoId = null;
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.carPhotos.length;
    final bool isMinReached = count >= 4;
    final bool isMaxReached = count >= 20;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Fotos del vehículo',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF002B4B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registra entre 4 y 20 fotos del estado de la unidad recuperada.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF4A5568),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMinReached
                                ? const Color(0xFFE6F4EA)
                                : const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Fotos agregadas: $count / 20 ${isMinReached ? "(Mínimo alcanzado)" : "(Se requieren mínimo 4)"}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isMinReached
                                  ? const Color(0xFF137333)
                                  : const Color(0xFFB06000),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Saved photos list
                  ...widget.carPhotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Foto ${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF002B4B),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  final newList = List<Map<String, dynamic>>.from(widget.carPhotos)..removeAt(index);
                                  widget.onCarPhotosChanged(newList);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF25A5A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Eliminar',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FlowPhotoInput(
                            label: 'Foto del vehículo',
                            taskId: widget.taskId,
                            photoLabel: 'foto_vehiculo_${index + 1}',
                            previewFileName: 'foto_vehiculo_${index + 1}.jpg',
                            isUploaded: item['isUploaded'] == true,
                            imagePath: item['imagePath'],
                            tag: item['tag'],
                            photoId: item['photoId'] is int
                                ? item['photoId'] as int
                                : int.tryParse(item['photoId']?.toString() ?? ''),
                            onChanged: (uploaded, res) {
                              final newList = List<Map<String, dynamic>>.from(widget.carPhotos);
                              if (uploaded && res is Map) {
                                newList[index] = {
                                  ...newList[index],
                                  'isUploaded': true,
                                  'imagePath': res['localPath'] ?? res['downloadUrl'],
                                  's3Key': res['s3Key'],
                                  'photoId': res['photoId'],
                                };
                              } else {
                                newList[index] = {
                                  ...newList[index],
                                  'isUploaded': false,
                                  'imagePath': null,
                                  's3Key': null,
                                  'photoId': null,
                                };
                              }
                              widget.onCarPhotosChanged(newList);
                            },
                            onTagChanged: (newTag) {
                              final newList = List<Map<String, dynamic>>.from(widget.carPhotos);
                              newList[index] = {
                                ...newList[index],
                                'tag': newTag,
                              };
                              widget.onCarPhotosChanged(newList);
                            },
                          ),
                        ],
                      ),
                    );
                  }),

                  // Add form or button
                  if (_isAdding)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nueva foto ${count + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FlowPhotoInput(
                            label: 'Capturar foto',
                            taskId: widget.taskId,
                            photoLabel: 'foto_vehiculo_${count + 1}',
                            previewFileName: 'foto_vehiculo_${count + 1}.jpg',
                            isUploaded: _newPhotoIsUploaded,
                            imagePath: _newPhotoImagePath,
                            tag: _newPhotoTag,
                            onChanged: (uploaded, res) {
                              setState(() {
                                _newPhotoIsUploaded = uploaded;
                                if (uploaded && res is Map) {
                                  _newPhotoImagePath = res['localPath'] ?? res['downloadUrl'];
                                  _newPhotoS3Key = res['s3Key'];
                                  _newPhotoPhotoId = res['photoId'];
                                } else {
                                  _newPhotoImagePath = null;
                                  _newPhotoS3Key = null;
                                  _newPhotoPhotoId = null;
                                }
                              });
                            },
                            onTagChanged: (newTag) {
                              setState(() {
                                _newPhotoTag = newTag;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isAdding = false;
                                      _resetNewPhotoState();
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: Color(0xFFCCD4DB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancelar',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF002B4B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _newPhotoIsUploaded
                                      ? () {
                                          final Map<String, dynamic> newObj = {
                                            'isUploaded': true,
                                            'imagePath': _newPhotoImagePath,
                                            'tag': _newPhotoTag,
                                            's3Key': _newPhotoS3Key,
                                            'photoId': _newPhotoPhotoId,
                                          };
                                          final newList = List<Map<String, dynamic>>.from(widget.carPhotos)..add(newObj);
                                          widget.onCarPhotosChanged(newList);
                                          setState(() {
                                            _isAdding = false;
                                            _resetNewPhotoState();
                                          });
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4FA4B5),
                                    disabledBackgroundColor: const Color(0xFFCCD5DB),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Guardar',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else if (!isMaxReached)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isAdding = true;
                            _resetNewPhotoState();
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Agregar foto del carro',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002B4B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: isMinReached && !_isAdding,
          onBack: widget.onBack,
          onContinue: widget.onContinue,
          buttonText: 'Continuar',
        ),
      ],
    );
  }
}
