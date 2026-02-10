import 'package:cloud_firestore/cloud_firestore.dart';

class Marks {
  final String id;
  final String studentId;
  final String subject;
  final String topic;
  final double obtainedMarks;
  final double maxMarks;
  final DateTime examDate;
  final String? notes;
  final DateTime? createdAt;

  Marks({
    required this.id,
    required this.studentId,
    required this.subject,
    required this.topic,
    required this.obtainedMarks,
    required this.maxMarks,
    required this.examDate,
    this.notes,
    this.createdAt,
  });

  factory Marks.fromMap(String id, Map<String, dynamic> data) {
    return Marks(
      id: id,
      studentId: data['studentId'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      topic: data['topic'] as String? ?? '',
      obtainedMarks: (data['obtainedMarks'] as num?)?.toDouble() ?? 0.0,
      maxMarks: (data['maxMarks'] as num?)?.toDouble() ?? 100.0,
      examDate: (data['examDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'studentId': studentId,
    'subject': subject,
    'topic': topic,
    'obtainedMarks': obtainedMarks,
    'maxMarks': maxMarks,
    'examDate': Timestamp.fromDate(examDate),
    if (notes != null) 'notes': notes,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
