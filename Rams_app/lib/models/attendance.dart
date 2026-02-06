import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an attendance record for a student on a specific date and class.
class Attendance {
  final String id;
  final String studentId;
  final DateTime date;
  final String klass; // "class" is reserved in Dart
  final bool present;
  final DateTime? markedAt;
  final String? markedBy;

  Attendance({
    required this.id,
    required this.studentId,
    required this.date,
    required this.klass,
    required this.present,
    this.markedAt,
    this.markedBy,
  });

  /// Create an Attendance instance from a Firestore document
  factory Attendance.fromMap(String id, Map<String, dynamic> data) {
    return Attendance(
      id: id,
      studentId: data['studentId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      klass: data['class'] as String? ?? '',
      present: data['present'] as bool? ?? false,
      markedAt: (data['markedAt'] as Timestamp?)?.toDate(),
      markedBy: data['markedBy'] as String?,
    );
  }

  /// Convert Attendance instance to a map for Firestore
  Map<String, dynamic> toMap() {
    // Normalize date to start of day for consistent querying
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return {
      'studentId': studentId,
      'date': Timestamp.fromDate(normalizedDate),
      'class': klass,
      'present': present,
      'markedAt': markedAt != null
          ? Timestamp.fromDate(markedAt!)
          : FieldValue.serverTimestamp(),
      if (markedBy != null) 'markedBy': markedBy,
    };
  }

  /// Create a copy of this Attendance with updated fields
  Attendance copyWith({
    String? id,
    String? studentId,
    DateTime? date,
    String? klass,
    bool? present,
    DateTime? markedAt,
    String? markedBy,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      klass: klass ?? this.klass,
      present: present ?? this.present,
      markedAt: markedAt ?? this.markedAt,
      markedBy: markedBy ?? this.markedBy,
    );
  }
}
