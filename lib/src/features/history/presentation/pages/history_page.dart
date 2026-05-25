import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/data/task_service.dart';
import '../../../task_summary/presentation/pages/task_summary_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // UI filter chips — labels shown to the user. They map to task type slugs
  // (or status keywords) internally in `_filterTasks`.
  String selectedFilter = 'Todas';
  final List<String> filters = [
    'Todas',
    'En curso',
    'Verificación Domiciliaria',
    'Recupero',
    'Entrega',
    'Conversión',
    'Traslado',
  ];

  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> _tasks = [];
  bool isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      isLoading = true;
      _error = null;
    });
    try {
      // Operario's own tasks. Backend filters by `assigned_to=request.user`,
      // so we get exactly the ones this operario should see.
      final tasks = await _taskService.getMyTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar el historial';
          isLoading = false;
        });
      }
    }
  }

  /// Filter the raw task list according to the currently-selected chip.
  /// Slug mapping keeps the chip label in Spanish while matching the
  /// backend's internal slug ('verificacion', 'recupero', ...).
  List<Map<String, dynamic>> _filterTasks() {
    if (selectedFilter == 'Todas') {
      return List.from(_tasks);
    }
    if (selectedFilter == 'En curso') {
      return _tasks
          .where((t) =>
              t['status'] == 'in_progress' || t['status'] == 'rescheduled')
          .toList();
    }
    const chipToSlug = {
      'Verificación Domiciliaria': 'verificacion',
      'Recupero': 'recupero',
      'Entrega': 'entrega',
      'Conversión': 'conversion',
      'Traslado': 'traslado',
    };
    final targetSlug = chipToSlug[selectedFilter];
    if (targetSlug == null) return _tasks;
    return _tasks
        .where((t) => (t['type'] as Map?)?['slug'] == targetSlug)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildTaskListHeader(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 24),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _buildErrorState()
              else
                _buildTaskList(),
            ],
          ),
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error desconocido',
              style: GoogleFonts.inter(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadTasks,
              child: Text(
                'Reintentar',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4FA4B5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = _filterTasks();

    // Sort:
    //  - Active tasks (pending/in_progress/rescheduled) come first.
    //  - Within active: oldest scheduled date first (overdue appears at top).
    //  - Completed/rejected sink to the bottom: newest first (most recent history on top).
    filteredTasks.sort((a, b) {
      final aDone = a['status'] == 'completed' || a['status'] == 'rejected';
      final bDone = b['status'] == 'completed' || b['status'] == 'rejected';
      if (aDone && !bDone) return 1;
      if (!aDone && bDone) return -1;
      final ad = (a['scheduled_date'] ?? '') as String;
      final bd = (b['scheduled_date'] ?? '') as String;
      // Active → oldest first (overdue at top); Done → newest first.
      return aDone ? bd.compareTo(ad) : ad.compareTo(bd);
    });

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
      itemBuilder: (context, index) => _buildTaskCard(filteredTasks[index]),
    );
  }

  Color _getStatusColor(String statusLabel) {
    switch (statusLabel) {
      case 'Pendiente':
        return const Color(0xFFFBC108);
      case 'En curso':
        return const Color(0xFFA855F7); // purple — fixed from wrong magenta
      case 'Completada':
        return const Color(0xFF23A26D);
      case 'Rechazada':
        return const Color(0xFFE53935);
      case 'Reprogramada':
        return const Color(0xFF4FA4B5);
      case 'Sin asignar':
        return const Color(0xFF3B82F6);
      case 'Aprobación':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF668093);
    }
  }

  void _navigateToTask(Map<String, dynamic> task) {
    // The summary page pulls full detail (photos, result_data, etc.)
    // from the backend using the task id; we pass the lightweight list
    // entry as an initial hint so it can render instantly while loading.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskSummaryPage(task: task),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    // ----- Extract backend fields with graceful fallbacks -------------
    final type = task['type'] as Map<String, dynamic>?;
    final String typeName = type?['name'] ?? 'Tarea';
    final String typeSlug = type?['slug'] ?? '';
    final String icon = TaskService.getIconForType(typeSlug);

    final String statusKey = task['status'] ?? 'pending';
    final String statusLabel = TaskService.getStatusLabel(statusKey);
    final Color statusColor = _getStatusColor(statusLabel);
    final bool isExtra = task['is_extra'] == true;

    final String scheduledDate = task['scheduled_date'] ?? '';

    // Detect overdue for history display (pending/in_progress tasks with past date)
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final bool isOverdue = scheduledDate.isNotEmpty &&
        scheduledDate.compareTo(todayStr) < 0 &&
        (statusKey == 'pending' || statusKey == 'in_progress' || statusKey == 'unassigned');
    int daysOverdue = 0;
    if (isOverdue) {
      final scheduled = DateTime.tryParse(scheduledDate);
      if (scheduled != null) {
        daysOverdue = DateTime(today.year, today.month, today.day)
            .difference(DateTime(scheduled.year, scheduled.month, scheduled.day))
            .inDays;
      }
    }
    final String startTime = TaskService.formatTime(task['start_time']);
    final String endTime = TaskService.formatTime(task['end_time']);
    final String timeRange = [startTime, endTime]
        .where((s) => s.isNotEmpty)
        .join(' - ');

    final String address = (task['address'] ?? '') as String;

    return GestureDetector(
      onTap: () => _navigateToTask(task),
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
                          icon,
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF002B4B),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  typeName,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF002B4B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isExtra) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'EXTRA',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFB45309),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          statusLabel,
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
                        if (isOverdue)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4E4),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFE53935), width: 1),
                            ),
                            child: Text(
                              '⚠ -${daysOverdue}d',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB71C1C),
                              ),
                            ),
                          ),
                        Flexible(
                          child: Text(
                            scheduledDate.isNotEmpty
                                ? scheduledDate
                                : 'Fecha no disponible',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isOverdue
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF99AAB7),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const Spacer(),
                        if (timeRange.isNotEmpty)
                          Text(
                            timeRange,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF99AAB7),
                            ),
                          ),
                      ],
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: const Color(0xFF002B4B),
                        ),
                      ),
                    ],
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
