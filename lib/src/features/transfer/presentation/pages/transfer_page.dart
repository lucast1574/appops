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
            _loadingDetail = false;
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
              _selectedMarca = draft['marca'];
              _selectedModelo = draft['modelo'];
              _selectedColor = draft['color'];
              _selectedConversion = draft['conversion'];
              _selectedFuel = draft['fuel'];
              _lockTestValue = draft['lock_test'];
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
  String? _selectedMarca;
  String? _selectedModelo;
  String? _selectedColor;
  String? _selectedConversion;
  String? _selectedFuel;
  bool? _lockTestValue;

  final List<String> _marcas = ['Toyota', 'Hyundai', 'Kia', 'Nissan', 'Chevrolet'];
  final List<String> _modelos = ['Hilux', 'Accent', 'Rio', 'Sentra', 'Onix', 'Ertiga', 'Swift'];
  final List<String> _colores = ['Blanco', 'Negro', 'Gris', 'Rojo', 'Azul', 'Plata'];
  final List<String> _conversiones = ['GNV', 'GLP', 'Gasolina', 'Dual'];
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
        'marca': _selectedMarca,
        'modelo': _selectedModelo,
        'color': _selectedColor,
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
    super.dispose(); 
  }

  String get _placa => _selectedPlaca ?? 'ABC-392';
  String get _origin => 'Concesionario movistar';
  String get _destination => _selectedDestination ?? 'Concesionario miraflores';

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

    bool showAppBar = _currentStep != 7;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Traslado', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: SvgPicture.asset('assets/warning.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)), onPressed: () {})],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 8, activeIndex: _getProgressIndex(), allComplete: _currentStep == 7)),
      ) : null,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_loadingDetail) return const Center(child: CircularProgressIndicator());
    switch (_currentStep) {
      case 0: return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
      case 1: return TransferInfoStep(
        taskId: widget.task['id'] ?? 0,
        placa: _placa, originLocation: _origin, destinationLocation: _destination,
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
        placa: _placa, originLocation: _origin, destinationLocation: _destination,
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
        selectedMarca: _selectedMarca,
        selectedModelo: _selectedModelo,
        selectedColor: _selectedColor,
        selectedConversion: _selectedConversion,
        selectedFuel: _selectedFuel,
        lockTestValue: _lockTestValue,
        marcas: _marcas, modelos: _modelos, colores: _colores, conversiones: _conversiones, fuelLevels: _fuelLevels,
        onMarcaChanged: (v) => setState(() => _selectedMarca = v),
        onModeloChanged: (v) => setState(() => _selectedModelo = v),
        onColorChanged: (v) => setState(() => _selectedColor = v),
        onConversionChanged: (v) => setState(() => _selectedConversion = v),
        onFuelChanged: (v) => setState(() => _selectedFuel = v),
        onLockTestChanged: (v) => setState(() => _lockTestValue = v),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 4: return TransferInventoryStep(
        inventoryValues: _inventoryValues,
        onInventoryChanged: (key, val) => setState(() => _inventoryValues[key] = Map<String, dynamic>.from(val)),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 5: return TransferInspectionStep(
        taskId: widget.task['id'] is int ? widget.task['id'] : int.tryParse('${widget.task['id']}') ?? 0,
        observations: _vehicleObservations,
        onObservationsChanged: (obs) => setState(() => _vehicleObservations = obs),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 6: return TransferSignaturesStep(
        signatureOperarioPath: _signatureOperarioPath,
        signatureClientPath: _signatureClientPath,
        onOperarioSignatureChanged: (val) => setState(() => _signatureOperarioPath = val),
        onClientSignatureChanged: (val) => setState(() => _signatureClientPath = val),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 7: return TransferSummaryStep(
        placa: _placa, originLocation: _origin, destinationLocation: _destination,
        exitPhotoUploaded: _exitPhotoUploaded, kmStartPhotoUploaded: _kmStartPhotoUploaded,
        deliveryPhotoUploaded: _deliveryPhotoUploaded, kmEndPhotoUploaded: _kmEndPhotoUploaded,
        deliveryName: _deliveryNameController.text,
        inventoryCount: _inventoryValues.values.where((v) => v['value'] != null).length,
        observationsCount: _vehicleObservations.length,
        hasOperarioSignature: _signatureOperarioPath != null,
        hasClientSignature: _signatureClientPath != null,
        onEditTaskInfo: () => setState(() => _currentStep = 0),
        onEditTransferInfo: () => setState(() => _currentStep = 1),
        onEditDeliveryInfo: () => setState(() => _currentStep = 2),
        onEditInventory: () => setState(() => _currentStep = 4),
        onEditInspection: () => setState(() => _currentStep = 5),
        onEditSignatures: () => setState(() => _currentStep = 6),
        onEditAll: () => setState(() => _currentStep = 0),
        onSend: () => _showConfirmation(context),
      );
      case 8: return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
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
          'placa': _selectedPlaca,
          'origin': _origin,
          'destination': _selectedDestination,
          'delivery_name': _deliveryNameController.text,
          'client_name': _clientNameController.text,
          'date': _dateController.text,
          'placa_input': _placaInputController.text,
          'km_input': _kmInputController.text,
          'marca': _selectedMarca,
          'modelo': _selectedModelo,
          'color': _selectedColor,
          'conversion': _selectedConversion,
          'fuel': _selectedFuel,
          'lock_test': _lockTestValue,
        },
        observations: '',
      );
      if (mounted) setState(() => _currentStep = 7);
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
      builder: (context) => FlowConfirmationSheet(onCancel: () => Navigator.pop(context), onConfirm: () async { Navigator.pop(context); await _submitTask(); }),
    );
  }
}
