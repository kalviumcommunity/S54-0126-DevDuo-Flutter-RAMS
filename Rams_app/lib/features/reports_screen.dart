import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/helpers/responsive_helper.dart';
import '../core/widgets/theme_toggle.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title(context, isMobile),
            const SizedBox(height: 20),
            _filtersCard(context),
            const SizedBox(height: 24),
            _statsGrid(context),
            const SizedBox(height: 24),
            _alertsAndActions(context),
            const SizedBox(height: 40),
            _footer(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      title: const Text('Reports'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/dashboard'),
      ),
      actions: const [
        SizedBox(width: 4),
        ThemeToggleButton(),
        SizedBox(width: 8),
      ],
    );
  }

  // ───────────────── Title ─────────────────
  Widget _title(BuildContext context, bool isMobile) {
    return Text(
      "Reports & Analytics",
      style: TextStyle(
        fontSize: isMobile ? 20 : 26,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  // ───────────────── Filters ─────────────────
  Widget _filtersCard(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isWide = responsive.isDesktop;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Filter Reports",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            if (isWide)
              Row(
                children: [
                  _dropdown(context, "Class", "Class 10A"),
                  const SizedBox(width: 12),
                  _dateField(context, "From Date", "2023-01-01"),
                  const SizedBox(width: 12),
                  _dateField(context, "To Date", "2023-01-31"),
                  const SizedBox(width: 12),
                  _dropdown(context, "Student", "Select Student"),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? AppColors.primaryDark
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Generate Report"),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _dropdownMobile(context, "Class", "Class 10A"),
                  const SizedBox(height: 12),
                  _dateFieldMobile(context, "From Date", "2023-01-01"),
                  const SizedBox(height: 12),
                  _dateFieldMobile(context, "To Date", "2023-01-31"),
                  const SizedBox(height: 12),
                  _dropdownMobile(context, "Student", "Select Student"),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Generate Report"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _dropdown(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).cardColor,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile versions without Expanded wrapper
  Widget _dropdownMobile(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateFieldMobile(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────── Stats ─────────────────
  Widget _statsGrid(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final crossAxisCount = responsive.isMobile
        ? 1
        : (responsive.isTablet ? 2 : 4);

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: responsive.isMobile ? 2.5 : 2.2,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(
          context,
          "Overall Attendance Rate",
          "85%",
          Icons.calendar_today,
        ),
        _statCard(context, "Total Classes Conducted", "120", Icons.menu_book),
        _statCard(context, "Total Students Present", "780", Icons.group),
        _statCard(context, "Total Students Absent", "140", Icons.person_off),
      ],
    );
  }

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.primaryDark
                : AppColors.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Alerts + Actions ─────────────────
  Widget _alertsAndActions(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isWide = responsive.isDesktop;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _lowAttendanceCard(context)),
          const SizedBox(width: 20),
          Column(
            children: [
              _actionButton(
                context,
                "Export PDF",
                Icons.picture_as_pdf,
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDark
                    : AppColors.primary,
              ),
              const SizedBox(height: 12),
              _actionButton(context, "Print Report", Icons.print, Colors.green),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _lowAttendanceCard(context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  context,
                  "Export PDF",
                  Icons.picture_as_pdf,
                  Theme.of(context).brightness == Brightness.dark
                      ? AppColors.primaryDark
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  context,
                  "Print Report",
                  Icons.print,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _lowAttendanceCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.errorDark
                      : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  "Low Attendance Alerts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _alertRow(context, "Priya Sharma", "68%"),
            _alertRow(context, "Rohan Mehta", "72%"),
            _alertRow(context, "Amit Kumar", "70%"),
            _alertRow(context, "Ananya Das", "74%"),
          ],
        ),
      ),
    );
  }

  Widget _alertRow(BuildContext context, String name, String percent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.errorDark.withValues(alpha: 0.2)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              percent,
              style: TextStyle(
                color: isDark ? AppColors.errorDark : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    final responsive = ResponsiveHelper(context);
    final isWide = responsive.isDesktop;

    return SizedBox(
      width: isWide ? 200 : null,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 16 : 12,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ───────────────── Footer ─────────────────
  Widget _footer(BuildContext context) {
    return Center(
      child: Text(
        '© 2026 RAMS. All rights reserved.',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}
