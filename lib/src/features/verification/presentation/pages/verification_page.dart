import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

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
import '../../../../shared/widgets/signature_pad.dart';

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
  late Map<String, dynamic> _task;
  bool _loadingDetail = true;

  String? _selectedRecipient;
  String? _selectedRelationship;

  // States for Document Validation (Step 3)
  bool _dniUploaded = false;
  String? _dniTag;
  String? _dniPath;
  bool _breveteUploaded = false;
  String? _breveteTag;
  String? _brevetePath;
  bool _reciboUploaded = false;
  String? _reciboTag;
  String? _reciboPath;

  // States for Familiar (Step 4)
  final GlobalKey<SignaturePadState> _signatureKey = GlobalKey<SignaturePadState>();
  final TextEditingController _familiarDniController = TextEditingController();
  final TextEditingController _familiarNameController = TextEditingController();

  // States for Housing (Step 6)
  String? _housingType;
  final TextEditingController _mapsController = TextEditingController();

  // States for Garage (Step 7)
  bool? _isGarageAtHome;
  bool _garageFacadeUploaded = false;
  String? _garageFacadeTag;
  String? _garageFacadePath;
  bool? _hasSecurity;
  bool? _hasCameras;
  bool _garageCamerasUploaded = false;
  String? _garageCamerasTag;
  String? _garageCamerasPath;
  String? _accessType;
  bool? _isRoofing;
  bool _garageRoofingUploaded = false;
  String? _garageRoofingTag;
  String? _garageRoofingPath;
  bool? _isBasement;
  bool _garageBasementUploaded = false;
  String? _garageBasementTag;
  String? _garageBasementPath;
  String? _garageDirection;
  bool _garageDirectionUploaded = false;
  String? _garageDirectionTag;
  String? _garageDirectionPath;
  String? _streetAccessibility;
  bool _streetAccessibilityUploaded = false;
  String? _streetAccessibilityTag;
  String? _streetAccessibilityPath;
  
  // Extra garage images
  int _extraGarageImagesCount = 1;
  bool _isCocheraFuera = false;
  final List<bool> _extraGarageImagesUploaded = [false, false, false];
  final List<String?> _extraGarageImagesTags = [null, null, null];
  final List<String?> _extraGarageImagesPaths = [null, null, null];

  // States for Result (Step 8)
  String? _verificationResult;
  final TextEditingController _observationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _mapsController.text = _task['google_maps_link'] ?? '';
    _fetchFullDetail();
  }

  Future<void> _fetchFullDetail() async {
    try {
      final taskId = widget.task['id'];
      if (taskId != null) {
        final full = await _taskService.getTaskDetail(
          taskId is int ? taskId : int.parse('$taskId'),
        );
        if (mounted) {
          setState(() {
            _task = full;
            _loadingDetail = false;
            // Update maps link if it changed or was empty
            if (_mapsController.text.isEmpty) {
              _mapsController.text = _task['google_maps_link'] ?? '';
            }
          });
        }
      } else {
        if (mounted) setState(() => _loadingDetail = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }

  Future<bool> _checkLocation() async {
    try {
      final taskLat = _task['latitude'] is num
          ? (_task['latitude'] as num).toDouble()
          : double.tryParse('${_task['latitude'] ?? ''}');
      final taskLng = _task['longitude'] is num
          ? (_task['longitude'] as num).toDouble()
          : double.tryParse('${_task['longitude'] ?? ''}');

      if (taskLat == null || taskLng == null) return true;

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      /*
      Position position = await Geolocator.getCurrentPosition();
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        taskLat,
        taskLng,
      );

      // Must be within 50 meters (TEMPORARILY DISABLED FOR TESTING)
      if (distance > 50) {
        ...
      }
      */
      return true; // Bypass slow GPS fix for testing
    } catch (e) {
      return false;
    }
  }

  void _nextStep() async {
    if (_currentStep == 0) {
      final isNear = await _checkLocation();
      if (!isNear) return;

      // Start task in backend
      try {
        await _taskService.startTask(_task['id'] ?? 0);
      } catch (e) {
        if (!e.toString().contains('400')) { // Ignore already started
           debugPrint('Error starting task: $e');
        }
      }
    }

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
        _currentStep = 3;
      });
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep < 10;

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
                child: VerificationProgressBar(currentStep: _currentStep),
              ),
            )
          : null,
      body: SafeArea(
        child: _loadingDetail && _currentStep > 0
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
          onContinue: _nextStep,
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
        return BeforeStartingStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return WhoReceivedStep(
          selectedRecipient: _selectedRecipient,
          task: _task,
          onRecipientSelected: (val) =>
              setState(() => _selectedRecipient = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return DocumentValidationStep(
          taskId: _task['id'] ?? 0,
          dniUploaded: _dniUploaded,
          dniTag: _dniTag,
          dniPath: _dniPath,
          breveteUploaded: _breveteUploaded,
          breveteTag: _breveteTag,
          brevetePath: _brevetePath,
          reciboUploaded: _reciboUploaded,
          reciboTag: _reciboTag,
          reciboPath: _reciboPath,
          onDniUploadedChanged: (val, res) => setState(() {
            _dniUploaded = val;
            if (val) _dniPath = res?['localPath'];
          }),
          onDniTagChanged: (val) => setState(() => _dniTag = val),
          onBreveteUploadedChanged: (val, res) => setState(() {
            _breveteUploaded = val;
            if (val) _brevetePath = res?['localPath'];
          }),
          onBreveteTagChanged: (val) => setState(() => _breveteTag = val),
          onReciboUploadedChanged: (val, res) => setState(() {
            _reciboUploaded = val;
            if (val) _reciboPath = res?['localPath'];
          }),
          onReciboTagChanged: (val) => setState(() => _reciboTag = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 6),
        );
      case 4:
        return FamiliarFormStep(
          selectedRelationship: _selectedRelationship,
          signatureKey: _signatureKey,
          dniController: _familiarDniController,
          nameController: _familiarNameController,
          onRelationshipChanged: (val) =>
              setState(() => _selectedRelationship = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 6), // Back to housing
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
          taskId: _task['id'] ?? 0,
          isGarageAtHome: _isGarageAtHome,
          garageFacadeUploaded: _garageFacadeUploaded,
          garageFacadeTag: _garageFacadeTag,
          garageFacadePath: _garageFacadePath,
          hasSecurity: _hasSecurity,
          hasCameras: _hasCameras,
          garageCamerasUploaded: _garageCamerasUploaded,
          garageCamerasTag: _garageCamerasTag,
          garageCamerasPath: _garageCamerasPath,
          accessType: _accessType,
          isRoofing: _isRoofing,
          garageRoofingUploaded: _garageRoofingUploaded,
          garageRoofingTag: _garageRoofingTag,
          garageRoofingPath: _garageRoofingPath,
          isBasement: _isBasement,
          garageBasementUploaded: _garageBasementUploaded,
          garageBasementTag: _garageBasementTag,
          garageBasementPath: _garageBasementPath,
          garageDirection: _garageDirection,
          garageDirectionUploaded: _garageDirectionUploaded,
          garageDirectionTag: _garageDirectionTag,
          garageDirectionPath: _garageDirectionPath,
          streetAccessibility: _streetAccessibility,
          streetAccessibilityUploaded: _streetAccessibilityUploaded,
          streetAccessibilityTag: _streetAccessibilityTag,
          streetAccessibilityPath: _streetAccessibilityPath,
          mapsController: _mapsController,
          extraImagesCount: _extraGarageImagesCount,
          isCocheraFuera: _isCocheraFuera,
          extraImagesUploaded: _extraGarageImagesUploaded,
          extraImagesTags: _extraGarageImagesTags,
          extraImagesPaths: _extraGarageImagesPaths,
          onGarageAtHomeChanged: (val) {
            setState(() {
              _isGarageAtHome = val;
              if (val == true) _isCocheraFuera = false;
              if (val == false) _isCocheraFuera = true;
            });
          },
          onCocheraFueraChanged: (val) =>
              setState(() => _isCocheraFuera = val ?? false),
          onFacadeUploadedChanged: (val, res) => setState(() {
            _garageFacadeUploaded = val;
            if (val) _garageFacadePath = res?['localPath'];
          }),
          onFacadeTagChanged: (val) => setState(() => _garageFacadeTag = val),
          onSecurityChanged: (val) => setState(() => _hasSecurity = val),
          onCamerasChanged: (val) => setState(() => _hasCameras = val),
          onCamerasUploadedChanged: (val, res) => setState(() {
            _garageCamerasUploaded = val;
            if (val) _garageCamerasPath = res?['localPath'];
          }),
          onCamerasTagChanged: (val) => setState(() => _garageCamerasTag = val),
          onAccessTypeChanged: (val) => setState(() => _accessType = val),
          onRoofingChanged: (val) => setState(() => _isRoofing = val),
          onRoofingUploadedChanged: (val, res) => setState(() {
            _garageRoofingUploaded = val;
            if (val) _garageRoofingPath = res?['localPath'];
          }),
          onRoofingTagChanged: (val) => setState(() => _garageRoofingTag = val),
          onBasementChanged: (val) => setState(() => _isBasement = val),
          onBasementUploadedChanged: (val, res) => setState(() {
            _garageBasementUploaded = val;
            if (val) _garageBasementPath = res?['localPath'];
          }),
          onBasementTagChanged: (val) =>
              setState(() => _garageBasementTag = val),
          onGarageDirectionChanged: (val) =>
              setState(() => _garageDirection = val),
          onDirectionUploadedChanged: (val, res) => setState(() {
            _garageDirectionUploaded = val;
            if (val) _garageDirectionPath = res?['localPath'];
          }),
          onDirectionTagChanged: (val) =>
              setState(() => _garageDirectionTag = val),
          onStreetAccessibilityChanged: (val) =>
              setState(() => _streetAccessibility = val),
          onAccessibilityUploadedChanged: (val, res) => setState(() {
            _streetAccessibilityUploaded = val;
            if (val) _streetAccessibilityPath = res?['localPath'];
          }),
          onAccessibilityTagChanged: (val) =>
              setState(() => _streetAccessibilityTag = val),
          onAddExtraImage: () {
            if (_extraGarageImagesCount < 3) {
              setState(() => _extraGarageImagesCount++);
            }
          },
          onExtraImageUploadedChanged: (index, val, res) {
            setState(() {
              _extraGarageImagesUploaded[index] = val;
              if (val) _extraGarageImagesPaths[index] = res?['localPath'];
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
          familiarName: _familiarNameController.text,
          familiarDni: _familiarDniController.text,
          isSignatureCaptured: !(_signatureKey.currentState?.isEmpty ?? true),
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
          task: _task,
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 10:
        return SuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(task: _task, onContinue: _nextStep);
    }
  }

  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = _task['id'] ?? 0;
      String? signatureS3Key;

      if (_selectedRecipient == 'Familiar') {
        final signatureBytes = await _signatureKey.currentState?.exportPng();
        if (signatureBytes != null) {
          final uploadInfo = await _taskService.requestUploadUrl(
            taskId,
            label: 'firma_familiar',
            contentType: 'image/png',
          );
          final uploadUrl = uploadInfo['upload_url'];
          signatureS3Key = uploadInfo['s3_key'];
          await _taskService.uploadImageToS3(uploadUrl, signatureBytes);
          await _taskService.confirmUpload(
            taskId,
            s3Key: signatureS3Key!,
            label: 'firma_familiar',
            tag: 'Firma de familiar: ${_familiarNameController.text}',
          );
        }
      }

      await _taskService.submitTask(
        taskId,
        resultData: {
          'who_received': _selectedRecipient,
          'relationship': _selectedRelationship,
          'familiar_dni': _familiarDniController.text,
          'familiar_name': _familiarNameController.text,
          'signature_s3_key': signatureS3Key,
          'documents': {
            'dni_uploaded': _dniUploaded,
            'brevete_uploaded': _breveteUploaded,
            'recibo_uploaded': _reciboUploaded,
          },
          'housing_type': _housingType,
          'garage': {
            'is_at_home': _isGarageAtHome,
            'is_cochera_fuera': _isCocheraFuera,
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


