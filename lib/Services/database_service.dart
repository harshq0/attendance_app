import 'package:attendance/Models/student_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _db;

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'attendance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT,
        rollno TEXT,
        course TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE absences (
        id TEXT,
        date TEXT
      )
    ''');
  }

  Future<void> insertStudent(Student student) async {
    final db = await database;
    await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final result = await db.query('students');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<void> insertAbsence(String id, String date) async {
    final db = await database;
    await db.insert(
      'absences',
      {'id': id, 'date': date},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, List<String>>> getStudentAbsence(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    final result = await db.query(
      'absences',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [formattedStartDate, formattedEndDate],
    );

    Map<String, List<String>> absenceData = {};
    for (var a in result) {
      final date = a['date'] as String;
      final studentId = a['id'] as String;
      if (absenceData.containsKey(date)) {
        absenceData[date]!.add(studentId);
      } else {
        absenceData[date] = [studentId];
      }
    }
    return absenceData;
  }

  Future<void> close() async {
    await _db?.close();
  }
}
