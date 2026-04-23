import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';
import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/conversion_service_info_step.dart';
import '../widgets/steps/conversion_certificate_step.dart';
import '../widgets/steps/conversion_checklist_step.dart';
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
  late Map<String, dynamic> _task;
  bool _loadingDetail = true;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _fetchFullDetail();
  }

  /// The dashboard passes a lightweight task (TaskListSerializer) which
  /// is missing metadata, google_maps_link, etc. We fetch the full
  /// detail immediately so all steps have the complete data.
  Future<void> _fetchFullDetail() async {
    try {
      final taskId = _task['id'];
      if (taskId != null) {
        final full = await _taskService.getTaskDetail(taskId is int ? taskId : int.parse('$taskId'));
        if (mounted) {
          setState(() {
            _task = full;
            _loadingDetail = false;
          });
        }
      } else {
        setState(() => _loadingDetail = false);
      }
    } catch (_) {
      // Fallback to the lightweight task if detail fetch fails
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  // Photo upload state (one per step)
  bool _certificateUploaded = false;
  String? _certificateTag;
  String? _certificateLocalPath;
  bool _checklistUploaded = false;
  String? _checklistTag;
  String? _checklistLocalPath;

  int _getProgressIndex() {
    if (_currentStep >= 5) return 4;
    if (_currentStep >= 4) return 4;
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

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = _currentStep != 5;

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
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () => _showRescheduleDialog(context),
                    icon: SvgPicture.asset(
                      'assets/warning.svg',
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        Colors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'Reportar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: FlowProgressBar(
                  totalSteps: 5,
                  activeIndex: _getProgressIndex(),
                  allComplete: _currentStep == 4,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: _loadingDetail
          ? const Center(child: CircularProgressIndicator())
          : _submitting
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
      case 0:
        return TaskInfoWidget(
          task: _task,
          onContinue: _nextStep,
        );
      case 1:
        return ConversionServiceInfoStep(
          task: _task,
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 2:
        return ConversionCertificateStep(
          taskId: _task['id'] ?? 0,
          googleMapsLink: _task['google_maps_link'] as String?,
          uploaded: _certificateUploaded,
          tag: _certificateTag,
          imagePath: _certificateLocalPath,
          onChanged: (uploaded, res) => setState(() {
            _certificateUploaded = uploaded;
            if (res is Map) _certificateLocalPath = res['localPath'];
          }),
          onTagChanged: (val) => setState(() => _certificateTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return ConversionChecklistStep(
          taskId: _task['id'] ?? 0,
          googleMapsLink: _task['google_maps_link'] as String?,
          uploaded: _checklistUploaded,
          tag: _checklistTag,
          imagePath: _checklistLocalPath,
          onChanged: (uploaded, res) => setState(() {
            _checklistUploaded = uploaded;
            if (res is Map) _checklistLocalPath = res['localPath'];
          }),
          onTagChanged: (val) => setState(() => _checklistTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 4:
        return ConversionSummaryStep(
          task: _task,
          certificateUploaded: _certificateUploaded,
          checklistUploaded: _checklistUploaded,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditServiceInfo: () => setState(() => _currentStep = 1),
          onEditResult: () => setState(() => _currentStep = 2),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 5:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(
          task: _task,
          onContinue: _nextStep,
        );
    }
  }

  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = _task['id'] ?? 0;
      final metadata = _task['metadata'] as Map<String, dynamic>? ?? {};

      await _taskService.submitTask(
        taskId,
        resultData: {
          'service_type': metadata['service_type'] ?? '',
          'google_maps_link': _task['google_maps_link'] ?? '',
          'certificate_uploaded': _certificateUploaded,
          'checklist_uploaded': _checklistUploaded,

        },
        observations: '',
      );
      if (mounted) setState(() => _currentStep = 5);
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
                final taskId = _task['id'] ?? 0;
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
