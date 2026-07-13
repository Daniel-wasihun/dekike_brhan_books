import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Opens a Flutter asset file (PDF/DOC) appropriately per platform.
/// On web: opens the asset URL in a new browser tab.
/// On other platforms: uses url_launcher to open it.
Future<void> openAssetFile(String assetPath) async {
  if (kIsWeb) {
    // For web, the most reliable way to open an asset (which is just a file served by the web server)
    // is to use dart:html to open a new tab with the relative path.
    // Ensure the path doesn't start with a slash so it resolves correctly relative to base href.
    final cleanPath =
        assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;

    // Construct the absolute URL based on the current window location
    final baseUrl = Uri.base.toString();
    final fullUrl = Uri.parse(baseUrl).resolve('assets/$cleanPath').toString();

    html.window.open(fullUrl, '_blank');
    return;
  }

  // Mobile/Desktop fallback
  final uri = Uri.parse(assetPath);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw Exception('Could not open file: $assetPath');
  }
}
