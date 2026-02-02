import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/theme_toggle.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedClass = 'Class 10 A';
  DateTime selectedDate = DateTime(2026, 1, 22);

  List<Map<String, dynamic>> students = [
    {'name': 'Aarav Sharma', 'id': 'ID: 0001', 'present': true},
    {'name': 'Priya Singh', 'id': 'ID: 0002', 'present': true},
    {'name': 'Rahul Kumar', 'id': 'ID: 0003', 'present': false},
    {'name': 'Sneha Gupta', 'id': 'ID: 0004', 'present': true},
    {'name': 'Amit Patel', 'id': 'ID: 0005', 'present': false},
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveHelper.fromWidth(constraints.maxWidth);
        final bool isWide = responsive.isDesktop;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectCard(isWide),
                    const SizedBox(height: 16),
                    _buildStudentCard(),
                    const SizedBox(height: 24),
                    _buildBottomActions(isWide),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 1,
      title: const Text('Attendance'),
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

  // ---------------- SELECT CARD ----------------

  Widget _buildSelectCard(bool isWide) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _classDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _datePicker()),
                ],
              )
            : Column(
                children: [
                  _classDropdown(),
                  const SizedBox(height: 12),
                  _datePicker(),
                ],
              ),
      ),
    );
  }

  Widget _classDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            initialValue: selectedClass,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              'Class 10 A',
              'Class 10 B',
              'Class 9 A',
            ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (val) => setState(() => selectedClass = val!),
          ),
        ),
      ],
    );
  }

  Widget _datePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) setState(() => selectedDate = date);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
                isDense: true,
              ),
              child: Text(
                '${selectedDate.day} ${_month(selectedDate.month)}, ${selectedDate.year}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- STUDENT LIST ----------------

  Widget _buildStudentCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Mark students as Present or Absent for the selected class and date.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            ...students.map(_studentTile),
          ],
        ),
      ),
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  student['id'],
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            student['present'] ? 'Present' : 'Absent',
            style: TextStyle(
              color: student['present'] ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: student['present'],
            activeThumbColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                final index = students.indexWhere(
                  (s) => s['id'] == student['id'],
                );
                if (index != -1) {
                  students[index] = {...students[index], 'present': val};
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // ---------------- ACTION BUTTONS ----------------

  Widget _buildBottomActions(bool isWide) {
    return Row(
      mainAxisAlignment: isWide
          ? MainAxisAlignment.end
          : MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              students = students.map((s) => {...s, 'present': true}).toList();
            });
          },
          child: const Text('Mark All Present'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.primaryDark
                : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          onPressed: () {},
          child: const Text('Save Attendance'),
        ),
      ],
    );
  }

  String _month(int m) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}
