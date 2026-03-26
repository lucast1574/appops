import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'Todas';
  final List<String> filters = ['Todas', 'Verificación', 'Recupero', 'Entrega', 'Conversión'];

  final List<Map<String, String>> mockTasks = [
    {
      'id': '1',
      'type': 'Verificación',
      'icon': 'assets/check.svg',
      'time': '13:00',
      'address': 'Avenida Pedro de Osma 789 Calle Centenario 156'
    },
    {
      'id': '2',
      'type': 'Entrega unidad',
      'icon': 'assets/entrega.svg',
      'time': '16:00',
      'address': 'Calle Los Manzanos 341, Urb. Monterrico'
    },
    {
      'id': '3',
      'type': 'Conversión',
      'icon': 'assets/GasPump.svg',
      'time': '16:00',
      'address': 'Calle Los Manzanos 341, Urb. Monterrico'
    },
    {
      'id': '4',
      'type': 'Traslado',
      'icon': 'assets/traslado.svg',
      'time': '16:00',
      'address': 'Calle Los Manzanos 341, Urb. Monterrico'
    },
    {
      'id': '5',
      'type': 'Recupero',
      'icon': 'assets/car.svg',
      'time': '16:00',
      'address': 'Calle Los Manzanos 341, Urb. Monterrico'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            _buildTaskListSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            '¡Bienvenido, Julian!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F0F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  'Nueva tarea',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FA4B5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/plus.svg',
                        height: 14,
                        width: 14,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Crear tarea',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTaskListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Listado de tareas',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF668093),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: filters.map((filter) => _buildFilterButton(filter)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: mockTasks.length,
          itemBuilder: (context, index) {
            final task = mockTasks[index];
            // Filtration logic mock
            if (selectedFilter != 'Todas' && !task['type']!.contains(selectedFilter)) {
              return const SizedBox.shrink();
            }
            return _buildTaskCard(task);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFilterButton(String filter) {
    bool isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = filter),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002B4B) : const Color(0xFFCCD5DB),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          filter,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF002B4B),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, String> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                task['icon']!,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Color(0xFF002B4B), BlendMode.srcIn),
              ),
              const SizedBox(width: 12),
              Text(
                task['type']!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002B4B),
                ),
              ),
              const Spacer(),
              Text(
                task['time']!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002B4B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              task['address']!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF002B4B).withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FA4B5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Iniciar tarea'),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_double_arrow_right_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
