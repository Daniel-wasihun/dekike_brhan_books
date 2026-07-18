import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../models/textbook.dart';
import '../data/school_provider.dart';
import '../screens/pdf_viewer_screen.dart';
import 'file_opener.dart';
import '../theme/app_theme.dart';
import 'subject_icons.dart';

void showTopRightToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 24,
      right: 24,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ማሳሰቢያ',
                        style: AppTheme.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTheme.outfit(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                  onTap: () {
                    if (overlayEntry.mounted) {
                      overlayEntry.remove();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Auto remove after 3.5 seconds
  Future.delayed(const Duration(milliseconds: 3500), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

Future<void> openTextbook(BuildContext context, Textbook textbook, {Color? gradeColor}) async {
  final provider = context.read<SchoolProvider>();
  final color = gradeColor ?? AppColors.primary;
  final subjectColor = SubjectIcons.colorFor(textbook.subjectId, color);

  try {
    // Try to load the asset file to verify it exists
    await rootBundle.load(textbook.file);
    
    // Add to recent reading only if file exists
    provider.addRecentReading(textbook.file);
    
    if (textbook.fileType.toLowerCase() == 'pdf') {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              textbook: textbook,
              themeColor: subjectColor,
            ),
          ),
        );
      }
    } else {
      await openAssetFile(textbook.file);
    }
  } catch (e) {
    if (context.mounted) {
      showTopRightToast(
        context,
        'ይቅርታ፥ "${textbook.title}" የተባለው መጽሐፍ ፋይል አልተገኘም። በቅርቡ ይጨመራል!',
      );
    }
  }
}
