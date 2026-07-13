import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/textbook.dart';
import '../theme/app_theme.dart';
import '../utils/subject_icons.dart';

class PdfViewerScreen extends StatefulWidget {
  final Textbook textbook;
  final Color themeColor;

  const PdfViewerScreen({
    super.key,
    required this.textbook,
    required this.themeColor,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.textbook.title,
              style: AppTheme.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Grade ${widget.textbook.grade}',
              style: AppTheme.outfit(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        widget.textbook.file, // This should be 'assets/books/...'
        key: _pdfViewerKey,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
