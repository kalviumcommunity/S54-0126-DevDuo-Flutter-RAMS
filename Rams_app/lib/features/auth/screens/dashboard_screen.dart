import 'package:flutter/material.dart';
import '../../../auth_service.dart';
import '../../../services/student_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/widgets.dart';

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
                ? AppColors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              color: isDestructive
                  ? AppColors.red
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
                        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  radius: AppSpacing.lg,
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
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------- STAT CARDS -----------
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: isMobile ? 2.5 : 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StatCard(
                  title: 'Total Students',
                  icon: Icons.groups,
                  isCompact: true,
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
                ),
                StatCard(
                  title: "Today's Attendance",
                  icon: Icons.check_circle,
                  isCompact: true,
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
                ),
                const StatCard(
                  title: 'Performance Alerts',
                  value: '5 Students',
                  icon: Icons.warning,
                  isCompact: true,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ----------- ACTION BUTTONS -----------
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: isMobile ? 3 : 3.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                CustomButton(
                  text: 'Mark Attendance',
                  icon: Icons.calendar_today,
                  type: ButtonType.action,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/attendance');
                  },
                ),
                CustomButton(
                  text: 'Add Student',
                  icon: Icons.person_add,
                  type: ButtonType.action,
                  onPressed: () {
                    Navigator.of(context).pushNamed('/add-student');
                  },
                ),
                CustomButton(
                  text: 'View Reports',
                  icon: Icons.description,
                  type: ButtonType.action,
                  onPressed: () {},
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

// Navigation item widget for desktop/tablet AppBar
class _NavItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const _NavItem({required this.title, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? AppColors.primary
                : Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
