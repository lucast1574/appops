import 'package:flutter/material.dart';

class VerificationProgressBar extends StatelessWidget {
  final int currentStep;

  const VerificationProgressBar({
    super.key,
    required this.currentStep,
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
      activeIndex = 5; // All full
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(6, (index) {
          bool isActive = index == activeIndex;
          bool isCompleted = index < activeIndex || currentStep == 9;

          return Expanded(
            child: Container(
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF27A376)
                    : (isActive ? null : const Color(0xFFE5E9EB)),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF27A376), Color(0xFFF1F4F5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.3, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
