import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import '../utils/book_handler.dart';

class GradeDetailScreen extends StatefulWidget {
  final int grade;

  const GradeDetailScreen({
    super.key,
    required this.grade,
  });

  @override
  State<GradeDetailScreen> createState() => _GradeDetailScreenState();
}

class _GradeDetailScreenState extends State<GradeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradeLevel =
        LibraryLoader.allGrades.firstWhere((g) => g.grade == widget.grade);
    final color = AppColors.gradeColors[(widget.grade - 1) % 12];
    final textbooks = gradeLevel.textbooks;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Consumer<SchoolProvider>(
                builder: (context, provider, _) {
                  final isFav = provider.favoriteGrades.contains(widget.grade);
                  return IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => provider.toggleFavoriteGrade(widget.grade),
                  );
                },
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
                    padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Grade color accent bar
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          gradeLevel.label,
                          style: AppTheme.outfit(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          gradeLevel.category,
                          style: AppTheme.outfit(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),


          // ─── Empty State ─────────────────────────────────
          if (textbooks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.hourglass_empty_rounded,
                            color: color, size: 48),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ፋይል አልተገኘም',
                        style: AppTheme.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: context.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ይቅርታ! ለዚህ ክፍል ምንም ፋይል አልተጨመረም።\nቅርቡ ሳይሸሽ ማከል ይጀምራሉ!',
                        textAlign: TextAlign.center,
                        style: AppTheme.outfit(
                          fontSize: 14,
                          color: context.textLightColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // ─── Textbook List ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final textbook = textbooks[index];
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animCtrl,
                        curve: Interval(
                          (index * 0.1).clamp(0.0, 0.8),
                          1.0,
                          curve: Curves.easeIn,
                        ),
                      ),
                      child: _TextbookListItem(
                        textbook: textbook,
                        gradeColor: color,
                      ),
                    );
                  },
                  childCount: textbooks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}



// ─── Textbook List Item ────────────────────────────────────────────────────────
class _TextbookListItem extends StatelessWidget {
  final Textbook textbook;
  final Color gradeColor;

  const _TextbookListItem({
    required this.textbook,
    required this.gradeColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolProvider>();
    final isBookmarked = provider.isBookmarked(textbook.assetPath);
    final subject = LibraryLoader.subjectById(textbook.subjectId);
    final subjectIcon = SubjectIcons.iconFor(textbook.subjectId);
    final subjectColor = SubjectIcons.colorFor(textbook.subjectId, gradeColor);

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
          onTap: () => openTextbook(context, textbook, gradeColor: gradeColor),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Subject icon circle (Material Icon, no emoji)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(subjectIcon, color: subjectColor, size: 24),
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
                      Row(
                        children: [
                          Text(
                            subject?.name ?? textbook.subjectId,
                            style: AppTheme.outfit(
                              fontSize: 12,
                              color: context.textLightColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: subjectColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              textbook.fileType.toUpperCase(),
                              style: AppTheme.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: subjectColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bookmark button
                IconButton(
                  icon: Icon(
                    isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color:
                        isBookmarked ? AppColors.accent : context.textLightColor,
                  ),
                  onPressed: () => provider.toggleBookmark(textbook.assetPath),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
