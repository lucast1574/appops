import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NotaryTaskInfoStep extends StatelessWidget {
  final String? selectedPickupNotary;
  final String? selectedDeliveryNotary;
  final Function(String?) onPickupNotaryChanged;
  final Function(String?) onDeliveryNotaryChanged;
  final VoidCallback onContinue;

  const NotaryTaskInfoStep({
    super.key,
    this.selectedPickupNotary,
    this.selectedDeliveryNotary,
    required this.onPickupNotaryChanged,
    required this.onDeliveryNotaryChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información de la tarea',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                _buildHeader('Fecha'),
                const SizedBox(height: 8),
                _buildValueContainer(
                  child: Row(
                    children: [
                      Text(
                        'Miércoles, 18 de marzo de 2026',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF002B4B),
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        'assets/doble.svg',
                        width: 10,
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeader('Ubicación de recojo de documentos'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedPickupNotary,
                  hint: 'Seleccionar notaría',
                  onChanged: onPickupNotaryChanged,
                ),
                const SizedBox(height: 16),
                _buildHeader('Notaría (recojo)'),
                const SizedBox(height: 8),
                _buildValueContainer(
                  child: Text(
                    selectedPickupNotary ?? 'Notaría Ramos',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeader('Ubicación de entrega de documentos'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: selectedDeliveryNotary,
                  hint: 'Seleccionar notaría',
                  onChanged: onDeliveryNotaryChanged,
                ),
                const SizedBox(height: 16),
                _buildHeader('Notaría (entrega)'),
                const SizedBox(height: 8),
                _buildValueContainer(
                  child: Text(
                    selectedDeliveryNotary ?? 'Notaría López',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E9EB))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27A376),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                'Comenzar tarea',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _buildValueContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: child,
    );
  }

  Widget _buildDropdown({
    String? value,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
          isExpanded: true,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF002B4B),
          ),
          items: ['Notaría Ramos', 'Notaría López', 'Notaría García', 'Notaría Torres']
              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
