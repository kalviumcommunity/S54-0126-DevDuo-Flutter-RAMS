import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/attendance.dart';

/// Firebase Firestore-backed StudentService for production use.
/// Provides real-time student data from Firestore with CRUD operations.
/// Attendance is now persisted in Firestore for permanent storage.
class StudentService {
  // Singleton instance
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _studentsCollection =>
      _firestore.collection('students');

  CollectionReference get _attendanceCollection =>
      _firestore.collection('attendance');

  StudentService._internal();

  // Helper method to normalize date to start of day for consistent querying
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // ============ STUDENT OPERATIONS (Firebase) ============

  /// Get real-time stream of students from Firestore
  /// Filtering and sorting is done client-side to avoid needing Firestore composite indexes
  Stream<List<Student>> studentsStream({String? klass}) {
    // Fetch all students without server-side filtering/ordering
    // This avoids needing composite indexes in Firestore
    return _studentsCollection.snapshots().map((snapshot) {
      var students = snapshot.docs.map((doc) {
        return Student.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();

      // Filter by class client-side if specified
      if (klass != null && klass.isNotEmpty && klass != 'All Classes') {
        students = students.where((s) => s.klass == klass).toList();
      }

      // Sort by createdAt client-side (newest first)
      students.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return students;
    });
  }

  /// Create a new student in Firestore
  Future<void> createStudent(Student student) async {
    try {
      // If student has an ID, use it; otherwise let Firestore generate one
      if (student.id.isNotEmpty) {
        await _studentsCollection.doc(student.id).set(student.toMap());
      } else {
        await _studentsCollection.add(student.toMap());
      }
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  /// Get total number of students
  Future<int> totalStudents() async {
    try {
      final snapshot = await _studentsCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // ============ ATTENDANCE OPERATIONS (Firebase Firestore) ============

  /// Toggle attendance for a student on a specific date and class
  /// Creates a new record if it doesn't exist, updates if it does
  Future<void> toggleAttendance({
    required String studentId,
    required DateTime date,
    required String klass,
    required bool present,
  }) async {
    try {
      final normalizedDate = _normalizeDate(date);

      // Query for existing attendance record
      final querySnapshot = await _attendanceCollection
          .where('studentId', isEqualTo: studentId)
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .where('class', isEqualTo: klass)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update existing record
        await querySnapshot.docs.first.reference.update({
          'present': present,
          'markedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new record
        final attendance = Attendance(
          id: '', // Firestore will generate
          studentId: studentId,
          date: normalizedDate,
          klass: klass,
          present: present,
        );
        await _attendanceCollection.add(attendance.toMap());
      }
    } catch (e) {
      throw Exception('Failed to toggle attendance: $e');
    }
  }

  /// Get real-time stream of attendance for a specific date and class
  /// Returns a map of studentId -> present status
  /// If klass is null, returns attendance for all classes
  Stream<Map<String, bool>> attendanceStreamForDate(
    DateTime date,
    String? klass,
  ) {
    final normalizedDate = _normalizeDate(date);

    Query query = _attendanceCollection.where(
      'date',
      isEqualTo: Timestamp.fromDate(normalizedDate),
    );

    // Only filter by class if a specific class is provided
    if (klass != null && klass.isNotEmpty) {
      query = query.where('class', isEqualTo: klass);
    }

    return query.snapshots().map((snapshot) {
      final Map<String, bool> attendanceMap = {};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final studentId = data['studentId'] as String?;
        final present = data['present'] as bool?;
        if (studentId != null) {
          attendanceMap[studentId] = present ?? false;
        }
      }
      return attendanceMap;
    });
  }

  /// Get real-time stream of today's attendance percentage
  Stream<double> attendancePercentForToday() {
    final today = _normalizeDate(DateTime.now());

    return _attendanceCollection
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .snapshots()
        .asyncMap((snapshot) async {
          final total = await totalStudents();
          if (total == 0) return 0.0;

          final presentCount = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['present'] as bool? ?? false;
          }).length;

          return (presentCount / total) * 100.0;
        });
  }

  /// Get attendance percentage for a specific student (all time)
  double attendancePercentForStudent(String studentId) {
    // This is a synchronous method, so we can't query Firestore directly
    // Return 0.0 and recommend using the stream version instead
    return 0.0;
  }

  /// Get real-time stream of attendance percentage for a specific student
  Stream<double> attendancePercentStreamForStudent(String studentId) {
    return _attendanceCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return 0.0;

          final presentCount = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['present'] as bool? ?? false;
          }).length;

          final total = snapshot.docs.length;
          return (presentCount / total) * 100.0;
        });
  }
}
