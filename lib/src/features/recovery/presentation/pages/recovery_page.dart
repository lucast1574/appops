import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';
import '../../../../shared/widgets/task_chat_action_button.dart';
import '../../../../shared/widgets/flow_reschedule_form_step.dart';

import '../widgets/steps/recovery_task_info_step.dart';
import '../widgets/steps/recovery_before_starting_step.dart';
import '../widgets/steps/recovery_efectuado_step.dart';
import '../widgets/steps/recovery_who_delivered_step.dart';
import '../widgets/steps/recovery_vehicle_state_step.dart';
import '../widgets/steps/recovery_docs_step.dart';
import '../widgets/steps/recovery_summary_step.dart';
import '../../../home/data/task_service.dart';

class RecoveryPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const RecoveryPage({super.key, required this.task});

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  bool _loadingDetail = true;
  bool _isAutoReschedule = false;

  @override
  void initState() {
    super.initState();
    _fetchFullDetail();
  }

  Future<void> _fetchFullDetail() async {
    try {
      final taskId = widget.task['id'];
      if (taskId != null) {
        final full = await _taskService.getTaskDetail(taskId is int ? taskId : int.parse('$taskId'));
        if (mounted) {
          setState(() {
            _loadingDetail = false;
            // RESTORE PROGRESS
            if (full['current_step'] != null && full['current_step'] > 0) {
              _currentStep = full['current_step'];
            }
            final draft = full['draft_data'] as Map<String, dynamic>? ?? {};
            if (draft.isNotEmpty) {
              if (draft['recovery_efectuado'] != null) _recoveryEfectuado = draft['recovery_efectuado'];
              if (draft['reschedule_reason'] != null) _selectedReason = draft['reschedule_reason'];
              if (draft['reschedule_observations'] != null) _observationsController.text = draft['reschedule_observations'];
              if (draft['selected_person'] != null) _selectedPerson = draft['selected_person'];
              if (draft['fuel_level'] != null) _selectedFuelLevel = draft['fuel_level'];
              if (draft['has_visible_damage'] != null) _hasVisibleDamage = draft['has_visible_damage'];
              if (draft['damage_description'] != null) _damageDescController.text = draft['damage_description'];
              if (draft['tiene_llave_original'] != null) _llaveOriginal = draft['tiene_llave_original'];
              if (draft['tiene_llave_repuesto'] != null) _llaveRepuesto = draft['tiene_llave_repuesto'];
              if (draft['tiene_gata'] != null) _gata = draft['tiene_gata'];
              if (draft['tiene_llanta_repuesto'] != null) _llantaRepuesto = draft['tiene_llanta_repuesto'];
              if (draft['tiene_extintor'] != null) _extintor = draft['tiene_extintor'];
              if (draft['tiene_triangulo'] != null) _triangulo = draft['tiene_triangulo'];
              if (draft['tiene_manual_conductor'] != null) _manualConductor = draft['tiene_manual_conductor'];
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

  // Step 2 — Recovery status
  bool? _recoveryEfectuado;
  String? _selectedReason;
  final TextEditingController _observationsController = TextEditingController();

  // Step 3 — who delivered
  String? _selectedPerson;

  // Step 4 — vehicle state
  bool _frontalUploaded = false; String? _frontalTag;
  bool _traseraUploaded = false; String? _traseraTag;
  bool _lateralIzqUploaded = false; String? _lateralIzqTag;
  bool _lateralDerUploaded = false; String? _lateralDerTag;
  bool _kmUploaded = false; String? _kmTag;
  String? _selectedFuelLevel;
  bool? _hasVisibleDamage;
  final TextEditingController _damageDescController = TextEditingController();

  // Step 5 — docs
  bool _tarjetaUploaded = false; String? _tarjetaTag;
  bool _soatUploaded = false; String? _soatTag;
  bool _revisionUploaded = false; String? _revisionTag;
  bool _actaUploaded = false; String? _actaTag;
  bool? _llaveOriginal; bool? _llaveRepuesto; bool? _gata;
  bool? _llantaRepuesto; bool? _extintor; bool? _triangulo; bool? _manualConductor;

  int _getTotalSteps() {
    return _recoveryEfectuado == false ? 3 : 6;
  }

  // 0=info, 1=interstitial, 2=efectuado, 3=who, 4=vehicle, 5=docs, 6=summary, 7=success, 8=reschedule
  int _getProgressIndex() {
    if (_recoveryEfectuado == false) {
      switch (_currentStep) {
        case 0: case 1: return 0;
        case 2: return 1;
        case 8: return 2;
        default: return 2;
      }
    }
    switch (_currentStep) {
      case 0: case 1: return 0;
      case 2: return 1;
      case 3: return 2;
      case 4: return 3;
      case 5: return 4;
      case 6: return 5;
      default: return 5;
    }
  }

  void _nextStep() {
    if (_currentStep == 2) {
      if (_recoveryEfectuado == false) {
        setState(() => _currentStep = 8); // Go to Reschedule step
        _saveProgress();
        return;
      }
    }
    setState(() => _currentStep++);
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    try {
      final taskId = widget.task['id'];
      if (taskId == null) return;

      final draftData = {
        'recovery_efectuado': _recoveryEfectuado,
        'reschedule_reason': _selectedReason,
        'reschedule_observations': _observationsController.text,
        'selected_person': _selectedPerson,
        'fuel_level': _selectedFuelLevel,
        'has_visible_damage': _hasVisibleDamage,
        'damage_description': _damageDescController.text,
        'tiene_llave_original': _llaveOriginal,
        'tiene_llave_repuesto': _llaveRepuesto,
        'tiene_gata': _gata,
        'tiene_llanta_repuesto': _llantaRepuesto,
        'tiene_extintor': _extintor,
        'tiene_triangulo': _triangulo,
        'tiene_manual_conductor': _manualConductor,
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
      setState(() => _currentStep = 1);
    } else if (_currentStep == 3) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 8) {
      setState(() => _currentStep = 2);
    } else {
      setState(() => _currentStep--);
    }
  }

  Future<void> _dial(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  void dispose() { 
    _damageDescController.dispose(); 
    _observationsController.dispose();
    super.dispose(); 
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

    bool showAppBar = _currentStep != 1 && _currentStep != 7;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)), onPressed: _previousStep),
              title: Text('Recupero', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
              actions: [
                if (_currentStep == 0) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 10),
                    child: InkWell(
                      onTap: () => _showRescheduleDialog(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECEC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD1D1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reportar',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE35959),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            SvgPicture.asset(
                              'assets/warning.svg',
                              width: 14,
                              height: 14,
                              colorFilter: const ColorFilter.mode(Color(0xFFE35959), BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else if (_currentStep == 2) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 10, bottom: 10),
                    child: InkWell(
                      onTap: () {
                        final String phone = widget.task['metadata']?['telefono']?.toString() ??
                            widget.task['metadata']?['phone']?.toString() ??
                            widget.task['metadata']?['client_phone']?.toString() ??
                            '3125531223';
                        _dial(phone);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27A376),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Llamar',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.phone, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/warning.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    ),
                    onPressed: () => _showRescheduleDialog(context),
                  ),
                ] else ...[
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/warning.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    ),
                    onPressed: () => _showRescheduleDialog(context),
                  ),
                ],
                TaskChatActionButton(
                  taskId: widget.task['id'] ?? 0,
                  taskTitle: 'Recupero',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(10),
                child: FlowProgressBar(
                  totalSteps: _getTotalSteps(),
                  activeIndex: _getProgressIndex(),
                  allComplete: _currentStep == 7,
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_loadingDetail) return const Center(child: CircularProgressIndicator());
    switch (_currentStep) {
      case 0: return RecoveryTaskInfoStep(task: widget.task, onContinue: _nextStep);
      case 1: return RecoveryBeforeStartingStep(onContinue: _nextStep, onBack: _previousStep);
      case 2: return RecoveryEfectuadoStep(
        value: _recoveryEfectuado,
        onChanged: (v) => setState(() => _recoveryEfectuado = v),
        onBack: _previousStep,
        onContinue: _nextStep,
      );
      case 3: return RecoveryWhoDeliveredStep(selectedPerson: _selectedPerson, onPersonSelected: (v) => setState(() => _selectedPerson = v), onBack: _previousStep, onContinue: _nextStep);
      case 4: return RecoveryVehicleStateStep(
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
      case 5: return RecoveryDocsStep(
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
      case 6: return RecoverySummaryStep(
        selectedPerson: _selectedPerson,
        frontalUploaded: _frontalUploaded, traseraUploaded: _traseraUploaded,
        lateralIzqUploaded: _lateralIzqUploaded, lateralDerUploaded: _lateralDerUploaded,
        kmUploaded: _kmUploaded, fuelLevel: _selectedFuelLevel, hasVisibleDamage: _hasVisibleDamage,
        tarjetaUploaded: _tarjetaUploaded, soatUploaded: _soatUploaded,
        revisionUploaded: _revisionUploaded, actaUploaded: _actaUploaded,
        llaveOriginal: _llaveOriginal, llaveRepuesto: _llaveRepuesto, gata: _gata,
        llantaRepuesto: _llantaRepuesto, extintor: _extintor, triangulo: _triangulo, manualConductor: _manualConductor,
        onEditTaskInfo: () => setState(() => _currentStep = 0), onEditWho: () => setState(() => _currentStep = 3),
        onEditVehicle: () => setState(() => _currentStep = 4), onEditDocs: () => setState(() => _currentStep = 5),
        onEditAll: () => setState(() => _currentStep = 0),
        onSend: () => _showConfirmation(context),
      );
      case 7: return FlowSuccessStep(
        onBackToStart: () => Navigator.pop(context),
        title: _isAutoReschedule ? 'Tarea reprogramada' : 'Tarea completada',
        subtitle: _isAutoReschedule 
            ? 'La tarea ha sido reprogramada y el registro ha sido actualizado.'
            : 'Los datos se han enviado correctamente y el registro ha sido actualizado',
        isReschedule: _isAutoReschedule,
      );
      case 8: return FlowRescheduleFormStep(
        title: 'Recupero no efectuado',
        subtitle: 'Se procederá a la reprogramación de la tarea.',
        reasons: const [
          'Cliente se niega a entregar',
          'Vehículo no ubicado',
          'Se realizó compromiso de pago',
          'Cliente no se encontraba',
          'Otro'
        ],
        selectedReason: _selectedReason,
        onReasonChanged: (v) => setState(() => _selectedReason = v),
        observationsController: _observationsController,
        onBack: () => setState(() => _currentStep = 2),
        onFinalizar: _submitAutomaticReschedule,
      );
      default: return RecoveryTaskInfoStep(task: widget.task, onContinue: _nextStep);
    }
  }

  Future<void> _submitAutomaticReschedule() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = widget.task['id'] ?? 0;
      
      String reason = "Reprogramación automática (Recupero). ";
      if (_selectedReason != null) reason += "Motivo: $_selectedReason. ";
      if (_observationsController.text.isNotEmpty) reason += "Obs: ${_observationsController.text}";

      await _taskService.rescheduleTask(
        taskId, 
        reason: reason,
        resultData: {
          'recovery_efectuado': false,
          'reschedule_reason': _selectedReason,
          'observations': _observationsController.text,
        },
      );
      
      if (mounted) {
        setState(() {
          _isAutoReschedule = true;
          _currentStep = 7;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al reprogramar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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
          'recovery_efectuado': true,
          'who_delivered': _selectedPerson,
          'vehicle_state': {
            'fuel_level': _selectedFuelLevel,
            'has_visible_damage': _hasVisibleDamage,
            'damage_description': _damageDescController.text,
          },
          'documents': {
            'tarjeta_propiedad': _tarjetaUploaded,
            'soat': _soatUploaded,
            'revision_tecnica': _revisionUploaded,
            'acta_recupero': _actaUploaded,
          },
          'accessories': {
            'llave_original': _llaveOriginal,
            'llave_repuesto': _llaveRepuesto,
            'gata': _gata,
            'llanta_repuesto': _llantaRepuesto,
            'extintor': _extintor,
            'triangulo': _triangulo,
            'manual_conductor': _manualConductor,
          },
        },
        observations: '',
      );
      if (mounted) setState(() => _currentStep = 7);
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

  void _showConfirmation(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => FlowConfirmationSheet(onCancel: () => Navigator.pop(context), onConfirm: () async { Navigator.pop(context); await _submitTask(); }),
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
                await _taskService.rescheduleTask(widget.task['id'] ?? 0);
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
