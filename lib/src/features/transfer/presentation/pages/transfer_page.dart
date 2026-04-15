import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../widgets/steps/transfer_task_info_step.dart';
import '../widgets/steps/transfer_info_step.dart';
import '../widgets/steps/transfer_delivery_info_step.dart';
import '../widgets/steps/transfer_checklist_step.dart';
import '../widgets/steps/transfer_summary_step.dart';

class TransferPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const TransferPage({super.key, required this.task});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  int _currentStep = 0;

  // Step 0
  String? _selectedPlaca;
  String? _selectedDestination;

  // Step 1 — transfer info
  bool _exitPhotoUploaded = false; String? _exitPhotoTag;
  bool _kmStartPhotoUploaded = false; String? _kmStartPhotoTag;

  // Step 2 — delivery info
  bool _deliveryPhotoUploaded = false; String? _deliveryPhotoTag;
  bool _kmEndPhotoUploaded = false; String? _kmEndPhotoTag;
  final TextEditingController _deliveryNameController = TextEditingController();

  // Step 3 — checklist
  String? _selectedMarca; String? _selectedModelo; String? _selectedColor;
  String? _unitType; final TextEditingController _kmController = TextEditingController();
  String? _selectedConversion; String? _selectedFuelLevel; bool? _bloqueoDesbloqueo;
  final Map<String, bool> _checklistValues = {};

  int _getProgressIndex() {
    switch (_currentStep) {
      case 0: return 0;
      case 1: return 1;
      case 2: return 2;
      case 3: return 3;
      case 4: return 4;
      default: return 4;
    }
  }

  void _nextStep() => setState(() => _currentStep++);
  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _currentStep--);
    }
  }

  @override
  void dispose() { _deliveryNameController.dispose(); _kmController.dispose(); super.dispose(); }

  String get _placa => _selectedPlaca ?? 'ABC-392';
  String get _origin => 'Concesionario movistar';
  String get _destination => _selectedDestination ?? 'Concesionario miraflores';

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep != 5;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Traslado', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: SvgPicture.asset('assets/warning.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)), onPressed: () {})],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 5, activeIndex: _getProgressIndex(), allComplete: _currentStep == 4)),
      ) : null,
      body: SafeArea(child: _buildCurrentStep()),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return TransferTaskInfoStep(
        selectedPlaca: _selectedPlaca, selectedDestination: _selectedDestination,
        onPlacaChanged: (v) => setState(() => _selectedPlaca = v),
        onDestinationChanged: (v) => setState(() => _selectedDestination = v),
        onContinue: _nextStep,
      );
      case 1: return TransferInfoStep(
        placa: _placa, originLocation: _origin, destinationLocation: _destination,
        exitPhotoUploaded: _exitPhotoUploaded, exitPhotoTag: _exitPhotoTag,
        kmStartPhotoUploaded: _kmStartPhotoUploaded, kmStartPhotoTag: _kmStartPhotoTag,
        onExitPhotoUploadedChanged: (v) => setState(() => _exitPhotoUploaded = v),
        onExitPhotoTagChanged: (v) => setState(() => _exitPhotoTag = v),
        onKmStartPhotoUploadedChanged: (v) => setState(() => _kmStartPhotoUploaded = v),
        onKmStartPhotoTagChanged: (v) => setState(() => _kmStartPhotoTag = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 2: return TransferDeliveryInfoStep(
        placa: _placa, originLocation: _origin, destinationLocation: _destination,
        deliveryPhotoUploaded: _deliveryPhotoUploaded, deliveryPhotoTag: _deliveryPhotoTag,
        kmEndPhotoUploaded: _kmEndPhotoUploaded, kmEndPhotoTag: _kmEndPhotoTag,
        deliveryNameController: _deliveryNameController,
        onDeliveryPhotoUploadedChanged: (v) => setState(() => _deliveryPhotoUploaded = v),
        onDeliveryPhotoTagChanged: (v) => setState(() => _deliveryPhotoTag = v),
        onKmEndPhotoUploadedChanged: (v) => setState(() => _kmEndPhotoUploaded = v),
        onKmEndPhotoTagChanged: (v) => setState(() => _kmEndPhotoTag = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 3: return TransferChecklistStep(
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
      case 4: return TransferSummaryStep(
        placa: _placa, originLocation: _origin, destinationLocation: _destination,
        exitPhotoUploaded: _exitPhotoUploaded, kmStartPhotoUploaded: _kmStartPhotoUploaded,
        deliveryPhotoUploaded: _deliveryPhotoUploaded, kmEndPhotoUploaded: _kmEndPhotoUploaded,
        deliveryName: _deliveryNameController.text,
        selectedMarca: _selectedMarca, selectedModelo: _selectedModelo, selectedColor: _selectedColor,
        unitType: _unitType, km: _kmController.text, selectedConversion: _selectedConversion,
        selectedFuelLevel: _selectedFuelLevel, bloqueoDesbloqueo: _bloqueoDesbloqueo,
        onEditTaskInfo: () => setState(() => _currentStep = 0),
        onEditTransferInfo: () => setState(() => _currentStep = 1),
        onEditDeliveryInfo: () => setState(() => _currentStep = 2),
        onEditChecklist: () => setState(() => _currentStep = 3),
        onEditAll: () => setState(() => _currentStep = 0),
        onSend: () => _showConfirmation(context),
      );
      case 5: return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default: return TransferTaskInfoStep(selectedPlaca: _selectedPlaca, selectedDestination: _selectedDestination, onPlacaChanged: (v) => setState(() => _selectedPlaca = v), onDestinationChanged: (v) => setState(() => _selectedDestination = v), onContinue: _nextStep);
    }
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => FlowConfirmationSheet(onCancel: () => Navigator.pop(context), onConfirm: () { Navigator.pop(context); setState(() => _currentStep = 5); }),
    );
  }
}
