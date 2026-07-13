final Map<String, String> _memStorage = {};

void saveString(String key, String value) {
  _memStorage[key] = value;
}

String? getString(String key) {
  return _memStorage[key];
}
