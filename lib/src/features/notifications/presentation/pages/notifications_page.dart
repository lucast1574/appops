import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF002B4B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificaciones',
          style: GoogleFonts.inter(
            color: const Color(0xFF002B4B),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E9EB).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          NotificationTile(
            type: 'Verificación',
            time: 'Hace 5 horas',
          ),
          SizedBox(height: 16),
          NotificationTile(
            type: 'Entrega unidad',
            time: 'Hace 5 horas',
          ),
          SizedBox(height: 16),
          NotificationTile(
            type: 'Traslado',
            time: 'Hace 5 horas',
          ),
          SizedBox(height: 16),
          NotificationTile(
            type: 'Traslado',
            time: 'Hace 5 horas',
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String type;
  final String time;

  const NotificationTile({
    super.key,
    required this.type,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva tarea!',
            style: GoogleFonts.inter(
              color: const Color(0xFF002B4B),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                color: const Color(0xFF002B4B),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: [
                const TextSpan(text: 'Se ha recibido una nueva tarea de '),
                TextSpan(
                  text: type,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: GoogleFonts.inter(
              color: const Color(0xFF99AAB7),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
