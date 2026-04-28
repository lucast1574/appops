import 'dart:io';
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
  final bool isReversed;

  const FlowYesNoQuestion({
    super.key,
    required this.question,
    required this.currentValue,
    required this.onChanged,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = [
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
    ];

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
          children: isReversed ? widgets.reversed.toList() : widgets,
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
  final String? imagePath;
  final String? tag;
  final VoidCallback onDeleteImage;
  final VoidCallback onDeleteTag;
  final Function(String) onTagAdded;

  const FlowImagePreview({
    super.key,
    required this.fileName,
    this.imagePath,
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
                  image: imagePath != null ? DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  ) : null,
                ),
                child: imagePath == null ? const Icon(Icons.image_outlined, color: Color(0xFF002B4B)) : null,
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

class FlowAddressDisplay extends StatelessWidget {
  final String label;
  final String address;
  final String? mapsLink;
  final VoidCallback? onOpenMaps;

  const FlowAddressDisplay({
    super.key,
    required this.label,
    required this.address,
    this.mapsLink,
    this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowSectionLabel(label: label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E9EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF002B4B).withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              if (mapsLink != null && mapsLink!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onOpenMaps,
                    icon: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF4FA4B5)),
                    label: Text(
                      'Abrir en Google Maps',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE5E9EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
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
        color: const Color(0xFFF8FBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowSectionLabel(label: label),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            style: GoogleFonts.inter(fontSize: 14),
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
            child: OutlinedButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF4FA4B5)),
              label: Text(
                'Abrir en Google Maps',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002B4B),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFE5E9EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
