import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_success_step.dart';

class SuccessStep extends StatelessWidget {
  final VoidCallback onBackToStart;

  const SuccessStep({
    super.key,
    required this.onBackToStart,
  });

  @override
  Widget build(BuildContext context) {
    return FlowSuccessStep(onBackToStart: onBackToStart);
  }
}
