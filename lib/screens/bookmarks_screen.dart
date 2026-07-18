import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import '../utils/book_handler.dart';
import 'grade_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: Consumer<SchoolProvider>(
        builder: (context, provider, _) {
          // Collect all bookmarked textbooks from JSON-loaded data
          final bookmarked = <Textbook>[];
          for (final grade in LibraryLoader.allGrades) {
            for (final book in grade.textbooks) {
              if (provider.isBookmarked(book.assetPath)) {
                bookmarked.add(book);
              }
            }
          }

          // Collect all favorited grades
          final favGradesList = LibraryLoader.allGrades
              .where((g) => provider.favoriteGrades.contains(g.grade))
              .toList();

          final isEmptyAll = bookmarked.isEmpty && favGradesList.isEmpty;

          return CustomScrollView(
            slivers: [
              // ─── Header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: Icon(
                      provider.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => provider.toggleThemeMode(),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1E1F4B),
                          Color(0xFF2A2B5F),
                          Color(0xFF3B3C83),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'የተቀመጡ ትምህርቶች',
                              style: AppTheme.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              isEmptyAll
                                  ? 'ምንም የተቀመጠ ነገር የለም'
                                  : 'በፍጥነት ለመድረስ ተወዳጅ ያደረጓቸው ነገሮች',
                              style: AppTheme.outfit(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Empty State ─────────────────────────────
              if (isEmptyAll)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              color: AppColors.accent,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ምንም የተቀመጠ ነገር የለም',
                            style: AppTheme.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ትምህርቶችን ወይም ክፍሎችን ተወዳጅ (Heart) በማድረግ\nበፍጥነት እዚህ ያገኟቸዋል።',
                            textAlign: TextAlign.center,
                            style: AppTheme.outfit(
                              fontSize: 14,
                              color: context.textLightColor,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                // ─── Favorite Grades Section ─────────────────
                if (favGradesList.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'ተወዳጅ የክፍል ደረጃዎች',
                            style: AppTheme.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.textDarkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: favGradesList.length,
                        itemBuilder: (context, index) {
                          final grade = favGradesList[index];
                          final color = AppColors.gradeColors[(grade.grade - 1) % 12];
                          return Container(
                            width: 190,
                            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 8),
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.dividerColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GradeDetailScreen(grade: grade.grade),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${grade.grade}',
                                            style: AppTheme.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              grade.label,
                                              style: AppTheme.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: context.textDarkColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${grade.textbooks.length} መጻሕፍት',
                                              style: AppTheme.outfit(
                                                fontSize: 10,
                                                color: context.textLightColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // ─── Bookmarked Books Section ────────────────
                if (bookmarked.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          const Icon(Icons.bookmark_rounded, color: AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'የተቀመጡ መጻሕፍት',
                            style: AppTheme.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.textDarkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = bookmarked[index];
                          final color = AppColors.gradeColors[(book.grade - 1) % 12];
                          final subject = LibraryLoader.subjectById(book.subjectId);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: context.surfaceColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.dividerColor, width: 1.5),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => openTextbook(context, book, gradeColor: color),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: SubjectIcons.colorFor(book.subjectId, color).withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            SubjectIcons.iconFor(book.subjectId),
                                            color: SubjectIcons.colorFor(book.subjectId, color),
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              book.title,
                                              style: AppTheme.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: context.textDarkColor,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'ክፍል ${book.grade} • ${subject?.name ?? book.subjectId}',
                                              style: AppTheme.outfit(
                                                fontSize: 12,
                                                color: context.textMediumColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.bookmark_rounded,
                                          color: AppColors.accent,
                                        ),
                                        onPressed: () => provider.toggleBookmark(book.assetPath),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: bookmarked.length,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
