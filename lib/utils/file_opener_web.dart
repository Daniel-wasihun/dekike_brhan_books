import 'dart:html' as html;

Future<void> openAssetFile(String assetPath) async {
  final cleanPath =
      assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;

  // Construct the absolute URL based on the current window location
  final baseUrl = Uri.base.toString();
  final fullUrl = Uri.parse(baseUrl).resolve('assets/$cleanPath').toString();

  html.window.open(fullUrl, '_blank');
}
