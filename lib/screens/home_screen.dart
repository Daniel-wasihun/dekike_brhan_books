import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import '../utils/ethiopian_date.dart';
import '../services/notification_service.dart';
import '../widgets/prayer_times_widget.dart';
import 'grade_detail_screen.dart';
import '../utils/book_handler.dart';

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
            title: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ደቂቀ ብርሃን ሰንበት ትምህርት ቤት',
                        style: AppTheme.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${EthiopianDayNames.today()} • ${EthiopianDate.today().formatted}',
                        style: AppTheme.outfit(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '"ሕግህ ለእግሬ መብራት ነው"',
                          style: AppTheme.outfit(
                            color: AppColors.accentLight,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'መዝሙር 119:105',
                          style: AppTheme.outfit(
                            color: Colors.white38,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
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
                  'የፍለጋ ውጤቶች (${booksToShow.length})',
                  style: AppTheme.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.textDarkColor,
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
                      Icon(Icons.search_off_rounded,
                          color: context.textLightColor, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'ለ "$query" የሚመሳሰል ትምህርት አልተገኘም',
                        textAlign: TextAlign.center,
                        style: AppTheme.outfit(color: context.textMediumColor),
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


            // ─── Notification Permission Banner ──────────────
            const SliverToBoxAdapter(
              child: _NotificationBanner(),
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
                      'ትምህርቶችን በክፍል ይፈልጉ',
                      style: AppTheme.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.textDarkColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        provider.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      onPressed: () {
                        provider.setGridView(!provider.isGridView);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ─── Grade Cards Grid or List ────────────────────────────
            if (provider.isGridView)
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
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final gradeLevel = LibraryLoader.allGrades[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GradeListCard(gradeLevel: gradeLevel),
                      );
                    },
                    childCount: LibraryLoader.allGrades.length,
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1.5),
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
        style: AppTheme.outfit(fontSize: 14, color: context.textDarkColor),
        decoration: InputDecoration(
          hintText: 'ትምህርቶችን፣ የትምህርት አይነቶችን ወይም ክፍሎችን ይፈልጉ...',
          hintStyle: AppTheme.outfit(
            fontSize: 14,
            color: context.textLightColor,
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
      color: context.surfaceColor,
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
            border: Border.all(color: context.dividerColor, width: 1.5),
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
                              color: context.isDark ? AppColors.accent : AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded,
                            color: color.withValues(alpha: 0.6), size: 22),
                      ],
                    ),
                    const Spacer(),
                    // Book icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.menu_book_outlined,
                          color: color, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gradeLevel.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.outfit(
                        fontSize: 12,
                        color: context.textMediumColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookCount == 0
                          ? 'ምንም ትምህርት የለም'
                          : '$bookCount ትምህርቶች',
                      style: AppTheme.outfit(
                        fontSize: 11,
                        color: bookCount == 0
                            ? context.textHintColor
                            : context.textLightColor,
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

// ─── Grade List Card ───────────────────────────────────────────────────────────
class _GradeListCard extends StatelessWidget {
  final GradeLevel gradeLevel;
  const _GradeListCard({required this.gradeLevel});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.gradeColors[(gradeLevel.grade - 1) % 12];
    final bookCount = gradeLevel.textbooks.length;

    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.dividerColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book_outlined, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              gradeLevel.label,
                              style: AppTheme.outfit(
                                color: context.isDark ? AppColors.accent : AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            bookCount == 0 ? 'ምንም ትምህርት የለም' : '$bookCount ትምህርቶች',
                            style: AppTheme.outfit(
                              fontSize: 11,
                              color: bookCount == 0 ? context.textHintColor : context.textLightColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gradeLevel.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.outfit(
                          fontSize: 14,
                          color: context.textMediumColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 20),
              ],
            ),
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => openTextbook(context, textbook),
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
                          color: context.textDarkColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ክፍል ${textbook.grade} • ${subject?.name ?? textbook.subjectId}',
                        style: AppTheme.outfit(
                          fontSize: 12,
                          color: context.textMediumColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.textLightColor,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.dividerColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                Icon(
                  Icons.wb_sunny_rounded,
                  color: AppColors.accent,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'የእለቱ የተመረጠ ትምህርት',
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
              '${dailyBook.title} — ክፍል ${dailyBook.grade}',
              style: AppTheme.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textDarkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dailyBook.description.isNotEmpty
                  ? dailyBook.description
                  : 'በመንፈሳዊ እድገት እና ግንዛቤ ላይ በማተኮር የዛሬውን ትምህርት ይመልከቱ።',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.outfit(
                fontSize: 12,
                color: context.textMediumColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => openTextbook(context, dailyBook),
              icon: const Icon(Icons.menu_book_rounded, size: 18),
              label: const Text('ማንበብ ይጀምሩ'),
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
                'ማንበብዎን ይቀጥሉ',
                style: AppTheme.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.textDarkColor,
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
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.dividerColor, width: 1.5),
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
                    onTap: () => openTextbook(context, book, gradeColor: gradeColor),
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
                                    color: context.textDarkColor,
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
                                        'ክፍል ${book.grade}',
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
                                        color: context.textLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: context.textLightColor,
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


// ─── Notification Permission Banner ──────────────────────────────────────────
class _NotificationBanner extends StatefulWidget {
  const _NotificationBanner();

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner> {
  bool _visible = !NotificationService.isGranted;

  Future<void> _enable() async {
    final granted = await NotificationService.requestPermission();
    if (mounted) {
      setState(() => _visible = !granted);
      if (granted) {
        NotificationService.showTest();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_none_rounded,
                color: AppColors.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'የጸሎት ሰዓቶች ማሳወቂያ ለማስቻል ፍቀዱ',
                style: AppTheme.outfit(
                  fontSize: 12,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _enable,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('ፍቀዱ',
                  style: AppTheme.outfit(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

