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
    if (currentStep == 10) return const SizedBox.shrink();

    int activeIndex = 0;
    if (currentStep == 0 || currentStep == 1) {
      activeIndex = 0;
    } else if (currentStep == 2) {
      activeIndex = 1;
    } else if (currentStep == 3 || currentStep == 4 || currentStep == 5) {
      activeIndex = 2;
    } else if (currentStep == 6) {
      activeIndex = 3;
    } else if (currentStep == 7) {
      activeIndex = 4;
    } else if (currentStep == 8) {
      activeIndex = 5;
    } else if (currentStep == 9) {
      activeIndex = 5;
    }

    return FlowProgressBar(
      totalSteps: totalSteps,
      activeIndex: activeIndex,
      allComplete: currentStep == 9,
    );
  }
}
