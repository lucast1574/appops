import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/mock_task_service.dart';
import '../../../verification/presentation/pages/verification_page.dart';
import '../../../recovery/presentation/pages/recovery_page.dart';
import '../../../delivery/presentation/pages/delivery_page.dart';
import '../../../conversion/presentation/pages/conversion_page.dart';
import '../../../transfer/presentation/pages/transfer_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Todas';
  final List<String> filters = [
    'Todas',
    'Verificación',
    'Recupero',
    'Entrega',
    'Conversión',
    'Traslado',
  ];
  List<Map<String, String>> mockTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildTaskListHeader(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildDateSelector(),
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildTaskList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Listado de tareas',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF668093),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) => _buildFilterButton(filter)).toList(),
      ),
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

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF000000),
              ),
              children: [
                TextSpan(
                  text: 'Fecha: ',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'Hoy - 24 Septiembre 2026',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFF002B4B),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = selectedFilter == 'Todas'
        ? mockTasks
        : mockTasks
              .where((task) => task['type']!.contains(selectedFilter))
              .toList();

    if (filteredTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No hay tareas para este filtro',
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(filteredTasks[index]);
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return const Color(0xFFFBC108);
      case 'Completada':
        return const Color(0xFF23A26D);
      case 'Rechazada':
        return const Color(0xFFE53935);
      case 'Reprogramada':
        return const Color(0xFF4FA4B5); // Navy Blue
      default:
        return const Color(0xFF002B4B);
    }
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
    } else {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildTaskCard(Map<String, String> task) {
    final String status = task['status'] ?? 'Pendiente';
    final Color statusColor = _getStatusColor(status);

    return GestureDetector(
      onTap: () => _navigateToTask(task['type']!),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          task['icon']!,
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF002B4B),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task['type']!,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002B4B),
                            ),
                          ),
                        ),
                        Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          task['date'] ?? 'Fecha no disponible',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF99AAB7),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          task['time'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF99AAB7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task['address']!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
