import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
import '../../../../../shared/widgets/signature_pad.dart';

class TransferSignaturesStep extends StatelessWidget {
  final String? signatureOperarioPath;
  final String? signatureClientPath;
  final Function(String?) onOperarioSignatureChanged;
  final Function(String?) onClientSignatureChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferSignaturesStep({
    super.key,
    this.signatureOperarioPath,
    this.signatureClientPath,
    required this.onOperarioSignatureChanged,
    required this.onClientSignatureChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Firmas de conformidad', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 32),

                Text('Firma del Operario*', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
                const SizedBox(height: 12),
                _SignatureInput(
                  existingSignaturePath: signatureOperarioPath,
                  onSignatureCaptured: onOperarioSignatureChanged,
                ),

                const SizedBox(height: 32),

                Text('Firma del Cliente*', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
                const SizedBox(height: 12),
                _SignatureInput(
                  existingSignaturePath: signatureClientPath,
                  onSignatureCaptured: onClientSignatureChanged,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(
          onBack: onBack, 
          onContinue: () {
            if (signatureOperarioPath != null && signatureClientPath != null) {
              onContinue();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ambas firmas son obligatorias para continuar.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        ),
      ],
    );
  }
}

class _SignatureInput extends StatefulWidget {
  final String? existingSignaturePath;
  final Function(String?) onSignatureCaptured;

  const _SignatureInput({
    required this.existingSignaturePath,
    required this.onSignatureCaptured,
  });

  @override
  State<_SignatureInput> createState() => _SignatureInputState();
}

class _SignatureInputState extends State<_SignatureInput> {
  final GlobalKey<SignaturePadState> _signatureKey = GlobalKey<SignaturePadState>();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.existingSignaturePath != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              border: Border.all(color: const Color(0xFFE5E9EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.existingSignaturePath!.startsWith('http')
                  ? Image.network(widget.existingSignaturePath!, fit: BoxFit.contain)
                  : Image.file(File(widget.existingSignaturePath!), fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => widget.onSignatureCaptured(null),
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            label: Text('Borrar firma', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SignaturePad(key: _signatureKey),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving ? null : () => _signatureKey.currentState?.clear(),
              child: Text('Limpiar', style: GoogleFonts.inter(color: const Color(0xFF668093))),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                final state = _signatureKey.currentState;
                if (state == null || state.isEmpty) return;
                
                setState(() => _isSaving = true);
                try {
                  final bytes = await state.exportPng();
                  if (bytes != null) {
                    final tempDir = await getTemporaryDirectory();
                    final file = File('${tempDir.path}/sig_${const Uuid().v4()}.png');
                    await file.writeAsBytes(bytes);
                    widget.onSignatureCaptured(file.path);
                  }
                } finally {
                  if (mounted) setState(() => _isSaving = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FA4B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Guardar firma', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}
