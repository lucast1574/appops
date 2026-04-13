import 'package:flutter/material.dart';
import '../../../../../shared/widgets/flow_form_widgets.dart';

// Re-export shared widgets with verification-specific names for backward compatibility
class YesNoQuestion extends StatelessWidget {
  final String question;
  final bool? currentValue;
  final Function(bool) onChanged;

  const YesNoQuestion({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FlowYesNoQuestion(
      question: question,
      currentValue: currentValue,
      onChanged: onChanged,
    );
  }
}

class DualOptionQuestion extends StatelessWidget {
  final String question;
  final String opt1;
  final String opt2;
  final String? currentValue;
  final Function(String) onChanged;

  const DualOptionQuestion({
    super.key,
    required this.question,
    required this.opt1,
    required this.opt2,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FlowDualOptionQuestion(
      question: question,
      opt1: opt1,
      opt2: opt2,
      currentValue: currentValue,
      onChanged: onChanged,
    );
  }
}

class ToggleOption extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const ToggleOption({
    super.key,
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlowToggleOption(
      text: text,
      isActive: isActive,
      onTap: onTap,
    );
  }
}

class FormSectionLabel extends StatelessWidget {
  final String label;

  const FormSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return FlowSectionLabel(label: label);
  }
}
