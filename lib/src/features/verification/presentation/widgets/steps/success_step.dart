import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_success_step.dart';

class SuccessStep extends StatelessWidget {
  final VoidCallback onBackToStart;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final bool isReschedule;

  const SuccessStep({
    super.key,
    required this.onBackToStart,
    this.title,
    this.subtitle,
    this.icon,
    this.isReschedule = false,
  });

  @override
  Widget build(BuildContext context) {
    return FlowSuccessStep(
      onBackToStart: onBackToStart,
      title: title ?? (isReschedule ? 'Reprogramación solicitada' : 'Tarea enviada'),
      subtitle: subtitle ?? (isReschedule
        ? 'La Verificación Domiciliaria no fue posible. Tu solicitud de reprogramación queda pendiente de la aprobación del supervisor.'
        : 'Tus datos se enviaron correctamente. La tarea queda pendiente de la revisión del supervisor.'),
      icon: icon ?? (isReschedule ? Icons.event_available : Icons.check),
      isReschedule: isReschedule,
    );
  }
}
