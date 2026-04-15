import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// Shared widgets
import '../../../../shared/widgets/flow_progress_bar.dart';
import '../../../../shared/widgets/flow_confirmation_sheet.dart';
import '../../../../shared/widgets/flow_success_step.dart';

// Step widgets
import '../widgets/steps/notary_task_info_step.dart';
import '../widgets/steps/notary_receive_docs_step.dart';
import '../widgets/steps/notary_deliver_docs_step.dart';
import '../widgets/steps/notary_summary_step.dart';

class NotaryPage extends StatefulWidget {
  final Map<String, dynamic> task;
  const NotaryPage({super.key, required this.task});

  @override
  State<NotaryPage> createState() => _NotaryPageState();
}

class _NotaryPageState extends State<NotaryPage> {
  int _currentStep = 0;

  // Step 0 - Task info
  String? _selectedPickupNotary;
  String? _selectedDeliveryNotary;

  // Step 1 - Receive docs
  bool _receivePhotoUploaded = false;
  String? _receivePhotoTag;
  final TextEditingController _receiverNameController = TextEditingController();

  // Step 2 - Deliver docs
  bool _deliverPhotoUploaded = false;
  String? _deliverPhotoTag;
  final TextEditingController _deliveryNameController = TextEditingController();

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
    _receiverNameController.dispose();
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
      body: SafeArea(child: _buildCurrentStep()),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return NotaryTaskInfoStep(
          selectedPickupNotary: _selectedPickupNotary,
          selectedDeliveryNotary: _selectedDeliveryNotary,
          onPickupNotaryChanged: (val) => setState(() => _selectedPickupNotary = val),
          onDeliveryNotaryChanged: (val) => setState(() => _selectedDeliveryNotary = val),
          onContinue: _nextStep,
        );
      case 1:
        return NotaryReceiveDocsStep(
          photoUploaded: _receivePhotoUploaded,
          photoTag: _receivePhotoTag,
          receiverNameController: _receiverNameController,
          onPhotoUploadedChanged: (val) => setState(() => _receivePhotoUploaded = val),
          onPhotoTagChanged: (val) => setState(() => _receivePhotoTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 2:
        return NotaryDeliverDocsStep(
          photoUploaded: _deliverPhotoUploaded,
          photoTag: _deliverPhotoTag,
          deliveryNameController: _deliveryNameController,
          onPhotoUploadedChanged: (val) => setState(() => _deliverPhotoUploaded = val),
          onPhotoTagChanged: (val) => setState(() => _deliverPhotoTag = val),
          onBack: _previousStep,
          onContinue: _nextStep,
        );
      case 3:
        return NotarySummaryStep(
          selectedPickupNotary: _selectedPickupNotary,
          selectedDeliveryNotary: _selectedDeliveryNotary,
          receivePhotoUploaded: _receivePhotoUploaded,
          receiverName: _receiverNameController.text,
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
        return NotaryTaskInfoStep(
          selectedPickupNotary: _selectedPickupNotary,
          selectedDeliveryNotary: _selectedDeliveryNotary,
          onPickupNotaryChanged: (val) => setState(() => _selectedPickupNotary = val),
          onDeliveryNotaryChanged: (val) => setState(() => _selectedDeliveryNotary = val),
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
            setState(() {
              _currentStep = 4;
            });
          },
        );
      },
    );
  }
}
