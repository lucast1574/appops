import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/flow_photo_input.dart';

class DocumentValidationStep extends StatefulWidget {
  final int taskId;

  final bool dniFrontUploaded;
  final String? dniFrontTag;
  final String? dniFrontPath;
  final bool dniBackUploaded;
  final String? dniBackTag;
  final String? dniBackPath;

  final bool breveteFrontUploaded;
  final String? breveteFrontTag;
  final String? breveteFrontPath;
  final bool breveteBackUploaded;
  final String? breveteBackTag;
  final String? breveteBackPath;

  final bool reciboFrontUploaded;
  final String? reciboFrontTag;
  final String? reciboFrontPath;
  final bool reciboBackUploaded;
  final String? reciboBackTag;
  final String? reciboBackPath;

  final Function(bool, dynamic) onDniFrontUploadedChanged;
  final Function(String?) onDniFrontTagChanged;
  final Function(bool, dynamic) onDniBackUploadedChanged;
  final Function(String?) onDniBackTagChanged;

  final Function(bool, dynamic) onBreveteFrontUploadedChanged;
  final Function(String?) onBreveteFrontTagChanged;
  final Function(bool, dynamic) onBreveteBackUploadedChanged;
  final Function(String?) onBreveteBackTagChanged;

  final Function(bool, dynamic) onReciboFrontUploadedChanged;
  final Function(String?) onReciboFrontTagChanged;
  final Function(bool, dynamic) onReciboBackUploadedChanged;
  final Function(String?) onReciboBackTagChanged;

  final VoidCallback onBack;
  final VoidCallback onContinue;

  const DocumentValidationStep({
    super.key,
    required this.taskId,
    required this.dniFrontUploaded,
    this.dniFrontTag,
    this.dniFrontPath,
    required this.dniBackUploaded,
    this.dniBackTag,
    this.dniBackPath,
    required this.breveteFrontUploaded,
    this.breveteFrontTag,
    this.breveteFrontPath,
    required this.breveteBackUploaded,
    this.breveteBackTag,
    this.breveteBackPath,
    required this.reciboFrontUploaded,
    this.reciboFrontTag,
    this.reciboFrontPath,
    required this.reciboBackUploaded,
    this.reciboBackTag,
    this.reciboBackPath,
    required this.onDniFrontUploadedChanged,
    required this.onDniFrontTagChanged,
    required this.onDniBackUploadedChanged,
    required this.onDniBackTagChanged,
    required this.onBreveteFrontUploadedChanged,
    required this.onBreveteFrontTagChanged,
    required this.onBreveteBackUploadedChanged,
    required this.onBreveteBackTagChanged,
    required this.onReciboFrontUploadedChanged,
    required this.onReciboFrontTagChanged,
    required this.onReciboBackUploadedChanged,
    required this.onReciboBackTagChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<DocumentValidationStep> createState() => _DocumentValidationStepState();
}

class _DocumentValidationStepState extends State<DocumentValidationStep> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    bool allUploaded = widget.dniFrontUploaded &&
        widget.dniBackUploaded &&
        widget.breveteFrontUploaded &&
        widget.breveteBackUploaded &&
        widget.reciboFrontUploaded &&
        widget.reciboBackUploaded;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validación de documentos',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                // Premium Segmented Tabs selector
                Row(
                  children: [
                    _buildTabButton(0, 'DNI/INE', widget.dniFrontUploaded && widget.dniBackUploaded),
                    const SizedBox(width: 8),
                    _buildTabButton(1, 'Brevete', widget.breveteFrontUploaded && widget.breveteBackUploaded),
                    const SizedBox(width: 8),
                    _buildTabButton(2, 'Recibo', widget.reciboFrontUploaded && widget.reciboBackUploaded),
                  ],
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _buildActiveTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: widget.onBack,
          onContinue: widget.onContinue,
          isContinueEnabled: allUploaded,
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String title, bool isComplete) {
    final bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF002B4B) : const Color(0xFFF8FBFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF002B4B) : const Color(0xFFE5E9EB),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF002B4B),
                ),
              ),
              if (isComplete) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, size: 14, color: Color(0xFF27A376)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    if (_activeTab == 0) {
      return Column(
        key: const ValueKey<int>(0),
        children: [
          FlowPhotoInput(
            label: 'DNI/INE Frontal',
            taskId: widget.taskId,
            photoLabel: 'dni_cliente',
            previewFileName: 'DNI-frontal.png',
            isUploaded: widget.dniFrontUploaded,
            imagePath: widget.dniFrontPath,
            tag: widget.dniFrontTag,
            onChanged: widget.onDniFrontUploadedChanged,
            onTagChanged: widget.onDniFrontTagChanged,
          ),
          const SizedBox(height: 16),
          FlowPhotoInput(
            label: 'DNI/INE Reverso',
            taskId: widget.taskId,
            photoLabel: 'dni_cliente_reverso',
            previewFileName: 'DNI-reverso.png',
            isUploaded: widget.dniBackUploaded,
            imagePath: widget.dniBackPath,
            tag: widget.dniBackTag,
            onChanged: widget.onDniBackUploadedChanged,
            onTagChanged: widget.onDniBackTagChanged,
          ),
        ],
      );
    } else if (_activeTab == 1) {
      return Column(
        key: const ValueKey<int>(1),
        children: [
          FlowPhotoInput(
            label: 'Brevete Frontal',
            taskId: widget.taskId,
            photoLabel: 'brevete_cliente',
            previewFileName: 'Brevete-frontal.png',
            isUploaded: widget.breveteFrontUploaded,
            imagePath: widget.breveteFrontPath,
            tag: widget.breveteFrontTag,
            onChanged: widget.onBreveteFrontUploadedChanged,
            onTagChanged: widget.onBreveteFrontTagChanged,
          ),
          const SizedBox(height: 16),
          FlowPhotoInput(
            label: 'Brevete Reverso',
            taskId: widget.taskId,
            photoLabel: 'brevete_cliente_reverso',
            previewFileName: 'Brevete-reverso.png',
            isUploaded: widget.breveteBackUploaded,
            imagePath: widget.breveteBackPath,
            tag: widget.breveteBackTag,
            onChanged: widget.onBreveteBackUploadedChanged,
            onTagChanged: widget.onBreveteBackTagChanged,
          ),
        ],
      );
    } else {
      return Column(
        key: const ValueKey<int>(2),
        children: [
          FlowPhotoInput(
            label: 'Recibo de servicios Frontal',
            taskId: widget.taskId,
            photoLabel: 'recibo_servicios',
            previewFileName: 'Recibo-frontal.png',
            isUploaded: widget.reciboFrontUploaded,
            imagePath: widget.reciboFrontPath,
            tag: widget.reciboFrontTag,
            onChanged: widget.onReciboFrontUploadedChanged,
            onTagChanged: widget.onReciboFrontTagChanged,
          ),
          const SizedBox(height: 16),
          FlowPhotoInput(
            label: 'Recibo de servicios Reverso',
            taskId: widget.taskId,
            photoLabel: 'recibo_servicios_reverso',
            previewFileName: 'Recibo-reverso.png',
            isUploaded: widget.reciboBackUploaded,
            imagePath: widget.reciboBackPath,
            tag: widget.reciboBackTag,
            onChanged: widget.onReciboBackUploadedChanged,
            onTagChanged: widget.onReciboBackTagChanged,
          ),
        ],
      );
    }
  }

  Widget _buildValidationSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
