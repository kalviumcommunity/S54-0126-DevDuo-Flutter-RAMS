/// Helper class for form field validations
class ValidationHelper {
  ValidationHelper._(); // Private constructor (prevents instantiation)

  /// Validate phone number - accepts various formats
  /// Supports: 1234567890, (123) 456-7890, 123-456-7890, +1 123 456 7890, etc.
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a phone number';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 10) {
      return 'Phone number must have at least 10 digits';
    }

    if (digits.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }

    return null;
  }

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate name field
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }

    final trimmed = value.trim();

    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmed.length > 100) {
      return 'Name cannot exceed 100 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmed)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate student ID
  static String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a student ID';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Student ID must be at least 3 characters';
    }

    if (trimmed.length > 50) {
      return 'Student ID cannot exceed 50 characters';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  /// Validate date format (DD/MM/YYYY)
  static String? validateDateFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Please enter date in DD/MM/YYYY format';
    }

    try {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      if (year < 1900 || year > DateTime.now().year) {
        return 'Invalid year';
      }

      final date = DateTime(year, month, day);

      // Ensure exact match (prevents 31/02/2023 type issues)
      if (date.day != day || date.month != month || date.year != year) {
        return 'Invalid date';
      }
    } catch (_) {
      return 'Invalid date format';
    }

    return null;
  }

  /// Validate notes field
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (value.trim().length > 500) {
      return 'Notes cannot exceed 500 characters';
    }

    return null;
  }
}
