import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskInfoStep extends StatelessWidget {
  final VoidCallback onContinue;

  const TaskInfoStep({super.key, required this.onContinue});

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
                _buildHeader('Cliente'),
                const SizedBox(height: 8),
                _buildValueContainer(
                  child: Text(
                    'Juan Ortiz',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeader('Hora inicio'),
                const SizedBox(height: 8),
                _buildValueContainer(
                  child: Text(
                    '16:00',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeader('Dirección'),
                const SizedBox(height: 8),
                _buildValueContainer(
                  child: Text(
                    'Avenida Pedro de Osma 789 Calle Centenario 156',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeader('Observaciones'),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF002B4B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Agregar observaciones',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF002B4B)),
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
                backgroundColor: const Color(0xFF002B4B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Iniciar tarea',
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
        color: const Color(0xFF002B4B),
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
        border: Border.all(
          color: const Color(0xFFE5E9EB).withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
