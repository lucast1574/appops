import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/task_info_widget.dart';
import 'package:leasy_ops_mobile/src/core/network/photo_upload_helper.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/delivery_info_step.dart';
import '../widgets/steps/delivery_confirmation_step.dart';
import '../../../transfer/presentation/widgets/steps/transfer_inventory_step.dart';
import '../../../transfer/presentation/widgets/steps/transfer_inventory_summary_step.dart';
import '../../../transfer/presentation/widgets/steps/transfer_inspection_step.dart';
import '../../../transfer/presentation/widgets/steps/transfer_signatures_step.dart';
import '../../../transfer/presentation/widgets/steps/transfer_checklist_step.dart';
import '../widgets/steps/delivery_summary_step.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class DeliveryPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const DeliveryPage({super.key, required this.task});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  bool _loadingDetail = true;
  Map<String, dynamic>? _taskDetail;
  bool _isAutoReschedule = false;

  @override
  void initState() {
    super.initState();
    _effectiveTimeController.text = "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}";
    _kmController.addListener(() => setState(() {}));
    _fetchFullDetail();
  }

  Future<void> _fetchFullDetail() async {
    try {
      final taskId = widget.task['id'];
      if (taskId != null) {
        final full = await _taskService.getTaskDetail(taskId is int ? taskId : int.parse('$taskId'));
        if (mounted) {
          setState(() {
            _taskDetail = full;
            _loadingDetail = false;

            // Initialize from full detail (Backoffice)
            final metadata = full['metadata'] as Map<String, dynamic>? ?? {};
            _clientNameController.text = full['client_name'] ?? metadata['client_name'] ?? widget.task['client_name'] ?? '';
            _dniController.text = full['client_dni'] ?? metadata['client_dni'] ?? widget.task['client_dni'] ?? '';
            _selectedMarca = full['marca'] ?? widget.task['marca'] ?? '';
            _selectedModelo = full['modelo'] ?? widget.task['modelo'] ?? '';
            _selectedColor = full['color'] ?? widget.task['color'] ?? '';
            _unitType = full['vehicle_type'] ?? widget.task['vehicle_type'] ?? '';
            _kmController.text = full['km']?.toString() ?? widget.task['km']?.toString() ?? '';

            // RESTORE PROGRESS (from draft)
            if (full['current_step'] != null && full['current_step'] > 0) {
              _currentStep = full['current_step'];
            }
            final draft = full['draft_data'] as Map<String, dynamic>? ?? {};
            if (draft.isNotEmpty) {
              if (draft['client_name'] != null) _clientNameController.text = draft['client_name'];
              if (draft['dni'] != null) _dniController.text = draft['dni'];
              if (draft['deliver_vehicle'] != null) _deliverVehicle = draft['deliver_vehicle'];
              if (draft['km'] != null) _kmController.text = draft['km'];
              if (draft['unit_type'] != null) _unitType = draft['unit_type'];
              if (draft['marca'] != null) _selectedMarca = draft['marca'];
              if (draft['modelo'] != null) _selectedModelo = draft['modelo'];
              if (draft['color'] != null) _selectedColor = draft['color'];
              if (draft['checklist_values'] != null) {
                final Map<String, dynamic> cv = draft['checklist_values'];
                cv.forEach((k, v) => _checklistValues[k] = v as bool);
              }
              if (draft['dni_front_uploaded'] != null) _dniFrontPhotoUploaded = draft['dni_front_uploaded'];
              if (draft['dni_front_tag'] != null) _dniFrontPhotoTag = draft['dni_front_tag'];
              if (draft['dni_front_path'] != null) _dniFrontPhotoPath = draft['dni_front_path'];
              if (draft['dni_back_uploaded'] != null) _dniBackPhotoUploaded = draft['dni_back_uploaded'];
              if (draft['dni_back_tag'] != null) _dniBackPhotoTag = draft['dni_back_tag'];
              if (draft['dni_back_path'] != null) _dniBackPhotoPath = draft['dni_back_path'];
              if (draft['client_photo_uploaded'] != null) _clientPhotoUploaded = draft['client_photo_uploaded'];
              if (draft['client_photo_tag'] != null) _clientPhotoTag = draft['client_photo_tag'];
              if (draft['client_photo_path'] != null) _clientPhotoPath = draft['client_photo_path'];
              if (draft['checklist_photo_uploaded'] != null) _checklistPhotoUploaded = draft['checklist_photo_uploaded'];
              if (draft['checklist_photo_tag'] != null) _checklistPhotoTag = draft['checklist_photo_tag'];
              if (draft['checklist_photo_path'] != null) _checklistPhotoPath = draft['checklist_photo_path'];
              if (draft['acta_uploaded'] != null) _actaUploaded = draft['acta_uploaded'];
              if (draft['acta_tag'] != null) _actaTag = draft['acta_tag'];
              if (draft['acta_path'] != null) _actaPhotoPath = draft['acta_path'];
              if (draft['checklist2_uploaded'] != null) _checklist2Uploaded = draft['checklist2_uploaded'];
              if (draft['checklist2_tag'] != null) _checklist2Tag = draft['checklist2_tag'];
              if (draft['checklist2_path'] != null) _checklist2PhotoPath = draft['checklist2_path'];
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

  // Step 1 — delivery info
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  bool? _deliverVehicle;
  bool _dniFrontPhotoUploaded = false; String? _dniFrontPhotoTag; String? _dniFrontPhotoPath;
  bool _dniBackPhotoUploaded = false; String? _dniBackPhotoTag; String? _dniBackPhotoPath;

  // Step 2 — confirmation
  bool _clientPhotoUploaded = false; String? _clientPhotoTag; String? _clientPhotoPath;
  bool _checklistPhotoUploaded = false; String? _checklistPhotoTag; String? _checklistPhotoPath;
  bool _actaUploaded = false; String? _actaTag; String? _actaPhotoPath;
  bool _checklist2Uploaded = false; String? _checklist2Tag; String? _checklist2PhotoPath;

  // Step 3 — inventory checklist (reused from Transfer)
  String? _selectedMarca; String? _selectedModelo; String? _selectedColor;
  String? _unitType; final TextEditingController _kmController = TextEditingController();
  final TextEditingController _effectiveTimeController = TextEditingController();
  String? _selectedReason;
  final TextEditingController _observationsController = TextEditingController();
  String? _selectedConversion; String? _selectedFuelLevel; bool? _bloqueoDesbloqueo;
  final Map<String, bool> _checklistValues = {};

  // 0=task, 1=delivery info, 2=confirmation, 3=checklist, 4=summary, 5=success
  // Inventory
  final Map<String, Map<String, dynamic>> _inventoryValues = {};
  List<VehicleObservation> _vehicleObservations = [];

  // Signatures
  String? _signatureOperarioPath;
  String? _signatureClientPath;

  int _getProgressIndex() {
    if (_deliverVehicle == false) {
      switch (_currentStep) {
        case 0: return 0;
        case 1: return 1;
        case 2: return 2;
        case 11: return 11; // Success
        default: return _currentStep;
      }
    }
    return _currentStep;
  }


  void _nextStep() {
    setState(() => _currentStep++);
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    try {
      final taskId = widget.task['id'];
      if (taskId == null) return;

      final draftData = {
        'client_name': _clientNameController.text,
        'dni': _dniController.text,
        'deliver_vehicle': _deliverVehicle,
        'km': _kmController.text,
        'unit_type': _unitType,
        'marca': _selectedMarca,
        'modelo': _selectedModelo,
        'color': _selectedColor,
        'checklist_values': _checklistValues,
        'dni_front_uploaded': _dniFrontPhotoUploaded,
        'dni_front_tag': _dniFrontPhotoTag,
        'dni_front_path': _dniFrontPhotoPath,
        'dni_back_uploaded': _dniBackPhotoUploaded,
        'dni_back_tag': _dniBackPhotoTag,
        'dni_back_path': _dniBackPhotoPath,
        'client_photo_uploaded': _clientPhotoUploaded,
        'client_photo_tag': _clientPhotoTag,
        'client_photo_path': _clientPhotoPath,
        'checklist_photo_uploaded': _checklistPhotoUploaded,
        'checklist_photo_tag': _checklistPhotoTag,
        'checklist_photo_path': _checklistPhotoPath,
        'acta_uploaded': _actaUploaded,
        'acta_tag': _actaTag,
        'acta_path': _actaPhotoPath,
        'checklist2_uploaded': _checklist2Uploaded,
        'checklist2_tag': _checklist2Tag,
        'checklist2_path': _checklist2PhotoPath,
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
    } else {
      setState(() => _currentStep--);
    }
  }

  @override
  void dispose() { 
    _observationsController.dispose(); 
    _effectiveTimeController.dispose();
    _kmController.dispose();
    _clientNameController.dispose();
    _dniController.dispose();
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

    bool showAppBar = _currentStep < 9; // Success step is index 9
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Entrega de unidad', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/warning.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 11, activeIndex: _getProgressIndex(), allComplete: _currentStep == 11)),
      ) : null,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_loadingDetail) return const Center(child: CircularProgressIndicator());
    final currentTask = _taskDetail ?? widget.task;
    switch (_currentStep) {
      case 0: return TaskInfoWidget(task: currentTask, onContinue: _nextStep);
      case 1: return DeliveryInfoStep(
        taskId: widget.task['id'] ?? 0,
        clientNameController: _clientNameController, dniController: _dniController,
        deliverVehicle: _deliverVehicle, 
        dniFrontPhotoUploaded: _dniFrontPhotoUploaded, dniFrontPhotoTag: _dniFrontPhotoTag, dniFrontPhotoPath: _dniFrontPhotoPath,
        onDniFrontPhotoUploadedChanged: (v, res) => setState(() {
          _dniFrontPhotoUploaded = v;
          _dniFrontPhotoPath = (v && res is Map) ? res['localPath'] : null;
        }),
        onDniFrontPhotoTagChanged: (v) => setState(() => _dniFrontPhotoTag = v),
        dniBackPhotoUploaded: _dniBackPhotoUploaded, dniBackPhotoTag: _dniBackPhotoTag, dniBackPhotoPath: _dniBackPhotoPath,
        onDniBackPhotoUploadedChanged: (v, res) => setState(() {
          _dniBackPhotoUploaded = v;
          _dniBackPhotoPath = (v && res is Map) ? res['localPath'] : null;
        }),
        onDniBackPhotoTagChanged: (v) => setState(() => _dniBackPhotoTag = v),
        onDeliverVehicleChanged: (v) => setState(() => _deliverVehicle = v),
        onBack: _previousStep, 
        onContinue: () {
          if (_deliverVehicle == false) {
            setState(() => _currentStep = 2); // Go to Reschedule step
            _saveProgress();
          } else {
            _nextStep();
          }
        },
        isReversed: true,
      );
      case 2: 
        if (_deliverVehicle == false) {
          return FlowRescheduleFormStep(
            title: 'Vehículo no entregado',
            yesNoValue: _deliverVehicle,
            onYesNoChanged: (v) => setState(() => _deliverVehicle = v),
            reasons: const [
              'No es el color que se pidió',
              'El cliente no se encontraba',
              'El vehículo presenta daños',
              'Documentación incompleta',
              'Otro'
            ],
            selectedReason: _selectedReason,
            onReasonChanged: (v) => setState(() => _selectedReason = v),
            observationsController: _observationsController,
            onBack: () => setState(() => _currentStep = 1),
            onFinalizar: () => _showConfirmation(context, isReschedule: true),
            isReversed: true,
          );
        }
        return DeliveryConfirmationStep(
        taskId: widget.task['id'] ?? 0,
        deliverVehicle: _deliverVehicle,
        clientPhotoUploaded: _clientPhotoUploaded, clientPhotoTag: _clientPhotoTag, clientPhotoPath: _clientPhotoPath,
        checklistPhotoUploaded: _checklistPhotoUploaded, checklistPhotoTag: _checklistPhotoTag, checklistPhotoPath: _checklistPhotoPath,
        actaUploaded: _actaUploaded, actaTag: _actaTag, actaPhotoPath: _actaPhotoPath,
        checklist2Uploaded: _checklist2Uploaded, checklist2Tag: _checklist2Tag, checklist2PhotoPath: _checklist2PhotoPath,
        onDeliverVehicleChanged: (v) => setState(() => _deliverVehicle = v),
        onClientPhotoUploadedChanged: (v, res) => setState(() {
          _clientPhotoUploaded = v;
          _clientPhotoPath = (v && res is Map) ? res['localPath'] : null;
        }),
        onClientPhotoTagChanged: (v) => setState(() => _clientPhotoTag = v),
        onChecklistPhotoUploadedChanged: (v, res) => setState(() {
          _checklistPhotoUploaded = v;
          _checklistPhotoPath = (v && res is Map) ? res['localPath'] : null;
        }),
        onChecklistPhotoTagChanged: (v) => setState(() => _checklistPhotoTag = v),
        onActaUploadedChanged: (v, res) => setState(() {
          _actaUploaded = v;
          _actaPhotoPath = (v && res is Map) ? res['localPath'] : null;
        }),
        onActaTagChanged: (v) => setState(() => _actaTag = v),
        onChecklist2UploadedChanged: (v, res) => setState(() {
          _checklist2Uploaded = v;
          _checklist2PhotoPath = (v && res is Map) ? res['localPath'] : null;
        }),
        onChecklist2TagChanged: (v) => setState(() => _checklist2Tag = v),
        effectiveTimeController: _effectiveTimeController,
        onTimeChanged: () => setState(() {}),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 3: return TransferChecklistStep(
        placa: currentTask['placa'], date: currentTask['scheduled_date'], clientName: _clientNameController.text,
        selectedMarca: _selectedMarca, selectedModelo: _selectedModelo, selectedColor: _selectedColor,
        unitType: _unitType, kmController: _kmController,
        selectedConversion: _selectedConversion, selectedFuelLevel: _selectedFuelLevel, bloqueoDesbloqueo: _bloqueoDesbloqueo,
        checklistValues: _checklistValues,
        onChecklistChanged: (key, val) => setState(() => _checklistValues[key] = val),
        onMarcaChanged: (v) => setState(() => _selectedMarca = v),
        onModeloChanged: (v) => setState(() => _selectedModelo = v),
        onColorChanged: (v) => setState(() => _selectedColor = v),
        onUnitTypeChanged: (v) => setState(() => _unitType = v),
        onConversionChanged: (v) => setState(() => _selectedConversion = v),
        onFuelLevelChanged: (v) => setState(() => _selectedFuelLevel = v),
        onBloqueoDesbloqueoChanged: (v) => setState(() => _bloqueoDesbloqueo = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 4: return TransferInventoryStep(
        title: 'Listado Inventario (1/3)',
        sections: {
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
        onBack: _previousStep, onContinue: _nextStep,
        isContinueEnabled: _isInventoryPart1Complete,
      );
      case 5: return TransferInventoryStep(
        title: 'Listado Inventario (2/3)',
        sections: {
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
        onBack: _previousStep, onContinue: _nextStep,
        isContinueEnabled: _isInventoryPart2Complete,
      );
      case 6: return TransferInventoryStep(
        title: 'Descripción General (3/3)',
        sections: {
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
            'Cámara de retroceso', 'Navegador and bluetooth', 'Porta documentos',
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
        onBack: _previousStep, onContinue: _nextStep,
        isContinueEnabled: _isInventoryPart3Complete,
      );
      case 7: return TransferInspectionStep(
        taskId: widget.task['id'] ?? 0,
        observations: _vehicleObservations,
        onObservationsChanged: (v) => setState(() => _vehicleObservations = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 8: return TransferInventorySummaryStep(
        inventoryValues: _inventoryValues,
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 9: return TransferSignaturesStep(
        signatureOperarioPath: _signatureOperarioPath,
        signatureClientPath: _signatureClientPath,
        onOperarioSignatureChanged: (v) => setState(() => _signatureOperarioPath = v),
        onClientSignatureChanged: (v) => setState(() => _signatureClientPath = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 10: 
        final docsCount = _getSectionCount(['Prueba de bloqueo / desbloqueo efectiva', 'Pasaporte de garantía y mantenimiento', 'Placas de rodaje y tercera placa', 'Manual del conductor', 'Conversión GNV/GLP – Pasaporte de proveedor', 'Certificado de Revisión técnica complementaria vigente']);
        final facilitiesCount = _getSectionCount(['Explicación de talleres', 'Explicación para agendar cita', 'Explicación de activación GNV/GLP']);
        final inspectionCount = _getSectionCount(['Limpieza y estado exterior del vehículo', 'Limpieza y estado interior del vehículo', 'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)']);
        final invDetailCount = _getSectionCount(['Antena', 'Gata', 'Seguro de aros', 'Segunda llave de contacto', 'Encendedor', 'Cenicero', 'Tapas de ruedas', 'Tapas de remolque', 'Dado de seguro de ruedas', 'Llanta de repuesto', 'Equipo multimedia', 'Pisos: Hule / Alfombra', 'Kit de emergencia:']);
        final generalCount = _getSectionCount(['Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas', 'Paneles de puertas y maletera – controles', 'Seguridad', 'Cinturones', 'Bolsas de aire', 'Seguro de niños', 'Ventanas y retrovisores', 'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda', 'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha', 'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos', 'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares', 'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho', 'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible', 'Cámara de retroceso', 'Navegador and bluetooth', 'Porta documentos']);

        return DeliverySummaryStep(
          task: currentTask,
          clientName: _clientNameController.text, clientDni: _dniController.text, deliverVehicle: _deliverVehicle,
          effectiveTime: _effectiveTimeController.text,
          clientPhotoUploaded: _clientPhotoUploaded, checklistPhotoUploaded: _checklistPhotoUploaded,
          actaUploaded: _actaUploaded,
          checklistChecked: docsCount + facilitiesCount + inspectionCount + invDetailCount + generalCount,
          checklistTotal: 6 + 3 + 3 + 13 + 31,
          observationsCount: _vehicleObservations.length,
          sectionCounts: {
            'docs': '$docsCount/6',
            'facilities': '$facilitiesCount/3',
            'inspection': '$inspectionCount/3',
            'inventory': '$invDetailCount/20',
            'general': '$generalCount/31',
          },
          hasOperarioSignature: _signatureOperarioPath != null,
          hasClientSignature: _signatureClientPath != null,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditDeliveryInfo: () => setState(() => _currentStep = 1),
          onEditConfirmation: () => setState(() => _currentStep = 2),
          onEditChecklist: () => setState(() => _currentStep = 3),
          onEditInventory: () => setState(() => _currentStep = 4),
          onEditInspection: () => setState(() => _currentStep = 7),
          onEditSignatures: () => setState(() => _currentStep = 9),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmation(context),
        );
      case 11: return FlowSuccessStep(
        onBackToStart: () => Navigator.pop(context),
        isReschedule: _isAutoReschedule,
      );
      default: return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
    }
  }


  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = widget.task['id'] ?? 0;

      // Upload signatures to S3 if they are local paths
      String? operarioUrl = _signatureOperarioPath;
      if (operarioUrl != null && !operarioUrl.startsWith('http')) {
        operarioUrl = await PhotoUploadHelper.uploadFile(
          taskId: taskId,
          label: 'signature_operario',
          filePath: operarioUrl,
        );
      }

      String? clientUrl = _signatureClientPath;
      if (clientUrl != null && !clientUrl.startsWith('http')) {
        clientUrl = await PhotoUploadHelper.uploadFile(
          taskId: taskId,
          label: 'signature_client',
          filePath: clientUrl,
        );
      }

      await _taskService.submitTask(
        taskId,
        resultData: {
          'client_name': _clientNameController.text,
          'dni': _dniController.text,
          'deliver_vehicle': _deliverVehicle,
          'reschedule_reason': _selectedReason,
          'observations': _observationsController.text,
          'effective_delivery_time': _effectiveTimeController.text,
          'km_input': _kmController.text,
          'conversion': _selectedConversion,
          'fuel_level': _selectedFuelLevel,
        },
        checklistData: _inventoryValues,
        observations: _vehicleObservations.map((o) {
          return {
            'id': o.id,
            'part': o.part,
            'type': o.type,
            'description': o.description,
            'photos': o.photos,
            'position_x': o.position?.dx,
            'position_y': o.position?.dy,
          };
        }).toList(),
        signatures: {
          'signature_operario': operarioUrl,
          'signature_client': clientUrl,
        },
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

  void _showConfirmation(BuildContext context, {bool isReschedule = false}) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => FlowConfirmationSheet(
        onCancel: () => Navigator.pop(context), 
        onConfirm: () async { 
          Navigator.pop(context); 
          if (isReschedule) {
            await _submitAutomaticReschedule();
          } else {
            await _submitTask(); 
          }
        }
      ),
    );
  }

  Future<void> _submitAutomaticReschedule() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = widget.task['id'] ?? 0;
      
      String reason = "Reprogramación automática (Entrega). ";
      if (_selectedReason != null) reason += "Motivo: $_selectedReason. ";
      if (_observationsController.text.isNotEmpty) reason += "Obs: ${_observationsController.text}";

      await _taskService.rescheduleTask(
        taskId, 
        reason: reason,
        resultData: {
          'deliver_vehicle': false,
          'reschedule_reason': _selectedReason,
          'observations': _observationsController.text,
        },
      );
      
      if (mounted) {
        setState(() {
          _isAutoReschedule = true;
          _currentStep = 11;
        });
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  int _getSectionCount(List<String> items) {
    return items.where((item) {
      final val = _inventoryValues[item];
      return val != null && val['value'] != null;
    }).length;
  }

  bool get _isInventoryPart1Complete {
    final items = [
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

    final items = [
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

    final items = [
      'Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas',
      'Paneles de puertas y maletera – controles', 'Seguridad',
      'Ventanas y retrovisores',
      'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda',
      'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha',
      'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos',
      'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares',
      'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho',
      'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible',
      'Cámara de retroceso', 'Navegador and bluetooth', 'Porta documentos',
    ];

    if (!items.every((item) => _inventoryValues[item]?['value'] != null)) return false;

    if (parentSeguridad == true) {
      final securitySubItems = ['Cinturones', 'Bolsas de aire', 'Seguro de niños'];
      if (!securitySubItems.every((item) => _inventoryValues[item]?['value'] != null)) return false;
    }

    return true;
  }
}
