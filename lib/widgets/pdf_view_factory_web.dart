import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import '../models/textbook.dart';

Widget createPdfViewer(BuildContext context, Textbook textbook) {
  final viewId = 'pdf-viewer-${textbook.id}';

  // Construct absolute URL based on the current window location
  final baseUrl = Uri.base.toString();
  final cleanPath = textbook.file.startsWith('/')
      ? textbook.file.substring(1)
      : textbook.file;
  final fullUrl = Uri.parse(baseUrl).resolve('assets/$cleanPath').toString();

  // Register the iframe view factory
  ui.platformViewRegistry.registerViewFactory(
    viewId,
    (int id) {
      final iframe = html.IFrameElement()
        ..src = fullUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    },
  );

  return HtmlElementView(viewType: viewId);
}
