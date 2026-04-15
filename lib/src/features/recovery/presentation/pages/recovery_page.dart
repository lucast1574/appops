import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

import '../widgets/steps/recovery_task_info_step.dart';
import '../../../management/presentation/widgets/steps/management_before_starting_step.dart';
import '../widgets/steps/recovery_who_delivered_step.dart';
import '../widgets/steps/recovery_vehicle_state_step.dart';
import '../widgets/steps/recovery_docs_step.dart';
import '../widgets/steps/recovery_summary_step.dart';

class RecoveryPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const RecoveryPage({super.key, required this.task});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  int _currentStep = 0;

  // Step 2 — who delivered
  String? _selectedPerson;

  // Step 3 — vehicle state
  bool _frontalUploaded = false; String? _frontalTag;
  bool _traseraUploaded = false; String? _traseraTag;
  bool _lateralIzqUploaded = false; String? _lateralIzqTag;
  bool _lateralDerUploaded = false; String? _lateralDerTag;
  bool _kmUploaded = false; String? _kmTag;
  String? _selectedFuelLevel;
  bool? _hasVisibleDamage;
  final TextEditingController _damageDescController = TextEditingController();

  // Step 4 — docs
  bool _tarjetaUploaded = false; String? _tarjetaTag;
  bool _soatUploaded = false; String? _soatTag;
  bool _revisionUploaded = false; String? _revisionTag;
  bool _actaUploaded = false; String? _actaTag;
  bool? _llaveOriginal; bool? _llaveRepuesto; bool? _gata;
  bool? _llantaRepuesto; bool? _extintor; bool? _triangulo; bool? _manualConductor;

  // 0=info, 1=interstitial, 2=who, 3=vehicle, 4=docs, 5=summary, 6=success
  int _getProgressIndex() {
    switch (_currentStep) {
      case 0: case 1: return 0;
      case 2: return 1;
      case 3: return 2;
      case 4: return 3;
      case 5: return 4;
      default: return 4;
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
  void dispose() { _damageDescController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep != 1 && _currentStep != 6;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar ? AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
        title: Text('Recupero', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [IconButton(icon: SvgPicture.asset('assets/warning.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)), onPressed: () {})],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(10), child: FlowProgressBar(totalSteps: 5, activeIndex: _getProgressIndex(), allComplete: _currentStep == 5)),
      ) : null,
      body: SafeArea(child: _buildCurrentStep()),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return RecoveryTaskInfoStep(onContinue: _nextStep);
      case 1: return ManagementBeforeStartingStep(onContinue: _nextStep, onBack: _previousStep);
      case 2: return RecoveryWhoDeliveredStep(selectedPerson: _selectedPerson, onPersonSelected: (v) => setState(() => _selectedPerson = v), onBack: _previousStep, onContinue: _nextStep);
      case 3: return RecoveryVehicleStateStep(
        frontalPhotoUploaded: _frontalUploaded, frontalPhotoTag: _frontalTag,
        traseraPhotoUploaded: _traseraUploaded, traseraPhotoTag: _traseraTag,
        lateralIzqPhotoUploaded: _lateralIzqUploaded, lateralIzqPhotoTag: _lateralIzqTag,
        lateralDerPhotoUploaded: _lateralDerUploaded, lateralDerPhotoTag: _lateralDerTag,
        kmPhotoUploaded: _kmUploaded, kmPhotoTag: _kmTag,
        selectedFuelLevel: _selectedFuelLevel, hasVisibleDamage: _hasVisibleDamage,
        damageDescController: _damageDescController,
        onFrontalUploadedChanged: (v) => setState(() => _frontalUploaded = v), onFrontalTagChanged: (v) => setState(() => _frontalTag = v),
        onTraseraUploadedChanged: (v) => setState(() => _traseraUploaded = v), onTraseraTagChanged: (v) => setState(() => _traseraTag = v),
        onLateralIzqUploadedChanged: (v) => setState(() => _lateralIzqUploaded = v), onLateralIzqTagChanged: (v) => setState(() => _lateralIzqTag = v),
        onLateralDerUploadedChanged: (v) => setState(() => _lateralDerUploaded = v), onLateralDerTagChanged: (v) => setState(() => _lateralDerTag = v),
        onKmUploadedChanged: (v) => setState(() => _kmUploaded = v), onKmTagChanged: (v) => setState(() => _kmTag = v),
        onFuelLevelChanged: (v) => setState(() => _selectedFuelLevel = v),
        onHasVisibleDamageChanged: (v) => setState(() => _hasVisibleDamage = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 4: return RecoveryDocsStep(
        tarjetaPropiedadUploaded: _tarjetaUploaded, tarjetaPropiedadTag: _tarjetaTag,
        soatUploaded: _soatUploaded, soatTag: _soatTag,
        revisionTecnicaUploaded: _revisionUploaded, revisionTecnicaTag: _revisionTag,
        actaRecuperoUploaded: _actaUploaded, actaRecuperoTag: _actaTag,
        tieneLlaveOriginal: _llaveOriginal, tieneLlaveRepuesto: _llaveRepuesto,
        tieneGata: _gata, tieneLlantaRepuesto: _llantaRepuesto,
        tieneExtintor: _extintor, tieneTriangulo: _triangulo, tieneManualConductor: _manualConductor,
        onTarjetaUploadedChanged: (v) => setState(() => _tarjetaUploaded = v), onTarjetaTagChanged: (v) => setState(() => _tarjetaTag = v),
        onSoatUploadedChanged: (v) => setState(() => _soatUploaded = v), onSoatTagChanged: (v) => setState(() => _soatTag = v),
        onRevisionUploadedChanged: (v) => setState(() => _revisionUploaded = v), onRevisionTagChanged: (v) => setState(() => _revisionTag = v),
        onActaUploadedChanged: (v) => setState(() => _actaUploaded = v), onActaTagChanged: (v) => setState(() => _actaTag = v),
        onLlaveOriginalChanged: (v) => setState(() => _llaveOriginal = v), onLlaveRepuestoChanged: (v) => setState(() => _llaveRepuesto = v),
        onGataChanged: (v) => setState(() => _gata = v), onLlantaRepuestoChanged: (v) => setState(() => _llantaRepuesto = v),
        onExtintorChanged: (v) => setState(() => _extintor = v), onTrianguloChanged: (v) => setState(() => _triangulo = v),
        onManualConductorChanged: (v) => setState(() => _manualConductor = v),
        onBack: _previousStep, onContinue: _nextStep,
      );
      case 5: return RecoverySummaryStep(
        selectedPerson: _selectedPerson,
        frontalUploaded: _frontalUploaded, traseraUploaded: _traseraUploaded,
        lateralIzqUploaded: _lateralIzqUploaded, lateralDerUploaded: _lateralDerUploaded,
        kmUploaded: _kmUploaded, fuelLevel: _selectedFuelLevel, hasVisibleDamage: _hasVisibleDamage,
        tarjetaUploaded: _tarjetaUploaded, soatUploaded: _soatUploaded,
        revisionUploaded: _revisionUploaded, actaUploaded: _actaUploaded,
        llaveOriginal: _llaveOriginal, llaveRepuesto: _llaveRepuesto, gata: _gata,
        llantaRepuesto: _llantaRepuesto, extintor: _extintor, triangulo: _triangulo, manualConductor: _manualConductor,
        onEditTaskInfo: () => setState(() => _currentStep = 0), onEditWho: () => setState(() => _currentStep = 2),
        onEditVehicle: () => setState(() => _currentStep = 3), onEditDocs: () => setState(() => _currentStep = 4),
        onEditAll: () => setState(() => _currentStep = 0),
        onSend: () => _showConfirmation(context),
      );
      case 6: return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default: return RecoveryTaskInfoStep(onContinue: _nextStep);
    }
  }

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => FlowConfirmationSheet(onCancel: () => Navigator.pop(context), onConfirm: () { Navigator.pop(context); setState(() => _currentStep = 6); }),
    );
  }
}
