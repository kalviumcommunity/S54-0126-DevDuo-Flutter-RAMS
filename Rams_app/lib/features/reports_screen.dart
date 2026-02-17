import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../core/constants/app_colors.dart';
import '../core/helpers/responsive_helper.dart';
import '../core/widgets/widgets.dart';
import '../services/student_service.dart';
import '../models/student.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String selectedClass = 'All Classes';
  String? selectedStudent;

  final StudentService _studentService = StudentService();

  // ───────────────── PDF GENERATION ─────────────────
  Future<void> _exportPdf(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "RAMS Report",
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Overall Attendance Rate: ${data['attendanceRate'].toStringAsFixed(1)}%",
                ),
                pw.Text("Total Classes Conducted: ${data['totalClasses']}"),
                pw.Text("Total Students Present: ${data['presentCount']}"),
                pw.Text("Total Students Absent: ${data['absentCount']}"),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Low Attendance Alerts",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                ...(data['lowAttendanceAlerts'] as List).map(
                  (alert) => pw.Text("${alert['name']} - ${alert['rate']}%"),
                ),
              ],
            );
          },
        ),
      );

      Uint8List bytes = await pdf.save();

      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory =
            await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      }

      final file = File("${directory.path}/RAMS_Report.pdf");
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("PDF downloaded to: ${file.path}")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to export PDF")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _studentService.reportsSummaryStream(
          klass: selectedClass,
          fromDate: fromDate,
          toDate: toDate,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load report data. Please try again.'),
            );
          }
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _title(context, isMobile),
                    const SizedBox(height: 20),
                    _filtersCard(context),
                    const SizedBox(height: 24),
                    if (data['totalClasses'] == 0)
                      const EmptyState(
                        icon: Icons.analytics_outlined,
                        title: 'No data available',
                        message:
                            'No attendance records found for the selected filters.',
                      )
                    else ...[
                      _statsGrid(context, data),
                      const SizedBox(height: 24),
                      _alertsAndActions(context, data),
                    ],
                    const SizedBox(height: 40),
                    _footer(context),
                  ],
                ),
              ),
            ),
          );
        },
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
                  Expanded(flex: 2, child: _classDropdown()),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _dateField(
                      context,
                      "From Date",
                      fromDate != null
                          ? "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}"
                          : "Select Date",
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _dateField(
                      context,
                      "To Date",
                      toDate != null
                          ? "${toDate!.day}/${toDate!.month}/${toDate!.year}"
                          : "Select Date",
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _studentDropdown()),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset Filters',
                  ),
                ],
              )
            else
              Column(
                children: [
                  _classDropdown(),
                  const SizedBox(height: 12),
                  _dateField(
                    context,
                    "From Date",
                    fromDate != null
                        ? "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}"
                        : "Select Date",
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 12),
                  _dateField(
                    context,
                    "To Date",
                    toDate != null
                        ? "${toDate!.day}/${toDate!.month}/${toDate!.year}"
                        : "Select Date",
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 12),
                  _studentDropdown(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Reset Filters"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _classDropdown() {
    return StreamBuilder<List<Student>>(
      stream: _studentService.studentsStream(),
      builder: (context, snapshot) {
        final uniqueClasses = <String>{'All Classes'};
        if (snapshot.hasData) {
          for (final student in snapshot.data!) {
            if (student.klass.isNotEmpty) {
              uniqueClasses.add(student.klass);
            }
          }
        }

        final classList = uniqueClasses.toList();
        final allClassesItem = classList.removeAt(0);
        classList.sort();
        classList.insert(0, allClassesItem);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Class", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedClass,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: classList
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedClass = val;
                    selectedStudent = null;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _studentDropdown() {
    return StreamBuilder<List<Student>>(
      stream: _studentService.studentsStream(klass: selectedClass),
      builder: (context, snapshot) {
        final List<Student> students = snapshot.data ?? [];

        final bool valid = students.any((s) => s.id == selectedStudent);
        final effectiveValue = valid ? selectedStudent : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Student", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              value: effectiveValue,
              hint: const Text("Select Student"),
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text("All Students"),
                ),
                ...students.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s.id,
                    child: Text(s.name),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => selectedStudent = val),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isFrom) {
          fromDate = date;
        } else {
          toDate = date;
        }
      });
    }
  }

  void _resetFilters() {
    setState(() {
      fromDate = null;
      toDate = null;
      selectedClass = 'All Classes';
      selectedStudent = null;
    });
  }

  Widget _dateField(
    BuildContext context,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(alignment: Alignment.centerLeft, child: Text(value)),
          ),
        ),
      ],
    );
  }

  Widget _statsGrid(BuildContext context, Map<String, dynamic> data) {
    final responsive = ResponsiveHelper(context);
    final crossAxisCount = responsive.isMobile
        ? 1
        : (responsive.isTablet ? 2 : 4);

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(
          context,
          "Overall Attendance Rate",
          "${data['attendanceRate'].toStringAsFixed(1)}%",
        ),
        _statCard(
          context,
          "Total Classes Conducted",
          "${data['totalClasses']}",
        ),
        _statCard(context, "Total Students Present", "${data['presentCount']}"),
        _statCard(context, "Total Students Absent", "${data['absentCount']}"),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value) {
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
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, letterSpacing: 1.2),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _alertsAndActions(BuildContext context, Map<String, dynamic> data) {
    final responsive = ResponsiveHelper(context);
    final isWide = responsive.isDesktop;

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _lowAttendanceCard(context, data)),
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
                onPressed: () => _exportPdf(context, data),
              ),
              const SizedBox(height: 12),
              _actionButton(
                context,
                "Print Report",
                Icons.print,
                Colors.green,
                onPressed: () {},
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _lowAttendanceCard(context, data),
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
                  onPressed: () => _exportPdf(context, data),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  context,
                  "Print Report",
                  Icons.print,
                  Colors.green,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _lowAttendanceCard(BuildContext context, Map<String, dynamic> data) {
    final alerts = data['lowAttendanceAlerts'] as List;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Low Attendance Alerts (< 75%)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              const Text("No student has low attendance in this range.")
            else
              ...alerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(alert['name']),
                      Text(
                        "${alert['rate']}%",
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color, {
    required VoidCallback onPressed,
  }) {
    final responsive = ResponsiveHelper(context);
    final isWide = responsive.isDesktop;

    return SizedBox(
      width: isWide ? 200 : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

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
