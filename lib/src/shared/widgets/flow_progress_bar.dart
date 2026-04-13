import 'package:flutter/material.dart';

class FlowProgressBar extends StatelessWidget {
  final int totalSteps;
  final int activeIndex;
  final bool allComplete;

  const FlowProgressBar({
    super.key,
    required this.totalSteps,
    required this.activeIndex,
    this.allComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(totalSteps, (index) {
          bool isActive = index == activeIndex;
          bool isCompleted = index < activeIndex || allComplete;

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
