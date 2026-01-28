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

  PopupMenuItem<void> _buildMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<void>(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive ? Colors.red : AppColors.textDark,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.red : AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

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

        actions: isMobile
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.textDark,
                    size: 26,
                  ),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 60, 16, 0),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      items: <PopupMenuEntry<void>>[
                        _buildMenuItem(
                          icon: Icons.dashboard,
                          label: 'Dashboard',
                        ),
                        _buildMenuItem(
                          icon: Icons.check_circle_outline,
                          label: 'Attendance',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed('/attendance');
                          },
                        ),
                        _buildMenuItem(icon: Icons.groups, label: 'Students'),
                        _buildMenuItem(icon: Icons.bar_chart, label: 'Reports'),
                        const PopupMenuDivider(),
                        _buildMenuItem(
                          icon: Icons.logout,
                          label: 'Logout',
                          isDestructive: true,
                          onTap: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            _logout();
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: 8),
              ]
            : [
                const _NavItem(title: 'Dashboard', selected: true),
                _NavItem(
                  title: 'Attendance',
                  onTap: () => Navigator.of(context).pushNamed('/attendance'),
                ),
                const _NavItem(title: 'Students'),
                const _NavItem(title: 'Reports'),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.textDark),
                  onPressed: _logout,
                ),
                const SizedBox(width: 12),
              ],
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
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
              childAspectRatio: isMobile ? 2.5 : 2.8,
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
              childAspectRatio: isMobile ? 3 : 3.5,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ActionCard(
                  title: 'Mark Attendance',
                  icon: Icons.calendar_today,
                ),
                _ActionCard(title: 'Add Student', icon: Icons.person_add),
                _ActionCard(title: 'View Reports', icon: Icons.description),
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
  final VoidCallback? onTap;

  const _NavItem({required this.title, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textDark,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
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
              textAlign: TextAlign.center,
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
