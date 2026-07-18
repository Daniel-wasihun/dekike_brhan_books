import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/textbook.dart';
import '../data/school_provider.dart';
import '../screens/pdf_viewer_screen.dart';
import 'file_opener.dart';
import '../theme/app_theme.dart';
import 'subject_icons.dart';

Future<void> openTextbook(BuildContext context, Textbook textbook, {Color? gradeColor}) async {
  final provider = context.read<SchoolProvider>();
  provider.addRecentReading(textbook.file);
  
  final color = gradeColor ?? AppColors.primary;
  final subjectColor = SubjectIcons.colorFor(textbook.subjectId, color);

  try {
    if (textbook.fileType.toLowerCase() == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            textbook: textbook,
            themeColor: subjectColor,
          ),
        ),
      );
    } else {
      await openAssetFile(textbook.file);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ፋይሉን መክፈት አልተቻለም፡ ${textbook.file.split('/').last}',
            style: AppTheme.outfit(fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
