import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/student_service.dart';
import '../../../models/marks.dart';

class StudentDetailsScreen extends StatelessWidget {
  StudentDetailsScreen({super.key});

  final StudentService _studentService = StudentService();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? student =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String studentId = student?['docId'] ?? student?['id'] ?? '';

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
                constraints: const BoxConstraints(maxWidth: 1200),
                child: student == null
                    ? Center(
                        child: Text(
                          'No student selected',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    : StreamBuilder<List<Marks>>(
                        stream: _studentService.marksStreamForStudent(
                          studentId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final marksList = snapshot.data ?? [];

                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: _leftColumn(
                                        context,
                                        student,
                                        marksList,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      flex: 1,
                                      child: _rightColumn(
                                        context,
                                        student,
                                        marksList,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _leftColumn(context, student, marksList),
                                    const SizedBox(height: AppSpacing.lg),
                                    _rightColumn(context, student, marksList),
                                  ],
                                );
                        },
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Students'),
      actions: const [
        SizedBox(width: 4),
        ThemeToggleButton(),
        SizedBox(width: 8),
      ],
    );
  }

  // ---------------- LEFT COLUMN ----------------

  Widget _leftColumn(
    BuildContext context,
    Map<String, dynamic> student,
    List<Marks> marksList,
  ) {
    return Column(
      children: [
        _studentHeader(context, student),
        const SizedBox(height: AppSpacing.lg),
        _subjectMarksCard(context, student, marksList),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _studentHeader(BuildContext context, Map<String, dynamic> student) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            _buildStudentDetailsAvatar(student),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student ID: ${student['id'] ?? student['docId'] ?? ''}',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetailsAvatar(Map<String, dynamic> student) {
    final photoUrl = student['photoUrl'] as String?;
    final hasImage = photoUrl != null && photoUrl.isNotEmpty;

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary,
      backgroundImage: hasImage ? NetworkImage(photoUrl) : null,
      onBackgroundImageError: hasImage
          ? (exception, stackTrace) {
              debugPrint('Failed to load student profile image: $exception');
            }
          : null,
      child: hasImage ? null : const Icon(Icons.person, color: AppColors.white),
    );
  }

  // ---------------- SUBJECT MARKS ----------------

  Widget _subjectMarksCard(
    BuildContext context,
    Map<String, dynamic> student,
    List<Marks> marksList,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Subject Marks'),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: const [
                Expanded(flex: 3, child: _Header('SUBJECT')),
                Expanded(flex: 2, child: _Header('MARKS')),
                Expanded(flex: 2, child: _Header('STATUS')),
                SizedBox(width: 40),
              ],
            ),
            const Divider(),
            _buildMarksList(context, student, marksList),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksList(
    BuildContext context,
    Map<String, dynamic> student,
    List<Marks> marksList,
  ) {
    final allSubjects = _studentService.getSubjects();

    // Group by subject and take the latest one for each
    final Map<String, Marks> latestMarksBySubject = {};
    for (final m in marksList) {
      if (!latestMarksBySubject.containsKey(m.subject) ||
          m.examDate.isAfter(latestMarksBySubject[m.subject]!.examDate)) {
        latestMarksBySubject[m.subject] = m;
      }
    }

    return Column(
      children: allSubjects.map((subjectName) {
        final m = latestMarksBySubject[subjectName];
        return _subjectRow(context, student, subjectName, m);
      }).toList(),
    );
  }

  Widget _subjectRow(
    BuildContext context,
    Map<String, dynamic> student,
    String subjectName,
    Marks? m,
  ) {
    String marksText = '- / -';
    String status = 'No Data';

    if (m != null) {
      final double percent = (m.obtainedMarks / m.maxMarks) * 100;
      marksText = '${m.obtainedMarks.toInt()}/${m.maxMarks.toInt()}';
      status = percent >= 40 ? 'Pass' : 'Fail';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(subjectName)),
          Expanded(flex: 2, child: Text(marksText)),
          Expanded(
            flex: 2,
            child: m != null
                ? PassFailBadge(
                    isPass:
                        m.maxMarks > 0 &&
                        (m.obtainedMarks / m.maxMarks) * 100 >= 40,
                  )
                : const StatusBadge(
                    text: 'No Data',
                    status: BadgeStatus.neutral,
                  ),
          ),
          IconButton(
            tooltip: 'Add marks',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-marks',
                arguments: {'student': student, 'subject': subjectName},
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- RIGHT COLUMN ----------------

  Widget _rightColumn(
    BuildContext context,
    Map<String, dynamic> student,
    List<Marks> marksList,
  ) {
    final String studentId = student['docId'] ?? student['id'] ?? '';

    double avg = 0;
    if (marksList.isNotEmpty) {
      avg =
          marksList
              .map((m) => (m.obtainedMarks / m.maxMarks) * 100)
              .reduce((a, b) => a + b) /
          marksList.length;
    }

    return Column(
      children: [
        StreamBuilder<double>(
          stream: _studentService.attendancePercentStreamForStudent(studentId),
          builder: (context, snapshot) {
            final percent = snapshot.data ?? 0.0;
            return StatCard(
              title: 'Attendance Percentage',
              value: '${percent.toStringAsFixed(1)}%',
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        StatCard(
          title: 'Overall Grade Average',
          value: '${avg.toStringAsFixed(1)}%',
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomButton(
          text: 'Edit Student Profile',
          icon: Icons.edit,
          type: ButtonType.elevated,
          fullWidth: true,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          text: 'View Full Attendance Record',
          icon: Icons.visibility,
          type: ButtonType.outlined,
          fullWidth: true,
          onPressed: () {},
        ),
      ],
    );
  }

  // Removed _statCard and _button methods - now using reusable widgets
}

// ---------------- DATA ----------------

// ---------------- HELPERS ----------------

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ---------------- CHART PAINTER ----------------

class _AcademicChartPainter extends CustomPainter {
  final BuildContext context;
  final List<Marks> marks;
  _AcademicChartPainter(this.context, this.marks);

  @override
  void paint(Canvas canvas, Size size) {
    if (marks.isEmpty) return;

    final double leftPad = 36;
    final double bottomPad = 28;
    final double topPad = 8;

    final chartHeight = size.height - bottomPad - topPad;
    final chartWidth = size.width - leftPad;

    // Grid lines for 0, 20, 40, 60, 80, 100
    final gridPaint = Paint()
      ..color = Theme.of(context).dividerColor.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = topPad + chartHeight * (1 - (i * 20) / 100);
      _drawDashedLine(
        canvas,
        Offset(leftPad, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Group marks by subject
    final Map<String, List<Marks>> groupedMarks = {};
    for (final m in marks) {
      if (!groupedMarks.containsKey(m.subject)) groupedMarks[m.subject] = [];
      groupedMarks[m.subject]!.add(m);
    }

    final subjects = groupedMarks.keys.toList()..sort();
    final colors = [
      Colors.orange,
      Colors.teal,
      Colors.blueGrey,
      Colors.purple,
      Colors.indigo,
    ];

    // Find date range
    final sortedDates = marks.map((m) => m.examDate).toList()..sort();
    final minDate = sortedDates.first;
    final maxDate = sortedDates.last;
    final dateRange = maxDate.difference(minDate).inDays.toDouble();

    for (int i = 0; i < subjects.length; i++) {
      final subjectMarks = groupedMarks[subjects[i]]!
        ..sort((a, b) => a.examDate.compareTo(b.examDate));

      _drawLine(
        canvas,
        subjectMarks,
        colors[i % colors.length],
        chartWidth,
        chartHeight,
        leftPad,
        topPad,
        minDate,
        dateRange,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    List<Marks> values,
    Color color,
    double width,
    double height,
    double left,
    double top,
    DateTime minDate,
    double dateRange,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final m = values[i];
      final double normalizedValue = (m.obtainedMarks / m.maxMarks);

      // X calculation: normalize date relative to range
      double dx = 0;
      if (dateRange > 0) {
        dx = m.examDate.difference(minDate).inDays / dateRange;
      } else {
        // Only one date point or same day
        dx = 0.5; // Center it
      }

      final x = left + width * dx;
      final y = top + height * (1 - normalizedValue);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
    }

    if (values.length > 1) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4;
    const dashSpace = 4;
    double dx = start.dx;

    while (dx < end.dx) {
      canvas.drawLine(
        Offset(dx, start.dy),
        Offset(dx + dashWidth, start.dy),
        paint,
      );
      dx += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
