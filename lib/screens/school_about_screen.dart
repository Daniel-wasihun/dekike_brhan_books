import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/school_provider.dart';

class SchoolAboutScreen extends StatefulWidget {
  const SchoolAboutScreen({super.key});
  @override
  State<SchoolAboutScreen> createState() => _SchoolAboutScreenState();
}

class _SchoolAboutScreenState extends State<SchoolAboutScreen> {
  late final ScrollController _scrollCtrl;
  bool _isCollapsed = false;

  // expandedHeight is 280
  static const double _collapseThreshold = 280 - kToolbarHeight;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _scrollCtrl.offset >= _collapseThreshold;
    if (collapsed != _isCollapsed) setState(() => _isCollapsed = collapsed);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  static const _pillars = [
    (icon: Icons.menu_book_rounded, title: 'ቅዱሳት መጻሕፍት', desc: 'ብሉይና ሐዲስ ኪዳን ጥናት'),
    (icon: Icons.music_note_rounded, title: 'ዜማ ና ቅኔ', desc: 'መዝሙርና ቅዱሳን ዜማዎች'),
    (icon: Icons.history_edu_rounded, title: 'የቤተ ክርስቲያን ታሪክ', desc: 'ቅዱሳን ሐዋርያትና ሊቃውንት'),
    (icon: Icons.favorite_rounded, title: 'ሥነ ምግባር', desc: 'ክርስቲያናዊ ሕይወትና አገልግሎት'),
    (icon: Icons.school_rounded, title: 'ትምህርተ ሃይማኖት', desc: 'ዶግማና ቀኖና ቤተ ክርስቲያን'),
    (icon: Icons.groups_rounded, title: 'ማሕበራዊ ትምህርት', desc: 'ኅብረትና ወንድማማችነት'),
  ];

  static const _infoItems = [
    (icon: Icons.location_on_rounded, label: 'አድራሻ', value: 'ኩራጂዳ ክፍለ ከተማ፣ ሸገር ከተማ'),
    (icon: Icons.church_rounded, label: 'ቤተ ክርስቲያን', value: 'መንበረ ብርሃን ቅ/ሥላሴ ቤ/ክ'),
    (icon: Icons.book_rounded, label: 'ሰንበት ት/ቤት ስም', value: 'ደቂቀ ብርሃን ሰንበት ትምህርት ቤት'),
    (icon: Icons.account_balance_rounded, label: 'ቤተ ክርስቲያን ዓይነት', value: 'ኢ/ኦ/ተ/ቤ/ክ'),
    (icon: Icons.layers_rounded, label: 'የትምህርት ደረጃዎች', value: 'ከ፩ኛ እስከ ፲፪ኛ ክፍል'),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolProvider>();
    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ─── Gradient Hero Header ─────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: _isCollapsed
                ? Row(
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
                        child: Text(
                          'ደቂቀ ብርሃን ሰንበት ትምህርት ቤት',
                          style: AppTheme.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
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
                    colors: [Color(0xFF0F0F2E), Color(0xFF1E1F4B), Color(0xFF2A2B5F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Cross emblem
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.church_rounded,
                          color: AppColors.accent,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'ደቂቀ ብርሃን',
                          textAlign: TextAlign.center,
                          style: AppTheme.outfit(
                            color: AppColors.accent,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'ሰንበት ትምህርት ቤት',
                          textAlign: TextAlign.center,
                          style: AppTheme.outfit(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        height: 1,
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'መንበረ ብርሃን ቅ/ሥላሴ ቤተ ክርስቲያን',
                          textAlign: TextAlign.center,
                          style: AppTheme.outfit(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Body Content ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mission Statement ────────────────────────
                  _card(
                    context,
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: AppColors.accent, size: 32),
                        const SizedBox(height: 10),
                        Text(
                          '"ልጅን በሚሄድበት መንገድ ምራው፤ ሲሸመግልም ከእርሱ አይለይም።"',
                          textAlign: TextAlign.center,
                          style: AppTheme.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.textDarkColor,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ምሳሌ 22:6',
                          style: AppTheme.outfit(
                            fontSize: 12,
                            color: context.textLightColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── About us text ────────────────────────────
                  _SectionTitle(title: 'ስለ ሰንበት ትምህርት ቤታችን'),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    child: Text(
                      'ደቂቀ ብርሃን ሰንበት ትምህርት ቤት በሸገር ከተማ፣ ኩራጂዳ ክፍለ ከተማ በሚገኘው በመንበረ ብርሃን ቅድስት ሥላሴ ቤተ ክርስቲያን ጥላ ሥር ሆኖ መንፈሳዊ አገልግሎት የሚሰጥ ተቋም ነው።\n\nዋና ዓላማውም ብሩህ የሆነውን ወጣት ትውልድ በኦርቶዶክሳዊት ተዋሕዶ ሃይማኖት ዶግማ፣ ቀኖና እና ትውፊት አንጾ ማሳደግ ነው። ይህ ዘመናዊ ዲጂታል ቤተ መጻሕፍት የተዘጋጀው መምህራንና ተማሪዎች መንፈሳዊ ትምህርታቸውን፣ የቤተ ክርስቲያን ታሪክን፣ ሥርዓትንና የቅዱሳት መጻሕፍት ጥናትን በየትኛውም ቦታና ጊዜ በቀላሉ እና በተመቻቸ ሁኔታ እንዲያገኙ ለማስቻል ነው።',
                      style: AppTheme.outfit(
                        fontSize: 14,
                        color: context.textMediumColor,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Church Info ──────────────────────────────
                  _SectionTitle(title: 'የቤተ ክርስቲያን መረጃ'),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    child: Column(
                      children: _infoItems
                          .map((item) => _InfoRow(
                                icon: item.icon,
                                label: item.label,
                                value: item.value,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Pillars of Teaching ──────────────────────
                  _SectionTitle(title: 'ዋና ዋና የትምህርት ዘርፎች'),
                  const SizedBox(height: 12),
                  Column(
                    children: _pillars
                        .map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PillarCard(
                                icon: p.icon,
                                title: p.title,
                                desc: p.desc,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Section Title ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTheme.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textDarkColor,
          ),
        ),
      ],
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.outfit(fontSize: 11, color: context.textLightColor),
                ),
                Text(
                  value,
                  style: AppTheme.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textDarkColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pillar Card ─────────────────────────────────────────────────────────────
class _PillarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _PillarCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTheme.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textDarkColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  desc,
                  style: AppTheme.outfit(fontSize: 13, color: context.textLightColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
