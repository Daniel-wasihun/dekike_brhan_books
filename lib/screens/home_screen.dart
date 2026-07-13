import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import 'grade_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolProvider>();
    final query = provider.searchQuery;
    final isSearching = query.isNotEmpty;
    final booksToShow =
        isSearching ? LibraryLoader.search(query) : <Textbook>[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero App Bar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: AppColors.accent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sunday School',
                              style: AppTheme.outfit(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '"Thy Word is a lamp unto my feet"',
                          style: AppTheme.outfit(
                            color: AppColors.accentLight,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'Psalm 119:105',
                          style: AppTheme.outfit(
                            color: Colors.white38,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Search Bar ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: _SearchBar(),
            ),
          ),

          if (isSearching) ...[
            // ─── Search Results Header ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'Search Results (${booksToShow.length})',
                  style: AppTheme.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            if (booksToShow.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded,
                          color: AppColors.textLight, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'No lessons found matching "$query"',
                        textAlign: TextAlign.center,
                        style: AppTheme.outfit(color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final textbook = booksToShow[index];
                      return _SearchTextbookCard(textbook: textbook);
                    },
                    childCount: booksToShow.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ] else ...[
            // ─── Daily Recommendation Card ────────────────────
            SliverToBoxAdapter(
              child: _DailyQuoteSection(),
            ),

            // ─── Recent Readings Row ──────────────────────────
            if (provider.recentReadingsList.isNotEmpty)
              SliverToBoxAdapter(
                child: _RecentReadingsSection(
                    recents: provider.recentReadingsList),
              ),

            // ─── Grade Sections Title ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: Row(
                  children: [
                    Text(
                      'Browse Lessons by Grade',
                      style: AppTheme.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.church_rounded,
                        color: AppColors.accent, size: 18),
                  ],
                ),
              ),
            ),

            // ─── Grade Cards Grid ────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final gradeLevel = LibraryLoader.allGrades[index];
                    return _GradeCard(gradeLevel: gradeLevel);
                  },
                  childCount: LibraryLoader.allGrades.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          context.read<SchoolProvider>().setSearchQuery(value);
        },
        style: AppTheme.outfit(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Search lessons, subjects or grades...',
          hintStyle: AppTheme.outfit(
            fontSize: 14,
            color: AppColors.textLight,
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.accent, size: 22),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Grade Card ────────────────────────────────────────────────────────────────
class _GradeCard extends StatelessWidget {
  final GradeLevel gradeLevel;
  const _GradeCard({required this.gradeLevel});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.gradeColors[(gradeLevel.grade - 1) % 12];
    final bookCount = gradeLevel.textbooks.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GradeDetailScreen(grade: gradeLevel.grade),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Stack(
            children: [
              // Subtle circle accent
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grade badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gradeLevel.label,
                            style: AppTheme.outfit(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: color.withValues(alpha: 0.5), size: 18),
                      ],
                    ),
                    const Spacer(),
                    // Book icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.menu_book_outlined,
                          color: color, size: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gradeLevel.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.outfit(
                        fontSize: 12,
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookCount == 0
                          ? 'No lessons yet'
                          : '$bookCount Lesson${bookCount == 1 ? '' : 's'}',
                      style: AppTheme.outfit(
                        fontSize: 11,
                        color: bookCount == 0
                            ? AppColors.textHint
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search Result Card ─────────────────────────────────────────────────────────
class _SearchTextbookCard extends StatelessWidget {
  final Textbook textbook;
  const _SearchTextbookCard({required this.textbook});

  @override
  Widget build(BuildContext context) {
    final subject = LibraryLoader.subjectById(textbook.subjectId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GradeDetailScreen(
                  grade: textbook.grade,
                  initialSelectedSubjectId: textbook.subjectId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SubjectIcons.colorFor(
                            textbook.subjectId, AppColors.primary)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    SubjectIcons.iconFor(textbook.subjectId),
                    color: SubjectIcons.colorFor(
                        textbook.subjectId, AppColors.primary),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textbook.title,
                        style: AppTheme.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Grade ${textbook.grade} • ${subject?.name ?? textbook.subjectId}',
                        style: AppTheme.outfit(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textLight,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Daily Devotion Quote Recommendation Card ─────────────────────────────────
class _DailyQuoteSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final allBooks = LibraryLoader.allBooks;

    if (allBooks.isEmpty) return const SizedBox.shrink();

    final dailyBook = allBooks[dayOfYear % allBooks.length];
    final gradeColor = AppColors.gradeColors[(dailyBook.grade - 1) % 12];
    final subjectColor = SubjectIcons.colorFor(dailyBook.subjectId, gradeColor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFAF0),
              Color(0xFFFFF2DC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFF7E2C4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recommended Lesson of the Day',
                  style: AppTheme.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${dailyBook.title} — Grade ${dailyBook.grade}',
              style: AppTheme.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dailyBook.description.isNotEmpty
                  ? dailyBook.description
                  : 'Delve into today\'s study focusing on spiritual development and understanding.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.outfit(
                fontSize: 12,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GradeDetailScreen(
                      grade: dailyBook.grade,
                      initialSelectedSubjectId: dailyBook.subjectId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_rounded, size: 16),
              label: const Text('Start Reading'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTheme.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Readings Section ──────────────────────────────────────────────────
class _RecentReadingsSection extends StatelessWidget {
  final List<Textbook> recents;

  const _RecentReadingsSection({required this.recents});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Text(
                'Continue Reading',
                style: AppTheme.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: recents.length,
            itemBuilder: (context, index) {
              final book = recents[index];
              final gradeColor = AppColors.gradeColors[(book.grade - 1) % 12];
              final subjectColor =
                  SubjectIcons.colorFor(book.subjectId, gradeColor);

              return Container(
                width: 260,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
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
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: subjectColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              SubjectIcons.iconFor(book.subjectId),
                              color: subjectColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            gradeColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Grade ${book.grade}',
                                        style: AppTheme.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: gradeColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      book.fileType.toUpperCase(),
                                      style: AppTheme.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textLight,
                            size: 18,
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
      ],
    );
  }
}
