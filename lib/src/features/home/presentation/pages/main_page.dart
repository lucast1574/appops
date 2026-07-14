import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/custom_app_bar.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../../../../core/notifications/push_service.dart';
import '../../../../core/events/task_events.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Task flows for deep linking
import '../../../verification/presentation/pages/verification_page.dart';
import '../../../recovery/presentation/pages/recovery_page.dart';
import '../../../delivery/presentation/pages/delivery_page.dart';
import '../../../conversion/presentation/pages/conversion_page.dart';
import '../../../transfer/presentation/pages/transfer_page.dart';
import '../../../vehicle_verification/presentation/pages/vehicle_verification_page.dart';
import '../../../notary/presentation/pages/notary_page.dart';
import '../../../management/presentation/pages/management_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final Color _selectedColor = const Color(0xFF4FA4B5);
  final Color _unselectedColor = const Color(0xFFB3B3B3);
  final List<String> _titles = ['Inicio', 'Historial de tareas', 'Perfil'];
  final Color _headerColor = const Color(0xFF002B4B);
  final Color _dividerColor = const Color(0xFFD2DADF);

  final List<Widget> _pages = [
    const DashboardPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];
  StreamSubscription? _notifSubscription;

  @override
  void initState() {
    super.initState();
    _notifSubscription = PushService.instance.messages.listen(_handleMessage);
  }

  @override
  void dispose() {
    _notifSubscription?.cancel();
    super.dispose();
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final kind = data['kind']?.toString() ?? '';
    final taskId = int.tryParse(data['task_id']?.toString() ?? '');

    // ----------------------------------------------------------------
    // Silent / cache-invalidation events. These arrive as data-only
    // pushes from the backend (send_silent_refresh) OR as visible
    // pushes whose `kind` tells us the target task no longer exists.
    // In both cases we must:
    //   * NEVER try to deep-link into the task (it may be gone).
    //   * Drop any cached copy and tell the task-list pages to reload.
    // ----------------------------------------------------------------
    if (kind == 'task.deleted' || kind == 'task.refresh') {
      // Every task-list page owns its own TaskService instance and is
      // responsible for invalidating its own cache when it hears the
      // event on the bus (see DashboardPage._onTaskEvent).
      if (kind == 'task.deleted' && taskId != null) {
        TaskEventBus.instance.notifyDeleted(taskId, reason: kind);
      } else {
        TaskEventBus.instance.requestRefresh(
          taskId: taskId,
          reason: kind.isEmpty ? null : kind,
        );
      }
      return;
    }

    if (taskId == null) return;

    // Direct task deep-link
    final slug = data['task_type_slug']?.toString();
    if (slug == null) return;

    final taskMap = {
      'id': taskId,
      'type': {
        'slug': slug,
        'name': data['task_type_name'],
      },
      'scheduled_date': data['scheduled_date'],
      'start_time': data['start_time'],
      'address': data['address'],
      'placa': data['placa'],
      'client_name': data['client_name'],
      'is_extra': data['is_extra'] == 'true' || data['is_extra'] == true,
      'status': data['status'] ?? 'pending',
    };

    Widget? page;
    switch (slug) {
      case 'verificacion':
        page = VerificationPage(task: taskMap);
        break;
      case 'recupero':
        page = RecoveryPage(task: taskMap);
        break;
      case 'entrega':
        page = DeliveryPage(task: taskMap);
        break;
      case 'conversion':
        page = ConversionPage(task: taskMap);
        break;
      case 'traslado':
        page = TransferPage(task: taskMap);
        break;
      case 'verificar_vehiculo':
        page = VehicleVerificationPage(task: taskMap);
        break;
      case 'notaria':
        page = NotaryPage(task: taskMap);
        break;
      case 'gestiones':
        page = ManagementPage(task: taskMap);
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        showNotificationBell: _selectedIndex == 0,
        headerColor: _headerColor,
        dividerColor: _dividerColor,
        titleSize: _selectedIndex == 1 ? 16 : null,
        onNotificationTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
      ),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: _unselectedColor.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCustomNavItem('assets/home.svg', 'Inicio', 0),
                _buildCustomNavItem('assets/history.svg', 'Historial', 1),
                _buildCustomNavItem('assets/user.svg', 'Perfil', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem(String assetPath, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final Color color = isSelected ? _selectedColor : _unselectedColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          splashColor: _selectedColor.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(35),
          radius: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
