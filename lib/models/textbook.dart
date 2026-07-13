/// Represents a single textbook/document.
class Textbook {
  final String id;
  final String title;
  final String subjectId;
  final String file; // Full asset path, e.g. assets/books/foo.pdf
  final String fileType;
  final int grade;
  final String description;
  final String language; // 'en' | 'am' | ...
  final int? pages;
  final int? year;

  const Textbook({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.file,
    required this.fileType,
    required this.grade,
    this.description = '',
    this.language = 'en',
    this.pages,
    this.year,
  });

  factory Textbook.fromJson(Map<String, dynamic> json, int grade) {
    return Textbook(
      id: json['id'] as String,
      title: json['title'] as String,
      subjectId: json['subject_id'] as String,
      file: json['file'] as String,
      fileType: json['file_type'] as String,
      grade: grade,
      description: json['description'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      pages: json['pages'] as int?,
      year: json['year'] as int?,
    );
  }

  bool get isPdf => fileType.toLowerCase() == 'pdf';
  bool get isDoc =>
      fileType.toLowerCase() == 'doc' || fileType.toLowerCase() == 'docx';

  String get assetPath => file;
}

/// Represents a subject category.
class Subject {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const Subject({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '📖',
      description: json['description'] as String? ?? '',
    );
  }
}

/// Represents a grade level containing textbooks.
class GradeLevel {
  final int grade;
  final String label;
  final String category;
  final List<Textbook> textbooks;

  const GradeLevel({
    required this.grade,
    required this.label,
    required this.category,
    required this.textbooks,
  });

  factory GradeLevel.fromJson(Map<String, dynamic> json) {
    final grade = json['grade'] as int;
    final rawBooks = json['books'] as List<dynamic>? ?? [];
    final books = rawBooks
        .map((b) => Textbook.fromJson(b as Map<String, dynamic>, grade))
        .toList();
    return GradeLevel(
      grade: grade,
      label: json['label'] as String,
      category: json['category'] as String,
      textbooks: books,
    );
  }

  int get pdfCount => textbooks.where((t) => t.isPdf).length;
  int get docCount => textbooks.where((t) => t.isDoc).length;

  /// Convenience: sublabel = category from JSON
  String get sublabel => category;
}
