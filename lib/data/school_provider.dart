import 'package:flutter/foundation.dart';
import '../models/textbook.dart';
import '../data/textbook_data.dart';

class SchoolProvider extends ChangeNotifier {
  String _searchQuery = '';
  String? _selectedSubjectFilter;
  final Set<int> _favoriteGrades = {};
  final Set<String> _bookmarkedBooks = {}; // Uses assetPath as key

  String get searchQuery => _searchQuery;
  String? get selectedSubjectFilter => _selectedSubjectFilter;
  Set<int> get favoriteGrades => _favoriteGrades;
  Set<String> get bookmarkedBooks => _bookmarkedBooks;

  List<GradeLevel> get allGrades => LibraryLoader.allGrades;
  List<Subject> get allSubjects => LibraryLoader.allSubjects;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSubjectFilter(String? subjectId) {
    _selectedSubjectFilter = subjectId;
    notifyListeners();
  }

  void toggleFavoriteGrade(int grade) {
    if (_favoriteGrades.contains(grade)) {
      _favoriteGrades.remove(grade);
    } else {
      _favoriteGrades.add(grade);
    }
    notifyListeners();
  }

  void toggleBookmark(String assetPath) {
    if (_bookmarkedBooks.contains(assetPath)) {
      _bookmarkedBooks.remove(assetPath);
    } else {
      _bookmarkedBooks.add(assetPath);
    }
    notifyListeners();
  }

  bool isBookmarked(String assetPath) => _bookmarkedBooks.contains(assetPath);

  List<Textbook> get searchResults {
    if (_searchQuery.isEmpty) return [];
    return LibraryLoader.search(_searchQuery);
  }

  List<Textbook> getFilteredTextbooks(int grade) {
    return LibraryLoader.booksForGrade(grade,
        subjectId: _selectedSubjectFilter);
  }
}
