import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_upload_button.dart';

class VerificationUploadButton extends StatelessWidget {
  final String text;
  final String iconAsset;
  final VoidCallback? onTap;

  const VerificationUploadButton({
    super.key,
    required this.text,
    required this.iconAsset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlowUploadButton(
      text: text,
      iconAsset: iconAsset,
      onTap: onTap,
    );
  }
}
