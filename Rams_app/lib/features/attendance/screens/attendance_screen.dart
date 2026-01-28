import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedClass = 'Class 10 A';
  DateTime selectedDate = DateTime(2026, 1, 22);

  final List<Map<String, dynamic>> students = [
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
        final bool isWide = constraints.maxWidth >= 900;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7F9),
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
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textDark,
      elevation: 1,
      title: const Text('Attendance'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/dashboard'),
      ),
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
            value: selectedClass,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: ['Class 10 A', 'Class 10 B', 'Class 9 A']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
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
            const Text(
              'Mark students as Present or Absent for the selected class and date.',
              style: TextStyle(color: Colors.grey),
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
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            child: Icon(Icons.person),
          ),
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
                  style: const TextStyle(
                    color: Colors.grey,
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
            activeColor: AppColors.primary,
            onChanged: (val) =>
                setState(() => student['present'] = val),
          ),
        ],
      ),
    );
  }

  // ---------------- ACTION BUTTONS ----------------

  Widget _buildBottomActions(bool isWide) {
    return Row(
      mainAxisAlignment:
          isWide ? MainAxisAlignment.end : MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () {
            for (var s in students) {
              s['present'] = true;
            }
            setState(() {});
          },
          child: const Text('Mark All Present'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          onPressed: () {},
          child: const Text('Save Attendance'),
        ),
      ],
    );
  }

  String _month(int m) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}
