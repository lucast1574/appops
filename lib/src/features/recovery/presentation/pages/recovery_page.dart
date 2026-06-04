import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';
import '../../../../shared/widgets/task_chat_action_button.dart';

import '../widgets/steps/recovery_task_info_step.dart';
import '../widgets/steps/recovery_before_starting_step.dart';
import '../widgets/steps/recovery_efectuado_step.dart';
import '../widgets/steps/recovery_efectuado_no_confirm_step.dart';
import '../widgets/steps/recovery_reschedule_step.dart';
import '../widgets/steps/recovery_reschedule_summary_step.dart';
import '../widgets/steps/recovery_personal_objects_step.dart';
import '../widgets/steps/recovery_photos_intro_step.dart';
import '../widgets/steps/recovery_car_photos_step.dart';
import '../widgets/steps/recovery_inspection_step.dart';
import '../widgets/steps/recovery_summary_step.dart';
import '../../../../shared/widgets/vehicle_inspection_widget.dart';
import '../../../transfer/presentation/widgets/steps/transfer_inventory_step.dart';
import '../../../home/data/task_service.dart';

class RecoveryPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const RecoveryPage({super.key, required this.task});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  late Map<String, dynamic> _task;
  bool _loadingDetail = true;
  bool _isAutoReschedule = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _fetchFullDetail();
  }

  Future<void> _fetchFullDetail() async {
    try {
      final taskId = _task['id'];
      if (taskId != null) {
        final full = await _taskService.getTaskDetail(taskId is int ? taskId : int.parse('$taskId'));
        if (mounted) {
          setState(() {
            _task = full;
            _loadingDetail = false;
            // RESTORE PROGRESS
            if (full['current_step'] != null && full['current_step'] > 0) {
              _currentStep = full['current_step'] == 1 ? 2 : full['current_step'];
            }
            final draft = full['draft_data'] as Map<String, dynamic>? ?? {};
            if (draft.isNotEmpty) {
              if (draft['recovery_efectuado'] != null) _recoveryEfectuado = draft['recovery_efectuado'];
              if (draft['reschedule_reason'] != null) _selectedReason = draft['reschedule_reason'];
              if (draft['reschedule_observations'] != null) _observationsController.text = draft['reschedule_observations'];
              if (draft['reschedule_photo_uploaded'] != null) _rescheduleUploaded = draft['reschedule_photo_uploaded'];
              if (draft['reschedule_photo_tag'] != null) _rescheduleTag = draft['reschedule_photo_tag'];
              if (draft['reschedule_photo_local_path'] != null) _rescheduleLocalPath = draft['reschedule_photo_local_path'];
              if (draft['inventory'] != null) {
                final Map<String, dynamic> inv = draft['inventory'];
                inv.forEach((k, v) => _inventoryValues[k] = Map<String, dynamic>.from(v));
              }
              if (draft['personal_objects'] != null) {
                _personalObjects = List<Map<String, dynamic>>.from(
                  (draft['personal_objects'] as List).map((x) => Map<String, dynamic>.from(x)),
                );
              }
              if (draft['car_observations'] != null) {
                _carObservations = draft['car_observations'];
              }
              if (draft['confirm_no_more_objects'] != null) {
                _confirmNoMoreObjects = draft['confirm_no_more_objects'];
              }
              if (draft['car_photos'] != null) {
                _carPhotos = List<Map<String, dynamic>>.from(
                  (draft['car_photos'] as List).map((x) => Map<String, dynamic>.from(x)),
                );
              }
              if (draft['observations'] != null) {
                final List obsList = draft['observations'];
                _vehicleObservations = obsList.map((o) => VehicleObservation(
                  id: o['id'],
                  part: o['part'],
                  type: o['type'] ?? '',
                  description: o['description'] ?? '',
                  photos: List<String?>.from(o['photos'] ?? [null, null, null]),
                  position: o['position_x'] != null ? Offset(o['position_x'], o['position_y']) : null,
                )).toList();
              }
            }
          });
        }
      } else {
        if (mounted) setState(() => _loadingDetail = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  // Step 2 — Recovery status
  bool? _recoveryEfectuado;
  String? _selectedReason;
  final TextEditingController _observationsController = TextEditingController();
  bool _rescheduleUploaded = false;
  String? _rescheduleTag;
  String? _rescheduleLocalPath;

  // Step 3 — Listado Inventario
  final Map<String, Map<String, dynamic>> _inventoryValues = {};

  // Step 6 — Objetos personales & Observaciones
  List<Map<String, dynamic>> _personalObjects = [];
  String _carObservations = '';
  bool _confirmNoMoreObjects = false;

  // Step 8 — Fotos de la unidad
  List<Map<String, dynamic>> _carPhotos = [];

  // Step 9 — Inspección de Daños
  List<VehicleObservation> _vehicleObservations = [];

  int _getTotalSteps() {
    if (_recoveryEfectuado == false) {
      return 3;
    }
    return 10;
  }

  // 0=info, 1=interstitial, 2=efectuado, 3=checklist, 4=checklist2, 5=checklist3, 6=personal_objects, 7=photos_360_intro, 8=photos_360_list, 9=inspection, 10=summary, 11=success, 12=success (no), 13=reschedule, 14=reschedule_summary, 15=efectuado_no_confirm
  int _getProgressIndex() {
    if (_recoveryEfectuado == false) {
      switch (_currentStep) {
        case 0: case 1: return 0;
        case 2: case 15: return 1;
        case 13: case 14: return 2;
        default: return 2;
      }
    }
    switch (_currentStep) {
      case 0: case 1: return 0;
      case 2: return 1;
      case 3: return 2;
      case 4: return 3;
      case 5: return 4;
      case 6: return 5;
      case 7: return 6;
      case 8: return 7;
      case 9: return 8;
      case 10: return 9;
      default: return 9;
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 2);
      _saveProgress();
      return;
    }
    if (_currentStep == 2) {
      if (_recoveryEfectuado == false) {
        setState(() => _currentStep = 15); // Go to Interstitial confirmation step (case 15)
        _saveProgress();
        return;
      } else {
        setState(() => _currentStep = 3); // Go to Listado Inventario step
        _saveProgress();
        return;
      }
    }
    if (_currentStep == 15) {
      setState(() => _currentStep = 13); // Go to Reschedule step (case 13)
      _saveProgress();
      return;
    }
    if (_currentStep == 3) {
      setState(() => _currentStep = 4); // Go to Listado Inventario step 2
      _saveProgress();
      return;
    }
    if (_currentStep == 4) {
      setState(() => _currentStep = 5); // Go to Listado Inventario step 3
      _saveProgress();
      return;
    }
    if (_currentStep == 5) {
      setState(() => _currentStep = 6); // Go to Personal Objects step
      _saveProgress();
      return;
    }
    if (_currentStep == 6) {
      setState(() => _currentStep = 7); // Go to 360 photos intro
      _saveProgress();
      return;
    }
    if (_currentStep == 7) {
      setState(() => _currentStep = 8); // Go to 360 photos list
      _saveProgress();
      return;
    }
    if (_currentStep == 8) {
      setState(() => _currentStep = 9); // Go to Vehicle Inspection step
      _saveProgress();
      return;
    }
    if (_currentStep == 9) {
      setState(() => _currentStep = 10); // Go to Summary step
      _saveProgress();
      return;
    }
    if (_currentStep == 10) {
      _showConfirmation(context);
      return;
    }
    setState(() => _currentStep++);
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    try {
      final taskId = _task['id'];
      if (taskId == null) return;

      final draftData = {
        'recovery_efectuado': _recoveryEfectuado,
        'reschedule_reason': _selectedReason,
        'reschedule_observations': _observationsController.text,
        'reschedule_photo_uploaded': _rescheduleUploaded,
        'reschedule_photo_tag': _rescheduleTag,
        'reschedule_photo_local_path': _rescheduleLocalPath,
        'inventory': _inventoryValues,
        'personal_objects': _personalObjects,
        'car_observations': _carObservations,
        'confirm_no_more_objects': _confirmNoMoreObjects,
        'car_photos': _carPhotos,
        'observations': _vehicleObservations.map((o) => {
          'id': o.id,
          'part': o.part,
          'type': o.type,
          'description': o.description,
          'photos': o.photos,
          'position_x': o.position?.dx,
          'position_y': o.position?.dy,
        }).toList(),
      };

      await _taskService.updateProgress(
        taskId is int ? taskId : int.parse('$taskId'),
        currentStep: _currentStep,
        draftData: draftData,
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 0);
    } else if (_currentStep == 3) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 4) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 5) {
      setState(() => _currentStep = 4);
    } else if (_currentStep == 6) {
      setState(() => _currentStep = 5);
    } else if (_currentStep == 7) {
      setState(() => _currentStep = 6);
    } else if (_currentStep == 8) {
      setState(() => _currentStep = 7);
    } else if (_currentStep == 9) {
      setState(() => _currentStep = 8);
    } else if (_currentStep == 10) {
      setState(() => _currentStep = 9);
    } else if (_currentStep == 15) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 13) {
      if (_recoveryEfectuado == false) {
        setState(() => _currentStep = 15);
      } else {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 14) {
      setState(() => _currentStep = 13);
    } else {
      setState(() => _currentStep--);
    }
  }

  @override
  void dispose() { 
    _observationsController.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    if (_submitting) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4FA4B5)),
              const SizedBox(height: 16),
              Text(
                'Enviando información...',
                style: GoogleFonts.inter(
                  color: const Color(0xFF002B4B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    bool showAppBar = _currentStep != 1 && _currentStep != 11 && _currentStep != 12;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
              title: Text(_currentStep == 10 ? 'Resumen de tarea' : 'Recupero', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
              actions: [
                if (_currentStep == 0 || _currentStep == 10) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 10),
                    child: InkWell(
                      onTap: () => _showRescheduleDialog(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD1D1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reportar',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE35959),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/warning.svg',
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(Color(0xFFE35959), BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/warning.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    ),
                    onPressed: () => _showRescheduleDialog(context),
                  ),
                ],
                TaskChatActionButton(
                  taskId: _task['id'] ?? 0,
                  taskTitle: 'Recupero',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: FlowProgressBar(
                  totalSteps: _getTotalSteps(),
                  activeIndex: _getProgressIndex(),
                  allComplete: _currentStep == 11 || _currentStep == 12,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  bool get _isInventoryComplete {
    const items = [
      'Prueba de bloqueo / desbloqueo efectiva',
      'Pasaporte de garantía y mantenimiento',
      'Placas de rodaje y tercera placa',
      'Manual del conductor',
      'Conversión GNV/GLP – Pasaporte de proveedor',
      'Certificado de Revisión técnica complementaria vigente',
      'Explicación de talleres',
      'Explicación para agendar cita',
      'Explicación de activación GNV/GLP',
      'Limpieza y estado exterior del vehículo',
      'Limpieza y estado interior del vehículo',
      'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)',
    ];
    return items.every((item) => _inventoryValues[item]?['value'] != null);
  }

  bool get _isInventoryPart2Complete {
    final parentKey = _inventoryValues['Segunda llave de contacto']?['value'];
    final parentKit = _inventoryValues['Kit de emergencia:']?['value'];

    const items = [
      'Antena', 'Gata', 'Seguro de aros', 'Segunda llave de contacto', 
      'Encendedor', 'Cenicero', 'Tapas de ruedas', 'Tapas de remolque', 'Dado de seguro de ruedas',
      'Llanta de repuesto', 'Equipo multimedia', 'Pisos: Hule / Alfombra',
      'Kit de emergencia:',
    ];

    if (!items.every((item) => _inventoryValues[item]?['value'] != null)) return false;

    if (parentKey == true) {
      if (_inventoryValues['Simple']?['value'] == null || _inventoryValues['Con control']?['value'] == null) return false;
    }

    if (parentKit == true) {
      final kitSubItems = ['Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas'];
      if (!kitSubItems.every((item) => _inventoryValues[item]?['value'] != null)) return false;
    }

    return true;
  }

  bool get _isInventoryPart3Complete {
    final parentSeguridad = _inventoryValues['Seguridad']?['value'];

    const items = [
      'Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas',
      'Paneles de puertas y maletera – controles', 'Seguridad',
      'Ventanas y retrovisores',
      'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda',
      'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha',
      'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos',
      'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares',
      'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho',
      'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible',
      'Cámara de retroceso', 'Navegador y bluetooth', 'Porta documentos',
    ];

    if (!items.every((item) => _inventoryValues[item]?['value'] != null)) return false;

    if (parentSeguridad == true) {
      final securitySubItems = ['Cinturones', 'Bolsas de aire', 'Seguro de niños'];
      if (!securitySubItems.every((item) => _inventoryValues[item]?['value'] != null)) return false;
    }

    return true;
  }

  Widget _buildCurrentStep() {
    if (_loadingDetail) return const Center(child: CircularProgressIndicator());
    switch (_currentStep) {
      case 0: return RecoveryTaskInfoStep(task: _task, onContinue: _nextStep);
      case 1: return RecoveryBeforeStartingStep(onContinue: _nextStep, onBack: _previousStep);
      case 2: return RecoveryEfectuadoStep(
        value: _recoveryEfectuado,
        onChanged: (v) => setState(() => _recoveryEfectuado = v),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 3: return TransferInventoryStep(
        title: 'Listado Inventario',
        sections: const {
          'Entrega y Explicación de Documentación del Vehículo': [
            'Prueba de bloqueo / desbloqueo efectiva',
            'Pasaporte de garantía y mantenimiento',
            'Placas de rodaje y tercera placa',
            'Manual del conductor',
            'Conversión GNV/GLP – Pasaporte de proveedor',
            'Certificado de Revisión técnica complementaria vigente',
          ],
          'Instalaciones del Concesionario': [
            'Explicación de talleres',
            'Explicación para agendar cita',
            'Explicación de activación GNV/GLP',
          ],
          'Inspección del Vehículo': [
            'Limpieza y estado exterior del vehículo',
            'Limpieza y estado interior del vehículo',
            'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)',
          ],
        },
        inventoryValues: _inventoryValues,
        onInventoryChanged: (key, val) => setState(() => _inventoryValues[key] = Map<String, dynamic>.from(val)),
        onBack: _previousStep,
        onContinue: _nextStep,
        isContinueEnabled: _isInventoryComplete,
      );
      case 4: return TransferInventoryStep(
        title: 'Listado Inventario',
        sections: const {
          'Detalle de Inventario': [
            'Antena', 'Gata', 'Seguro de aros', 'Segunda llave de contacto', 
            'Simple', 'Con control', 'Encendedor', 'Cenicero', 'Tapas de ruedas', 
            'Tapas de remolque', 'Dado de seguro de ruedas', 'Llanta de repuesto', 
            'Equipo multimedia', 'Pisos: Hule / Alfombra', 'Kit de emergencia:',
            'Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas',
          ],
        },
        inventoryValues: _inventoryValues,
        onInventoryChanged: (key, val) => setState(() {
          _inventoryValues[key] = Map<String, dynamic>.from(val);
          if (key == 'Segunda llave de contacto' && val['value'] == false) {
            _inventoryValues['Simple'] = {'value': null, 'obs': ''};
            _inventoryValues['Con control'] = {'value': null, 'obs': ''};
          } else if (key == 'Kit de emergencia:' && val['value'] == false) {
            final kitSubItems = ['Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas'];
            for (var item in kitSubItems) {
              _inventoryValues[item] = {'value': null, 'obs': ''};
            }
          }
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
        isContinueEnabled: _isInventoryPart2Complete,
      );
      case 5: return TransferInventoryStep(
        title: 'Listado Inventario',
        sections: const {
          'Descripción General': [
            'Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas',
            'Paneles de puertas y maletera – controles', 'Seguridad', 'Cinturones',
            'Bolsas de aire', 'Seguro de niños', 'Ventanas y retrovisores',
            'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda',
            'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha',
            'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos',
            'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares',
            'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho',
            'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible',
            'Cámara de retroceso', 'Navegador y bluetooth', 'Porta documentos',
          ],
        },
        inventoryValues: _inventoryValues,
        onInventoryChanged: (key, val) => setState(() {
          _inventoryValues[key] = Map<String, dynamic>.from(val);
          if (key == 'Seguridad' && val['value'] == false) {
            _inventoryValues['Cinturones'] = {'value': null, 'obs': ''};
            _inventoryValues['Bolsas de aire'] = {'value': null, 'obs': ''};
            _inventoryValues['Seguro de niños'] = {'value': null, 'obs': ''};
          }
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
        isContinueEnabled: _isInventoryPart3Complete,
      );
      case 6: return RecoveryPersonalObjectsStep(
        taskId: _task['id'] is int ? _task['id'] as int : int.parse('${_task['id']}'),
        personalObjects: _personalObjects,
        onPersonalObjectsChanged: (list) => setState(() {
          _personalObjects = list;
          _saveProgress();
        }),
        confirmNoMoreObjects: _confirmNoMoreObjects,
        onConfirmNoMoreObjectsChanged: (val) => setState(() {
          _confirmNoMoreObjects = val;
          _saveProgress();
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 7: return RecoveryPhotosIntroStep(
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 8: return RecoveryCarPhotosStep(
        taskId: _task['id'] is int ? _task['id'] as int : int.parse('${_task['id']}'),
        carPhotos: _carPhotos,
        onCarPhotosChanged: (list) => setState(() {
          _carPhotos = list;
          _saveProgress();
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 9: return RecoveryInspectionStep(
        taskId: _task['id'] is int ? _task['id'] as int : int.parse('${_task['id']}'),
        observations: _vehicleObservations,
        onObservationsChanged: (obs) => setState(() {
          _vehicleObservations = obs;
          _saveProgress();
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 10:
        final docsCount = _getSectionCount(const [
          'Prueba de bloqueo / desbloqueo efectiva',
          'Pasaporte de garantía y mantenimiento',
          'Placas de rodaje y tercera placa',
          'Manual del conductor',
          'Conversión GNV/GLP – Pasaporte de proveedor',
          'Certificado de Revisión técnica complementaria vigente'
        ]);
        final facilitiesCount = _getSectionCount(const [
          'Explicación de talleres',
          'Explicación para agendar cita',
          'Explicación de activación GNV/GLP'
        ]);
        final inspectionCount = _getSectionCount(const [
          'Limpieza y estado exterior del vehículo',
          'Limpieza y estado interior del vehículo',
          'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)'
        ]);
        final invDetailCount = _getSectionCount(const [
          'Antena', 'Gata', 'Seguro de aros', 'Segunda llave de contacto', 
          'Simple', 'Con control', 'Encendedor', 'Cenicero', 'Tapas de ruedas', 
          'Tapas de remolque', 'Dado de seguro de ruedas', 'Llanta de repuesto', 
          'Equipo multimedia', 'Pisos: Hule / Alfombra', 'Kit de emergencia:',
          'Extintor', 'Triángulo o cono de seguridad', 'Botiquín', 'Linterna', 'Cintas reflectivas'
        ]);
        final generalCount = _getSectionCount(const [
          'Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas',
          'Paneles de puertas y maletera – controles', 'Seguridad', 'Cinturones',
          'Bolsas de aire', 'Seguro de niños', 'Ventanas y retrovisores',
          'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda',
          'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha',
          'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos',
          'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares',
          'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho',
          'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible',
          'Cámara de retroceso', 'Navegador y bluetooth', 'Porta documentos'
        ]);

        return RecoverySummaryStep(
          task: _task,
          recoveryEfectuado: _recoveryEfectuado,
          personalObjects: _personalObjects,
          carPhotos: _carPhotos,
          sectionCounts: {
            'docs': '$docsCount/6',
            'facilities': '$facilitiesCount/3',
            'inspection': '$inspectionCount/3',
            'inventory': '$invDetailCount/20',
            'general': '$generalCount/31',
          },
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditRecoveryEfectuado: () => setState(() => _currentStep = 2),
          onEditInventory: () => setState(() => _currentStep = 3),
          onEditPersonalObjects: () => setState(() => _currentStep = 6),
          onEditCarPhotos: () => setState(() => _currentStep = 8),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmation(context),
        );
      case 11: return FlowSuccessStep(
        onBackToStart: () => Navigator.pop(context),
        title: 'Tarea completada',
        subtitle: 'Los datos se han enviado correctamente y el registro ha sido actualizado',
      );
      case 12: return FlowSuccessStep(
        onBackToStart: () => Navigator.pop(context),
        title: _isAutoReschedule ? 'Tarea reprogramada' : 'Tarea completada',
        subtitle: _isAutoReschedule 
            ? 'La tarea ha sido reprogramada y el registro ha sido actualizado.'
            : 'Los datos se han enviado correctamente y el registro ha sido actualizado',
        isReschedule: _isAutoReschedule,
      );
      case 13: return RecoveryRescheduleStep(
        taskId: _task['id'] ?? 0,
        isPhotoUploaded: _rescheduleUploaded,
        photoPath: _rescheduleLocalPath,
        photoTag: _rescheduleTag,
        onPhotoChanged: (uploaded, res) => setState(() {
          _rescheduleUploaded = uploaded;
          if (res is Map) _rescheduleLocalPath = res['localPath'];
        }),
        onPhotoTagChanged: (v) => setState(() => _rescheduleTag = v),
        selectedReason: _selectedReason,
        reasons: const [
          'Cliente se niega a entregar',
          'Vehículo no ubicado',
          'Se realizó compromiso de pago',
          'Cliente no se encontraba',
          'Otro'
        ],
        onReasonChanged: (v) => setState(() => _selectedReason = v),
        observationsController: _observationsController,
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 14: return RecoveryRescheduleSummaryStep(
        task: _task,
        isPhotoUploaded: _rescheduleUploaded,
        selectedReason: _selectedReason,
        observations: _observationsController.text,
        onEditTaskInfo: () => setState(() => _currentStep = 0),
        onEditRescheduleInfo: () => setState(() => _currentStep = 13),
        onEditAll: () => setState(() => _currentStep = 2),
        onSend: () => _showConfirmation(context),
      );
      case 15: return RecoveryEfectuadoNoConfirmStep(
        onCambiar: () => setState(() {
          _currentStep = 2;
          _saveProgress();
        }),
        onBack: _previousStep,
        onConfirm: _nextStep,
      );
      default: return RecoveryTaskInfoStep(task: _task, onContinue: _nextStep);
    }
  }

  Future<void> _submitAutomaticReschedule() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = _task['id'] ?? 0;
      
      String reason = "Reprogramación automática (Recupero). ";
      if (_selectedReason != null) reason += "Motivo: $_selectedReason. ";
      if (_observationsController.text.isNotEmpty) reason += "Obs: ${_observationsController.text}";

      await _taskService.rescheduleTask(
        taskId, 
        reason: reason,
        resultData: {
          'recovery_efectuado': false,
          'reschedule_reason': _selectedReason,
          'observations': _observationsController.text,
        },
      );
      
      if (mounted) {
        setState(() {
          _isAutoReschedule = true;
          _currentStep = 12;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reprogramar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = _task['id'] ?? 0;
      await _taskService.submitTask(
        taskId,
        resultData: {
          'recovery_efectuado': true,
          'personal_objects': _personalObjects,
          'car_photos': _carPhotos,
        },
        checklistData: _inventoryValues,
        observations: _vehicleObservations.map((o) => {
          'id': o.id,
          'part': o.part,
          'type': o.type,
          'description': o.description,
          'photos': o.photos,
          'position_x': o.position?.dx,
          'position_y': o.position?.dy,
        }).toList(),
      );
      if (mounted) setState(() => _currentStep = 11);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => FlowConfirmationSheet(
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          if (_recoveryEfectuado == false) {
            await _submitAutomaticReschedule();
          } else {
            await _submitTask();
          }
        },
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Reprogramar tarea?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('La tarea volverá a estado pendiente.', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              try {
                await _taskService.rescheduleTask(_task['id'] ?? 0);
                if (mounted) nav.pop();
              } catch (e) {
                if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            child: Text('Reprogramar', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  int _getSectionCount(List<String> items) {
    return items.where((item) {
      final val = _inventoryValues[item];
      return val != null && val['value'] != null;
    }).length;
  }
}
