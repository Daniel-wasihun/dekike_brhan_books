import 'package:flutter/material.dart';

/// Maps subject IDs (from library.json) to Material Icons and colors.
/// This avoids rendering emoji as text, which causes Noto font warnings.
class SubjectIcons {
  static IconData iconFor(String subjectId) {
    switch (subjectId) {
      case 'bible_study':
        return Icons.menu_book_rounded;
      case 'liturgy_hymns':
        return Icons.music_note_rounded;
      case 'christian_ethics':
        return Icons.volunteer_activism_rounded;
      case 'church_history':
        return Icons.account_balance_rounded;
      case 'prayers_devotionals':
        return Icons.self_improvement_rounded;
      case 'inspirational':
        return Icons.lightbulb_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  static Color colorFor(String subjectId, Color fallback) {
    switch (subjectId) {
      case 'bible_study':
        return const Color(0xFF6B4F9E); // purple
      case 'liturgy_hymns':
        return const Color(0xFF2A9D8F); // teal
      case 'christian_ethics':
        return const Color(0xFF4CAF50); // green
      case 'church_history':
        return const Color(0xFF8B6914); // gold/brown
      case 'prayers_devotionals':
        return const Color(0xFF457B9D); // steel blue
      case 'inspirational':
        return const Color(0xFFE07A5F); // warm coral
      default:
        return fallback;
    }
  }
}
