import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  String _getInitials() {
    if (_user == null) return '';
    final first = (_user!['first_name'] ?? '').toString();
    final last = (_user!['last_name'] ?? '').toString();
    String initials = '';
    if (first.isNotEmpty) initials += first[0];
    if (last.isNotEmpty) initials += last[0];
    return initials.toUpperCase();
  }

  String _getFullName() {
    if (_user == null) return '';
    return '${_user!['first_name'] ?? ''} ${_user!['last_name'] ?? ''}'.trim();
  }

  String _getEmail() {
    return _user?['email'] ?? '';
  }

  String? _getProfilePicture() {
    final pic = _user?['profile_picture'];
    if (pic != null && pic.toString().isNotEmpty) return pic.toString();
    return null;
  }

  String _getRoleName() {
    final role = _user?['role'];
    if (role == null) return 'Sin rol';
    return (role['name'] ?? '').toString();
  }

  String _getCountryCity() {
    final country = _user?['country'];
    final city = _user?['city'];
    String result = '';
    if (country != null) result = country['name'] ?? '';
    if (city != null) {
      if (result.isNotEmpty) result += ', ';
      result += city['name'] ?? '';
    }
    return result.isEmpty ? 'No asignado' : result;
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profilePic = _getProfilePicture();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: Column(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF002B4A),
                backgroundImage: profilePic != null
                    ? CachedNetworkImageProvider(profilePic)
                    : null,
                child: profilePic == null
                    ? Text(
                        _getInitials(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 20),

              // Name
              Text(
                _getFullName(),
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002B4A),
                ),
              ),
              const SizedBox(height: 6),

              // Email
              Text(
                _getEmail(),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF668093),
                ),
              ),
              const SizedBox(height: 32),

              // Info cards
              _buildInfoCard('Rol', _getRoleName(), Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildInfoCard('Ubicación', _getCountryCity(), Icons.location_on_outlined),
              const SizedBox(height: 40),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Cerrar Sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53935),
                    side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4FA4B5), size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF002B4A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
