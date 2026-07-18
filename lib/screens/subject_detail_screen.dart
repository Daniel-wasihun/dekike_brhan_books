import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/textbook.dart';
import '../utils/subject_icons.dart';
import '../utils/book_handler.dart';

class SubjectDetailScreen extends StatelessWidget {
  final Subject subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final color = SubjectIcons.colorFor(subject.id, AppColors.primary);
    final books = subject.textbooks;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1F4B), Color(0xFF2A2B5F), Color(0xFF3B3C83)],
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
                        Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          subject.name,
                          style: AppTheme.outfit(
                            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${books.length} ደጋፊ መጻሕፍት',
                          style: AppTheme.outfit(
                            color: Colors.white70, fontSize: 13,
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

          if (books.isEmpty)
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
                        child: Icon(Icons.hourglass_empty_rounded, color: color, size: 48),
                      ),
                      const SizedBox(height: 20),
                      Text('ፋይል አልተገኘም', style: AppTheme.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      const SizedBox(height: 10),
                      Text('ይቅርታ! ለዚህ ትምህርት ምንም ፋይል አልተጨመረም።\nበቅርቡ ይጨመራል!',
                        textAlign: TextAlign.center,
                        style: AppTheme.outfit(fontSize: 14, color: AppColors.textLight, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = books[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
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
                          onTap: () => openTextbook(context, book),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(SubjectIcons.iconFor(subject.id), color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(book.title, style: AppTheme.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: context.textDarkColor)),
                                      if (book.description.isNotEmpty)
                                        Text(book.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.outfit(fontSize: 11, color: context.textLightColor)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: books.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
