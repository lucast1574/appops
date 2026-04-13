import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

// Re-export shared widgets with verification-specific names for backward compatibility
class SummarySection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onEdit;

  const SummarySection({
    super.key,
    required this.title,
    required this.children,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return FlowSummarySection(
      title: title,
      onEdit: onEdit,
      children: children,
    );
  }
}

class SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String? secondLabel;
  final String? secondValue;

  const SummaryItem({
    super.key,
    required this.label,
    required this.value,
    this.secondLabel,
    this.secondValue,
  });

  @override
  Widget build(BuildContext context) {
    return FlowSummaryItem(
      label: label,
      value: value,
      secondLabel: secondLabel,
      secondValue: secondValue,
    );
  }
}

class SummaryStatus extends StatelessWidget {
  final String label;
  final bool isComplete;

  const SummaryStatus({
    super.key,
    required this.label,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return FlowSummaryStatus(
      label: label,
      isComplete: isComplete,
    );
  }
}
