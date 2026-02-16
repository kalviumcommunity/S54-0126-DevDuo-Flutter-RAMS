import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/responsive_helper.dart';
import '../../../core/helpers/validation_helper.dart';
import '../../../core/widgets/widgets.dart';
import '../../../services/student_service.dart';
import '../../../models/student.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentService = StudentService();

  // Form controllers
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianContactController = TextEditingController();
  final _enrollmentDateController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedClass = 'Grade 8';
  bool _isLoading = false;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _dobController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _enrollmentDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final trimmedStudentId = _studentIdController.text.trim();

      // Check for duplicate student ID
      final isDuplicate = await _studentService.checkStudentIdExists(
        trimmedStudentId,
      );
      if (isDuplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Student ID "$trimmedStudentId" is already in use. Please use a unique ID.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Validate date range if both dates are provided
      final dobText = _dobController.text.trim();
      final enrollmentText = _enrollmentDateController.text.trim();

      if (dobText.isNotEmpty && enrollmentText.isNotEmpty) {
        final dateRangeError = ValidationHelper.validateDobBeforeEnrollment(
          dobText,
          enrollmentText,
        );
        if (dateRangeError != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(dateRangeError),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      }

      // Create student object first
      late Student student;
      String? photoUrl;

      // If there's a profile image, upload it to Firebase Storage
      if (_profileImage != null) {
        try {
          // Use studentId for upload naming
          photoUrl = await _studentService.uploadProfileImage(
            trimmedStudentId,
            _profileImage!,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error uploading photo. Continuing without photo.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Continue without image if upload fails
        }
      }

      // Create student with photoUrl if available
      student = Student(
        id: '',
        name: _nameController.text.trim(),
        studentId: trimmedStudentId,
        klass: _selectedClass,
        dateOfBirth: dobText.isNotEmpty ? dobText : null,
        guardianName: _guardianNameController.text.trim(),
        guardianContact: _guardianContactController.text.trim(),
        enrollmentDate: enrollmentText.isNotEmpty ? enrollmentText : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text
            : null,
        photoUrl: photoUrl,
        createdAt: DateTime.now(),
      );

      await _studentService.createStudent(student);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating student: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(elevation: 1, title: const Text('Add Student')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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
                    _photoUpload(),
                    const SizedBox(height: 20),

                    _input(
                      'Full Name',
                      'John Doe',
                      _nameController,
                      required: true,
                      validator: ValidationHelper.validateName,
                    ),
                    _input(
                      'Student ID',
                      'STD12345',
                      _studentIdController,
                      required: true,
                      validator: ValidationHelper.validateStudentId,
                    ),
                    _dropdown('Class', ['Grade 8', 'Grade 9', 'Grade 10']),
                    _dateInput(
                      'Date of Birth',
                      'DD/MM/YYYY',
                      _dobController,
                      validator: ValidationHelper.validateDateFormat,
                    ),
                    _input(
                      'Guardian Name',
                      'Jane Doe',
                      _guardianNameController,
                      required: true,
                      validator: ValidationHelper.validateName,
                    ),
                    _input(
                      'Guardian Contact',
                      '(123) 456-7890',
                      _guardianContactController,
                      required: true,
                      validator: ValidationHelper.validatePhoneNumber,
                    ),
                    _dateInput(
                      'Enrollment Date',
                      'DD/MM/YYYY',
                      _enrollmentDateController,
                      validator: ValidationHelper.validateDateFormat,
                    ),
                    _notes(),

                    const SizedBox(height: 12),
                    const Text(
                      'Fields marked with * are required.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _actions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Photo',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Optional',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _profileImage != null
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: _profileImage != null ? 2 : 1,
              ),
              image: _profileImage != null
                  ? DecorationImage(
                      image: FileImage(_profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _profileImage == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.grey, size: 32),
                      SizedBox(height: 4),
                      Text(
                        'Tap to upload',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'JPG, PNG, up to 5MB',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Will be displayed on all student views',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (_profileImage != null)
              TextButton.icon(
                onPressed: () => setState(() => _profileImage = null),
                icon: const Icon(Icons.clear, size: 18),
                label: const Text('Remove'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _dateInput(
    String label,
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: true,
            validator: validator,
            onTap: () => _pickDate(controller),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: const Icon(Icons.calendar_today, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String label,
    String hint,
    TextEditingController controller, {
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedClass,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _selectedClass = val!),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _notes() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Notes',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any additional notes about the student here.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          text: 'Cancel',
          type: ButtonType.outlined,
          isLoading: false,
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Save Student',
          type: ButtonType.elevated,
          isLoading: _isLoading,
          onPressed: _saveStudent,
        ),
      ],
    );
  }
}
