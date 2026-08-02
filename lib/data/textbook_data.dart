import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/textbook.dart';

/// Loads and parses the library.json asset file.
///
/// DATA CONTRACT
/// ─────────────
/// library.json must have two top-level arrays:
///   "grades"   — grade-level textbooks (grade ≥ 1)
///   "subjects" — grade-independent subject books (grade == 0)
///
/// Subject books may optionally declare an "asset_folder" field
/// (defaults to "assets/books/") so they can live in their own
/// directory (e.g. "assets/subjects/").
///
/// To add content: edit library.json and hot-reload.
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
  static int get totalBooks => allBooks.length;

  /// All books across all grades and subjects.
  static List<Textbook> get allBooks {
    final books = <Textbook>[];
    for (final grade in allGrades) books.addAll(grade.textbooks);
    for (final subject in allSubjects) books.addAll(subject.textbooks);
    return books;
  }

  /// All grade-independent subject books (grade == 0).
  static List<Textbook> get allSubjectBooks {
    final books = <Textbook>[];
    for (final subject in allSubjects) books.addAll(subject.textbooks);
    return books;
  }

  /// Only subjects that have at least one book.
  static List<Subject> get subjectsWithBooks =>
      allSubjects.where((s) => s.hasBooks).toList();

  /// Total book count across all subjects.
  static int get totalSubjectBooks => allSubjectBooks.length;

  /// Search grade books only (grade >= 1).
  static List<Textbook> searchGradeBooks(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return [
      for (final g in allGrades)
        for (final t in g.textbooks)
          if (t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q) ||
              'ክፍል ${t.grade}'.contains(q))
            t,
    ];
  }

  /// Search subject books only (grade == 0).
  static List<Textbook> searchSubjectBooks(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return [
      for (final s in allSubjects)
        for (final t in s.textbooks)
          if (t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q) ||
              s.name.toLowerCase().contains(q))
            t,
    ];
  }

  /// Search across ALL books (grades + subjects).
  static List<Textbook> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allBooks.where((t) {
      final subject = subjectById(t.subjectId);
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          (subject?.name.toLowerCase().contains(q) ?? false) ||
          (t.grade > 0 ? 'ክፍል ${t.grade}'.contains(q) : false);
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
