import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../../../home/data/task_service.dart';
import '../widgets/steps/transfer_info_step.dart';
import '../widgets/steps/transfer_delivery_info_step.dart';
import '../widgets/steps/transfer_inventory_step.dart';
import '../widgets/steps/transfer_inspection_step.dart';
import '../widgets/steps/transfer_signatures_step.dart';
import '../widgets/steps/transfer_general_data_step.dart';
import '../widgets/steps/transfer_summary_step.dart';
import '../../../../shared/widgets/task_info_widget.dart';

import '../../../../shared/widgets/vehicle_inspection_widget.dart';

class TransferPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const TransferPage({super.key, required this.task});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  bool _loadingDetail = true;
  Map<String, dynamic>? _taskDetail;

  @override
  void initState() {
    super.initState();
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
            
            // Initialize from full detail data (Backoffice)
            _marcaController.text = full['marca'] ?? widget.task['marca'] ?? '';
            _modeloController.text = full['modelo'] ?? widget.task['modelo'] ?? '';
            _colorController.text = full['color'] ?? widget.task['color'] ?? '';
            _placaInputController.text = full['placa'] ?? widget.task['placa'] ?? '';

            if (full['current_step'] != null && full['current_step'] > 0) {
              _currentStep = full['current_step'];
            }
            final draft = full['draft_data'] as Map<String, dynamic>? ?? {};
            if (draft.isNotEmpty) {
              if (draft['placa'] != null) _selectedPlaca = draft['placa'];
              if (draft['destination'] != null) _selectedDestination = draft['destination'];
              if (draft['delivery_name'] != null) _deliveryNameController.text = draft['delivery_name'];
              
              if (draft['inventory'] != null) {
                final Map<String, dynamic> inv = draft['inventory'];
                inv.forEach((k, v) => _inventoryValues[k] = Map<String, dynamic>.from(v));
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
              _signatureClientPath = draft['sig_client'];

              if (draft['client_name'] != null) _clientNameController.text = draft['client_name'];
              if (draft['date'] != null) _dateController.text = draft['date'];
              if (draft['placa_input'] != null) _placaInputController.text = draft['placa_input'];
              if (draft['km_input'] != null) _kmInputController.text = draft['km_input'];
              if (draft['marca'] != null) _marcaController.text = draft['marca'];
              if (draft['modelo'] != null) _modeloController.text = draft['modelo'];
              if (draft['color'] != null) _colorController.text = draft['color'];
              _selectedConversion = draft['conversion'];
              _selectedFuel = draft['fuel'];
              _lockTestValue = draft['lock_test'];
              if (_lockTestValue != null) {
                _inventoryValues['Prueba de bloqueo / desbloqueo efectiva'] = {'value': _lockTestValue, 'obs': ''};
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

  // State Variables
  String? _selectedPlaca;
  String? _selectedDestination;

  // Photos
  bool _exitPhotoUploaded = false; String? _exitPhotoTag; String? _exitPhotoPath;
  bool _kmStartPhotoUploaded = false; String? _kmStartPhotoTag; String? _kmStartPhotoPath;
  bool _deliveryPhotoUploaded = false; String? _deliveryPhotoTag; String? _deliveryPhotoPath;
  bool _kmEndPhotoUploaded = false; String? _kmEndPhotoTag; String? _kmEndPhotoPath;

  // General Car Info
  final TextEditingController _deliveryNameController = TextEditingController();

  // Inventory
  final Map<String, Map<String, dynamic>> _inventoryValues = {};

  // Vehicle Inspection
  List<VehicleObservation> _vehicleObservations = [];

  // Signatures
  // General Data
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _placaInputController = TextEditingController();
  final TextEditingController _kmInputController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  String? _selectedConversion;
  String? _selectedFuel;
  bool? _lockTestValue;

  final List<String> _conversiones = ['GNV', 'Revisión técnica'];
  final List<String> _fuelLevels = ['E', '1/4', '1/2', '3/4', 'F'];

  // Signatures
  String? _signatureOperarioPath;
  String? _signatureClientPath;

  int _getProgressIndex() {
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
        'placa': _selectedPlaca,
        'destination': _selectedDestination,
        'delivery_name': _deliveryNameController.text,
        'inventory': _inventoryValues,
        'observations': _vehicleObservations.map((o) => {
          'id': o.id,
          'part': o.part,
          'type': o.type,
          'description': o.description,
          'photos': o.photos,
          'position_x': o.position?.dx,
          'position_y': o.position?.dy,
        }).toList(),
        'sig_operario': _signatureOperarioPath,
        'sig_client': _signatureClientPath,
        'client_name': _clientNameController.text,
        'date': _dateController.text,
        'placa_input': _placaInputController.text,
        'km_input': _kmInputController.text,
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'color': _colorController.text,
        'conversion': _selectedConversion,
        'fuel': _selectedFuel,
        'lock_test': _lockTestValue,
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
    _deliveryNameController.dispose(); 
    _clientNameController.dispose();
    _dateController.dispose();
    _placaInputController.dispose();
    _kmInputController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    super.dispose(); 
  }

  String get _placa => _selectedPlaca ?? widget.task['placa'] ?? '---';
  String get _origin {
    final t = _taskDetail ?? widget.task;
    final metadata = t['metadata'] as Map<String, dynamic>? ?? {};
    return metadata['origin_address'] ?? t['address'] ?? 'Origen no especificado';
  }
  String get _destination {
    final t = _taskDetail ?? widget.task;
    final metadata = t['metadata'] as Map<String, dynamic>? ?? {};
    return _selectedDestination ?? metadata['dest_address'] ?? metadata['destination_address'] ?? 'Destino no especificado';
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

    bool showAppBar = _currentStep < 9;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Traslado', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: SvgPicture.asset('assets/warning.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)), onPressed: () {})],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 10, activeIndex: _getProgressIndex(), allComplete: _currentStep == 9)),
      ) : null,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_loadingDetail) return const Center(child: CircularProgressIndicator());
    final t = _taskDetail ?? widget.task;
    final metadata = t['metadata'] as Map<String, dynamic>? ?? {};
    final originMapsLink = metadata['origin_google_maps_link']?.toString() ?? metadata['google_maps_link']?.toString() ?? t['google_maps_link']?.toString();
    final destMapsLink = metadata['dest_google_maps_link']?.toString();

    switch (_currentStep) {
      case 0: return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
      case 1: return TransferInfoStep(
        taskId: widget.task['id'] ?? 0,
        placa: _placa, 
        originLocation: _origin, 
        originMapsLink: originMapsLink,
        destinationLocation: _destination,
        destinationMapsLink: destMapsLink,
        exitPhotoUploaded: _exitPhotoUploaded, exitPhotoTag: _exitPhotoTag, exitPhotoPath: _exitPhotoPath,
        kmStartPhotoUploaded: _kmStartPhotoUploaded, kmStartPhotoTag: _kmStartPhotoTag, kmStartPhotoPath: _kmStartPhotoPath,
        onExitPhotoUploadedChanged: (v, result) => setState(() { 
          _exitPhotoUploaded = v; 
          _exitPhotoPath = result is Map ? result['localPath'] : result as String?; 
        }),
        onExitPhotoTagChanged: (v) => setState(() => _exitPhotoTag = v),
        onKmStartPhotoUploadedChanged: (v, result) => setState(() { 
          _kmStartPhotoUploaded = v; 
          _kmStartPhotoPath = result is Map ? result['localPath'] : result as String?; 
        }),
        onKmStartPhotoTagChanged: (v) => setState(() => _kmStartPhotoTag = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 2: return TransferDeliveryInfoStep(
        taskId: widget.task['id'] ?? 0,
        placa: _placa, 
        originLocation: _origin, 
        originMapsLink: originMapsLink,
        destinationLocation: _destination,
        destinationMapsLink: destMapsLink,
        deliveryPhotoUploaded: _deliveryPhotoUploaded, deliveryPhotoTag: _deliveryPhotoTag, deliveryPhotoPath: _deliveryPhotoPath,
        kmEndPhotoUploaded: _kmEndPhotoUploaded, kmEndPhotoTag: _kmEndPhotoTag, kmEndPhotoPath: _kmEndPhotoPath,
        deliveryNameController: _deliveryNameController,
        onDeliveryPhotoUploadedChanged: (v, result) => setState(() { 
          _deliveryPhotoUploaded = v; 
          _deliveryPhotoPath = result is Map ? result['localPath'] : result as String?; 
        }),
        onDeliveryPhotoTagChanged: (v) => setState(() => _deliveryPhotoTag = v),
        onKmEndPhotoUploadedChanged: (v, result) => setState(() { 
          _kmEndPhotoUploaded = v; 
          _kmEndPhotoPath = result is Map ? result['localPath'] : result as String?; 
        }),
        onKmEndPhotoTagChanged: (v) => setState(() => _kmEndPhotoTag = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 3: return TransferGeneralDataStep(
        nameController: _clientNameController,
        dateController: _dateController,
        placaController: _placaInputController,
        kmController: _kmInputController,
        marcaController: _marcaController,
        modeloController: _modeloController,
        colorController: _colorController,
        selectedConversion: _selectedConversion,
        selectedFuel: _selectedFuel,
        lockTestValue: _lockTestValue,
        conversiones: _conversiones, fuelLevels: _fuelLevels,
        onConversionChanged: (v) => setState(() => _selectedConversion = v),
        onFuelChanged: (v) => setState(() => _selectedFuel = v),
        onLockTestChanged: (v) => setState(() {
          _lockTestValue = v;
          _inventoryValues['Prueba de bloqueo / desbloqueo efectiva'] = {'value': v, 'obs': ''};
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 4: return TransferInventoryStep(
        title: 'Listado Inventario (1/2)',
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
        onInventoryChanged: (key, val) => setState(() {
          _inventoryValues[key] = Map<String, dynamic>.from(val);
          if (key == 'Prueba de bloqueo / desbloqueo efectiva') {
            _lockTestValue = val['value'];
          }
        }),
        onBack: _previousStep,
        onContinue: _nextStep,
        isContinueEnabled: _isInventoryPart1Complete,
      );
      case 5: return TransferInventoryStep(
        title: 'Listado Inventario (2/2)',
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
          // Clear sub-items if parent is false
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
      case 6: return TransferInventoryStep(
        title: 'Descripción General',
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
            'Cámara de retroceso', 'Navegador y bluetooth', 'Porta documentos',
          ],
        },
        inventoryValues: _inventoryValues,
        onInventoryChanged: (key, val) => setState(() {
          _inventoryValues[key] = Map<String, dynamic>.from(val);
          // Clear safety sub-items if parent 'Seguridad' is false
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
      case 7: return TransferInspectionStep(
        taskId: widget.task['id'] is int ? widget.task['id'] : int.tryParse('${widget.task['id']}') ?? 0,
        observations: _vehicleObservations,
        onObservationsChanged: (obs) => setState(() => _vehicleObservations = obs),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 8: return TransferSignaturesStep(
        signatureOperarioPath: _signatureOperarioPath,
        signatureClientPath: _signatureClientPath,
        onOperarioSignatureChanged: (val) => setState(() => _signatureOperarioPath = val),
        onClientSignatureChanged: (val) => setState(() => _signatureClientPath = val),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 9:
        final docsCount = _getSectionCount(['Prueba de bloqueo / desbloqueo efectiva', 'Pasaporte de garantía y mantenimiento', 'Placas de rodaje y tercera placa', 'Manual del conductor', 'Conversión GNV/GLP – Pasaporte de proveedor', 'Certificado de Revisión técnica complementaria vigente']);
        final facilitiesCount = _getSectionCount(['Explicación de talleres', 'Explicación para agendar cita', 'Explicación de activación GNV/GLP']);
        final inspectionCount = _getSectionCount(['Limpieza y estado exterior del vehículo', 'Limpieza y estado interior del vehículo', 'Presión de llantas y niveles de líquidos (aceite, anticongelante, gasolina, otros)']);
        final invDetailCount = _getSectionCount(['Antena', 'Gata', 'Seguro de aros', 'Segunda llave de contacto', 'Encendedor', 'Cenicero', 'Tapas de ruedas', 'Tapas de remolque', 'Dado de seguro de ruedas', 'Llanta de repuesto', 'Equipo multimedia', 'Pisos: Hule / Alfombra', 'Kit de emergencia:']);
        final generalCount = _getSectionCount(['Llave inteligente', 'Sistema antirrobo – alarma', 'Bloqueo y desbloqueo de puertas', 'Paneles de puertas y maletera – controles', 'Seguridad', 'Cinturones', 'Bolsas de aire', 'Seguro de niños', 'Ventanas y retrovisores', 'Aire acondicionado', 'Plumillas delanteras y traseras', 'Luz direccional delantera izquierda', 'Luz direccional delantera derecha', 'Luz trasera izquierda', 'Luz trasera derecha', 'Sensor de retroceso posterior', 'Reloj', 'Tapasoles', 'Indicadores del tablero de instrumentos', 'Indicadores del nivel de gasolina y aceite', 'Sistema de audio y auxiliares', 'Espejos exteriores', 'Faro delantero izquierdo', 'Faro delantero derecho', 'Luz de placa', 'Emblemas', 'Accionamiento capot', 'Accionamiento de tapa de depósito de combustible', 'Cámara de retroceso', 'Navegador y bluetooth', 'Porta documentos']);

        return TransferSummaryStep(
          placa: _placa, originLocation: _origin, destinationLocation: _destination,
          exitPhotoUploaded: _exitPhotoUploaded, kmStartPhotoUploaded: _kmStartPhotoUploaded,
          deliveryPhotoUploaded: _deliveryPhotoUploaded, kmEndPhotoUploaded: _kmEndPhotoUploaded,
          deliveryName: _deliveryNameController.text,
          sectionCounts: {
            'docs': '$docsCount/6',
            'facilities': '$facilitiesCount/3',
            'inspection': '$inspectionCount/3',
            'inventory': '$invDetailCount/20',
            'general': '$generalCount/31',
          },
          isInventoryComplete: _isInventoryPart1Complete && _isInventoryPart2Complete && _isInventoryPart3Complete,
          observationsCount: _vehicleObservations.length,
          hasOperarioSignature: _signatureOperarioPath != null,
          hasClientSignature: _signatureClientPath != null,
          isSubmitting: _submitting,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditTransferInfo: () => setState(() => _currentStep = 1),
          onEditDeliveryInfo: () => setState(() => _currentStep = 2),
          onEditInventory: () => setState(() => _currentStep = 4),
          onEditInspection: () => setState(() => _currentStep = 7),
          onEditSignatures: () => setState(() => _currentStep = 8),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmation(context),
        );
      case 10: return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default: return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
    }
  }


  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = widget.task['id'] ?? 0;
      await _taskService.submitTask(
        taskId,
        resultData: {
          'placa': _placa,
          'origin': _origin,
          'destination': _destination,
          'delivery_name': _deliveryNameController.text,
          'client_name': _clientNameController.text,
          'date': _dateController.text,
          'placa_input': _placaInputController.text,
          'km_input': _kmInputController.text,
          'marca': _marcaController.text,
          'modelo': _modeloController.text,
          'color': _colorController.text,
          'conversion': _selectedConversion,
          'fuel': _selectedFuel,
          'lock_test': _lockTestValue,
          'sig_operario': _signatureOperarioPath,
          'sig_client': _signatureClientPath,
          'exit_photo': _exitPhotoPath,
          'km_start_photo': _kmStartPhotoPath,
          'delivery_photo': _deliveryPhotoPath,
          'km_end_photo': _kmEndPhotoPath,
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
      if (mounted) setState(() => _currentStep = 10);
    } catch (e) {
      debugPrint('Error submitTask: $e');
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
      builder: (context) => FlowConfirmationSheet(onCancel: () => Navigator.pop(context), onConfirm: () async { Navigator.pop(context); await _submitTask(); }),
    );
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

    // Check basic items
    if (!items.every((item) => _inventoryValues[item]?['value'] != null)) return false;

    // Check Key sub-items only if parent is true
    if (parentKey == true) {
      if (_inventoryValues['Simple']?['value'] == null || _inventoryValues['Con control']?['value'] == null) return false;
    }

    // Check Kit sub-items only if parent is true
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
      'Cámara de retroceso', 'Navegador y bluetooth', 'Porta documentos',
    ];

    // Check basic items
    if (!items.every((item) => _inventoryValues[item]?['value'] != null)) return false;

    // Check Security sub-items only if parent is true
    if (parentSeguridad == true) {
      final securitySubItems = ['Cinturones', 'Bolsas de aire', 'Seguro de niños'];
      if (!securitySubItems.every((item) => _inventoryValues[item]?['value'] != null)) return false;
    }

    return true;
  }

  int _getSectionCount(List<String> items) {
    return items.where((item) {
      final val = _inventoryValues[item];
      return val != null && val['value'] != null;
    }).length;
  }
}
