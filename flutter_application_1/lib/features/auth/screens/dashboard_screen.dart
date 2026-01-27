import 'package:flutter/material.dart';
import '../../../auth_service.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: AppColors.background,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: const [
            Icon(Icons.school, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'RAMS',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          _NavItem(title: 'Dashboard', selected: true),
          _NavItem(title: 'Attendance'),
          _NavItem(title: 'Students'),
          _NavItem(title: 'Reports'),
          const SizedBox(width: 16),
          const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textDark),
            onPressed: _logout,
          ),
          const SizedBox(width: 12),
        ],
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),

            // ----------- STAT CARDS -----------
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StatCard(
                  title: 'Total Students',
                  value: '345',
                  icon: Icons.groups,
                ),
                _StatCard(
                  title: "Today's Attendance",
                  value: '92%',
                  icon: Icons.check_circle,
                ),
                _StatCard(
                  title: 'Performance Alerts',
                  value: '5 Students',
                  icon: Icons.warning,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ----------- ACTION BUTTONS -----------
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3.5,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ActionCard(
                  title: 'Mark Attendance',
                  icon: Icons.calendar_today,
                ),
                _ActionCard(
                  title: 'Add Student',
                  icon: Icons.person_add,
                ),
                _ActionCard(
                  title: 'View Reports',
                  icon: Icons.description,
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Center(
              child: Text(
                '© 2026 RAMS. All rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- NAV ITEM ----------------
class _NavItem extends StatelessWidget {
  final String title;
  final bool selected;

  const _NavItem({required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? AppColors.primary : AppColors.textDark,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// ---------------- STAT CARD ----------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------- ACTION CARD ----------------
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ActionCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
