import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import 'grade_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          return CustomScrollView(
            slivers: [
              // ─── Header ──────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: AppColors.background,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
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
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'በፍጥነት ለማንበብ ${bookmarked.length} ትምህርቶች ተቀምጠዋል',
                            style: AppTheme.outfit(
                              fontSize: 14,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Content ────────────────────────────────
              if (bookmarked.isEmpty)
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
                            'ምንም የተቀመጠ ትምህርት የለም',
                            style: AppTheme.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ትምህርቶችን ከየትኛውም ክፍል አስቀምጠው\nበፍጥነት እዚህ ያገኟቸዋል።',
                            textAlign: TextAlign.center,
                            style: AppTheme.outfit(
                              fontSize: 14,
                              color: AppColors.textLight,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = bookmarked[index];
                        final color =
                            AppColors.gradeColors[(book.grade - 1) % 12];
                        final subject =
                            LibraryLoader.subjectById(book.subjectId);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.divider, width: 1.5),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GradeDetailScreen(
                                      grade: book.grade,
                                      initialSelectedSubjectId: book.subjectId,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Subject icon circle
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: SubjectIcons.colorFor(
                                                book.subjectId, color)
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          SubjectIcons.iconFor(book.subjectId),
                                          color: SubjectIcons.colorFor(
                                              book.subjectId, color),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book.title,
                                            style: AppTheme.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ክፍል ${book.grade} • ${subject?.name ?? book.subjectId}',
                                            style: AppTheme.outfit(
                                              fontSize: 12,
                                              color: AppColors.textMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Remove bookmark
                                    IconButton(
                                      icon: const Icon(
                                        Icons.bookmark_rounded,
                                        color: AppColors.accent,
                                      ),
                                      onPressed: () => provider
                                          .toggleBookmark(book.assetPath),
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
          );
        },
      ),
    );
  }
}
