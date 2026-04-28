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
      title: title ?? (isReschedule ? 'Reprogramación automática' : 'Tarea completada'),
      subtitle: subtitle ?? (isReschedule 
        ? 'Verificación no es posible de completar. La visita será reprogramada automáticamente.' 
        : 'Los datos se han enviado correctamente y el registro ha sido actualizado'),
      icon: icon ?? (isReschedule ? Icons.event_available : Icons.check),
      isReschedule: isReschedule,
    );
  }
}
