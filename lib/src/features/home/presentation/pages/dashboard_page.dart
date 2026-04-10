import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_task_service.dart';
import '../../../auth/data/auth_service.dart';
import '../../../verification/presentation/pages/verification_page.dart';
import '../../../recovery/presentation/pages/recovery_page.dart';
import '../../../delivery/presentation/pages/delivery_page.dart';
import '../../../conversion/presentation/pages/conversion_page.dart';
import '../../../transfer/presentation/pages/transfer_page.dart';
import '../../../vehicle_verification/presentation/pages/vehicle_verification_page.dart';
import '../../../notary/presentation/pages/notary_page.dart';
import '../../../management/presentation/pages/management_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = 'Todas';
  final List<String> filters = [
    'Todas',
    'En curso',
    'Verificación',
    'Recupero',
    'Entrega',
    'Conversión',
    'Traslado',
    'Verificar Vehículo',
    'Notaría',
    'Gestiones/Otros'
  ];

  List<Map<String, String>> mockTasks = [];
  bool isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userName = user['first_name'] ?? '';
      });
    }
  }

  Future<void> _loadTasks() async {
    final tasks = await MockTaskService.loadTasks();
    if (mounted) {
      setState(() {
        mockTasks = tasks;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
            else
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
            '¡Bienvenido, $_userName!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
          const SizedBox(height: 10),
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
            final status = task['status'];
            // Filtration logic mock
            if (status == 'Completada' || status == 'Rechazada') {
              return const SizedBox.shrink();
            }

            if (selectedFilter == 'En curso') {
              if (status != 'En curso') return const SizedBox.shrink();
            } else if (selectedFilter != 'Todas' && !task['type']!.contains(selectedFilter)) {
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

  void _navigateToTask(String type) {
    Widget page;
    if (type.contains('Verificación')) {
      page = const VerificationPage();
    } else if (type.contains('Recupero')) {
      page = const RecoveryPage();
    } else if (type.contains('Entrega')) {
      page = const DeliveryPage();
    } else if (type.contains('Conversión')) {
      page = const ConversionPage();
    } else if (type.contains('Traslado')) {
      page = const TransferPage();
    } else if (type.contains('Verificar Vehículo')) {
      page = const VehicleVerificationPage();
    } else if (type.contains('Notaría')) {
      page = const NotaryPage();
    } else if (type.contains('Gestiones/Otros')) {
      page = const ManagementPage();
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildTaskCard(Map<String, String> task) {
    final bool isInProgress = task['status'] == 'En curso';
    final Color buttonColor = isInProgress ? const Color(0xFFFBDF83) : const Color(0xFF4FA4B5);
    final String buttonText = isInProgress ? 'En curso' : 'Iniciar tarea';

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
              onPressed: () => _navigateToTask(task['type']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: isInProgress ? const Color(0xFF002B4B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isInProgress) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.keyboard_double_arrow_right_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
