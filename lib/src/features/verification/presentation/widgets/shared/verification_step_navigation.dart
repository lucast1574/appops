import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';

class VerificationStepNavigation extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final String buttonText;
  final bool isContinueEnabled;

  const VerificationStepNavigation({
    super.key,
    required this.onBack,
    required this.onContinue,
    this.buttonText = 'Continuar',
    this.isContinueEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FlowStepNavigation(
      onBack: onBack,
      onContinue: onContinue,
      buttonText: buttonText,
      isContinueEnabled: isContinueEnabled,
    );
  }
}
