import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_confirmation_sheet.dart';

class ConfirmationSheet extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ConfirmationSheet({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return FlowConfirmationSheet(
      onCancel: onCancel,
      onConfirm: onConfirm,
    );
  }
}
