import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import '../../../history/presentation/pages/history_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/custom_app_bar.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';

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
