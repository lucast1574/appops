import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../widgets/steps/vv_task_info_step.dart';
import '../widgets/steps/vv_detail_step.dart';
import '../widgets/steps/vv_summary_step.dart';

// Reuse the shared before-starting step from management
import '../../../management/presentation/widgets/steps/management_before_starting_step.dart';

class VehicleVerificationPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const VehicleVerificationPage({super.key, required this.task});

  @override
  State<VehicleVerificationPage> createState() => _VehicleVerificationPageState();
}

class _VehicleVerificationPageState extends State<VehicleVerificationPage> {
  int _currentStep = 0;
  bool? _isVisible;
  final TextEditingController _observationsController = TextEditingController();

  // 0=info, 1=interstitial, 2=detail, 3=summary, 4=success
  int _getProgressIndex() {
    switch (_currentStep) {
      case 0: case 1: return 0;
      case 2: return 1;
      case 3: return 2;
      default: return 2;
    }
  }

  void _nextStep() => setState(() => _currentStep++);
  void _previousStep() {
    if (_currentStep == 0) { Navigator.pop(context); }
    else if (_currentStep == 2) { setState(() => _currentStep = 0); }
    else { setState(() => _currentStep--); }
  }

  @override
  void dispose() { _observationsController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep != 1 && _currentStep != 4;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Verificar vehículo', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: SvgPicture.asset('assets/warning.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)), onPressed: () {})],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 3, activeIndex: _getProgressIndex(), allComplete: _currentStep == 3)),
      ) : null,
      body: SafeArea(child: _buildCurrentStep()),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return VehicleVerificationTaskInfoStep(onContinue: _nextStep);
      case 1: return ManagementBeforeStartingStep(onContinue: _nextStep, onBack: _previousStep);
      case 2: return VehicleVerificationDetailStep(
        isVisible: _isVisible,
        observationsController: _observationsController,
        onVisibleChanged: (val) => setState(() => _isVisible = val),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 3: return VehicleVerificationSummaryStep(
        isVisible: _isVisible,
        observations: _observationsController.text,
        onEditTaskInfo: () => setState(() => _currentStep = 0),
        onEditDetail: () => setState(() => _currentStep = 2),
        onEditAll: () => setState(() => _currentStep = 0),
        onSend: () => _showConfirmation(context),
      );
      case 4: return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default: return VehicleVerificationTaskInfoStep(onContinue: _nextStep);
    }
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => FlowConfirmationSheet(
        onCancel: () => Navigator.pop(context),
        onConfirm: () { Navigator.pop(context); setState(() => _currentStep = 4); },
      ),
    );
  }
}
