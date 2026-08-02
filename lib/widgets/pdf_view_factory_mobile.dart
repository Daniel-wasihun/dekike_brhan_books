import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/textbook.dart';
import '../theme/app_theme.dart';

/// Cache: asset path → extracted temp File
final Map<String, File> _pdfFileCache = {};

Widget createPdfViewer(BuildContext context, Textbook textbook) {
  return _FastPdfViewer(textbook: textbook);
}

class _FastPdfViewer extends StatefulWidget {
  final Textbook textbook;
  const _FastPdfViewer({required this.textbook});

  @override
  State<_FastPdfViewer> createState() => _FastPdfViewerState();
}

class _FastPdfViewerState extends State<_FastPdfViewer> {
  late final PdfViewerController _controller;
  File? _pdfFile;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
    _loadPdf();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Extracts the asset PDF to a temp file once per session, then caches it.
  /// File I/O is significantly faster than reading from the asset bundle
  /// during scroll rendering.
  Future<void> _loadPdf() async {
    final assetPath = widget.textbook.file;

    // Return immediately if already cached
    if (_pdfFileCache.containsKey(assetPath)) {
      if (mounted) {
        setState(() {
          _pdfFile = _pdfFileCache[assetPath];
          _loading = false;
        });
      }
      return;
    }

    try {
      // Load bytes from asset bundle (one-time cost)
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();

      // Write to app's temp directory
      final dir = await getTemporaryDirectory();
      // Use a safe filename derived from the asset path
      final safeName = assetPath.replaceAll(RegExp(r'[/\\]'), '_');
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes, flush: true);

      // Cache for future opens
      _pdfFileCache[assetPath] = file;

      if (mounted) {
        setState(() {
          _pdfFile = file;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoader();
    }

    if (_error != null || _pdfFile == null) {
      return _buildError();
    }

    return SfPdfViewer.file(
      _pdfFile!,
      controller: _controller,
      // Single-page layout: renders one page at a time — far smoother scrolling
      pageLayoutMode: PdfPageLayoutMode.single,
      // Pan mode: no text-selection overhead during scroll
      interactionMode: PdfInteractionMode.pan,
      // Disable heavy UI chrome
      canShowScrollHead: false,
      canShowScrollStatus: false,
      canShowPaginationDialog: false,
      // Allow double-tap zoom for convenience
      enableDoubleTapZooming: true,
      // Start at a comfortable zoom level
      initialZoomLevel: 1.0,
    );
  }

  Widget _buildLoader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1F4B), Color(0xFF2A2B5F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'መጽሐፍ እየተጫነ ነው…',
              style: AppTheme.outfit(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      color: const Color(0xFF1E1F4B),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 52),
            const SizedBox(height: 16),
            Text(
              'መጽሐፍ መጫን አልተሳካም',
              style: AppTheme.outfit(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _loadPdf();
              },
              icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
              label: Text(
                'እንደገና ሞክር',
                style: AppTheme.outfit(color: AppColors.accent, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
