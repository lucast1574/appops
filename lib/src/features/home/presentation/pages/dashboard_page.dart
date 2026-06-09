import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/task_service.dart';
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
    'Pendiente',
    'Atrasada',
    'Reprogramada',
  ];

  final TaskService _taskService = TaskService();
  List<Map<String, dynamic>> _tasks = [];
  bool isLoading = true;
  String? _error;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadTasks();
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
    // Only show full-screen loader if we have no tasks and no error yet
    if (_tasks.isEmpty && _error == null) {
      setState(() => isLoading = true);
    }

    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final tomorrow = today.add(const Duration(days: 1));
      final tomorrowStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      // Configurable threshold hour (24h format) for showing next day's tasks (default: 6 PM / 18:00)
      const int showNextDayTasksHour = 18;
      final bool showNextDay = today.hour >= showNextDayTasksHour;
      final String maxAllowedDateStr = showNextDay ? tomorrowStr : todayStr;

      // Lookback: we still want overdue/atrasada tasks from the past 30 days
      // so the operator can see them in the dedicated tab.
      final lookback = today.subtract(const Duration(days: 30));
      final lookbackStr =
          '${lookback.year}-${lookback.month.toString().padLeft(2, '0')}-${lookback.day.toString().padLeft(2, '0')}';

      // Backend already excludes completed/rejected/cancelled. We pass a
      // 'since' filter so historical pending rows don't bloat the payload.
      final tasks = await _taskService.getMyTasks();

      if (mounted) {
        setState(() {
          _tasks = tasks
              .where((t) {
                // Future tasks beyond the day-after-tomorrow are not shown
                // in the dashboard until they are imminent.
                final date = t['scheduled_date'] ?? '';
                if (date.isNotEmpty && date.compareTo(maxAllowedDateStr) > 0) return false;
                if (date.isNotEmpty && date.compareTo(lookbackStr) < 0) return false;
                return true;
              })
              .toList();
          isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar tareas';
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (selectedFilter == 'Todas') {
      // "Todas" shows active/pending/overdue, not rescheduled or missed
      return _tasks.where((t) => t['status'] != 'rescheduled' && t['status'] != 'missed').toList();
    }
    if (selectedFilter == 'En curso') {
      return _tasks.where((t) => t['status'] == 'in_progress' || (t['status'] == 'overdue' && t['started_at'] != null)).toList();
    }
    if (selectedFilter == 'Pendiente') {
      return _tasks.where((t) => t['status'] == 'pending').toList();
    }
    if (selectedFilter == 'Atrasada') {
      return _tasks.where((t) => t['status'] == 'overdue').toList();
    }
    if (selectedFilter == 'Reprogramada') {
      return _tasks.where((t) => t['status'] == 'rescheduled').toList();
    }
    return _tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        color: const Color(0xFF4FA4B5),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSection(),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF4FA4B5)),
                  ),
                )
              else if (_error != null)
                _buildErrorState()
              else
                _buildTaskListSection(),
            ],
          ),
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
            _userName.isNotEmpty
                ? '\u00a1Bienvenido, $_userName!'
                : '\u00a1Bienvenido!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_filteredTasks.length} tarea${_filteredTasks.length == 1 ? '' : 's'} activa${_filteredTasks.length == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF668093),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFFCCD5DB),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error desconocido',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF668093),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Reintentar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4FA4B5),
              ),
            ),
          ],
        ),
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
            children: filters
                .map((filter) => _buildFilterButton(filter))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        if (_filteredTasks.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredTasks.length,
            itemBuilder: (context, index) =>
                _buildTaskCard(_filteredTasks[index]),
          ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: Color(0xFFCCD5DB),
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes tareas pendientes',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF668093),
              ),
            ),
          ],
        ),
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

  void _navigateToTask(Map<String, dynamic> task) {
    final slug = task['type']?['slug'] ?? '';
    Widget page;

    switch (slug) {
      case 'verificacion':
        page = VerificationPage(task: task);
        break;
      case 'recupero':
        page = RecoveryPage(task: task);
        break;
      case 'entrega':
        page = DeliveryPage(task: task);
        break;
      case 'conversion':
        page = ConversionPage(task: task);
        break;
      case 'traslado':
        page = TransferPage(task: task);
        break;
      case 'verificar_vehiculo':
        page = VehicleVerificationPage(task: task);
        break;
      case 'notaria':
        page = NotaryPage(task: task);
        break;
      case 'gestiones':
        page = ManagementPage(task: task);
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) => _loadTasks()); // Reload tasks when coming back
  }

  /// Extracts a human-friendly message from a Dio error (backend
  /// returns `{ "error": "..." }` on validation failures) and falls back
  /// to a generic message when nothing useful is available.
  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['error'] ?? data['detail'] ?? data['message'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
      }
      if (data is String && data.trim().isNotEmpty) return data;
      final code = e.response?.statusCode;
      if (code != null) return 'Error $code del servidor';
      return e.message ?? 'Error de conexión';
    }
    return e.toString();
  }

  final Set<int> _startingTaskIds = {};
  Future<void> _onStartTask(Map<String, dynamic> task) async {
    final int taskId = task['id'] ?? 0;
    if (taskId == 0 || _startingTaskIds.contains(taskId)) return;

    setState(() => _startingTaskIds.add(taskId));
    try {
      await _taskService.startTask(taskId);
      _navigateToTask(task);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar tarea: ${_friendlyError(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _startingTaskIds.remove(taskId));
      }
    }
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final String status = task['status'] ?? 'pending';
    final bool isInProgress = status == 'in_progress' || (status == 'overdue' && task['started_at'] != null);
    final bool isOverdue = status == 'overdue' && task['started_at'] == null;
    final bool isMissed = status == 'missed';
    final bool isRescheduled = status == 'rescheduled';
    final bool isExtra = task['is_extra'] == true;

    // Detect visually overdue from date (fallback for tasks not yet processed by scheduler)
    final String scheduledDateRaw = task['scheduled_date'] ?? '';
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final tomorrow = today.add(const Duration(days: 1));
    final tomorrowStr =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    final bool isTomorrow = scheduledDateRaw == tomorrowStr;

    final bool isDateOverdue = scheduledDateRaw.isNotEmpty &&
        scheduledDateRaw.compareTo(todayStr) < 0 &&
        (status == 'pending' || status == 'in_progress' || status == 'unassigned');
    // Days overdue count
    int daysOverdue = 0;
    if (status == 'overdue' || isDateOverdue) {
      final scheduled = DateTime.tryParse(scheduledDateRaw);
      if (scheduled != null) {
        daysOverdue = DateTime(today.year, today.month, today.day)
            .difference(DateTime(scheduled.year, scheduled.month, scheduled.day))
            .inDays;
      }
    }
    
    final Color buttonColor = isInProgress
        ? const Color(0xFFFBDF83)
        : isOverdue
            ? const Color(0xFFFF8A65)  // orange for overdue
            : const Color(0xFF4FA4B5);
    final String buttonText = isInProgress
        ? 'Continuar'
        : isOverdue
            ? 'Ejecutar (atrasada)'
            : 'Iniciar tarea';

    // Extract task data
    final type = task['type'] as Map<String, dynamic>?;
    final String typeName = type?['name'] ?? 'Tarea';
    final String typeSlug = type?['slug'] ?? '';
    final String icon = TaskService.getIconForType(typeSlug);
    final String time = TaskService.formatTime(task['start_time']);
    final String address = task['address'] ?? '';
    final String clientName = task['client_name'] ?? '';
    final String placa = task['placa'] ?? '';
    final String scheduledDate = scheduledDateRaw;

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
          // Header: type + time
          Row(
            children: [
              SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF002B4B),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  typeName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
              ),
              if (status == 'overdue' || isDateOverdue)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0CC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE65100), width: 1),
                  ),
                  child: Text(
                    '⚠ ATRASADA${daysOverdue > 0 ? ' -${daysOverdue}d' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFBF360C),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              if (isMissed)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCDD2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFB71C1C), width: 1.5),
                  ),
                  child: Text(
                    '⛔ FALTANTE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7F0000),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              if (isExtra)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                  ),
                  child: Text(
                    '⚠ EXTRA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              if (isTomorrow)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1), // light teal
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF00796B), width: 1),
                  ),
                  child: Text(
                    'MAÑANA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF004D40),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              if (isRescheduled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Reprogramada',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ),
              if (time.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Client / placa info
          if (clientName.isNotEmpty || placa.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                [
                  clientName,
                  if (placa.isNotEmpty) placa,
                ].where((s) => s.isNotEmpty).join(' \u00b7 '),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF002B4B),
                ),
              ),
            ),

          // Address
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 2),
              child: Text(
                address,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF002B4B).withValues(alpha: 0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Date
          if (scheduledDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Text(
                scheduledDate,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF99AAB7),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Action button — shown for all except rescheduled and missed
          if (!isRescheduled && !isMissed)
            SizedBox(
              width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (isInProgress) {
                  _navigateToTask(task);
                } else {
                  _onStartTask(task);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: isInProgress
                    ? const Color(0xFF002B4B)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _startingTaskIds.contains(task['id'])
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        if (!isInProgress) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            size: 20,
                          ),
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
