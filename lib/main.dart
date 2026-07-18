import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/school_provider.dart';
import 'data/textbook_data.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/bookmarks_screen.dart';
import 'screens/about_screen.dart';
import 'screens/school_about_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the JSON library config before the app starts
  await LibraryLoader.load();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => SchoolProvider(),
      child: const SundaySchoolApp(),
    ),
  );
}

class SundaySchoolApp extends StatelessWidget {
  const SundaySchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SchoolProvider>();
    return MaterialApp(
      title: 'Sunday School Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.themeMode,
      home: const SplashScreen(),
    );
  }
}

// ─── Splash Screen ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1F4B),
              Color(0xFF2A2B5F),
              Color(0xFF3F3E8F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '✦   ✦   ✦',
                      style: AppTheme.outfit(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          fontSize: 14,
                          letterSpacing: 10),
                    ),
                    const SizedBox(height: 30),
                    // Spiritual symbol container (Cross & Light rays)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.4), width: 2),
                        color: Colors.white.withValues(alpha: 0.06),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 55,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ሰንበት ትምህርት ቤት',
                      style: AppTheme.outfit(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'የማስተማሪያ መጻሕፍት',
                      style: AppTheme.outfit(
                          fontSize: 16,
                          color: AppColors.accentLight,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"ልጅን በሚሄድበት መንገድ ምራው..."',
                      style: AppTheme.outfit(
                          color: Colors.white60,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 50),
                    // Elegant progress loader
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'ምሳሌ 22:6',
                      style: AppTheme.outfit(
                          color: Colors.white38,
                          fontSize: 11,
                          letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Main Shell with Bottom Nav ────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = [
    HomeScreen(),
    BookmarksScreen(),
    AboutScreen(),
    SchoolAboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.surfaceColor,
          border: Border(
            top: BorderSide(color: context.dividerColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'ትምህርቶች',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.bookmark_outline_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'የተቀመጡ',
                  isSelected: _currentIndex == 1,
                  onTap: () {
                    context.read<SchoolProvider>().clearUnreadBookmarksCount();
                    setState(() => _currentIndex = 1);
                  },
                  badgeCount:
                      context.watch<SchoolProvider>().unreadBookmarksCount,
                ),
                _NavItem(
                  icon: Icons.library_books_outlined,
                  activeIcon: Icons.library_books_rounded,
                  label: 'መዝገብ',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.info_outline_rounded,
                  activeIcon: Icons.info_rounded,
                  label: 'ስለ እኛ',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Nav Item ───────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: badgeCount > 0,
              label: Text(
                '$badgeCount',
                style: const TextStyle(fontSize: 9),
              ),
              backgroundColor: AppColors.accent,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? (context.isDark ? AppColors.accent : AppColors.primary) : context.textMediumColor,
                size: 24,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.isDark ? AppColors.accent : AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
