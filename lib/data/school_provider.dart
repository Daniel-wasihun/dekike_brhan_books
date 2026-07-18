import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/textbook.dart';
import '../data/textbook_data.dart';
import '../utils/storage.dart' as storage;

class SchoolProvider extends ChangeNotifier {
  String _searchQuery = '';
  String? _selectedSubjectFilter;
  final Set<int> _favoriteGrades = {};
  final Set<String> _bookmarkedBooks = {}; // Uses assetPath as key
  final List<String> _recentReadings = []; // Uses assetPath
  bool _isGridView = false; // Default to list view (false)
  ThemeMode _themeMode = ThemeMode.light;

  SchoolProvider() {
    _loadPersistedData();
  }

  void _loadPersistedData() {
    try {
      final bookmarksJson = storage.getString('bookmarked_books');
      if (bookmarksJson != null) {
        final List<dynamic> decoded = jsonDecode(bookmarksJson);
        _bookmarkedBooks.addAll(decoded.cast<String>());
      }

      final favoritesJson = storage.getString('favorite_grades');
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        _favoriteGrades.addAll(decoded.cast<int>());
      }

      final recentsJson = storage.getString('recent_readings');
      if (recentsJson != null) {
        final List<dynamic> decoded = jsonDecode(recentsJson);
        _recentReadings.addAll(decoded.cast<String>());
      }

      final layoutPref = storage.getString('layout_preference');
      if (layoutPref != null) {
        _isGridView = (layoutPref == 'grid');
      } else {
        _isGridView = false; // Default is list
      }

      final themePref = storage.getString('theme_mode');
      if (themePref != null) {
        _themeMode = (themePref == 'dark') ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading persisted data: $e');
    }
  }

  void _saveBookmarks() {
    storage.saveString(
        'bookmarked_books', jsonEncode(_bookmarkedBooks.toList()));
  }

  void _saveFavorites() {
    storage.saveString('favorite_grades', jsonEncode(_favoriteGrades.toList()));
  }

  void _saveRecents() {
    storage.saveString('recent_readings', jsonEncode(_recentReadings));
  }

  String get searchQuery => _searchQuery;
  String? get selectedSubjectFilter => _selectedSubjectFilter;
  Set<int> get favoriteGrades => _favoriteGrades;
  Set<String> get bookmarkedBooks => _bookmarkedBooks;
  List<String> get recentReadings => _recentReadings;
  bool get isGridView => _isGridView;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    storage.saveString('theme_mode', _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  void setGridView(bool value) {
    _isGridView = value;
    storage.saveString('layout_preference', value ? 'grid' : 'list');
    notifyListeners();
  }

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
    _saveFavorites();
    notifyListeners();
  }

  void toggleBookmark(String assetPath) {
    if (_bookmarkedBooks.contains(assetPath)) {
      _bookmarkedBooks.remove(assetPath);
    } else {
      _bookmarkedBooks.add(assetPath);
    }
    _saveBookmarks();
    notifyListeners();
  }

  void addRecentReading(String assetPath) {
    _recentReadings.remove(assetPath);
    _recentReadings.insert(0, assetPath);
    if (_recentReadings.length > 6) {
      _recentReadings.removeLast();
    }
    _saveRecents();
    notifyListeners();
  }

  List<Textbook> get recentReadingsList {
    return _recentReadings
        .map((path) => LibraryLoader.findBookByPath(path))
        .whereType<Textbook>()
        .toList();
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
