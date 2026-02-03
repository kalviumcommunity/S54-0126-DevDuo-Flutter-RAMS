import 'dart:async';
import '../models/student.dart';

/// In-memory StudentService used for local-only flows during early development.
/// Exposes the same API as the Firestore-backed version but keeps all data in
/// memory and not persisted. It seeds sample students so UI works immediately.
class StudentService {
  // Singleton instance so in-memory data is shared across the app
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;

  // In-memory storage
  final Map<String, Student> _students = {};
  // attendanceKey => { studentId: present }
  final Map<String, Map<String, bool>> _attendance = {};

  // Streams (initialized in internal constructor so we can add `onListen` callbacks)
  late final StreamController<List<Student>> _studentsController;
  late final StreamController<Map<String, Map<String, bool>>>
  _attendanceController;
  late final StreamController<double> _todayPercentController;

  StudentService._internal() {
    // controllers will push current state to any new listeners immediately
    _studentsController = StreamController<List<Student>>.broadcast(
      onListen: () {
        _studentsController.add(_students.values.toList());
      },
    );

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

    _seedSampleData();
  }

  void _seedSampleData() {
    // Only seed when empty to avoid overwriting any runtime changes
    if (_students.isNotEmpty) return;

    final seeds = [
      Student(
        id: 's1',
        name: 'Aarav Sharma',
        studentId: 'ID: 0001',
        klass: 'Class 10 A',
      ),
      Student(
        id: 's2',
        name: 'Priya Singh',
        studentId: 'ID: 0002',
        klass: 'Class 10 A',
      ),
      Student(
        id: 's3',
        name: 'Rahul Kumar',
        studentId: 'ID: 0003',
        klass: 'Class 10 B',
      ),
      Student(
        id: 's4',
        name: 'Sneha Gupta',
        studentId: 'ID: 0004',
        klass: 'Class 10 A',
      ),
      Student(
        id: 's5',
        name: 'Amit Patel',
        studentId: 'ID: 0005',
        klass: 'Class 9 A',
      ),
    ];

    for (final s in seeds) {
      _students[s.id] = s;
    }

    // seed today's attendance a bit
    final todayKey = _dateKey(DateTime.now()) + '|Class 10 A';
    _attendance[todayKey] = {'s1': true, 's2': true, 's4': true};

    _notifyStudents();
    _notifyAttendance();
    _emitAttendancePercent();
  }

  void _notifyStudents() {
    _studentsController.add(_students.values.toList());
  }

  void _notifyAttendance() {
    _attendanceController.add(Map.unmodifiable(_attendance));
  }

  void _emitAttendancePercent() {
    final todayKeyPattern = _dateKey(DateTime.now());
    final total = _students.length;
    if (total == 0) {
      _todayPercentController.add(0.0);
      return;
    }
    int presentCount = 0;
    int countEntries = 0;
    _attendance.forEach((k, val) {
      if (k.startsWith(todayKeyPattern)) {
        countEntries += val.length;
        presentCount += val.values.where((v) => v).length;
      }
    });
    // If attendance docs per-student (multiple entries per date), normalize by students
    final percent = total == 0
        ? 0.0
        : (presentCount / (total == 0 ? 1 : total)) * 100.0;
    _todayPercentController.add(percent);
  }

  Stream<List<Student>> studentsStream({String? klass}) {
    return _studentsController.stream.map((list) {
      if (klass != null && klass.isNotEmpty && klass != 'All Classes') {
        return list.where((s) => s.klass == klass).toList();
      }
      return list;
    });
  }

  Future<void> createStudent(Student s) async {
    _students[s.id] = s;
    _notifyStudents();
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
    _notifyAttendance();
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

  Future<int> totalStudents() async {
    return _students.length;
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
