import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String studentId;
  final String klass; // "class" is reserved in Dart
  final String? dateOfBirth;
  final String? guardianName;
  final String? guardianContact;
  final String? enrollmentDate;
  final String? notes;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.klass,
    this.dateOfBirth,
    this.guardianName,
    this.guardianContact,
    this.enrollmentDate,
    this.notes,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Student.fromMap(String id, Map<String, dynamic> data) {
    return Student(
      id: id,
      name: data['name'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      klass: data['class'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] as String?,
      guardianName: data['guardianName'] as String?,
      guardianContact: data['guardianContact'] as String?,
      enrollmentDate: data['enrollmentDate'] as String?,
      notes: data['notes'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'studentId': studentId,
    'class': klass,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (guardianName != null) 'guardianName': guardianName,
    if (guardianContact != null) 'guardianContact': guardianContact,
    if (enrollmentDate != null) 'enrollmentDate': enrollmentDate,
    if (notes != null) 'notes': notes,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
