import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RecoveryTaskInfoStep extends StatelessWidget {
  final VoidCallback onContinue;

  const RecoveryTaskInfoStep({super.key, required this.onContinue});

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
                _header('Fecha'), const SizedBox(height: 8),
                _value(Row(children: [
                  Text('Miércoles, 18 de marzo de 2026', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B))),
                  const Spacer(),
                  SvgPicture.asset('assets/doble.svg', width: 10, height: 10),
                ])),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _header('Hora inicio'), const SizedBox(height: 8),
                    _value(Text('10:00', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                  ])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _header('Hora fin'), const SizedBox(height: 8),
                    _value(Text('12:00', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                  ])),
                ]),
                const SizedBox(height: 16),
                _header('Nombre del cliente'), const SizedBox(height: 8),
                _value(Text('Carlos Mendoza', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 16),
                _header('DNI cliente'), const SizedBox(height: 8),
                _value(Text('45678912', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 16),
                _header('Placa'), const SizedBox(height: 8),
                _value(Text('ABC-392', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 16),
                _header('Dirección de recupero'), const SizedBox(height: 8),
                _value(Text('Calle Los Manzanos 341, Urb. Monterrico', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 16),
                _header('Motivo de recupero'), const SizedBox(height: 8),
                _value(Text('Mora en pagos - 3 cuotas vencidas', style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        Container(padding: const EdgeInsets.all(24.0), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E9EB)))),
          child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: onContinue, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27A376), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0), child: Text('Comenzar tarea', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold))))),
      ],
    );
  }

  Widget _header(String t) => Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  Widget _value(Widget child) => Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9EB))), child: child);
}
