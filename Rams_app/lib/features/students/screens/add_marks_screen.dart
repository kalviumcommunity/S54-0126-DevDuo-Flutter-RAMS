import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../services/student_service.dart';
import '../../../models/student.dart';
import '../../../models/marks.dart';

class AddMarksScreen extends StatefulWidget {
  const AddMarksScreen({super.key});

  @override
  State<AddMarksScreen> createState() => _AddMarksScreenState();
}

class _AddMarksScreenState extends State<AddMarksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentService = StudentService();

  final TextEditingController _examDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<_MarksRow> _rows = [_MarksRow()];

  String? _selectedClass;
  String? _selectedSubject;
  String? _selectedStudent;
  DateTime? _selectedDateTime;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['student'] != null) {
          final studentData = args['student'] as Map<String, dynamic>;
          _selectedStudent = studentData['docId'] ?? studentData['id'];
          _selectedClass = studentData['class'] ?? studentData['klass'];
        }
        if (args['subject'] != null) {
          _selectedSubject = args['subject'] as String;
        }
      }
      _isInitialized = true;
    }
  }

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
      setState(() {
        _selectedDateTime = picked;
        _examDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _saveAllMarks() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudent == null ||
        _selectedSubject == null ||
        _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      for (final row in _rows) {
        if (row.topic.text.isEmpty ||
            row.max.text.isEmpty ||
            row.obtained.text.isEmpty)
          continue;

        final marks = Marks(
          id: '',
          studentId: _selectedStudent!,
          subject: _selectedSubject!,
          topic: row.topic.text.trim(),
          obtainedMarks: double.tryParse(row.obtained.text) ?? 0,
          maxMarks: double.tryParse(row.max.text) ?? 100,
          examDate: _selectedDateTime!,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text
              : null,
        );
        await _studentService.saveMarks(marks);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marks uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isMobile = responsive.isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Upload Marks'), elevation: 1),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._rows.map((row) => _marksRow(row, isMobile)).toList(),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => _rows.add(_MarksRow())),
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
    return StreamBuilder<List<Student>>(
      stream: _studentService.studentsStream(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];

        // Extract unique classes dynamically
        final uniqueClasses =
            students
                .map((s) => s.klass)
                .where((k) => k.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        // Ensure current selection is still valid
        if (_selectedClass != null && !uniqueClasses.contains(_selectedClass)) {
          _selectedClass = null;
          _selectedStudent = null;
        }

        // Filter students based on selected class
        final filteredStudents = _selectedClass == null
            ? []
            : students.where((s) => s.klass == _selectedClass).toList();

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _dropdown('Class *', _selectedClass, uniqueClasses, (v) {
              setState(() {
                _selectedClass = v;
                _selectedStudent = null;
              });
            }),
            _dropdown(
              'Subject *',
              _selectedSubject,
              _studentService.getSubjects(),
              (v) => setState(() => _selectedSubject = v),
            ),
            _dropdown(
              'Student *',
              _selectedStudent,
              filteredStudents.map((s) => s.id as String).toList(),
              (v) => setState(() => _selectedStudent = v),
              itemLabelBuilder: (id) {
                final s = filteredStudents.firstWhere((s) => s.id == id);
                return '${s.name} (${s.studentId})';
              },
            ),
          ],
        );
      },
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    Function(String) onChanged, {
    String Function(String)? itemLabelBuilder,
  }) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelWithAsterisk(label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(isDense: true),
            hint: Text('Select ${label.replaceAll('*', '').trim()}'),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      itemLabelBuilder != null ? itemLabelBuilder(e) : e,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => onChanged(v!),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _labelWithAsterisk(String label) {
    if (!label.contains('*')) {
      return Text(label, style: const TextStyle(fontWeight: FontWeight.w600));
    }
    final text = label.replaceAll('*', '').trim();
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
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
              decoration: const InputDecoration(hintText: 'Topic / Assessment'),
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
        _labelWithAsterisk('Exam Date *'),
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
          onPressed: _isLoading ? null : _saveAllMarks,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Marks'),
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
