import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/student_service.dart';
import '../../../models/student.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedClass = 'All Classes';
  String? selectedSubject;
  DateTime selectedDate = DateTime.now();

  final List<String> subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer',
  ];

  final StudentService _studentService = StudentService();

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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelectCard(isWide),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStudentCard(),
                    const SizedBox(height: AppSpacing.xxl),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _classDropdown()),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _subjectDropdown()),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _datePicker()),
                ],
              )
            : Column(
                children: [
                  _classDropdown(),
                  const SizedBox(height: AppSpacing.md),
                  _subjectDropdown(),
                  const SizedBox(height: AppSpacing.md),
                  _datePicker(),
                ],
              ),
      ),
    );
  }

  Widget _subjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Subject',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            initialValue: selectedSubject,
            hint: const Text('Select Subject'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => selectedSubject = val),
          ),
        ),
      ],
    );
  }

  Widget _classDropdown() {
    return StreamBuilder<List<Student>>(
      stream: _studentService.studentsStream(),
      builder: (context, snapshot) {
        // Extract unique classes from students
        final uniqueClasses = <String>{'All Classes'};
        if (snapshot.hasData) {
          for (final student in snapshot.data!) {
            if (student.klass.isNotEmpty) {
              uniqueClasses.add(student.klass);
            }
          }
        }

        // Convert to sorted list (All Classes first, then alphabetically)
        final classList = uniqueClasses.toList();
        final allClassesItem = classList.removeAt(0); // Remove 'All Classes'
        classList.sort(); // Sort remaining classes
        classList.insert(0, allClassesItem); // Put 'All Classes' back at start

        // Ensure selectedClass is valid, reset to 'All Classes' if not
        if (!classList.contains(selectedClass)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => selectedClass = 'All Classes');
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Class', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                initialValue: classList.contains(selectedClass)
                    ? selectedClass
                    : 'All Classes',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: classList
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => selectedClass = val!),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _datePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
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
    return StreamBuilder<List<Student>>(
      stream: _studentService.studentsStream(
        klass: selectedClass == 'All Classes' ? null : selectedClass,
      ),
      builder: (context, studentsSnap) {
        final isLoadingStudents = !studentsSnap.hasData;
        final students = studentsSnap.data ?? [];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Mark students as Present or Absent for the selected class and date.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isLoadingStudents)
                  const LoadingIndicator()
                else if (selectedSubject == null)
                  const EmptyState(
                    icon: Icons.subject,
                    title: 'Select a subject',
                    message:
                        'Please select a subject to view or mark attendance',
                  )
                else
                  StreamBuilder<Map<String, bool>>(
                    stream: _studentService.attendanceStreamForDate(
                      selectedDate,
                      selectedClass == 'All Classes' ? null : selectedClass,
                      selectedSubject,
                    ),
                    builder: (context, attSnap) {
                      if (attSnap.hasError) {
                        return const Center(
                          child: Text('Failed to load attendance data.'),
                        );
                      }
                      if (!attSnap.hasData) {
                        return const LoadingIndicator();
                      }
                      final attendance = attSnap.data ?? {};

                      final combined = students
                          .map(
                            (s) => {
                              'name': s.name,
                              'id': s.studentId.isNotEmpty ? s.studentId : s.id,
                              'docId': s.id,
                              'class': s.klass,
                              'present': attendance[s.id] ?? false,
                              'enabled': selectedSubject != null,
                            },
                          )
                          .toList();

                      if (combined.isEmpty) {
                        return const EmptyState(
                          icon: Icons.people_outline,
                          title: 'No students found',
                          message: 'No students found for this class.',
                        );
                      }

                      return Column(
                        children: combined.map(_studentTile).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, child: Icon(Icons.person)),
          const SizedBox(width: AppSpacing.md),
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
              color: student['present'] ? AppColors.green : AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: student['present'],
            activeThumbColor: AppColors.primary,
            onChanged: student['enabled']
                ? (val) async {
                    // Persist change to Firestore; UI will update via streams
                    try {
                      await _studentService.toggleAttendance(
                        studentId: student['docId'],
                        date: selectedDate,
                        klass: student['class'], // Use student's actual class
                        subject: selectedSubject!,
                        present: val,
                      );
                    } catch (e) {
                      // show a simple feedback if something fails
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to save attendance'),
                        ),
                      );
                    }
                  }
                : null,
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppColors.primaryDark
                : AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: 14,
            ),
          ),
          onPressed: selectedSubject == null
              ? null
              : () async {
                  // Fetch latest students for the selected class and mark them present
                  final students = await _studentService
                      .studentsStream(
                        klass: selectedClass == 'All Classes'
                            ? null
                            : selectedClass,
                      )
                      .first;
                  final futures = students.map(
                    (s) => _studentService.toggleAttendance(
                      studentId: s.id,
                      date: selectedDate,
                      klass: s.klass, // Use student's actual class
                      subject: selectedSubject!,
                      present: true,
                    ),
                  );

                  try {
                    await Future.wait(futures);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All students marked present.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to mark all students present.'),
                        ),
                      );
                    }
                  }
                },
          child: const Text('Mark All Present'),
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
