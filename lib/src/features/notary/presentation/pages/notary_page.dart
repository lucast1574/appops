import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared widgets
import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

// Step widgets
import '../../../home/data/task_service.dart';
import '../widgets/steps/notary_receive_docs_step.dart';
import '../widgets/steps/notary_deliver_docs_step.dart';
import '../widgets/steps/notary_summary_step.dart';
import '../../../../shared/widgets/task_info_widget.dart';

class NotaryPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const NotaryPage({super.key, required this.task});

  @override
  State<NotaryPage> createState() => _NotaryPageState();
}

class _NotaryPageState extends State<NotaryPage> {
  int _currentStep = 0;
  final TaskService _taskService = TaskService();
  bool _submitting = false;
  late Map<String, dynamic> _task;
  bool _loadingDetail = true;

  // Step 1 - Receive docs
  bool _receivePhotoUploaded = false;
  String? _receivePhotoTag;
  String? _receivePhotoPath;

  // Step 2 - Deliver docs
  bool _deliverPhotoUploaded = false;
  String? _deliverPhotoTag;
  String? _deliverPhotoPath;
  final TextEditingController _deliveryNameController = TextEditingController();

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
        if (mounted) {
          setState(() {
            _task = full;
            _loadingDetail = false;
          });
        }
      } else {
        if (mounted) setState(() => _loadingDetail = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetail = false);
    }
  }


  int _getProgressIndex() {
    switch (_currentStep) {
      case 0: return 0;
      case 1: return 1;
      case 2: return 2;
      case 3: return 3;
      default: return 3;
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
    _deliveryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep != 4;

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
                'Notaría',
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
        );
      case 1:
        return NotaryReceiveDocsStep(
          taskId: _task['id'] ?? 0,
          photoUploaded: _receivePhotoUploaded,
          photoTag: _receivePhotoTag,
          photoPath: _receivePhotoPath,
          onPhotoUploadedChanged: (val, res) => setState(() {
            _receivePhotoUploaded = val;
            if (val) _receivePhotoPath = res?['localPath'];
          }),
          onPhotoTagChanged: (val) => setState(() => _receivePhotoTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 2:
        return NotaryDeliverDocsStep(
          taskId: _task['id'] ?? 0,
          photoUploaded: _deliverPhotoUploaded,
          photoTag: _deliverPhotoTag,
          photoPath: _deliverPhotoPath,
          deliveryNameController: _deliveryNameController,
          onPhotoUploadedChanged: (val, res) => setState(() {
            _deliverPhotoUploaded = val;
            if (val) _deliverPhotoPath = res?['localPath'];
          }),
          onPhotoTagChanged: (val) => setState(() => _deliverPhotoTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        final metadata = _task['metadata'] ?? {};
        return NotarySummaryStep(
          selectedPickupNotary: metadata['pickup_notary'],
          selectedDeliveryNotary: metadata['delivery_notary'],
          receivePhotoUploaded: _receivePhotoUploaded,
          receiverName: '', // Not used anymore in Step 1
          deliverPhotoUploaded: _deliverPhotoUploaded,
          deliveryName: _deliveryNameController.text,
          onEditTaskInfo: () => setState(() => _currentStep = 0),
          onEditReceive: () => setState(() => _currentStep = 1),
          onEditDeliver: () => setState(() => _currentStep = 2),
          onEditAll: () => setState(() => _currentStep = 0),
          onSend: () => _showConfirmationBottomSheet(context),
        );
      case 4:
        return FlowSuccessStep(onBackToStart: () => Navigator.pop(context));
      default:
        return TaskInfoWidget(task: _task, onContinue: _nextStep);
    }
  }

  Future<void> _submitTask() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      final int taskId = _task['id'] ?? 0;
      final metadata = _task['metadata'] ?? {};
      
      await _taskService.submitTask(
        taskId,
        resultData: {
          'pickup_notary': metadata['pickup_notary'],
          'delivery_notary': metadata['delivery_notary'],
          'delivery_name': _deliveryNameController.text,
          'receive_photo_uploaded': _receivePhotoUploaded,
          'deliver_photo_uploaded': _deliverPhotoUploaded,
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

