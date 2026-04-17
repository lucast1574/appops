import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';
import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/conversion_service_info_step.dart';
import '../widgets/steps/conversion_result_step.dart';
import '../widgets/steps/conversion_summary_step.dart';

/// Conversion flow:
///   Step 0: Task info (shared TaskInfoWidget) — read-only, "Comenzar tarea"
///   Step 1: Service info — placa, tipo read-only, Google Maps button
///   Step 2: Result — upload certificate, checklist, creative photo
///   Step 3: Summary — review before sending
///   Step 4: Confirmation bottom sheet → submit → success
class ConversionPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const ConversionPage({super.key, required this.task});

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;

  // Step 2 — photo upload state
  bool _certificateUploaded = false;
  String? _certificateKey;
  bool _checklistUploaded = false;
  String? _checklistKey;
  bool _creativeUploaded = false;
  String? _creativeKey;

  int _getProgressIndex() {
    if (_currentStep >= 3) return 3;
    return _currentStep;
  }

  void _nextStep() => setState(() => _currentStep++);

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _currentStep--);
    }
  }

  Future<void> _startAndContinue() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final int taskId = widget.task['id'] ?? 0;
      final status = widget.task['status'] ?? 'pending';
      // Only call startTask if task hasn't been started yet.
      // Backend accepts: pending, rescheduled. Already in_progress = skip.
      if (status == 'pending' || status == 'rescheduled') {
        await _taskService.startTask(taskId);
      }
      _nextStep();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al iniciar tarea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = _currentStep != 4;

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
                'Conversión',
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
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => _showRescheduleDialog(context),
                  tooltip: 'Reprogramar',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: FlowProgressBar(
                  totalSteps: 4,
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
        return TaskInfoWidget(
          task: widget.task,
          onContinue: _startAndContinue,
        );
      case 1:
        return ConversionServiceInfoStep(
          task: widget.task,
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 2:
        return ConversionResultStep(
          taskId: widget.task['id'] ?? 0,
          googleMapsLink: widget.task['google_maps_link'] as String?,
          certificateUploaded: _certificateUploaded,
          certificateKey: _certificateKey,
          onCertificateChanged: (uploaded, key) => setState(() {
            _certificateUploaded = uploaded;
            _certificateKey = key;
          }),
          checklistUploaded: _checklistUploaded,
          checklistKey: _checklistKey,
          onChecklistChanged: (uploaded, key) => setState(() {
            _checklistUploaded = uploaded;
            _checklistKey = key;
          }),
          creativeUploaded: _creativeUploaded,
          creativeKey: _creativeKey,
          onCreativeChanged: (uploaded, key) => setState(() {
            _creativeUploaded = uploaded;
            _creativeKey = key;
          }),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return ConversionSummaryStep(
          task: widget.task,
          certificateUploaded: _certificateUploaded,
          checklistUploaded: _checklistUploaded,
          creativeUploaded: _creativeUploaded,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditServiceInfo: () => setState(() => _currentStep = 1),
          onEditResult: () => setState(() => _currentStep = 2),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 4:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(
          task: widget.task,
          onContinue: _startAndContinue,
        );
    }
  }

  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = widget.task['id'] ?? 0;
      final metadata = widget.task['metadata'] as Map<String, dynamic>? ?? {};

      await _taskService.submitTask(
        taskId,
        resultData: {
          'service_type': metadata['service_type'] ?? '',
          'google_maps_link': widget.task['google_maps_link'] ?? '',
          'certificate_uploaded': _certificateUploaded,
          'checklist_uploaded': _checklistUploaded,
          'creative_uploaded': _creativeUploaded,
        },
        observations: '',
      );
      if (mounted) setState(() => _currentStep = 4);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red,
          ),
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

  void _showRescheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '¿Reprogramar tarea?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'La tarea volverá a estado pendiente y podrá ser reprogramada desde el backoffice.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              try {
                final taskId = widget.task['id'] ?? 0;
                await _taskService.rescheduleTask(taskId);
                if (mounted) nav.pop();
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Reprogramar',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
