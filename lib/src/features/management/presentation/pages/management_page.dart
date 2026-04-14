import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../widgets/steps/management_task_info_step.dart';
import '../widgets/steps/management_before_starting_step.dart';
import '../widgets/steps/management_result_step.dart';
import '../widgets/steps/management_payment_step.dart';
import '../widgets/steps/management_detail_step.dart';
import '../widgets/steps/management_police_step.dart';
import '../widgets/steps/management_summary_step.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  int _currentStep = 0;

  // The management type — in production comes from task data
  // Options: 'Prueba de Bloqueo / Desbloqueo', 'Pago servicio',
  //          'Trámite policial', 'Apoyo oficina', 'Apoyo taller'
  final String _managementType = 'Prueba de Bloqueo / Desbloqueo';

  // === Bloqueo/Desbloqueo state ===
  String? _verificationResult;
  final TextEditingController _observationsController = TextEditingController();

  // === Pago servicio state ===
  String? _fineType;
  String? _municipality;
  String? _ticketMunicipality;
  String? _selectedMunicipality;
  // Pago servicio has a 2nd detail screen when certain options are picked
  // Step 2 = first payment screen, Step 2b (encoded as _pagoSubStep) = extended

  // === Trámite policial state ===
  final TextEditingController _comisariaController = TextEditingController();
  final TextEditingController _expedienteController = TextEditingController();
  final TextEditingController _policeMotiveController = TextEditingController();
  bool _constanciaUploaded = false;
  String? _constanciaTag;

  // === Apoyo oficina/taller state ===
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  // Steps layout:
  // 0 = Task info
  // 1 = Before starting (interstitial)
  // 2 = Type-specific step
  // 3 = Summary
  // 4 = Success

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
      // Skip interstitial going back
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
    _comisariaController.dispose();
    _expedienteController.dispose();
    _policeMotiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        return ManagementTaskInfoStep(
          managementType: _managementType,
          onContinue: _nextStep,
        );
      case 1:
        return ManagementBeforeStartingStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return _buildTypeSpecificStep();
      case 3:
        return ManagementSummaryStep(
          managementType: _managementType,
          verificationResult: _verificationResult,
          fineType: _fineType,
          municipality: _municipality,
          selectedMunicipality: _selectedMunicipality,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          motivo: _motivoController.text,
          comisaria: _comisariaController.text,
          expediente: _expedienteController.text,
          policeMotivo: _policeMotiveController.text,
          constanciaUploaded: _constanciaUploaded,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditDetail: () => setState(() => _currentStep = 2),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 4:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return ManagementTaskInfoStep(
          managementType: _managementType,
          onContinue: _nextStep,
        );
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
          ticketMunicipality: _ticketMunicipality,
          selectedMunicipality: _selectedMunicipality,
          onFineTypeChanged: (val) => setState(() => _fineType = val),
          onMunicipalityChanged: (val) => setState(() => _municipality = val),
          onTicketMunicipalityChanged: (val) => setState(() => _ticketMunicipality = val),
          onSelectedMunicipalityChanged: (val) => setState(() => _selectedMunicipality = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 'Trámite policial':
        return ManagementPoliceStep(
          comisariaController: _comisariaController,
          expedienteController: _expedienteController,
          motivoController: _policeMotiveController,
          constanciaUploaded: _constanciaUploaded,
          constanciaTag: _constanciaTag,
          onConstanciaUploadedChanged: (val) => setState(() => _constanciaUploaded = val),
          onConstanciaTagChanged: (val) => setState(() => _constanciaTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
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
          onConfirm: () {
            Navigator.pop(context);
            setState(() => _currentStep = 4);
          },
        );
      },
    );
  }
}
