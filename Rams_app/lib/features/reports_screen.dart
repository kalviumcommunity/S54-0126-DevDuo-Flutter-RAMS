import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../core/constants/app_colors.dart';
import '../core/helpers/responsive_helper.dart';
import '../core/helpers/validation_helper.dart';
import '../core/widgets/theme_toggle.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? fromDate;
  String? toDate;
  String? selectedClass;
  String? selectedStudent;

  // ───────────────── PDF GENERATION ─────────────────
  Future<void> _exportPdf(BuildContext context) async {
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
                pw.Text("Overall Attendance Rate: 85%"),
                pw.Text("Total Classes Conducted: 120"),
                pw.Text("Total Students Present: 780"),
                pw.Text("Total Students Absent: 140"),
                pw.SizedBox(height: 20),
                pw.Text(
                  "Low Attendance Alerts",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text("Priya Sharma - 68%"),
                pw.Text("Rohan Mehta - 72%"),
                pw.Text("Amit Kumar - 70%"),
                pw.Text("Ananya Das - 74%"),
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
                  _dropdown(context, "Class", selectedClass ?? "Class 10A"),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _selectFromDate(context),
                    child: _dateField(
                      context,
                      "From Date",
                      fromDate ?? "Select Date",
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _selectToDate(context),
                    child: _dateField(
                      context,
                      "To Date",
                      toDate ?? "Select Date",
                    ),
                  ),
                  const SizedBox(width: 12),
                  _dropdown(
                    context,
                    "Student",
                    selectedStudent ?? "Select Student",
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _validateAndGenerateReport,
                    child: const Text("Generate Report"),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _dropdownMobile(
                    context,
                    "Class",
                    selectedClass ?? "Class 10A",
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _selectFromDate(context),
                    child: _dateFieldMobile(
                      context,
                      "From Date",
                      fromDate ?? "Select Date",
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _selectToDate(context),
                    child: _dateFieldMobile(
                      context,
                      "To Date",
                      toDate ?? "Select Date",
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dropdownMobile(
                    context,
                    "Student",
                    selectedStudent ?? "Select Student",
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _validateAndGenerateReport,
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

  Future<void> _selectFromDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        fromDate = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        toDate = "${date.day}/${date.month}/${date.year}";
      });
    }
  }

  void _validateAndGenerateReport() {
    // Validate that at least one filter is selected
    if (fromDate == null &&
        toDate == null &&
        selectedClass == null &&
        selectedStudent == null) {
      _showError('Please select at least one filter');
      return;
    }

    // Validate date range if both dates are provided
    if (fromDate != null && toDate != null) {
      final error = ValidationHelper.validateDateRange(
        fromDate,
        toDate,
        fromLabel: 'From Date',
        toLabel: 'To Date',
      );
      if (error != null) {
        _showError(error);
        return;
      }
    }

    // If all validation passes, generate report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report generated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _dropdown(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(value)),
                const Icon(Icons.keyboard_arrow_down),
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
          Text(label),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(alignment: Alignment.centerLeft, child: Text(value)),
          ),
        ],
      ),
    );
  }

  Widget _dropdownMobile(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value)),
              const Icon(Icons.keyboard_arrow_down),
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
        Text(label),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Align(alignment: Alignment.centerLeft, child: Text(value)),
        ),
      ],
    );
  }

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
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(context, "Overall Attendance Rate", "85%"),
        _statCard(context, "Total Classes Conducted", "120"),
        _statCard(context, "Total Students Present", "780"),
        _statCard(context, "Total Students Absent", "140"),
      ],
    );
  }

  Widget _statCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title.toUpperCase(), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

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
                onPressed: () => _exportPdf(context),
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
                  onPressed: () => _exportPdf(context),
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

  Widget _lowAttendanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Low Attendance Alerts"),
            SizedBox(height: 16),
            Text("Priya Sharma - 68%"),
            Text("Rohan Mehta - 72%"),
            Text("Amit Kumar - 70%"),
            Text("Ananya Das - 74%"),
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
