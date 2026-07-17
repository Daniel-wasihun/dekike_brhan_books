import 'package:url_launcher/url_launcher.dart';

Future<void> openAssetFile(String assetPath) async {
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
