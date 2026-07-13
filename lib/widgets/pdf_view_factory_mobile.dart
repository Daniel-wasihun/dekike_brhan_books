import 'package:flutter/material.dart';
import '../models/textbook.dart';
import '../utils/file_opener.dart';
import '../theme/app_theme.dart';

Widget createPdfViewer(BuildContext context, Textbook textbook) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            size: 64,
            color: AppColors.pdfColor,
          ),
          const SizedBox(height: 16),
          Text(
            'PDF View Optimized',
            style: AppTheme.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To view this document on mobile, open it in your system\'s external reader.',
            textAlign: TextAlign.center,
            style: AppTheme.outfit(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => openAssetFile(textbook.file),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open Externally'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
