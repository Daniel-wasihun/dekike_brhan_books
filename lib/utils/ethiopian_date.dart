/// Ethiopian (Ge'ez) Calendar utilities
class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate(this.year, this.month, this.day);

  /// Convert Gregorian DateTime to Ethiopian date
  static EthiopianDate fromGregorian(DateTime gregorian) {
    // Ethiopian New Year (Enkutatash) = Sept 11 (Sept 12 in Gregorian leap year)
    final int jdn = _gregorianToJdn(gregorian.year, gregorian.month, gregorian.day);
    return _jdnToEthiopian(jdn);
  }

  static EthiopianDate today() => fromGregorian(DateTime.now());

  static int _gregorianToJdn(int y, int m, int d) {
    final a = (14 - m) ~/ 12;
    final yr = y + 4800 - a;
    final mo = m + 12 * a - 3;
    return d + (153 * mo + 2) ~/ 5 + 365 * yr + yr ~/ 4 - yr ~/ 100 + yr ~/ 400 - 32045;
  }

  static EthiopianDate _jdnToEthiopian(int jdn) {
    const jdnEpoch = 1723856; // Ethiopian epoch in JDN
    final r = (jdn - jdnEpoch) % 1461;
    final n = r % 365 + 365 * (r ~/ 1460);
    final year = 4 * ((jdn - jdnEpoch) ~/ 1461) + r ~/ 365 - r ~/ 1460;
    final month = n ~/ 30 + 1;
    final day = n % 30 + 1;
    return EthiopianDate(year, month, day);
  }

  /// Ethiopian month names
  static const List<String> monthNames = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሣሥ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዚያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ',
  ];

  /// Ethiopian Ge'ez numerals
  static String toGeez(int n) {
    if (n <= 0 || n > 100) return '$n';
    const units = ['', '፩', '፪', '፫', '፬', '፭', '፮', '፯', '፰', '፱'];
    const tens = ['', '፲', '፳', '፴', '፵', '፶', '፷', '፸', '፹', '፺'];
    if (n == 100) return '፻';
    final t = tens[n ~/ 10];
    final u = units[n % 10];
    return '$t$u';
  }

  String get monthName => month >= 1 && month <= 13 ? monthNames[month - 1] : '?';

  String get formatted => '${toGeez(day)} $monthName ${toGeez(year % 100)}';

  @override
  String toString() => formatted;
}

/// Day of week names in Amharic
class EthiopianDayNames {
  static const List<String> names = [
    'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'ዓርብ', 'ቅዳሜ', 'እሑድ',
  ];

  static String today() {
    final wd = DateTime.now().weekday; // 1=Mon ... 7=Sun
    return names[wd - 1];
  }
}
