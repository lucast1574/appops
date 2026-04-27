import 'package:flutter/material.dart';
import '../../../../../shared/widgets/vehicle_inspection_widget.dart';

class TransferInspectionStep extends StatelessWidget {
  final int taskId;
  final List<VehicleObservation> observations;
  final Function(List<VehicleObservation>) onObservationsChanged;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  const TransferInspectionStep({
    super.key,
    required this.taskId,
    required this.observations,
    required this.onObservationsChanged,
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
            child: VehicleInspectionWidget(
              taskId: taskId,
              initialObservations: observations,
              onObservationsChanged: onObservationsChanged,
              onContinue: onContinue,
              onBack: onBack,
            ),
          ),
        ),
      ],
    );
  }
}
