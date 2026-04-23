import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';
import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/vv_detail_step.dart';
import '../widgets/steps/vv_photo_step.dart';
import '../widgets/steps/vv_summary_step.dart';

/// Flow: Verificar Vehículo
/// Step 0: Task info (read-only) + GPS proximity check (≤50m)
/// Step 1: Confirmation interstitial ("Recuerda estar en la ubicación")
/// Step 2: Detail (¿visible? + observaciones)
/// Step 3: Photo of vehicle
/// Step 4: Summary
/// Step 5: Success
class VehicleVerificationPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const VehicleVerificationPage({super.key, required this.task});

  @override
  State<VehicleVerificationPage> createState() => _VehicleVerificationPageState();
}

class _VehicleVerificationPageState extends State<VehicleVerificationPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  bool _startingTask = false;
  late Map<String, dynamic> _task;
  bool _loadingDetail = true;

  // Step 2 state
  bool? _isVisible;
  final TextEditingController _observationsController = TextEditingController();

  // Step 3 state
  bool _photoUploaded = false;
  String? _photoTag;
  String? _photoLocalPath;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _fetchFullDetail();
  }

  Future<void> _fetchFullDetail() async {
    try {
      final taskId = widget.task['id'];
      if (taskId != null) {
        final full = await _taskService.getTaskDetail(
          taskId is int ? taskId : int.parse('$taskId'),
        );
        if (mounted) setState(() { _task = full; _loadingDetail = false; });
      } else {
        if (mounted) setState(() => _loadingDetail = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  int _getProgressIndex() {
    if (_currentStep <= 1) return 0;
    if (_currentStep == 2) return 1;
    if (_currentStep == 3) return 2;
    if (_currentStep >= 4) return 3;
    return 0;
  }

  void _nextStep() => setState(() => _currentStep++);

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else if (_currentStep == 2) {
      // Skip the interstitial going back
      setState(() => _currentStep = 0);
    } else {
      setState(() => _currentStep--);
    }
  }

  /// Validate GPS proximity before starting the task.
  /// The operario must be within 50m of the task location.
  Future<void> _validateAndStart() async {
    if (_startingTask) return;
    setState(() => _startingTask = true);
    
    final messenger = ScaffoldMessenger.of(context);

    // Check if task has coordinates
    final double? taskLat = _task['latitude'] is num
        ? (_task['latitude'] as num).toDouble()
        : double.tryParse('${_task['latitude'] ?? ''}');
    final double? taskLng = _task['longitude'] is num
        ? (_task['longitude'] as num).toDouble()
        : double.tryParse('${_task['longitude'] ?? ''}');

    if (taskLat != null && taskLng != null) {
      try {
        // Request location
        LocationPermission perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Se necesita permiso de ubicación para iniciar esta tarea'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        /*
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        final distance = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, taskLat, taskLng,
        );

        if (distance > 50) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Debes estar a menos de 50 metros de la ubicación de la tarea. '
                  'Distancia actual: ${distance.round()}m',
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return;
        }
        */
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error al obtener ubicación: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // GPS OK (or no coordinates to validate) — start the task
    try {
      final int taskId = _task['id'] ?? 0;
      if (_task['status'] != 'in_progress') {
        await _taskService.startTask(taskId);
      }
      _nextStep();
    } catch (e) {
      // 400 = already started, just advance
      if (e.toString().contains('400')) {
        _nextStep();
        return;
      }
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al iniciar tarea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _startingTask = false);
    }
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
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
                'Verificar vehículo',
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
                      width: 18, height: 18,
                      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    ),
                    label: Text(
                      'Reportar',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: FlowProgressBar(
                  totalSteps: 4,
                  activeIndex: _getProgressIndex(),
                  allComplete: _currentStep == 4,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: _loadingDetail
            ? const Center(child: CircularProgressIndicator())
            : _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return TaskInfoWidget(
          task: _task,
          onContinue: _validateAndStart,
          isSubmitting: _startingTask,
          extraFields: [
            // Warning banner about GPS proximity
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCCD5DB)),
              ),
              child: Row(
                children: [
                  SvgPicture.asset('assets/alarm.svg', width: 20, height: 20,
                    colorFilter: const ColorFilter.mode(Color(0xFF002B4B), BlendMode.srcIn)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Antes de comenzar\nRecuerda estar en la ubicación de la tarea antes de comenzar',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF002B4B),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        // Interstitial confirmation
        return _buildInterstitial();
      case 2:
        return VehicleVerificationDetailStep(
          task: _task,
          isVisible: _isVisible,
          observationsController: _observationsController,
          onVisibleChanged: (val) => setState(() => _isVisible = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return VehicleVerificationPhotoStep(
          taskId: _task['id'] ?? 0,
          uploaded: _photoUploaded,
          tag: _photoTag,
          imagePath: _photoLocalPath,
          onChanged: (uploaded, res) => setState(() {
            _photoUploaded = uploaded;
            if (uploaded) _photoLocalPath = res?['localPath'];
          }),
          onTagChanged: (val) => setState(() => _photoTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 4:
        return VehicleVerificationSummaryStep(
          task: _task,
          isVisible: _isVisible,
          observations: _observationsController.text,
          photoUploaded: _photoUploaded,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditDetail: () => setState(() => _currentStep = 2),
          onEditPhoto: () => setState(() => _currentStep = 3),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmation(context),
        );
      case 5:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(task: _task, onContinue: _validateAndStart);
    }
  }

  Widget _buildInterstitial() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6F8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/alarm.svg',
                        width: 40, height: 40,
                        colorFilter: const ColorFilter.mode(Color(0xFF002B4B), BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Antes de comenzar',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Recuerda estar en la ubicación de la tarea antes de comenzar',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF668093), height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFCCD4DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Atrás', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF4FA4B5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: Text('Continuar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final int taskId = _task['id'] ?? 0;
      await _taskService.submitTask(
        taskId,
        resultData: {
          'is_visible': _isVisible,
          'observations': _observationsController.text,
          'photo_uploaded': _photoUploaded,
        },
      );
      if (mounted) setState(() => _currentStep = 5);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('Error al enviar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (ctx) => FlowConfirmationSheet(
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () async { Navigator.pop(ctx); await _submitTask(); },
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
}
