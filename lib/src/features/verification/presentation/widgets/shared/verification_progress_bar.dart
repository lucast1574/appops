import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_progress_bar.dart';

class VerificationProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const VerificationProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStep == 12) return const SizedBox.shrink();

    int activeIndex = 0;
    if (currentStep == 0 || currentStep == 1) {
      activeIndex = 0;
    } else if (currentStep == 2) {
      activeIndex = 1;
    } else if (currentStep == 3) {
      activeIndex = 2; // DNI
    } else if (currentStep == 4) {
      activeIndex = 3; // Brevete
    } else if (currentStep == 5) {
      activeIndex = 4; // Recibo
    } else if (currentStep == 6 || currentStep == 7) {
      activeIndex = 2; // FamiliarForm or Reschedule
    } else if (currentStep == 8) {
      activeIndex = 5; // Housing
    } else if (currentStep == 9) {
      activeIndex = 6; // Garage
    } else if (currentStep == 10 || currentStep == 11) {
      activeIndex = 7; // Result / Summary
    }

    return FlowProgressBar(
      totalSteps: totalSteps,
      activeIndex: activeIndex,
      allComplete: currentStep == 11,
    );
  }
}
