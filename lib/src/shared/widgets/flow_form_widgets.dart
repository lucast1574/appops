import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlowToggleOption extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const FlowToggleOption({
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

class FlowYesNoQuestion extends StatelessWidget {
  final String question;
  final bool? currentValue;
  final Function(bool) onChanged;

  const FlowYesNoQuestion({
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
              child: FlowToggleOption(
                text: 'Si',
                isActive: currentValue == true,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FlowToggleOption(
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

class FlowDualOptionQuestion extends StatelessWidget {
  final String question;
  final String opt1;
  final String opt2;
  final String? currentValue;
  final Function(String) onChanged;

  const FlowDualOptionQuestion({
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
              child: FlowToggleOption(
                text: opt1,
                isActive: currentValue == opt1,
                onTap: () => onChanged(opt1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FlowToggleOption(
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

class FlowSectionLabel extends StatelessWidget {
  final String label;

  const FlowSectionLabel({super.key, required this.label});

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

class FlowImagePreview extends StatelessWidget {
  final String fileName;
  final String? tag;
  final VoidCallback onDeleteImage;
  final VoidCallback onDeleteTag;
  final Function(String) onTagAdded;

  const FlowImagePreview({
    super.key,
    required this.fileName,
    this.tag,
    required this.onDeleteImage,
    required this.onDeleteTag,
    required this.onTagAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E9EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFB9DBE1).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_outlined, color: Color(0xFF002B4B)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  fileName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF002B4B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/Trash.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFE35959),
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: onDeleteImage,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        tag != null
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E9EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tag!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF002B4B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: onDeleteTag,
                      child: SvgPicture.asset(
                        'assets/close.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF002B4B),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : TextField(
                onSubmitted: onTagAdded,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Agregar etiqueta',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E9EB))),
                ),
              ),
      ],
    );
  }
}

class FlowGoogleMapsSection extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback? onOpenMaps;

  const FlowGoogleMapsSection({
    super.key,
    required this.label,
    required this.controller,
    this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowSectionLabel(label: label),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Agregar link Google maps',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.location_on_outlined, color: Color(0xFF002B4B)),
              label: Text(
                'Abrir Google maps',
                style: GoogleFonts.inter(
                  color: const Color(0xFF002B4B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF002B4B), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
