import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/marks.dart';

/// Firebase Firestore-backed StudentService for production use.
/// Provides real-time student data from Firestore with CRUD operations.
/// Attendance is now persisted in Firestore for permanent storage.
class StudentService {
  // Singleton instance
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _studentsCollection =>
      _firestore.collection('students');

  CollectionReference get _attendanceCollection =>
      _firestore.collection('attendance');

  CollectionReference get _marksCollection => _firestore.collection('marks');

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

  /// Check if a student ID (roll number) already exists
  /// Returns true if the student ID is already in use
  Future<bool> checkStudentIdExists(String studentId) async {
    try {
      final query = await _studentsCollection
          .where('studentId', isEqualTo: studentId)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check student ID: $e');
    }
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

  /// Upload a profile image to Firebase Storage and return the download URL
  /// [studentId] is used to create a unique file name
  /// [imageFile] is the File object containing the image data
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage(String studentId, File imageFile) async {
    try {
      final fileExtension = imageFile.path.split('.').last;
      final fileName =
          'profile_${studentId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final ref = _storage.ref().child('student_profiles/$fileName');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Update student's profile image URL
  Future<void> updateStudentProfileImage(
    String studentId,
    String photoUrl,
  ) async {
    try {
      await _studentsCollection.doc(studentId).update({
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update student profile image: $e');
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
    required String subject,
    required bool present,
  }) async {
    try {
      final normalizedDate = _normalizeDate(date);

      // Use a deterministic ID to prevent duplicates and ensure atomicity
      // studentId + date (ms) + subject
      final docId =
          '${studentId}_${normalizedDate.millisecondsSinceEpoch}_$subject';

      final attendance = Attendance(
        id: docId,
        studentId: studentId,
        date: normalizedDate,
        klass: klass,
        subject: subject,
        present: present,
        markedAt: DateTime.now(),
      );

      // doc().set() is atomic and will overwrite if exists, preventing duplicates
      await _attendanceCollection.doc(docId).set(attendance.toMap());
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
    String? subject,
  ) {
    // If no subject is specified, return an empty map to avoid cross-subject data leakage
    if (subject == null || subject.isEmpty) {
      return Stream.value({});
    }

    final normalizedDate = _normalizeDate(date);

    Query query = _attendanceCollection.where(
      'date',
      isEqualTo: Timestamp.fromDate(normalizedDate),
    );

    // Only filter by class if a specific class is provided
    if (klass != null && klass.isNotEmpty) {
      query = query.where('class', isEqualTo: klass);
    }

    // Since we already checked subject is not null/empty above, we can safely apply the filter
    query = query.where('subject', isEqualTo: subject);

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

          // Count unique students who are present in AT LEAST one subject today
          final presentStudentIds = <String>{};
          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final isPresent = data['present'] as bool? ?? false;
            final sId = data['studentId'] as String?;
            if (isPresent && sId != null) {
              presentStudentIds.add(sId);
            }
          }

          final presentCount = presentStudentIds.length;
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

  /// Get real-time stream of reports summary data
  Stream<Map<String, dynamic>> reportsSummaryStream({
    String? klass,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    Query query = _attendanceCollection;

    if (klass != null && klass != 'All Classes') {
      query = query.where('class', isEqualTo: klass);
    }

    if (fromDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(_normalizeDate(fromDate)),
      );
    }

    if (toDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(_normalizeDate(toDate)),
      );
    }

    return query.snapshots().asyncMap((snapshot) async {
      final totalRecords = snapshot.docs.length;
      if (totalRecords == 0) {
        return {
          'attendanceRate': 0.0,
          'totalClasses': 0,
          'presentCount': 0,
          'absentCount': 0,
          'lowAttendanceAlerts': <Map<String, dynamic>>[],
        };
      }

      int presentCount = 0;
      int absentCount = 0;
      final studentStats = <String, Map<String, int>>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final isPresent = data['present'] as bool? ?? false;
        final sId = data['studentId'] as String?;

        if (isPresent) {
          presentCount++;
        } else {
          absentCount++;
        }

        if (sId != null) {
          studentStats.putIfAbsent(sId, () => {'total': 0, 'present': 0});
          studentStats[sId]!['total'] = studentStats[sId]!['total']! + 1;
          if (isPresent) {
            studentStats[sId]!['present'] = studentStats[sId]!['present']! + 1;
          }
        }
      }

      final attendanceRate = (presentCount / totalRecords) * 100.0;

      // Calculate low attendance alerts (< 75%)
      final lowAttendanceAlerts = <Map<String, dynamic>>[];
      for (final entry in studentStats.entries) {
        final rate = (entry.value['present']! / entry.value['total']!) * 100.0;
        if (rate < 75.0) {
          // Fetch student name (simplified for now, ideally we'd have a map or cache)
          final studentDoc = await _studentsCollection.doc(entry.key).get();
          final name =
              (studentDoc.data() as Map<String, dynamic>?)?['name'] ??
              entry.key;
          lowAttendanceAlerts.add({'name': name, 'rate': rate.round()});
        }
      }

      // Count unique subjects and dates to estimate "classes conducted"
      final uniqueSessions = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rawDate = data['date'];
        if (rawDate == null) continue;

        DateTime? date;
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is String) {
          date = DateTime.tryParse(rawDate);
        }

        if (date == null) continue;

        final subject = data['subject'] as String?;
        final klassName = data['class'] as String?;
        if (subject != null && klassName != null) {
          uniqueSessions.add(
            '${klassName}_${subject}_${date.millisecondsSinceEpoch}',
          );
        }
      }

      return {
        'attendanceRate': attendanceRate,
        'totalClasses': uniqueSessions.length,
        'presentCount': presentCount,
        'absentCount': absentCount,
        'lowAttendanceAlerts': lowAttendanceAlerts,
      };
    });
  }

  // ============ MARKS OPERATIONS (Firebase Firestore) ============

  /// Save or update marks for a student
  Future<void> saveMarks(Marks marks) async {
    try {
      if (marks.id.isNotEmpty) {
        await _marksCollection.doc(marks.id).set(marks.toMap());
      } else {
        await _marksCollection.add(marks.toMap());
      }
    } catch (e) {
      throw Exception('Failed to save marks: $e');
    }
  }

  /// Get real-time stream of marks for a specific student
  Stream<List<Marks>> marksStreamForStudent(String studentId) {
    return _marksCollection
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Marks.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();
        });
  }

  /// Get list of available subjects
  List<String> getSubjects() {
    return ['Mathematics', 'Science', 'English', 'History', 'Computer'];
  }
}
