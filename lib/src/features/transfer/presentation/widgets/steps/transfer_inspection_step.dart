import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_step_navigation.dart';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('Estado de Unidad', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 8),
                Center(child: Text('Marca los daños en el diagrama', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF668093)))),
                const SizedBox(height: 24),

                VehicleInspectionWidget(
                  taskId: taskId,
                  initialObservations: observations,
                  onObservationsChanged: onObservationsChanged,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        FlowStepNavigation(onBack: onBack, onContinue: onContinue),
      ],
    );
  }
}
