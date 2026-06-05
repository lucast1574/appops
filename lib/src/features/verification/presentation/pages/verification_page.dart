import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

// Import Shared Widgets
import '../widgets/shared/verification_progress_bar.dart';
import '../widgets/shared/confirmation_sheet.dart';
import '../../../../shared/widgets/task_chat_action_button.dart';

// Import Step Widgets
import '../../../../shared/widgets/task_info_widget.dart';
import '../../../home/data/task_service.dart';
import '../../../auth/data/auth_service.dart';
import '../widgets/steps/before_starting_step.dart';
import '../widgets/steps/who_received_step.dart';
import '../widgets/steps/dni_validation_step.dart';
import '../widgets/steps/brevete_validation_step.dart';
import '../widgets/steps/recibo_validation_step.dart';
import '../widgets/steps/familiar_form_step.dart';
import '../widgets/steps/housing_step.dart';
import '../widgets/steps/garage_step.dart';
import '../widgets/steps/verification_result_step.dart';
import '../widgets/steps/verification_summary_step.dart';
import '../widgets/steps/success_step.dart';
import '../../../../shared/widgets/signature_pad.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../shared/widgets/flow_reschedule_form_step.dart';

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
  bool _startingTask = false;
  late Map<String, dynamic> _task;
  bool _loadingDetail = true;
  bool _isAutoReschedule = false;
  bool _isEcuador = false;
  final Map<String, int> _photoIds = {};

  String? _selectedRecipient;
  String? _selectedRelationship;

  // States for Document Validation (Step 3)
  bool _dniFrontUploaded = false;
  String? _dniFrontTag;
  String? _dniFrontPath;
  bool _dniBackUploaded = false;
  String? _dniBackTag;
  String? _dniBackPath;

  bool _breveteFrontUploaded = false;
  String? _breveteFrontTag;
  String? _breveteFrontPath;
  bool _breveteBackUploaded = false;
  String? _breveteBackTag;
  String? _breveteBackPath;

  bool _reciboFrontUploaded = false;
  String? _reciboFrontTag;
  String? _reciboFrontPath;
  bool _reciboBackUploaded = false;
  String? _reciboBackTag;
  String? _reciboBackPath;

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
  String? _selectedReason;
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
          // Determine Ecuador context from stored user data
          final user = await AuthService().getCurrentUser();
          final countryCode = user?['country']?['code'] as String?;
          setState(() {
            _task = full;
            _isEcuador = countryCode == 'EC';
            _loadingDetail = false;
            // Update maps link if it changed or was empty
            if (_mapsController.text.isEmpty) {
              _mapsController.text = _task['google_maps_link'] ?? '';
            }

            // Restore photos and photo IDs from backend
            _photoIds.clear();
            if (full['photos'] != null) {
              for (var photo in full['photos']) {
                if (photo is Map && photo['label'] != null) {
                  final String label = photo['label'];
                  final int? id = photo['id'] is int ? photo['id'] : int.tryParse('${photo['id']}');
                  final String? tag = photo['tag'];
                  final String? url = photo['download_url'];
                  if (id != null) {
                    _photoIds[label] = id;
                  }
                  
                  // Map to the state variables
                  if (label == 'dni_cliente') {
                    _dniFrontUploaded = true;
                    _dniFrontTag = tag;
                    _dniFrontPath = url;
                  } else if (label == 'dni_cliente_reverso') {
                    _dniBackUploaded = true;
                    _dniBackTag = tag;
                    _dniBackPath = url;
                  } else if (label == 'brevete_cliente') {
                    _breveteFrontUploaded = true;
                    _breveteFrontTag = tag;
                    _breveteFrontPath = url;
                  } else if (label == 'brevete_cliente_reverso') {
                    _breveteBackUploaded = true;
                    _breveteBackTag = tag;
                    _breveteBackPath = url;
                  } else if (label == 'recibo_servicios') {
                    _reciboFrontUploaded = true;
                    _reciboFrontTag = tag;
                    _reciboFrontPath = url;
                  } else if (label == 'recibo_servicios_reverso') {
                    _reciboBackUploaded = true;
                    _reciboBackTag = tag;
                    _reciboBackPath = url;
                  } else if (label == 'fachada_vivienda') {
                    _garageFacadeUploaded = true;
                    _garageFacadeTag = tag;
                    _garageFacadePath = url;
                  } else if (label == 'camara_vigilancia') {
                    _garageCamerasUploaded = true;
                    _garageCamerasTag = tag;
                    _garageCamerasPath = url;
                  } else if (label == 'cochera_techada' || label == 'cochera_general') {
                    _garageRoofingUploaded = true;
                    _garageRoofingTag = tag;
                    _garageRoofingPath = url;
                  } else if (label == 'cochera_sotano') {
                    _garageBasementUploaded = true;
                    _garageBasementTag = tag;
                    _garageBasementPath = url;
                  } else if (label == 'cochera_direccion') {
                    _garageDirectionUploaded = true;
                    _garageDirectionTag = tag;
                    _garageDirectionPath = url;
                  } else if (label == 'accesibilidad_calle') {
                    _streetAccessibilityUploaded = true;
                    _streetAccessibilityTag = tag;
                    _streetAccessibilityPath = url;
                  } else if (label.startsWith('fachada_calle_extra_')) {
                    final idxParts = label.split('_');
                    final idx = int.tryParse(idxParts.last);
                    if (idx != null && idx >= 1 && idx <= 3) {
                      _extraGarageImagesUploaded[idx - 1] = true;
                      _extraGarageImagesTags[idx - 1] = tag;
                      _extraGarageImagesPaths[idx - 1] = url;
                    }
                  }
                }
              }
            }

            // RESTORE PROGRESS
            if (full['current_step'] != null && full['current_step'] > 0) {
              _currentStep = full['current_step'];
            }
            final draft = full['draft_data'] as Map<String, dynamic>? ?? {};
            if (draft.isNotEmpty) {
              if (draft['selected_recipient'] != null) _selectedRecipient = draft['selected_recipient'];
              if (draft['selected_relationship'] != null) _selectedRelationship = draft['selected_relationship'];
              if (draft['familiar_name'] != null) _familiarNameController.text = draft['familiar_name'];
              if (draft['familiar_dni'] != null) _familiarDniController.text = draft['familiar_dni'];
              if (draft['housing_type'] != null) _housingType = draft['housing_type'];
              if (draft['is_garage_at_home'] != null) {
                _isGarageAtHome = draft['is_garage_at_home'];
                _isCocheraFuera = _isGarageAtHome == false;
              }
              if (draft['has_security'] != null) _hasSecurity = draft['has_security'];
              if (draft['has_cameras'] != null) _hasCameras = draft['has_cameras'];
              if (draft['access_type'] != null) _accessType = draft['access_type'];
              if (draft['is_roofing'] != null) _isRoofing = draft['is_roofing'];
              if (draft['is_basement'] != null) _isBasement = draft['is_basement'];
              if (draft['garage_direction'] != null) _garageDirection = draft['garage_direction'];
              if (draft['street_accessibility'] != null) _streetAccessibility = draft['street_accessibility'];
              if (draft['verification_result'] != null) _verificationResult = draft['verification_result'];
              if (draft['observations'] != null) _observationsController.text = draft['observations'];

              if (draft['dni_front_uploaded'] != null) _dniFrontUploaded = draft['dni_front_uploaded'];
              if (draft['dni_front_tag'] != null) _dniFrontTag = draft['dni_front_tag'];
              if (draft['dni_front_path'] != null) _dniFrontPath = draft['dni_front_path'];
              if (draft['dni_back_uploaded'] != null) _dniBackUploaded = draft['dni_back_uploaded'];
              if (draft['dni_back_tag'] != null) _dniBackTag = draft['dni_back_tag'];
              if (draft['dni_back_path'] != null) _dniBackPath = draft['dni_back_path'];

              if (draft['brevete_front_uploaded'] != null) _breveteFrontUploaded = draft['brevete_front_uploaded'];
              if (draft['brevete_front_tag'] != null) _breveteFrontTag = draft['brevete_front_tag'];
              if (draft['brevete_front_path'] != null) _breveteFrontPath = draft['brevete_front_path'];
              if (draft['brevete_back_uploaded'] != null) _breveteBackUploaded = draft['brevete_back_uploaded'];
              if (draft['brevete_back_tag'] != null) _breveteBackTag = draft['brevete_back_tag'];
              if (draft['brevete_back_path'] != null) _breveteBackPath = draft['brevete_back_path'];

              if (draft['recibo_front_uploaded'] != null) _reciboFrontUploaded = draft['recibo_front_uploaded'];
              if (draft['recibo_front_tag'] != null) _reciboFrontTag = draft['recibo_front_tag'];
              if (draft['recibo_front_path'] != null) _reciboFrontPath = draft['recibo_front_path'];
              if (draft['recibo_back_uploaded'] != null) _reciboBackUploaded = draft['recibo_back_uploaded'];
              if (draft['recibo_back_tag'] != null) _reciboBackTag = draft['recibo_back_tag'];
              if (draft['recibo_back_path'] != null) _reciboBackPath = draft['recibo_back_path'];
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
    if (_submitting || _startingTask) return;

    if (_currentStep == 0) {
      if (_startingTask) return;
      setState(() => _startingTask = true);
      
      try {
        final isNear = await _checkLocation();
        if (!isNear) {
          setState(() => _startingTask = false);
          return;
        }

        // Start task in backend if not already started
        if (_task['status'] != 'in_progress') {
          await _taskService.startTask(_task['id'] ?? 0);
        }
      } catch (e) {
        if (!e.toString().contains('400')) {
          debugPrint('Error starting task: $e');
        }
      } finally {
        if (mounted) setState(() => _startingTask = false);
      }
    }

    if (!mounted) return;

    if (_currentStep == 2 && _selectedRecipient == 'Nadie') {
      _showConfirmationBottomSheet(context, onConfirm: _submitAutomaticReschedule);
      return;
    }

    if (_currentStep == 6) {
      _showConfirmationBottomSheet(context, onConfirm: _submitAutomaticReschedule);
      return;
    }

    setState(() {
      if (_currentStep == 2 && _selectedRecipient == 'Cliente') {
        _currentStep = 3;
      } else if (_currentStep == 2 && _selectedRecipient == 'Familiar') {
        _currentStep = 6; // Go to Familiar Form first
      } else if (_currentStep == 5) {
        _currentStep = 8; // From Recibo, go to Housing Step (previously 6)
      } else {
        _currentStep++;
      }
    });

    _saveProgress();
  }

  Future<void> _submitAutomaticReschedule() async {
    if (_submitting) return;

    // Check if task is already finished in local state
    if (_task['status'] == 'completed' || _task['status'] == 'rescheduled' || _task['status'] == 'rejected') {
      if (mounted) {
        setState(() {
          _isAutoReschedule = _task['status'] == 'rescheduled';
          _currentStep = 12;
        });
      }
      return;
    }

    setState(() => _submitting = true);

    try {
      final int taskId = _task['id'] is int 
          ? _task['id'] 
          : int.parse('${_task['id'] ?? 0}');
          
      String reason = "Reprogramación automática. ";
      Map<String, dynamic> resultData = {
        'who_received': _selectedRecipient,
        'verification_result': 'Reprogramada',
      };

      if (_selectedRecipient == 'Familiar') {
        reason += "Recibió familiar ${_familiarNameController.text} ($_selectedRelationship).";
        resultData['relationship'] = _selectedRelationship;
        resultData['familiar_dni'] = _familiarDniController.text;
        resultData['familiar_name'] = _familiarNameController.text;

        // Upload signature
        final signatureBytes = await _signatureKey.currentState?.exportPng();
        if (signatureBytes != null) {
          final uploadInfo = await _taskService.requestUploadUrl(
            taskId,
            label: 'firma_familiar',
            contentType: 'image/png',
          );
          
          final uploadUrl = uploadInfo['upload_url'];
          final s3Key = uploadInfo['s3_key'];
          
          if (uploadUrl != null && s3Key != null) {
            await _taskService.uploadImageToS3(uploadUrl, signatureBytes);
            resultData['signature_s3_key'] = s3Key;
            
            await _taskService.confirmUpload(
              taskId,
              s3Key: s3Key,
              label: 'firma_familiar',
              tag: 'Firma de familiar: ${_familiarNameController.text}',
            );
          }
        }
      } else {
        reason += "No se encontró a nadie en el domicilio.";
      }

      await _taskService.rescheduleTask(
        taskId, 
        reason: reason,
        resultData: resultData,
      );
      
      if (mounted) {
        setState(() {
          // El backend ahora marca la tarea como `reschedule_requested`
          // (pendiente de aprobación del supervisor) en vez de cerrarla.
          _task['status'] = 'reschedule_requested';
          _isAutoReschedule = true;
          _currentStep = 12;
        });
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          errorMessage = data['error'] ?? data['detail'] ?? data.toString();
        } else if (data != null) {
          errorMessage = data.toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _saveProgress() async {
    try {
      final taskId = _task['id'];
      if (taskId == null) return;

      final draftData = {
        'selected_recipient': _selectedRecipient,
        'selected_relationship': _selectedRelationship,
        'familiar_name': _familiarNameController.text,
        'familiar_dni': _familiarDniController.text,
        'housing_type': _housingType,
        'is_garage_at_home': _isGarageAtHome,
        'has_security': _hasSecurity,
        'has_cameras': _hasCameras,
        'access_type': _accessType,
        'is_roofing': _isRoofing,
        'is_basement': _isBasement,
        'garage_direction': _garageDirection,
        'street_accessibility': _streetAccessibility,
        'verification_result': _verificationResult,
        'observations': _observationsController.text,
        'dni_front_uploaded': _dniFrontUploaded,
        'dni_front_tag': _dniFrontTag,
        'dni_front_path': _dniFrontPath,
        'dni_back_uploaded': _dniBackUploaded,
        'dni_back_tag': _dniBackTag,
        'dni_back_path': _dniBackPath,
        'brevete_front_uploaded': _breveteFrontUploaded,
        'brevete_front_tag': _breveteFrontTag,
        'brevete_front_path': _breveteFrontPath,
        'brevete_back_uploaded': _breveteBackUploaded,
        'brevete_back_tag': _breveteBackTag,
        'brevete_back_path': _breveteBackPath,
        'recibo_front_uploaded': _reciboFrontUploaded,
        'recibo_front_tag': _reciboFrontTag,
        'recibo_front_path': _reciboFrontPath,
        'recibo_back_uploaded': _reciboBackUploaded,
        'recibo_back_tag': _reciboBackTag,
        'recibo_back_path': _reciboBackPath,
      };

      await _taskService.updateProgress(
        taskId is int ? taskId : int.parse('$taskId'),
        currentStep: _currentStep,
        draftData: draftData,
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 0;
      });
    } else if (_currentStep == 3 || _currentStep == 6 || _currentStep == 7) {
      setState(() {
        _currentStep = 2;
      });
    } else if (_currentStep == 4) {
      setState(() {
        _currentStep = 3;
      });
    } else if (_currentStep == 5) {
      setState(() {
        _currentStep = 4;
      });
    } else if (_currentStep == 11) {
      setState(() {
        _currentStep = 10;
      });
    } else if (_currentStep == 10) {
      setState(() {
        _currentStep = 9;
      });
    } else if (_currentStep == 9) {
      setState(() {
        _currentStep = 8;
      });
    } else if (_currentStep == 8) {
      setState(() {
        _currentStep = 5;
      });
    } else {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitting) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4FA4B5)),
              const SizedBox(height: 16),
              Text(
                'Enviando información...',
                style: GoogleFonts.inter(
                  color: const Color(0xFF002B4B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    bool showAppBar = _currentStep != 12 && _currentStep != 7;

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
                'Verificación Domiciliaria',
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
                TaskChatActionButton(
                  taskId: _task['id'] ?? 0,
                  taskTitle: _task['type']?['name'] ?? 'Verificación Domiciliaria',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: VerificationProgressBar(
                  currentStep: _currentStep,
                  totalSteps: (_selectedRecipient == 'Familiar' || _selectedRecipient == 'Nadie') ? 3 : 8,
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
          onContinue: _nextStep,
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
        return BeforeStartingStep(
          onContinue: _nextStep,
          onBack: _previousStep,
        );
      case 2:
        return WhoReceivedStep(
          selectedRecipient: _selectedRecipient,
          task: _task,
          onRecipientSelected: (val) {
            setState(() {
              _selectedRecipient = val;
            });
          },
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return DniValidationStep(
          taskId: _task['id'] ?? 0,
          task: _task,
          dniFrontUploaded: _dniFrontUploaded,
          dniFrontTag: _dniFrontTag,
          dniFrontPath: _dniFrontPath,
          dniFrontPhotoId: _photoIds['dni_cliente'],
          dniBackUploaded: _dniBackUploaded,
          dniBackTag: _dniBackTag,
          dniBackPath: _dniBackPath,
          dniBackPhotoId: _photoIds['dni_cliente_reverso'],
          onDniFrontUploadedChanged: (val, res) => setState(() {
            _dniFrontUploaded = val;
            _dniFrontPath = (val && res is Map) ? res['localPath'] : null;
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['dni_cliente'] = id;
            } else if (!val) {
              _photoIds.remove('dni_cliente');
            }
          }),
          onDniFrontTagChanged: (val) => setState(() => _dniFrontTag = val),
          onDniBackUploadedChanged: (val, res) => setState(() {
            _dniBackUploaded = val;
            _dniBackPath = (val && res is Map) ? res['localPath'] : null;
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['dni_cliente_reverso'] = id;
            } else if (!val) {
              _photoIds.remove('dni_cliente_reverso');
            }
          }),
          onDniBackTagChanged: (val) => setState(() => _dniBackTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 4:
        return BreveteValidationStep(
          taskId: _task['id'] ?? 0,
          isEcuador: _isEcuador,
          breveteFrontUploaded: _breveteFrontUploaded,
          breveteFrontTag: _breveteFrontTag,
          breveteFrontPath: _breveteFrontPath,
          breveteFrontPhotoId: _photoIds['brevete_cliente'],
          breveteBackUploaded: _breveteBackUploaded,
          breveteBackTag: _breveteBackTag,
          breveteBackPath: _breveteBackPath,
          breveteBackPhotoId: _photoIds['brevete_cliente_reverso'],
          onBreveteFrontUploadedChanged: (val, res) => setState(() {
            _breveteFrontUploaded = val;
            _breveteFrontPath = (val && res is Map) ? res['localPath'] : null;
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['brevete_cliente'] = id;
            } else if (!val) {
              _photoIds.remove('brevete_cliente');
            }
          }),
          onBreveteFrontTagChanged: (val) => setState(() => _breveteFrontTag = val),
          onBreveteBackUploadedChanged: (val, res) => setState(() {
            _breveteBackUploaded = val;
            _breveteBackPath = (val && res is Map) ? res['localPath'] : null;
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['brevete_cliente_reverso'] = id;
            } else if (!val) {
              _photoIds.remove('brevete_cliente_reverso');
            }
          }),
          onBreveteBackTagChanged: (val) => setState(() => _breveteBackTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 5:
        return ReciboValidationStep(
          taskId: _task['id'] ?? 0,
          reciboFrontUploaded: _reciboFrontUploaded,
          reciboFrontTag: _reciboFrontTag,
          reciboFrontPath: _reciboFrontPath,
          reciboFrontPhotoId: _photoIds['recibo_servicios'],
          reciboBackUploaded: _reciboBackUploaded,
          reciboBackTag: _reciboBackTag,
          reciboBackPath: _reciboBackPath,
          reciboBackPhotoId: _photoIds['recibo_servicios_reverso'],
          onReciboFrontUploadedChanged: (val, res) => setState(() {
            _reciboFrontUploaded = val;
            _reciboFrontPath = (val && res is Map) ? res['localPath'] : null;
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['recibo_servicios'] = id;
            } else if (!val) {
              _photoIds.remove('recibo_servicios');
            }
          }),
          onReciboFrontTagChanged: (val) => setState(() => _reciboFrontTag = val),
          onReciboBackUploadedChanged: (val, res) => setState(() {
            _reciboBackUploaded = val;
            _reciboBackPath = (val && res is Map) ? res['localPath'] : null;
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['recibo_servicios_reverso'] = id;
            } else if (!val) {
              _photoIds.remove('recibo_servicios_reverso');
            }
          }),
          onReciboBackTagChanged: (val) => setState(() => _reciboBackTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 6:
        return FamiliarFormStep(
          selectedRelationship: _selectedRelationship,
          signatureKey: _signatureKey,
          dniController: _familiarDniController,
          nameController: _familiarNameController,
          onRelationshipChanged: (val) =>
              setState(() => _selectedRelationship = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 7:
        return FlowRescheduleFormStep(
          title: _selectedRecipient == 'Familiar' ? 'Cliente no se encontraba' : 'Nadie en el domicilio',
          subtitle: 'Se procederá a la reprogramación de la visita.',
          reasons: const [
            'Cliente no se encontraba',
            'Solo se encontró a un familiar',
            'Dirección no existe / incorrecta',
            'Zona peligrosa',
            'Otro'
          ],
          selectedReason: _selectedReason,
          onReasonChanged: (v) => setState(() => _selectedReason = v),
          observationsController: _observationsController,
          onBack: () => setState(() => _currentStep = 2),
          onFinalizar: _submitAutomaticReschedule,
          showBackButton: _selectedRecipient != 'Nadie',
        );
      case 8:
        return HousingStep(
          housingType: _housingType,
          mapsController: _mapsController,
          onHousingTypeChanged: (val) => setState(() => _housingType = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 9),
        );
      case 9:
        final bool needRoofingPhoto = _isRoofing == true;
        final String roofingLabel = needRoofingPhoto ? 'cochera_techada' : 'cochera_general';
        return GarageStep(
          taskId: _task['id'] ?? 0,
          isGarageAtHome: _isGarageAtHome,
          garageFacadeUploaded: _garageFacadeUploaded,
          garageFacadeTag: _garageFacadeTag,
          garageFacadePath: _garageFacadePath,
          garageFacadePhotoId: _photoIds['fachada_vivienda'],
          hasSecurity: _hasSecurity,
          hasCameras: _hasCameras,
          garageCamerasUploaded: _garageCamerasUploaded,
          garageCamerasTag: _garageCamerasTag,
          garageCamerasPath: _garageCamerasPath,
          garageCamerasPhotoId: _photoIds['camara_vigilancia'],
          accessType: _accessType,
          isRoofing: _isRoofing,
          garageRoofingUploaded: _garageRoofingUploaded,
          garageRoofingTag: _garageRoofingTag,
          garageRoofingPath: _garageRoofingPath,
          garageRoofingPhotoId: _photoIds[roofingLabel],
          isBasement: _isBasement,
          garageBasementUploaded: _garageBasementUploaded,
          garageBasementTag: _garageBasementTag,
          garageBasementPath: _garageBasementPath,
          garageBasementPhotoId: _photoIds['cochera_sotano'],
          garageDirection: _garageDirection,
          garageDirectionUploaded: _garageDirectionUploaded,
          garageDirectionTag: _garageDirectionTag,
          garageDirectionPath: _garageDirectionPath,
          garageDirectionPhotoId: _photoIds['cochera_direccion'],
          streetAccessibility: _streetAccessibility,
          streetAccessibilityUploaded: _streetAccessibilityUploaded,
          streetAccessibilityTag: _streetAccessibilityTag,
          streetAccessibilityPath: _streetAccessibilityPath,
          streetAccessibilityPhotoId: _photoIds['accesibilidad_calle'],
          mapsController: _mapsController,
          extraImagesCount: _extraGarageImagesCount,
          isCocheraFuera: _isCocheraFuera,
          extraImagesUploaded: _extraGarageImagesUploaded,
          extraImagesTags: _extraGarageImagesTags,
          extraImagesPaths: _extraGarageImagesPaths,
          extraImagesPhotoIds: [
            _photoIds['fachada_calle_extra_1'],
            _photoIds['fachada_calle_extra_2'],
            _photoIds['fachada_calle_extra_3'],
          ],
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
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['fachada_vivienda'] = id;
            } else if (!val) {
              _photoIds.remove('fachada_vivienda');
            }
          }),
          onFacadeTagChanged: (val) => setState(() => _garageFacadeTag = val),
          onSecurityChanged: (val) => setState(() => _hasSecurity = val),
          onCamerasChanged: (val) => setState(() => _hasCameras = val),
          onCamerasUploadedChanged: (val, res) => setState(() {
            _garageCamerasUploaded = val;
            if (val) _garageCamerasPath = res?['localPath'];
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['camara_vigilancia'] = id;
            } else if (!val) {
              _photoIds.remove('camara_vigilancia');
            }
          }),
          onCamerasTagChanged: (val) => setState(() => _garageCamerasTag = val),
          onAccessTypeChanged: (val) => setState(() => _accessType = val),
          onRoofingChanged: (val) => setState(() => _isRoofing = val),
          onRoofingUploadedChanged: (val, res) => setState(() {
            _garageRoofingUploaded = val;
            if (val) _garageRoofingPath = res?['localPath'];
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds[roofingLabel] = id;
            } else if (!val) {
              _photoIds.remove(roofingLabel);
            }
          }),
          onRoofingTagChanged: (val) => setState(() => _garageRoofingTag = val),
          onBasementChanged: (val) => setState(() => _isBasement = val),
          onBasementUploadedChanged: (val, res) => setState(() {
            _garageBasementUploaded = val;
            if (val) _garageBasementPath = res?['localPath'];
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['cochera_sotano'] = id;
            } else if (!val) {
              _photoIds.remove('cochera_sotano');
            }
          }),
          onBasementTagChanged: (val) =>
              setState(() => _garageBasementTag = val),
          onGarageDirectionChanged: (val) =>
              setState(() => _garageDirection = val),
          onDirectionUploadedChanged: (val, res) => setState(() {
            _garageDirectionUploaded = val;
            if (val) _garageDirectionPath = res?['localPath'];
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['cochera_direccion'] = id;
            } else if (!val) {
              _photoIds.remove('cochera_direccion');
            }
          }),
          onDirectionTagChanged: (val) =>
              setState(() => _garageDirectionTag = val),
          onStreetAccessibilityChanged: (val) =>
              setState(() => _streetAccessibility = val),
          onAccessibilityUploadedChanged: (val, res) => setState(() {
            _streetAccessibilityUploaded = val;
            if (val) _streetAccessibilityPath = res?['localPath'];
            if (val && res is Map && res['photoId'] != null) {
              final id = int.tryParse(res['photoId'].toString());
              if (id != null) _photoIds['accesibilidad_calle'] = id;
            } else if (!val) {
              _photoIds.remove('accesibilidad_calle');
            }
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
              final String label = 'fachada_calle_extra_${index + 1}';
              if (val && res is Map && res['photoId'] != null) {
                final id = int.tryParse(res['photoId'].toString());
                if (id != null) _photoIds[label] = id;
              } else if (!val) {
                _photoIds.remove(label);
              }
            });
          },
          onExtraImageTagChanged: (index, val) {
            setState(() {
              _extraGarageImagesTags[index] = val;
            });
          },
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 10),
        );
      case 10:
        return VerificationResultStep(
          verificationResult: _verificationResult,
          observationsController: _observationsController,
          onResultChanged: (val) => setState(() => _verificationResult = val),
          onBack: _previousStep,
          onContinue: () => setState(() => _currentStep = 11),
        );
      case 11:
        return VerificationSummaryStep(
          selectedRecipient: _selectedRecipient,
          selectedRelationship: _selectedRelationship,
          familiarName: _familiarNameController.text,
          familiarDni: _familiarDniController.text,
          isSignatureCaptured: !(_signatureKey.currentState?.isEmpty ?? true),
          dniFrontUploaded: _dniFrontUploaded,
          dniBackUploaded: _dniBackUploaded,
          reciboFrontUploaded: _reciboFrontUploaded,
          reciboBackUploaded: _reciboBackUploaded,
          breveteFrontUploaded: _breveteFrontUploaded,
          breveteBackUploaded: _breveteBackUploaded,
          isEcuador: _isEcuador,
          housingType: _housingType,
          isGarageAtHome: _isGarageAtHome,
          hasCameras: _hasCameras,
          accessType: _accessType,
          isRoofing: _isRoofing,
          isBasement: _isBasement,
          garageDirection: _garageDirection,
          streetAccessibility: _streetAccessibility,
          isCocheraFuera: _isCocheraFuera,
          extraGarageImagesUploaded: _extraGarageImagesUploaded,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditRecipient: () => setState(() => _currentStep = 2),
          onEditDocuments: () => setState(() => _currentStep = 3),
          onEditHousing: () => setState(() => _currentStep = 8),
          onEditGarage: () => setState(() => _currentStep = 9),
          onEditAll: () => setState(() => _currentStep = 0),
          task: {
            ..._task,
            'observations': _observationsController.text,
          },
          onSend: () => _showConfirmationBottomSheet(context, onConfirm: _submitTask),
        );
      case 12:
        return SuccessStep(
          onBackToStart: () => Navigator.pop(context),
          isReschedule: _isAutoReschedule,
        );
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
            'dni_uploaded': _dniFrontUploaded,
            'dni_front_uploaded': _dniFrontUploaded,
            'dni_back_uploaded': _dniBackUploaded,
            'brevete_uploaded': _breveteFrontUploaded,
            'brevete_front_uploaded': _breveteFrontUploaded,
            'brevete_back_uploaded': _breveteBackUploaded,
            'recibo_uploaded': _reciboFrontUploaded,
            'recibo_front_uploaded': _reciboFrontUploaded,
            'recibo_back_uploaded': _reciboBackUploaded,
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
      if (mounted) {
        setState(() {
          _task['status'] = 'completed';
          _currentStep = 12;
        });
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          errorMessage = data['error'] ?? data['detail'] ?? data.toString();
        } else if (data != null) {
          errorMessage = data.toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showConfirmationBottomSheet(BuildContext context, {required Future<void> Function() onConfirm}) {
    showModalBottomSheet(
      context: context,
      isDismissible: !_submitting,
      enableDrag: !_submitting,
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
            if (_submitting) return;
            Navigator.pop(context);
            await onConfirm();
          },
        );
      },
    );
  }
}
