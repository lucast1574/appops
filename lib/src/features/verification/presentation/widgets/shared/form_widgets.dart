import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF002B4B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ToggleOption(
                text: 'Si',
                isActive: currentValue == true,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ToggleOption(
                text: 'No',
                isActive: currentValue == false,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF002B4B),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ToggleOption(
                text: opt1,
                isActive: currentValue == opt1,
                onTap: () => onChanged(opt1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ToggleOption(
                text: opt2,
                isActive: currentValue == opt2,
                onTap: () => onChanged(opt2),
              ),
            ),
          ],
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFB9DBE1) : const Color(0xFFF8FBFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFB9DBE1),
            width: 1.0,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF002B4B),
          ),
        ),
      ),
    );
  }
}

class FormSectionLabel extends StatelessWidget {
  final String label;

  const FormSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF002B4B),
      ),
    );
  }
}
