import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskSummaryPage extends StatelessWidget {
  const TaskSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resumen de tarea',
          style: GoogleFonts.inter(
            color: const Color(0xFF002B4B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E9EB),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Información de la tarea'),
            const SizedBox(height: 16),
            _buildInfoField('Cliente', 'Juan Ortiz'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInfoField('Hora inicio', '16:00')),
                const SizedBox(width: 16),
                Expanded(child: _buildInfoField('Hora fin', '18:00')),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoField('Dirección', 'Avenida Pedro de Osma 789 Calle Centenario 156'),
            const SizedBox(height: 16),
            _buildInfoField('DNI cliente', '9999129912'),
            const SizedBox(height: 16),
            _buildInfoField('Observaciones', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
            
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E9EB)),
            const SizedBox(height: 24),
            
            _buildSectionHeader('¿Quién te recibió?'),
            const SizedBox(height: 16),
            _buildStatusField('Familiar', true),
            const SizedBox(height: 16),
            _buildInfoField('DNI del familiar', '9999129912'),
            const SizedBox(height: 16),
            _buildInfoField('Nombre completo', 'Ana Ortiz'),
            const SizedBox(height: 16),
            _buildInfoField('Parentesco con el cliente', 'Hermana'),
            const SizedBox(height: 16),
            _buildStatusField('Firma de familiar', true),
            
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E9EB)),
            const SizedBox(height: 24),
            
            _buildSectionHeader('Validación de documentos'),
            const SizedBox(height: 16),
            _buildStatusField('DNI', true),
            const SizedBox(height: 16),
            _buildStatusField('Recibo de servicios', false),
            const SizedBox(height: 16),
            _buildStatusField('Brevete', false),
            
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E9EB)),
            const SizedBox(height: 24),
            
            _buildSectionHeader('Tipo de vivienda'),
            const SizedBox(height: 16),
            _buildInfoField('Tipo de vivienda', 'Propia'),
            const SizedBox(height: 16),
            _buildInfoField('¿Vivienda es también la cochera?', 'Si'),
            const SizedBox(height: 16),
            _buildStatusField('Foto de la vivienda / fachada', true),
            const SizedBox(height: 16),
            _buildStatusField('Link Google Maps · Ubicación de vivienda', true),
            
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE5E9EB)),
            const SizedBox(height: 24),
            
            _buildSectionHeader('Tipo de vivienda'),
            const SizedBox(height: 16),
            _buildInfoField('¿Cochera cuenta con cámara de vigilancia?', 'Si'),
            const SizedBox(height: 16),
            _buildStatusField('Foto de la cámara de vigilancia', true),
            const SizedBox(height: 16),
            _buildInfoField('Tipo de vía de acceso a la cochera', 'Asfaltado'),
            const SizedBox(height: 16),
            _buildInfoField('Cochera es techada?', 'Si'),
            const SizedBox(height: 16),
            _buildStatusField('Foto de la cochera', true),
            const SizedBox(height: 16),
            _buildInfoField('Cochera se ubica en sótano', 'Si'),
            const SizedBox(height: 16),
            _buildStatusField('Foto de la cochera', true),
            const SizedBox(height: 16),
            _buildInfoField('Hacia dónde da la cochera?', 'Calle'),
            const SizedBox(height: 16),
            _buildStatusField('Foto de calle / condominio', true),
            const SizedBox(height: 16),
            _buildInfoField('Accesibilidad de la calle', 'Libre acceso'),
            const SizedBox(height: 16),
            _buildStatusField('Foto accesibilidad de la calle', true),
            const SizedBox(height: 24),
            Text(
              'En caso de que la cochera no quede en el domicilio se debe adjuntar 3 fotos más',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF99AAB7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusField('Foto 1', false),
            const SizedBox(height: 16),
            _buildStatusField('Foto 2', false),
            const SizedBox(height: 16),
            _buildStatusField('Foto 3', false),
            const SizedBox(height: 16),
            _buildStatusField('Link Google Maps · Ubicación de cochera', true),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF002B4B),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF99AAB7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF002B4B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField(String label, bool isSuccess) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF002B4B),
            ),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSuccess ? const Color(0xFF23A26D) : const Color(0xFFFF5252),
          ),
        ),
      ],
    );
  }
}
