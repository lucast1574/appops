import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/delivery_info_step.dart';
import '../widgets/steps/delivery_confirmation_step.dart';
import '../../../transfer/presentation/widgets/steps/transfer_checklist_step.dart';
import '../widgets/steps/delivery_summary_step.dart';

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

  // Step 1 — delivery info
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  bool? _deliverVehicle;
  bool _dniPhotoUploaded = false; String? _dniPhotoTag;

  // Step 2 — confirmation
  bool _clientPhotoUploaded = false; String? _clientPhotoTag;
  bool _checklistPhotoUploaded = false; String? _checklistPhotoTag;
  bool _actaUploaded = false; String? _actaTag;
  final TextEditingController _deliveryTimeController = TextEditingController(text: '16:00');
  bool _checklist2Uploaded = false; String? _checklist2Tag;

  // Step 3 — inventory checklist (reused from Transfer)
  String? _selectedMarca; String? _selectedModelo; String? _selectedColor;
  String? _unitType; final TextEditingController _kmController = TextEditingController();
  String? _selectedConversion; String? _selectedFuelLevel; bool? _bloqueoDesbloqueo;
  final Map<String, bool> _checklistValues = {};

  // 0=task, 1=delivery info, 2=confirmation, 3=checklist, 4=summary, 5=success
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
  void dispose() { _clientNameController.dispose(); _dniController.dispose(); _deliveryTimeController.dispose(); _kmController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep != 5;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Entrega de unidad', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: SvgPicture.asset('assets/warning.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)), onPressed: () {})],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 5, activeIndex: _getProgressIndex(), allComplete: _currentStep == 4)),
      ) : null,
      body: SafeArea(
        child: _submitting
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF27A376)),
                    const SizedBox(height: 16),
                    Text(
                      'Enviando información...',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                  ],
                ),
              )
            : _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
      case 1: return DeliveryInfoStep(
        clientNameController: _clientNameController, dniController: _dniController,
        deliverVehicle: _deliverVehicle, dniPhotoUploaded: _dniPhotoUploaded, dniPhotoTag: _dniPhotoTag,
        onDeliverVehicleChanged: (v) => setState(() => _deliverVehicle = v),
        onDniPhotoUploadedChanged: (v) => setState(() => _dniPhotoUploaded = v),
        onDniPhotoTagChanged: (v) => setState(() => _dniPhotoTag = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 2: return DeliveryConfirmationStep(
        deliverVehicle: _deliverVehicle,
        clientPhotoUploaded: _clientPhotoUploaded, clientPhotoTag: _clientPhotoTag,
        checklistPhotoUploaded: _checklistPhotoUploaded, checklistPhotoTag: _checklistPhotoTag,
        actaUploaded: _actaUploaded, actaTag: _actaTag,
        deliveryTimeController: _deliveryTimeController,
        checklist2Uploaded: _checklist2Uploaded, checklist2Tag: _checklist2Tag,
        onDeliverVehicleChanged: (v) => setState(() => _deliverVehicle = v),
        onClientPhotoUploadedChanged: (v) => setState(() => _clientPhotoUploaded = v), onClientPhotoTagChanged: (v) => setState(() => _clientPhotoTag = v),
        onChecklistPhotoUploadedChanged: (v) => setState(() => _checklistPhotoUploaded = v), onChecklistPhotoTagChanged: (v) => setState(() => _checklistPhotoTag = v),
        onActaUploadedChanged: (v) => setState(() => _actaUploaded = v), onActaTagChanged: (v) => setState(() => _actaTag = v),
        onChecklist2UploadedChanged: (v) => setState(() => _checklist2Uploaded = v), onChecklist2TagChanged: (v) => setState(() => _checklist2Tag = v),
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
      case 4: return DeliverySummaryStep(
        clientName: _clientNameController.text, deliverVehicle: _deliverVehicle,
        clientPhotoUploaded: _clientPhotoUploaded, checklistPhotoUploaded: _checklistPhotoUploaded,
        actaUploaded: _actaUploaded, deliveryTime: _deliveryTimeController.text,
        checklistChecked: _checklistValues.values.where((v) => v).length,
        checklistTotal: _checklistValues.length,
        onEditTaskInfo: () => setState(() => _currentStep = 0),
        onEditDeliveryInfo: () => setState(() => _currentStep = 1),
        onEditConfirmation: () => setState(() => _currentStep = 2),
        onEditChecklist: () => setState(() => _currentStep = 3),
        onEditAll: () => setState(() => _currentStep = 0),
        onSend: () => _showConfirmation(context),
      );
      case 5: return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
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
          'client_name': _clientNameController.text,
          'dni': _dniController.text,
          'deliver_vehicle': _deliverVehicle,
          'delivery_time': _deliveryTimeController.text,
        },
        observations: '',
      );
      if (mounted) setState(() => _currentStep = 5);
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
