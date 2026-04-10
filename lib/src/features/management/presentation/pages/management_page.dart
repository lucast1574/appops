import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Gestiones/Otros',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestiones y Otros',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002B4B),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aquí se realizará el seguimiento de gestiones diversas y otros tipos de tareas.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF668093),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002B4B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Completar Gestión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
