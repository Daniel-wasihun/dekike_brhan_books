import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/textbook.dart';

/// Loads and parses the library.json asset file.
/// This is the single source of truth — to add subjects or books,
/// edit assets/library.json and hot-reload.
class LibraryLoader {
  static List<GradeLevel>? _grades;
  static List<Subject>? _subjects;
  static bool _loaded = false;

  /// Call once at app start to load and cache data.
  static Future<void> load() async {
    if (_loaded) return;
    final jsonString = await rootBundle.loadString('assets/library.json');
    final Map<String, dynamic> data =
        json.decode(jsonString) as Map<String, dynamic>;

    final rawSubjects = data['subjects'] as List<dynamic>;
    _subjects = rawSubjects
        .map((s) => Subject.fromJson(s as Map<String, dynamic>))
        .toList();

    final rawGrades = data['grades'] as List<dynamic>;
    _grades = rawGrades
        .map((g) => GradeLevel.fromJson(g as Map<String, dynamic>))
        .toList();

    _loaded = true;
  }

  static List<GradeLevel> get allGrades {
    assert(
        _loaded, 'LibraryLoader.load() must be called before accessing data');
    return _grades!;
  }

  static List<Subject> get allSubjects {
    assert(
        _loaded, 'LibraryLoader.load() must be called before accessing data');
    return _subjects!;
  }

  /// Find a subject by its ID.
  static Subject? subjectById(String id) {
    try {
      return allSubjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get emoji for a subject ID (fallback to 📖).
  static String emojiForSubject(String subjectId) {
    return subjectById(subjectId)?.emoji ?? '📖';
  }

  /// Total number of books across all grades and subjects.
  static int get totalBooks {
    return allBooks.length;
  }

  /// All books across all grades and subjects.
  static List<Textbook> get allBooks {
    final books = <Textbook>[];
    for (final grade in allGrades) {
      books.addAll(grade.textbooks);
    }
    for (final subject in allSubjects) {
      books.addAll(subject.textbooks);
    }
    return books;
  }

  /// Search across title, subject name, description, and grade.
  static List<Textbook> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allBooks.where((t) {
      final subject = subjectById(t.subjectId);
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          (subject?.name.toLowerCase().contains(q) ?? false) ||
          'grade ${t.grade}'.contains(q);
    }).toList();
  }

  /// Get all books for a specific grade, optionally filtered by subjectId.
  static List<Textbook> booksForGrade(int grade, {String? subjectId}) {
    final gradeLevel = allGrades.firstWhere((g) => g.grade == grade,
        orElse: () => const GradeLevel(
              grade: 0,
              label: '',
              category: '',
              textbooks: [],
            ));
    if (subjectId == null) return gradeLevel.textbooks;
    return gradeLevel.textbooks.where((t) => t.subjectId == subjectId).toList();
  }

  /// Get unique subject IDs used in a specific grade.
  static List<String> subjectIdsForGrade(int grade) {
    final gradeLevel = allGrades.firstWhere((g) => g.grade == grade,
        orElse: () => const GradeLevel(
              grade: 0,
              label: '',
              category: '',
              textbooks: [],
            ));
    return gradeLevel.textbooks.map((t) => t.subjectId).toSet().toList();
  }

  /// Find a textbook by its file path.
  static Textbook? findBookByPath(String path) {
    try {
      return allBooks.firstWhere((b) => b.file == path);
    } catch (_) {
      return null;
    }
  }
}
