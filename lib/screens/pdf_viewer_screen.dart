import 'package:flutter/material.dart';
import '../models/textbook.dart';
import '../theme/app_theme.dart';
import '../widgets/pdf_view_factory.dart' as pdf_factory;

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
              'ክፍል ${widget.textbook.grade}',
              style: AppTheme.outfit(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: pdf_factory.createPdfViewer(context, widget.textbook),
    );
  }
}
