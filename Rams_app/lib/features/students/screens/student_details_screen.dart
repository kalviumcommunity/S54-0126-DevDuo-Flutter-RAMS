import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/widgets/theme_toggle.dart';

class StudentDetailsScreen extends StatelessWidget {
  const StudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? student =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

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
                    : isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _leftColumn(context, student)),
                              const SizedBox(width: 16),
                              Expanded(flex: 1, child: _rightColumn(context, student)),
                            ],
                          )
                        : Column(
                            children: [
                              _leftColumn(context, student),
                              const SizedBox(height: 16),
                              _rightColumn(context, student),
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

  Widget _leftColumn(BuildContext context, Map<String, dynamic> student) {
    return Column(
      children: [
        _studentHeader(context, student),
        const SizedBox(height: 16),
        _subjectMarksCard(context, student),
        const SizedBox(height: 16),
        _progressChartCard(context),
      ],
    );
  }

  Widget _studentHeader(BuildContext context, Map<String, dynamic> student) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // ---------------- SUBJECT MARKS ----------------

  Widget _subjectMarksCard(BuildContext context, Map<String, dynamic> student) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Subject Marks', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(flex: 3, child: _Header('SUBJECT')),
                Expanded(flex: 2, child: _Header('MARKS')),
                Expanded(flex: 2, child: _Header('STATUS')),
                SizedBox(width: 40),
              ],
            ),
            const Divider(),
            ..._subjects.map((s) => _subjectRow(context, student, s)),
          ],
        ),
      ),
    );
  }

  Widget _subjectRow(
    BuildContext context,
    Map<String, dynamic> student,
    Map<String, dynamic> s,
  ) {
    final Color c = s['status'] == 'Pass'
        ? Colors.green
        : s['status'] == 'Fail'
            ? Colors.red
            : Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(s['subject'])),
          Expanded(flex: 2, child: Text(s['marks'])),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                s['status'],
                style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Add Marks',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/add-marks',
                arguments: {
                  'student': student,
                  'subject': s['subject'],
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS CHART ----------------

  Widget _progressChartCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Academic Progress Over Time',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              width: double.infinity,
              child: CustomPaint(painter: _AcademicChartPainter(context)),
            ),
            const SizedBox(height: 12),
            _legend(),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendDot(color: Colors.orange, label: 'Mathematics'),
        SizedBox(width: 16),
        _LegendDot(color: Colors.teal, label: 'Science'),
        SizedBox(width: 16),
        _LegendDot(color: Colors.blueGrey, label: 'English'),
      ],
    );
  }

  // ---------------- RIGHT COLUMN ----------------

  Widget _rightColumn(BuildContext context, Map<String, dynamic> student) {
    return Column(
      children: [
        _statCard('Attendance Percentage', '85%', context),
        const SizedBox(height: 16),
        _statCard('Overall Grade Average', '85%', context),
        const SizedBox(height: 16),
        _button('Edit Student Profile', Icons.edit, false, context),
        const SizedBox(height: 10),
        _button('View Full Attendance Record', Icons.visibility, true, context),
      ],
    );
  }

  Widget _statCard(String title, String value, BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryDark
                  : AppColors.primary,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _button(String text, IconData icon, bool outlined, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(onPressed: () {}, icon: Icon(icon), label: Text(text))
          : ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(icon),
              label: Text(text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primaryDark
                    : AppColors.primary,
              ),
            ),
    );
  }
}

// ---------------- DATA ----------------

final List<Map<String, dynamic>> _subjects = [
  {'subject': 'Mathematics', 'marks': '88/100', 'status': 'Pass'},
  {'subject': 'Science', 'marks': '92/100', 'status': 'Pass'},
  {'subject': 'English', 'marks': '75/100', 'status': 'Improvement Needed'},
  {'subject': 'History', 'marks': '62/100', 'status': 'Fail'},
  {'subject': 'Computer', 'marks': '99/100', 'status': 'Pass'},
];

// ---------------- HELPERS ----------------

class _Header extends StatelessWidget {
  final String text;
  const _Header(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

// ---------------- CHART PAINTER ----------------

class _AcademicChartPainter extends CustomPainter {
  final BuildContext context;
  _AcademicChartPainter(this.context);

  final List<double> math = [78, 82, 85, 88];
  final List<double> science = [81, 85, 88, 92];
  final List<double> english = [70, 72, 74, 76];

  final List<int> yAxis = [70, 76, 82, 88, 94];
  final List<String> xAxis = ['Jan', 'Feb', 'Mar', 'Apr'];

  @override
  void paint(Canvas canvas, Size size) {
    final double leftPad = 36;
    final double bottomPad = 28;
    final double topPad = 8;

    final chartHeight = size.height - bottomPad - topPad;
    final chartWidth = size.width - leftPad;

    final gridPaint = Paint()
      ..color = Theme.of(context).dividerColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 0; i < yAxis.length; i++) {
      final y = topPad + chartHeight * (i / (yAxis.length - 1));
      _drawDashedLine(canvas, Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    _drawLine(canvas, math, Colors.orange, chartWidth, chartHeight, leftPad, topPad);
    _drawLine(canvas, science, Colors.teal, chartWidth, chartHeight, leftPad, topPad);
    _drawLine(canvas, english, Colors.blueGrey, chartWidth, chartHeight, leftPad, topPad);
  }

  void _drawLine(Canvas canvas, List<double> values, Color color, double width,
      double height, double left, double top) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = left + width * (i / (values.length - 1));
      final y = top + height * (1 - (values[i] - 70) / 24);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }

    canvas.drawPath(path, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4;
    const dashSpace = 4;
    double dx = start.dx;

    while (dx < end.dx) {
      canvas.drawLine(Offset(dx, start.dy), Offset(dx + dashWidth, start.dy), paint);
      dx += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
