import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/file_opener.dart';
import '../utils/subject_icons.dart';
import 'pdf_viewer_screen.dart';

class GradeDetailScreen extends StatefulWidget {
  final int grade;
  final String? initialSelectedSubjectId;

  const GradeDetailScreen({
    super.key,
    required this.grade,
    this.initialSelectedSubjectId,
  });

  @override
  State<GradeDetailScreen> createState() => _GradeDetailScreenState();
}

class _GradeDetailScreenState extends State<GradeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSelectedSubjectId;
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

    // Filter textbooks by selected subjectId
    final textbooks = _selectedSubjectId == null
        ? gradeLevel.textbooks
        : gradeLevel.textbooks
            .where((t) => t.subjectId == _selectedSubjectId)
            .toList();

    // Unique subjectIds used in this grade
    final usedSubjectIds =
        gradeLevel.textbooks.map((t) => t.subjectId).toSet().toList();

    // Map to Subject objects (preserving JSON order)
    final usedSubjects = LibraryLoader.allSubjects
        .where((s) => usedSubjectIds.contains(s.id))
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Hero Header ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.95), color],
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
                            color: Colors.white.withValues(alpha: 0.8),
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

          // ─── Subject Filter Chips ────────────────────────
          if (usedSubjects.isNotEmpty)
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _SubjectChip(
                      label: 'All Lessons',
                      icon: Icons.apps_rounded,
                      isSelected: _selectedSubjectId == null,
                      color: color,
                      onTap: () => setState(() => _selectedSubjectId = null),
                    ),
                    const SizedBox(width: 8),
                    ...usedSubjects.map((subject) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _SubjectChip(
                            label: subject.name,
                            icon: SubjectIcons.iconFor(subject.id),
                            isSelected: _selectedSubjectId == subject.id,
                            color: color,
                            onTap: () =>
                                setState(() => _selectedSubjectId = subject.id),
                          ),
                        )),
                  ],
                ),
              ),
            ),

          // ─── Empty State ─────────────────────────────────
          if (textbooks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined,
                          color: color.withValues(alpha: 0.4), size: 56),
                      const SizedBox(height: 16),
                      Text(
                        'No lessons added yet',
                        style: AppTheme.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add PDF or DOC files to assets/books/\nthen update assets/library.json',
                        textAlign: TextAlign.center,
                        style: AppTheme.outfit(
                          fontSize: 13,
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

// ─── Subject Filter Chip ───────────────────────────────────────────────────────
class _SubjectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SubjectChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textMedium,
              ),
            ),
          ],
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTextbookDetail(context, textbook, gradeColor),
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
                          color: AppColors.textDark,
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
                              color: AppColors.textLight,
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
                        isBookmarked ? AppColors.accent : AppColors.textLight,
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

  void _showTextbookDetail(
      BuildContext context, Textbook textbook, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TextbookDetailSheet(textbook: textbook, color: color),
    );
  }
}

// ─── Textbook Detail Bottom Sheet ──────────────────────────────────────────────
class _TextbookDetailSheet extends StatefulWidget {
  final Textbook textbook;
  final Color color;

  const _TextbookDetailSheet({
    required this.textbook,
    required this.color,
  });

  @override
  State<_TextbookDetailSheet> createState() => _TextbookDetailSheetState();
}

class _TextbookDetailSheetState extends State<_TextbookDetailSheet> {
  bool _isOpening = false;

  @override
  Widget build(BuildContext context) {
    final subject = LibraryLoader.subjectById(widget.textbook.subjectId);
    final subjectIcon = SubjectIcons.iconFor(widget.textbook.subjectId);
    final subjectColor =
        SubjectIcons.colorFor(widget.textbook.subjectId, widget.color);

    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with icon
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: subjectColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(subjectIcon, color: subjectColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.textbook.title,
                            style: AppTheme.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Grade ${widget.textbook.grade} • ${subject?.name ?? widget.textbook.subjectId}',
                            style: AppTheme.outfit(
                              fontSize: 13,
                              color: AppColors.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                if (widget.textbook.description.isNotEmpty) ...[
                  Text(
                    'About this Lesson',
                    style: AppTheme.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.textbook.description,
                    style: AppTheme.outfit(
                      fontSize: 13,
                      color: AppColors.textMedium,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // File details
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        Icons.insert_drive_file_rounded,
                        'File',
                        widget.textbook.file.split('/').last,
                      ),
                      _DetailRow(
                        Icons.label_rounded,
                        'Type',
                        widget.textbook.fileType.toUpperCase(),
                      ),
                      _DetailRow(
                        Icons.language_rounded,
                        'Language',
                        widget.textbook.language == 'am'
                            ? 'Amharic'
                            : 'English',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Open button — actually opens the PDF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isOpening
                        ? null
                        : () async {
                            setState(() => _isOpening = true);
                            try {
                              context.read<SchoolProvider>().addRecentReading(widget.textbook.file);
                              if (widget.textbook.fileType.toLowerCase() ==
                                  'pdf') {
                                if (context.mounted) {
                                  Navigator.pop(context); // Close bottom sheet
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PdfViewerScreen(
                                        textbook: widget.textbook,
                                        themeColor: subjectColor,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                await openAssetFile(widget.textbook.file);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Could not open file: ${widget.textbook.file.split('/').last}',
                                      style: AppTheme.outfit(fontSize: 13),
                                    ),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isOpening = false);
                            }
                          },
                    icon: _isOpening
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.open_in_new_rounded),
                    label: Text(_isOpening ? 'Opening...' : 'Open PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subjectColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          subjectColor.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textLight),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.outfit(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: AppTheme.outfit(
                fontSize: 12,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
