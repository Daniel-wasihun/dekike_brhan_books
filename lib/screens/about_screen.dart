import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/textbook_data.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import 'grade_detail_screen.dart';
import 'subject_detail_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final grades = LibraryLoader.allGrades;
    final subjects = LibraryLoader.allSubjects;
    final totalBooks = LibraryLoader.totalBooks;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
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
                        Text(
                          'መዝገብ',
                          style: AppTheme.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'የሰንበት ትምህርት ቤት የመጻሕፍት ዝርዝር',
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

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ─── Stats Row ──────────────────────────────────
                Row(
                  children: [
                    _StatCard('${grades.length}', 'የክፍል ደረጃዎች', Icons.layers_rounded, AppColors.primary),
                    const SizedBox(width: 10),
                    _StatCard('$totalBooks', 'አጠቃላይ መጻሕፍት', Icons.menu_book_rounded, AppColors.accent),
                    const SizedBox(width: 10),
                    _StatCard('${subjects.length}', 'የትምህርት አይነቶች', Icons.category_rounded, AppColors.gradeColors[3]),
                  ],
                ),
                const SizedBox(height: 28),

                // ─── Subjects ────────────────────────────────────
                _SectionHeader(title: 'የትምህርት አይነቶች', icon: Icons.category_rounded),
                const SizedBox(height: 12),
                if (subjects.isEmpty)
                  _EmptyState(message: 'ምንም የትምህርት አይነት አልተጨመረም።')
                else
                  ...subjects.map((subject) {
                    final color = SubjectIcons.colorFor(subject.id, AppColors.primary);
                    return _ClickableSubjectCard(
                      subject: subject,
                      color: color,
                      bookCount: subject.textbooks.length,
                    );
                  }),
                const SizedBox(height: 28),

                // ─── Grade Breakdown ──────────────────────────────
                _SectionHeader(title: 'የክፍል ደረጃ ዝርዝር', icon: Icons.layers_rounded),
                const SizedBox(height: 12),
                ...grades.map((grade) {
                  final color = AppColors.gradeColors[(grade.grade - 1) % 12];
                  final isEmpty = grade.textbooks.isEmpty;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GradeDetailScreen(grade: grade.grade),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${grade.grade}',
                                    style: AppTheme.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      grade.label,
                                      style: AppTheme.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      grade.category,
                                      style: AppTheme.outfit(
                                        fontSize: 11,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isEmpty ? context.dividerColor : (context.isDark ? AppColors.accent.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.08)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isEmpty ? 'ባዶ' : '${grade.textbooks.length} መጻሕፍት',
                                  style: AppTheme.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isEmpty ? context.textHintColor : (context.isDark ? AppColors.accent : AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.chevron_right_rounded,
                                  color: color.withValues(alpha: 0.5), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // ─── How to add books tip ─────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tips_and_updates_rounded,
                              color: AppColors.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'መጻሕፍትን እንዴት ማከል ይቻላል',
                            style: AppTheme.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _TipStep('1', 'ፒዲኤፍ ፋይሉን ወደ assets/books/ ይቅዱ'),
                      const _TipStep('2', 'assets/library.json ፋይልን ይክፈቱ'),
                      const _TipStep('3', 'ተገቢውን የክፍል ደረጃ "books" ዝርዝር ውስጥ ያክሉ'),
                      const _TipStep('4', 'መተግበሪያውን እንደገና ያስጀምሩ'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Clickable Subject Card ──────────────────────────────────────────────────
class _ClickableSubjectCard extends StatelessWidget {
  final Subject subject;
  final Color color;
  final int bookCount;

  const _ClickableSubjectCard({
    required this.subject,
    required this.color,
    required this.bookCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SubjectDetailScreen(subject: subject),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(SubjectIcons.iconFor(subject.id), color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: AppTheme.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        bookCount == 0 ? 'ምንም ፋይል የለም' : '$bookCount መጻሕፍት',
                        style: AppTheme.outfit(
                          fontSize: 11,
                          color: bookCount == 0 ? AppColors.textHint : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.5), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              label,
              style: AppTheme.outfit(fontSize: 10, color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: AppTheme.outfit(fontSize: 13, color: AppColors.textLight),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─── Tip Step ────────────────────────────────────────────────────────────────
class _TipStep extends StatelessWidget {
  final String step;
  final String text;
  const _TipStep(this.step, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 10, top: 1),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTheme.outfit(fontSize: 13, color: AppColors.textMedium, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
