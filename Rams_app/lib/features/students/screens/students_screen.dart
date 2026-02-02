import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/theme_toggle.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String selectedClass = 'All Classes';
  String searchQuery = '';

  final List<Map<String, dynamic>> allStudents = [
    {'name': 'Aarav Sharma', 'id': 'ID: 0001', 'class': 'Class 10 A'},
    {'name': 'Priya Singh', 'id': 'ID: 0002', 'class': 'Class 10 A'},
    {'name': 'Rahul Kumar', 'id': 'ID: 0003', 'class': 'Class 10 B'},
    {'name': 'Sneha Gupta', 'id': 'ID: 0004', 'class': 'Class 10 A'},
    {'name': 'Amit Patel', 'id': 'ID: 0005', 'class': 'Class 9 A'},
    {'name': 'Neha Reddy', 'id': 'ID: 0006', 'class': 'Class 10 B'},
    {'name': 'Vikram Mehta', 'id': 'ID: 0007', 'class': 'Class 9 A'},
    {'name': 'Ananya Iyer', 'id': 'ID: 0008', 'class': 'Class 10 A'},
    {'name': 'Rohan Desai', 'id': 'ID: 0009', 'class': 'Class 10 B'},
    {'name': 'Kavya Nair', 'id': 'ID: 0010', 'class': 'Class 9 A'},
    {'name': 'Arjun Kapoor', 'id': 'ID: 0011', 'class': 'Class 10 A'},
    {'name': 'Diya Malhotra', 'id': 'ID: 0012', 'class': 'Class 10 B'},
    {'name': 'Karan Verma', 'id': 'ID: 0013', 'class': 'Class 9 A'},
    {'name': 'Ishita Joshi', 'id': 'ID: 0014', 'class': 'Class 10 A'},
    {'name': 'Sravan Teja', 'id': 'ID: 0015', 'class': 'Class 10 B'},
  ];

  List<Map<String, dynamic>> get filteredStudents {
    return allStudents.where((student) {
      final matchesClass =
          selectedClass == 'All Classes' || student['class'] == selectedClass;
      final matchesSearch = student['name'].toString().toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return matchesClass && matchesSearch;
    }).toList();
  }

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
                    _buildFilterCard(isWide),
                    const SizedBox(height: 16),
                    _buildStudentListCard(),
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
      // use AppBarTheme from ThemeData for colors
      elevation: 1,
      title: const Text('Students'),
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

  // ---------------- FILTER CARD ----------------

  Widget _buildFilterCard(bool isWide) {
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
                  Expanded(child: _searchBar()),
                ],
              )
            : Column(
                children: [
                  _classDropdown(),
                  const SizedBox(height: 12),
                  _searchBar(),
                ],
              ),
      ),
    );
  }

  Widget _classDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Class',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
              'All Classes',
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

  Widget _searchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Students',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            hintText: 'Search by name...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => searchQuery = value),
        ),
      ],
    );
  }

  // ---------------- STUDENT LIST ----------------

  Widget _buildStudentListCard() {
    final students = filteredStudents;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Student List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${students.length} student${students.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Click on any student to view their details.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: 16),
            if (students.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'No students found',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...students.map(_studentTile),
          ],
        ),
      ),
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/student-details', arguments: student);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
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
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        student['id'],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          student['class'],
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}
