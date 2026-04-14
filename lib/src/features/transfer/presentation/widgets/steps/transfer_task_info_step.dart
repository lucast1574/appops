import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TransferTaskInfoStep extends StatelessWidget {
  final String? selectedPlaca;
  final String? selectedDestination;
  final Function(String?) onPlacaChanged;
  final Function(String?) onDestinationChanged;
  final VoidCallback onContinue;

  const TransferTaskInfoStep({
    super.key,
    this.selectedPlaca,
    this.selectedDestination,
    required this.onPlacaChanged,
    required this.onDestinationChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Información de la tarea', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B))),
                const SizedBox(height: 24),
                _header('Fecha'),
                const SizedBox(height: 8),
                _readOnly(Row(children: [
                  Text('Miércoles, 18 de marzo de 2026', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                  const Spacer(),
                  SvgPicture.asset('assets/doble.svg', width: 10, height: 10),
                ])),
                const SizedBox(height: 16),
                _header('Placa'),
                const SizedBox(height: 8),
                _dropdown(value: selectedPlaca, hint: 'Seleccionar placa', items: const ['ABC-392', 'EDZ-478', 'XYZ-123'], onChanged: onPlacaChanged),
                const SizedBox(height: 16),
                _header('Ubicación final de traslado'),
                const SizedBox(height: 8),
                _dropdown(value: selectedDestination, hint: 'Seleccionar ubicación', items: const ['Concesionario miraflores', 'Concesionario movistar', 'Taller central'], onChanged: onDestinationChanged),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _footer(onContinue),
      ],
    );
  }

  Widget _header(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _readOnly(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: child);
  Widget _dropdown({String? value, required String hint, required List<String> items, required Function(String?) onChanged}) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, hint: Text(hint, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF99AAB7).withValues(alpha: 0.5))), icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)), isExpanded: true, style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)), items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onChanged)),
  );
  Widget _footer(VoidCallback onContinue) => Container(padding: const EdgeInsets.all(24.0), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E9EB)))), child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: onContinue, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27A376), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0), child: Text('Comenzar tarea', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)))));
}
