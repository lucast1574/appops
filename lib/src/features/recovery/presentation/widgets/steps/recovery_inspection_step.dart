import 'package:flutter/material.dart';
import '../../../../../shared/widgets/vehicle_inspection_widget.dart';

class RecoveryInspectionStep extends StatelessWidget {
  final int taskId;
  final List<VehicleObservation> observations;
  final Function(List<VehicleObservation>) onObservationsChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const RecoveryInspectionStep({
    super.key,
    required this.taskId,
    required this.observations,
    required this.onObservationsChanged,
    required this.onBack,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return VehicleInspectionWidget(
      taskId: taskId,
      initialObservations: observations,
      onObservationsChanged: onObservationsChanged,
      onContinue: onContinue,
      onBack: onBack,
    );
  }
}
