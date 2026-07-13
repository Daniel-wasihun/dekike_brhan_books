import 'dart:html' as html;

void saveString(String key, String value) {
  html.window.localStorage[key] = value;
}

String? getString(String key) {
  return html.window.localStorage[key];
}
