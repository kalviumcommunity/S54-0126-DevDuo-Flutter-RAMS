import 'package:flutter/material.dart';
import '../../../auth_service.dart';
import '../../../services/student_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/theme_toggle.dart';

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
            color: isDestructive
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDestructive
                  ? Colors.red
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.school, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'RAMS',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: isMobile
            ? [
                const ThemeToggleButton(),
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                    size: 26,
                  ),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(100, 60, 16, 0),
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      items: <PopupMenuEntry<void>>[
                        _buildMenuItem(
                          icon: Icons.check_circle_outline,
                          label: 'Attendance',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed('/attendance');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.groups,
                          label: 'Students',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed('/students');
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.bar_chart,
                          label: 'Reports',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed('/reports');
                          },
                        ),
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
                _NavItem(
                  title: 'Students',
                  onTap: () => Navigator.of(context).pushNamed('/students'),
                ),
                _NavItem(
                  title: 'Reports',
                  onTap: () => Navigator.of(context).pushNamed('/reports'),
                ),
                const SizedBox(width: 16),
                const ThemeToggleButton(),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Icons.person, size: 18),
                ),
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
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
            // ----------- STAT CARDS -----------
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.5 : 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(
                  title: 'Total Students',
                  valueWidget: StreamBuilder<int>(
                    stream: StudentService().studentsStream().map(
                      (list) => list.length,
                    ),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const SizedBox(
                          width: 60,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Text(
                        '${snap.data}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  icon: Icons.groups,
                ),
                _StatCard(
                  title: "Today's Attendance",
                  valueWidget: StreamBuilder<double>(
                    stream: StudentService().attendancePercentForToday(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const SizedBox(
                          width: 60,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      return Text(
                        '${snap.data!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  icon: Icons.check_circle,
                ),
                const _StatCard(
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
              children: [
                _ActionCard(
                  title: 'Mark Attendance',
                  icon: Icons.calendar_today,
                  onTap: () {
                    Navigator.of(context).pushNamed('/attendance');
                  },
                ),
                _ActionCard(
                  title: 'Add Student',
                  icon: Icons.person_add,
                  onTap: () {
                    Navigator.of(context).pushNamed('/add-student');
                  },
                ),
                const _ActionCard(
                  title: 'View Reports',
                  icon: Icons.description,
                ),
              ],
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                '© 2026 RAMS. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
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
            color: selected
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyLarge?.color,
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
  final String? value;
  final Widget? valueWidget;
  final IconData icon;

  const _StatCard({
    required this.title,
    this.value,
    this.valueWidget,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                valueWidget ??
                    Text(
                      value ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
  final VoidCallback? onTap;

  const _ActionCard({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.primary,
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
      ),
    );
  }
}
