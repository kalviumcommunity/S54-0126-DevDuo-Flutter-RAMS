import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

/// Firebase Firestore-backed StudentService for production use.
/// Provides real-time student data from Firestore with CRUD operations.
/// Attendance methods remain in-memory for now (not changed in this update).
class StudentService {
  // Singleton instance
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _studentsCollection =>
      _firestore.collection('students');

  // In-memory attendance storage (keeping existing functionality)
  final Map<String, Map<String, bool>> _attendance = {};
  late final StreamController<Map<String, Map<String, bool>>>
  _attendanceController;
  late final StreamController<double> _todayPercentController;

  StudentService._internal() {
    // Initialize attendance controllers
    _attendanceController =
        StreamController<Map<String, Map<String, bool>>>.broadcast(
          onListen: () {
            _attendanceController.add(Map.unmodifiable(_attendance));
          },
        );

    _todayPercentController = StreamController<double>.broadcast(
      onListen: () {
        _emitAttendancePercent();
      },
    );
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

  // ============ ATTENDANCE OPERATIONS (In-Memory - Not Changed) ============

  void _emitAttendancePercent() async {
    final todayKeyPattern = _dateKey(DateTime.now());
    final total = await totalStudents();
    if (total == 0) {
      _todayPercentController.add(0.0);
      return;
    }
    int presentCount = 0;
    _attendance.forEach((k, val) {
      if (k.startsWith(todayKeyPattern)) {
        presentCount += val.values.where((v) => v).length;
      }
    });
    final percent = total == 0 ? 0.0 : (presentCount / total) * 100.0;
    _todayPercentController.add(percent);
  }

  Future<void> toggleAttendance({
    required String studentId,
    required DateTime date,
    required String klass,
    required bool present,
  }) async {
    final dateKey = _dateKey(date) + '|$klass';
    final map = _attendance[dateKey] ?? {};
    map[studentId] = present;
    _attendance[dateKey] = map;
    _attendanceController.add(Map.unmodifiable(_attendance));
    _emitAttendancePercent();
  }

  Stream<Map<String, bool>> attendanceStreamForDate(
    DateTime date,
    String klass,
  ) {
    final key = _dateKey(date) + '|$klass';
    return _attendanceController.stream.map(
      (all) => Map.unmodifiable(all[key] ?? {}),
    );
  }

  Stream<double> attendancePercentForToday() {
    return _todayPercentController.stream;
  }

  double attendancePercentForStudent(String studentId) {
    int present = 0;
    int total = 0;
    _attendance.forEach((_, map) {
      if (map.containsKey(studentId)) {
        total += 1;
        if (map[studentId] == true) present += 1;
      }
    });
    if (total == 0) return 0.0;
    return (present / total) * 100.0;
  }

  Stream<double> attendancePercentStreamForStudent(String studentId) {
    return _attendanceController.stream.map((_) {
      int present = 0;
      int total = 0;
      _attendance.forEach((_, map) {
        if (map.containsKey(studentId)) {
          total += 1;
          if (map[studentId] == true) present += 1;
        }
      });
      if (total == 0) return 0.0;
      return (present / total) * 100.0;
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
