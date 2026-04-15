import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared widgets
import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

// Step widgets
import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/conversion_service_info_step.dart';
import '../widgets/steps/conversion_result_step.dart';
import '../widgets/steps/conversion_summary_step.dart';

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

  // Step 1 - Service Info
  String? _selectedServiceType;
  String? _selectedLocation;

  // Step 2 - Conversion Result
  bool _certificateUploaded = false;
  String? _certificateTag;
  bool _checklistPhotoUploaded = false;
  String? _checklistPhotoTag;
  bool _fitoChecklistUploaded = false;
  String? _fitoChecklistTag;
  final TextEditingController _mapsController = TextEditingController();

  int _getProgressIndex() {
    switch (_currentStep) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return 3;
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  void dispose() {
    _mapsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep != 4; // Hide on success

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
                  onPressed: () {},
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
        return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
      case 1:
        return ConversionServiceInfoStep(
          selectedServiceType: _selectedServiceType,
          selectedLocation: _selectedLocation,
          onServiceTypeChanged: (val) => setState(() => _selectedServiceType = val),
          onLocationChanged: (val) => setState(() => _selectedLocation = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 2:
        return ConversionResultStep(
          certificateUploaded: _certificateUploaded,
          certificateTag: _certificateTag,
          onCertificateUploadedChanged: (val) => setState(() => _certificateUploaded = val),
          onCertificateTagChanged: (val) => setState(() => _certificateTag = val),
          checklistPhotoUploaded: _checklistPhotoUploaded,
          checklistPhotoTag: _checklistPhotoTag,
          onChecklistPhotoUploadedChanged: (val) => setState(() => _checklistPhotoUploaded = val),
          onChecklistPhotoTagChanged: (val) => setState(() => _checklistPhotoTag = val),
          fitoChecklistUploaded: _fitoChecklistUploaded,
          fitoChecklistTag: _fitoChecklistTag,
          onFitoChecklistUploadedChanged: (val) => setState(() => _fitoChecklistUploaded = val),
          onFitoChecklistTagChanged: (val) => setState(() => _fitoChecklistTag = val),
          mapsController: _mapsController,
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return ConversionSummaryStep(
          selectedServiceType: _selectedServiceType,
          selectedLocation: _selectedLocation,
          certificateUploaded: _certificateUploaded,
          checklistPhotoUploaded: _checklistPhotoUploaded,
          fitoChecklistUploaded: _fitoChecklistUploaded,
          mapsLink: _mapsController.text,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditServiceInfo: () => setState(() => _currentStep = 1),
          onEditResult: () => setState(() => _currentStep = 2),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 4:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(task: widget.task, onContinue: _nextStep);
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
          'service_type': _selectedServiceType,
          'location': _selectedLocation,
          'maps_link': _mapsController.text,
        },
        observations: '',
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
