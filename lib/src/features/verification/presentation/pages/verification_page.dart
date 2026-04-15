import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Shared Widgets
import '../widgets/shared/verification_progress_bar.dart';
import '../widgets/shared/confirmation_sheet.dart';

// Import Step Widgets
import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../widgets/steps/before_starting_step.dart';
import '../widgets/steps/who_received_step.dart';
import '../widgets/steps/document_validation_step.dart';
import '../widgets/steps/familiar_form_step.dart';
import '../widgets/steps/reschedule_result_step.dart';
import '../widgets/steps/housing_step.dart';
import '../widgets/steps/garage_step.dart';
import '../widgets/steps/verification_result_step.dart';
import '../widgets/steps/verification_summary_step.dart';
import '../widgets/steps/success_step.dart';

class VerificationPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const VerificationPage({super.key, required this.task});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  String? _selectedRecipient;
  String? _selectedRelationship;

  // States for Document Validation (Step 3)
  bool _dniUploaded = true;
  String? _dniTag = 'Frontal documento';
  bool _breveteUploaded = false;
  String? _breveteTag;
  bool _reciboUploaded = false;
  String? _reciboTag;

  final List<Offset?> _signaturePoints = [];

  // States for Housing (Step 6)
  String? _housingType;
  final TextEditingController _mapsController = TextEditingController();

  // States for Garage (Step 7)
  bool? _isGarageAtHome;
  bool _garageFacadeUploaded = false;
  String? _garageFacadeTag;
  bool? _hasSecurity;
  bool? _hasCameras;
  bool _garageCamerasUploaded = false;
  String? _garageCamerasTag;
  String? _accessType;
  bool? _isRoofing;
  bool _garageRoofingUploaded = false;
  String? _garageRoofingTag;
  bool? _isBasement;
  bool _garageBasementUploaded = false;
  String? _garageBasementTag;
  String? _garageDirection;
  bool _garageDirectionUploaded = false;
  String? _garageDirectionTag;
  String? _streetAccessibility;
  bool _streetAccessibilityUploaded = false;
  String? _streetAccessibilityTag;
  
  // Extra garage images (for when it's not at home)
  int _extraGarageImagesCount = 1; // 1 to 3
  bool _isCocheraFuera = false;
  final List<bool> _extraGarageImagesUploaded = [false, false, false];
  final List<String?> _extraGarageImagesTags = [null, null, null];

  // States for Result (Step 8)
  String? _verificationResult;
  final TextEditingController _observationsController = TextEditingController();

  void _nextStep() {
    setState(() {
      if (_currentStep == 2 && _selectedRecipient == 'Cliente') {
        _currentStep = 3;
      } else if (_currentStep == 2 && _selectedRecipient == 'Familiar') {
        _currentStep = 4;
      } else if (_currentStep == 2 && _selectedRecipient == 'Nadie') {
        _currentStep = 5;
      } else {
        _currentStep++;
      }
    });
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 0;
      });
    } else if (_currentStep == 3 || _currentStep == 4 || _currentStep == 5) {
      setState(() {
        _currentStep = 2;
      });
    } else if (_currentStep == 9) {
      setState(() {
        _currentStep = 8;
      });
    } else if (_currentStep == 8) {
      setState(() {
        _currentStep = 7;
      });
    } else if (_currentStep == 7) {
      setState(() {
        _currentStep = 6;
      });
    } else if (_currentStep == 6) {
      setState(() {
        _currentStep = 3; // From housing back to validation
      });
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showAppBar =
        _currentStep == 0 ||
        _currentStep == 2 ||
        _currentStep == 3 ||
        _currentStep == 4 ||
        _currentStep == 5 ||
        _currentStep == 6 ||
        _currentStep == 7 ||
        _currentStep == 8 ||
        _currentStep == 9;

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
                'Verificación',
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
                child: VerificationProgressBar(currentStep: _currentStep),
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
        return BeforeStartingStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return WhoReceivedStep(
          selectedRecipient: _selectedRecipient,
          onRecipientSelected: (val) =>
              setState(() => _selectedRecipient = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return DocumentValidationStep(
          dniUploaded: _dniUploaded,
          dniTag: _dniTag,
          breveteUploaded: _breveteUploaded,
          breveteTag: _breveteTag,
          reciboUploaded: _reciboUploaded,
          reciboTag: _reciboTag,
          onDniUploadedChanged: (val) => setState(() => _dniUploaded = val),
          onDniTagChanged: (val) => setState(() => _dniTag = val),
          onBreveteUploadedChanged: (val) =>
              setState(() => _breveteUploaded = val),
          onBreveteTagChanged: (val) => setState(() => _breveteTag = val),
          onReciboUploadedChanged: (val) =>
              setState(() => _reciboUploaded = val),
          onReciboTagChanged: (val) => setState(() => _reciboTag = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 6),
        );
      case 4:
        return FamiliarFormStep(
          selectedRelationship: _selectedRelationship,
          signaturePoints: _signaturePoints,
          onRelationshipChanged: (val) =>
              setState(() => _selectedRelationship = val),
          onSignaturePointAdded: (point) =>
              setState(() => _signaturePoints.add(point)),
          onClearSignature: () => setState(() => _signaturePoints.clear()),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 5),
        );
      case 5:
        return RescheduleResultStep(
          onBack: _previousStep,
          onContinue: () => Navigator.pop(context),
        );
      case 6:
        return HousingStep(
          housingType: _housingType,
          mapsController: _mapsController,
          onHousingTypeChanged: (val) => setState(() => _housingType = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 7),
        );
      case 7:
        return GarageStep(
          isGarageAtHome: _isGarageAtHome,
          garageFacadeUploaded: _garageFacadeUploaded,
          garageFacadeTag: _garageFacadeTag,
          hasSecurity: _hasSecurity,
          hasCameras: _hasCameras,
          garageCamerasUploaded: _garageCamerasUploaded,
          garageCamerasTag: _garageCamerasTag,
          accessType: _accessType,
          isRoofing: _isRoofing,
          garageRoofingUploaded: _garageRoofingUploaded,
          garageRoofingTag: _garageRoofingTag,
          isBasement: _isBasement,
          garageBasementUploaded: _garageBasementUploaded,
          garageBasementTag: _garageBasementTag,
          garageDirection: _garageDirection,
          garageDirectionUploaded: _garageDirectionUploaded,
          garageDirectionTag: _garageDirectionTag,
          streetAccessibility: _streetAccessibility,
          streetAccessibilityUploaded: _streetAccessibilityUploaded,
          streetAccessibilityTag: _streetAccessibilityTag,
          extraImagesCount: _extraGarageImagesCount,
          isCocheraFuera: _isCocheraFuera,
          extraImagesUploaded: _extraGarageImagesUploaded,
          extraImagesTags: _extraGarageImagesTags,
          onGarageAtHomeChanged: (val) {
            setState(() {
              _isGarageAtHome = val;
              if (val == true) _isCocheraFuera = false;
              if (val == false) _isCocheraFuera = true;
            });
          },
          onCocheraFueraChanged: (val) => setState(() => _isCocheraFuera = val ?? false),
          onFacadeUploadedChanged: (val) => setState(() => _garageFacadeUploaded = val),
          onFacadeTagChanged: (val) => setState(() => _garageFacadeTag = val),
          onSecurityChanged: (val) => setState(() => _hasSecurity = val),
          onCamerasChanged: (val) => setState(() => _hasCameras = val),
          onCamerasUploadedChanged: (val) => setState(() => _garageCamerasUploaded = val),
          onCamerasTagChanged: (val) => setState(() => _garageCamerasTag = val),
          onAccessTypeChanged: (val) => setState(() => _accessType = val),
          onRoofingChanged: (val) => setState(() => _isRoofing = val),
          onRoofingUploadedChanged: (val) => setState(() => _garageRoofingUploaded = val),
          onRoofingTagChanged: (val) => setState(() => _garageRoofingTag = val),
          onBasementChanged: (val) => setState(() => _isBasement = val),
          onBasementUploadedChanged: (val) => setState(() => _garageBasementUploaded = val),
          onBasementTagChanged: (val) => setState(() => _garageBasementTag = val),
          onGarageDirectionChanged: (val) => setState(() => _garageDirection = val),
          onDirectionUploadedChanged: (val) => setState(() => _garageDirectionUploaded = val),
          onDirectionTagChanged: (val) => setState(() => _garageDirectionTag = val),
          onStreetAccessibilityChanged: (val) => setState(() => _streetAccessibility = val),
          onAccessibilityUploadedChanged: (val) => setState(() => _streetAccessibilityUploaded = val),
          onAccessibilityTagChanged: (val) => setState(() => _streetAccessibilityTag = val),
          onAddExtraImage: () {
            if (_extraGarageImagesCount < 3) {
              setState(() => _extraGarageImagesCount++);
            }
          },
          onExtraImageUploadedChanged: (index, val) {
            setState(() {
              _extraGarageImagesUploaded[index] = val;
            });
          },
          onExtraImageTagChanged: (index, val) {
            setState(() {
              _extraGarageImagesTags[index] = val;
            });
          },
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 8),
        );
      case 8:
        return VerificationResultStep(
          verificationResult: _verificationResult,
          observationsController: _observationsController,
          onResultChanged: (val) => setState(() => _verificationResult = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 9),
        );
      case 9:
        return VerificationSummaryStep(
          selectedRecipient: _selectedRecipient,
          selectedRelationship: _selectedRelationship,
          dniUploaded: _dniUploaded,
          reciboUploaded: _reciboUploaded,
          breveteUploaded: _breveteUploaded,
          housingType: _housingType,
          isGarageAtHome: _isGarageAtHome,
          hasCameras: _hasCameras,
          accessType: _accessType,
          isRoofing: _isRoofing,
          isBasement: _isBasement,
          garageDirection: _garageDirection,
          streetAccessibility: _streetAccessibility,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditRecipient: () => setState(() => _currentStep = 2),
          onEditDocuments: () => setState(() => _currentStep = 3),
          onEditHousing: () => setState(() => _currentStep = 6),
          onEditGarage: () => setState(() => _currentStep = 7),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 10:
        return SuccessStep(onBackToStart: () => Navigator.pop(context));
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
          'who_received': _selectedRecipient,
          'relationship': _selectedRelationship,
          'documents': {
            'dni_uploaded': _dniUploaded,
            'brevete_uploaded': _breveteUploaded,
            'recibo_uploaded': _reciboUploaded,
          },
          'housing_type': _housingType,
          'garage': {
            'is_at_home': _isGarageAtHome,
            'has_security': _hasSecurity,
            'has_cameras': _hasCameras,
            'access_type': _accessType,
            'is_roofing': _isRoofing,
            'is_basement': _isBasement,
            'garage_direction': _garageDirection,
            'street_accessibility': _streetAccessibility,
          },
          'verification_result': _verificationResult,
        },
        observations: _observationsController.text,
      );
      if (mounted) setState(() => _currentStep = 10);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: \$e'), backgroundColor: Colors.red),
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
        return ConfirmationSheet(
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
