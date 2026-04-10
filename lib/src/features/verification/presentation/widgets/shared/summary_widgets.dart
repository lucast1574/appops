import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002B4B),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF002B4B), size: 24),
              onPressed: onEdit,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 8),
        const Divider(color: Color(0xFFE5E9EB), thickness: 1),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7)),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (secondLabel != null) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    secondLabel ?? '',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF99AAB7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    secondValue ?? '',
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF002B4B)),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isComplete ? const Color(0xFF27A376) : const Color(0xFFE35959),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
