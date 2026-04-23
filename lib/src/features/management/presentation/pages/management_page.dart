import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../../../home/data/task_service.dart';
import '../widgets/steps/management_before_starting_step.dart';
import '../widgets/steps/management_result_step.dart';
import '../widgets/steps/management_payment_step.dart';
import '../widgets/steps/management_detail_step.dart';
import '../widgets/steps/management_summary_step.dart';
import '../../../../shared/widgets/task_info_widget.dart';

class ManagementPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const ManagementPage({super.key, required this.task});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  late String _managementType;
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
            final metadata = full['metadata'] as Map<String, dynamic>? ?? {};
            _managementType = metadata['management_type'] ?? 'Prueba de Bloqueo / Desbloqueo';
            
            // Pre-fill from metadata if available
            _fineType = metadata['fine_type'];
            _selectedMunicipality = metadata['selected_municipality'];
            
            // Pre-fill times from task base if available
            _startTimeController.text = TaskService.formatTime(full['start_time'] as String?);
            _endTimeController.text = TaskService.formatTime(full['end_time'] as String?);
            
            _loadingDetail = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingDetail = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          final metadata = widget.task['metadata'] as Map<String, dynamic>? ?? {};
          _managementType = metadata['management_type'] ?? 'Prueba de Bloqueo / Desbloqueo';
          _loadingDetail = false;
        });
      }
    }
  }

  // === Bloqueo/Desbloqueo state ===
  String? _verificationResult;
  final TextEditingController _observationsController = TextEditingController();

  // === Pago servicio state ===
  String? _fineType;
  String? _municipality;
  String? _selectedMunicipality;

  // === General Detail (Apoyo oficina/taller, Trámite policial) state ===
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  int _getProgressIndex() {
    switch (_currentStep) {
      case 0:
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 2;
      default:
        return 2;
    }
  }

  void _nextStep() => setState(() => _currentStep++);

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 0);
    } else {
      setState(() => _currentStep--);
    }
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDetail) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool showAppBar = _currentStep != 1 && _currentStep != 4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)),
                onPressed: _previousStep,
              ),
              title: Text(
                'Gestiones / Otros',
                style: GoogleFonts.inter(
                  color: const Color(0xFF002B4B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: FlowProgressBar(
                  totalSteps: 3,
                  activeIndex: _getProgressIndex(),
                  allComplete: _currentStep == 3,
                ),
              ),
            )
          : null,
      body: SafeArea(child: _buildCurrentStep()),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
      case 1:
        return ManagementBeforeStartingStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return _buildTypeSpecificStep();
      case 3:
        return ManagementSummaryStep(
          task: widget.task,
          managementType: _managementType,
          verificationResult: _verificationResult,
          fineType: _fineType,
          municipality: _municipality,
          selectedMunicipality: _selectedMunicipality,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          motivo: _motivoController.text,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditDetail: () => setState(() => _currentStep = 2),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 4:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
    }
  }

  Widget _buildTypeSpecificStep() {
    switch (_managementType) {
      case 'Prueba de Bloqueo / Desbloqueo':
        return ManagementResultStep(
          result: _verificationResult,
          observationsController: _observationsController,
          onResultChanged: (val) => setState(() => _verificationResult = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 'Pago servicio':
        return ManagementPaymentStep(
          fineType: _fineType,
          municipality: _municipality,
          selectedMunicipality: _selectedMunicipality,
          onFineTypeChanged: (val) => setState(() => _fineType = val),
          onMunicipalityChanged: (val) => setState(() => _municipality = val),
          onSelectedMunicipalityChanged: (val) => setState(() => _selectedMunicipality = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 'Trámite policial':
      case 'Apoyo oficina':
      case 'Apoyo taller':
        return ManagementDetailStep(
          startTimeController: _startTimeController,
          endTimeController: _endTimeController,
          motivoController: _motivoController,
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      default:
        return ManagementResultStep(
          result: _verificationResult,
          observationsController: _observationsController,
          onResultChanged: (val) => setState(() => _verificationResult = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
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
          'management_type': _managementType,
          'verification_result': _verificationResult,
          'fine_type': _fineType,
          'municipality': _municipality,
          'start_time': _startTimeController.text,
          'end_time': _endTimeController.text,
          'motivo': _motivoController.text,
        },
        observations: _observationsController.text,
      );
      if (mounted) setState(() => _currentStep = 4);
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

  void _showConfirmationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return FlowConfirmationSheet(
          onCancel: () => Navigator.pop(context),
          onConfirm: () async {
            Navigator.pop(context);
            await _submitTask();
          },
        );
      },
    );
  }
}
