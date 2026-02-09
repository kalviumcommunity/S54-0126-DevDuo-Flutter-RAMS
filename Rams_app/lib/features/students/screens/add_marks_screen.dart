import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';

class AddMarksScreen extends StatefulWidget {
  const AddMarksScreen({super.key});

  @override
  State<AddMarksScreen> createState() => _AddMarksScreenState();
}

class _AddMarksScreenState extends State<AddMarksScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _examDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<_MarksRow> _rows = [
    _MarksRow(),
    _MarksRow(),
  ];

  String _selectedClass = 'Grade 10 A';
  String _selectedSubject = 'Mathematics';
  String _selectedStudent = 'John Doe';

  @override
  void dispose() {
    _examDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExamDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _examDateController.text =
          '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Upload Marks'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topSelectors(isMobile),
                    const SizedBox(height: 20),
                    const Text(
                      'Marks Entry',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ..._rows.map((row) => _marksRow(row, isMobile)).toList(),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _rows.add(_MarksRow())),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Row'),
                    ),
                    const SizedBox(height: 16),
                    _examDate(),
                    const SizedBox(height: 16),
                    _notes(),
                    const SizedBox(height: 24),
                    _actions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- TOP SELECTORS ----------------
  Widget _topSelectors(bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _dropdown('Class *', _selectedClass,
            ['Grade 10 A', 'Grade 9 B'], (v) {
          setState(() => _selectedClass = v);
        }),
        _dropdown('Subject *', _selectedSubject,
            ['Mathematics', 'Science'], (v) {
          setState(() => _selectedSubject = v);
        }),
        _dropdown(
            'Student *', _selectedStudent, ['John Doe', 'Jane Smith'], (v) {
          setState(() => _selectedStudent = v);
        }),
      ],
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => onChanged(v!),
            decoration: const InputDecoration(isDense: true),
          ),
        ],
      ),
    );
  }

  // ---------------- MARKS ROW ----------------
  Widget _marksRow(_MarksRow row, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: row.topic,
              decoration:
                  const InputDecoration(hintText: 'Topic / Assessment'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: row.max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Max'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: row.obtained,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Obtained'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _rows.remove(row)),
            icon: const Icon(Icons.remove_circle, color: Colors.red),
          ),
        ],
      ),
    );
  }

  // ---------------- EXAM DATE ----------------
  Widget _examDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exam Date *',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _examDateController,
          readOnly: true,
          onTap: _pickExamDate,
          decoration: const InputDecoration(
            hintText: 'Select exam date',
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ],
    );
  }

  // ---------------- NOTES ----------------
  Widget _notes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Add any additional notes about the marks...',
          ),
        ),
      ],
    );
  }

  // ---------------- ACTIONS ----------------
  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {},
          style:
              ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Save Marks'),
        ),
      ],
    );
  }
}

// ---------------- ROW MODEL ----------------
class _MarksRow {
  final TextEditingController topic = TextEditingController();
  final TextEditingController max = TextEditingController();
  final TextEditingController obtained = TextEditingController();
}
