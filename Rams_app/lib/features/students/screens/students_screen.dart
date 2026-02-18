import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/student_service.dart';
import '../../../models/student.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String selectedClass = 'All Classes';
  String searchQuery = '';

  // Service for real data
  final _studentService = StudentService();

  // We will use a StreamBuilder in the UI to listen to students in real-time.
  // Filtering and searching is performed client-side against the streamed list.

  List<Map<String, dynamic>> _filterStudents(List<Student> students) {
    return students
        .map(
          (s) => {
            'name': s.name,
            'id': s.studentId.isNotEmpty ? s.studentId : s.id,
            'docId': s.id,
            'class': s.klass,
            'photoUrl': s.photoUrl,
          },
        )
        .where((student) {
          final matchesClass =
              selectedClass == 'All Classes' ||
              student['class'] == selectedClass;
          final matchesSearch = student['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
          return matchesClass && matchesSearch;
        })
        .toList();
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterCard(isWide),
                    const SizedBox(height: AppSpacing.lg),
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
                  Expanded(child: _searchBar()),
                ],
              )
            : Column(
                children: [
                  _classDropdown(),
                  const SizedBox(height: AppSpacing.md),
                  _searchBar(),
                ],
              ),
      ),
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
            const SectionHeader(
              title: 'Filter by Class',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
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

  Widget _searchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Search Students',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: AppSpacing.xs),
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
    return StreamBuilder<List<Student>>(
      stream: _studentService.studentsStream(klass: selectedClass),
      builder: (context, snapshot) {
        final students = snapshot.hasData
            ? _filterStudents(snapshot.data!)
            : <Map<String, dynamic>>[];

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Student List',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                const SizedBox(height: AppSpacing.lg),
                if (!snapshot.hasData)
                  const LoadingIndicator()
                else if (students.isEmpty)
                  const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No students found',
                    message: 'Try adjusting your filters or search query.',
                  )
                else
                  ...students.map(_studentTile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _studentTile(Map<String, dynamic> student) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/student-details', arguments: student);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.transparent),
        ),
        child: Row(
          children: [
            _buildStudentAvatar(student),
            const SizedBox(width: AppSpacing.md),
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
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.xs),
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

  Widget _buildStudentAvatar(Map<String, dynamic> student) {
    final photoUrl = student['photoUrl'] as String?;

    final hasImage = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary,
      backgroundImage: hasImage ? NetworkImage(photoUrl) : null,
      onBackgroundImageError: hasImage
          ? (exception, stackTrace) {
              debugPrint('Failed to load student profile image: $exception');
            }
          : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, color: AppColors.white, size: 20),
    );
  }
}
