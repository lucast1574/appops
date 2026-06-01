import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class RecoveryPersonalObjectsStep extends StatefulWidget {
  final int taskId;
  final List<Map<String, dynamic>> personalObjects;
  final ValueChanged<List<Map<String, dynamic>>> onPersonalObjectsChanged;
  final bool confirmNoMoreObjects;
  final ValueChanged<bool> onConfirmNoMoreObjectsChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryPersonalObjectsStep({
    super.key,
    required this.taskId,
    required this.personalObjects,
    required this.onPersonalObjectsChanged,
    required this.confirmNoMoreObjects,
    required this.onConfirmNoMoreObjectsChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<RecoveryPersonalObjectsStep> createState() => _RecoveryPersonalObjectsStepState();
}

class _RecoveryPersonalObjectsStepState extends State<RecoveryPersonalObjectsStep> {
  bool _isAdding = false;
  late TextEditingController _objectDescController;

  // New object photo state
  bool _newObjectIsUploaded = false;
  String? _newObjectImagePath;
  String? _newObjectTag;
  String? _newObjectS3Key;
  dynamic _newObjectPhotoId;

  @override
  void initState() {
    super.initState();
    _objectDescController = TextEditingController();
  }

  @override
  void dispose() {
    _objectDescController.dispose();
    super.dispose();
  }

  void _resetNewObjectPhotoState() {
    _newObjectIsUploaded = false;
    _newObjectImagePath = null;
    _newObjectTag = null;
    _newObjectS3Key = null;
    _newObjectPhotoId = null;
  }

  @override
  Widget build(BuildContext context) {
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
                          'Objetos personales',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF002B4B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Objetos personales encontrados en el vehículo de recupero',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF4A5568),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Saved personal objects list
                  ...widget.personalObjects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final description = item['description'] as String? ?? '';
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
                                'Objeto personal ${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF002B4B),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  final newList = List<Map<String, dynamic>>.from(widget.personalObjects)..removeAt(index);
                                  widget.onPersonalObjectsChanged(newList);
                                  widget.onConfirmNoMoreObjectsChanged(false);
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
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF002B4B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FlowPhotoInput(
                            label: 'Foto del objeto',
                            taskId: widget.taskId,
                            photoLabel: 'objeto_personal_${index + 1}',
                            previewFileName: 'objeto_personal_${index + 1}.jpg',
                            isUploaded: item['isUploaded'] == true,
                            imagePath: item['imagePath'],
                            tag: item['tag'],
                            photoId: item['photoId'] is int
                                ? item['photoId'] as int
                                : int.tryParse(item['photoId']?.toString() ?? ''),
                            onChanged: (uploaded, res) {
                              final newList = List<Map<String, dynamic>>.from(widget.personalObjects);
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
                              widget.onPersonalObjectsChanged(newList);
                            },
                            onTagChanged: (newTag) {
                              final newList = List<Map<String, dynamic>>.from(widget.personalObjects);
                              newList[index] = {
                                ...newList[index],
                                'tag': newTag,
                              };
                              widget.onPersonalObjectsChanged(newList);
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
                            'Objeto personal ${widget.personalObjects.length + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _objectDescController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Describir objeto personal',
                              hintStyle: GoogleFonts.inter(color: const Color(0xFFA0AEC0)),
                              fillColor: const Color(0xFFF8FAFC),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF4FA4B5)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FlowPhotoInput(
                            label: 'Foto del objeto (Opcional)',
                            taskId: widget.taskId,
                            photoLabel: 'objeto_personal_${widget.personalObjects.length + 1}',
                            previewFileName: 'objeto_personal_${widget.personalObjects.length + 1}.jpg',
                            isUploaded: _newObjectIsUploaded,
                            imagePath: _newObjectImagePath,
                            tag: _newObjectTag,
                            onChanged: (uploaded, res) {
                              setState(() {
                                _newObjectIsUploaded = uploaded;
                                if (uploaded && res is Map) {
                                  _newObjectImagePath = res['localPath'] ?? res['downloadUrl'];
                                  _newObjectS3Key = res['s3Key'];
                                  _newObjectPhotoId = res['photoId'];
                                } else {
                                  _newObjectImagePath = null;
                                  _newObjectS3Key = null;
                                  _newObjectPhotoId = null;
                                }
                              });
                            },
                            onTagChanged: (newTag) {
                              setState(() {
                                _newObjectTag = newTag;
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
                                      _objectDescController.clear();
                                      _resetNewObjectPhotoState();
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
                                  onPressed: () {
                                    final text = _objectDescController.text.trim();
                                    if (text.isNotEmpty) {
                                      final Map<String, dynamic> newObj = {
                                        'description': text,
                                        'isUploaded': _newObjectIsUploaded,
                                        'imagePath': _newObjectImagePath,
                                        'tag': _newObjectTag,
                                        's3Key': _newObjectS3Key,
                                        'photoId': _newObjectPhotoId,
                                      };
                                      final newList = List<Map<String, dynamic>>.from(widget.personalObjects)..add(newObj);
                                      widget.onPersonalObjectsChanged(newList);
                                      setState(() {
                                        _isAdding = false;
                                        _objectDescController.clear();
                                        _resetNewObjectPhotoState();
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4FA4B5),
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
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isAdding = true;
                            _objectDescController.clear();
                            _resetNewObjectPhotoState();
                            widget.onConfirmNoMoreObjectsChanged(false);
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Agregar objeto',
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

                  const SizedBox(height: 32),
                  InkWell(
                    onTap: () {
                      widget.onConfirmNoMoreObjectsChanged(!widget.confirmNoMoreObjects);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.confirmNoMoreObjects
                            ? const Color(0xFF4FA4B5).withValues(alpha: 0.05)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.confirmNoMoreObjects
                              ? const Color(0xFF4FA4B5)
                              : const Color(0xFFE2E8F0),
                          width: widget.confirmNoMoreObjects ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: widget.confirmNoMoreObjects,
                            activeColor: const Color(0xFF4FA4B5),
                            onChanged: (val) {
                              if (val != null) {
                                widget.onConfirmNoMoreObjectsChanged(val);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.personalObjects.isEmpty
                                  ? 'No se encontraron objetos personales en el carro'
                                  : 'Confirmar que no se encontraron más objetos',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF002B4B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        FlowStepNavigation(
          isContinueEnabled: widget.confirmNoMoreObjects && !_isAdding,
          onBack: widget.onBack,
          onContinue: widget.onContinue,
          buttonText: 'Continuar',
        ),
      ],
    );
  }
}
