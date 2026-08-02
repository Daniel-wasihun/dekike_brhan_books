import 'notification_service.dart';

class NotificationService {
  static const List<PrayerTime> prayerTimes = [
    PrayerTime(
      hour: 3, minute: 0,
      ethiopianTime: 'ሌሊቱ ፱ ሰዓት',
      name: 'ሌሊቱ ፱ ሰዓት — ዘወትር ጸሎት',
      message: '"ሌሊቱን ሁሉ ጸለዩ" — ቅዱሳን ሐዋርያት ሌሊቱን ሳያቋርጡ ይጸልዩ ነበር። ይነሡ ጸሎት ያድርሱ።',
      emoji: '⭐',
    ),
    PrayerTime(
      hour: 5, minute: 0,
      ethiopianTime: 'ሌሊቱ ፲፩ ሰዓት',
      name: 'ሌሊቱ ፲፩ ሰዓት — ቀዳሚት',
      message: '"ጌታ ሆይ ጥዋት ቃሌን ትሰማለህ" (መዝ. ፭፥፫) — የጥዋት ጸሎት ሰዓት ደርሷል።',
      emoji: '🌅',
    ),
    PrayerTime(
      hour: 9, minute: 0,
      ethiopianTime: 'ቀኑ ፫ ሰዓት',
      name: 'ቀኑ ፫ ሰዓት — ሦስተኛ ሰዓት',
      message: '"መንፈስ ቅዱስ ሐዋርያትን ሞላ" — ቀኑ ፫ ሰዓት ሰሌዳ። ጸሎት አድርሱ። (ሐ.ሥ. ፪፥፩)',
      emoji: '☀️',
    ),
    PrayerTime(
      hour: 12, minute: 0,
      ethiopianTime: 'ቀኑ ፮ ሰዓት',
      name: 'ቀኑ ፮ ሰዓት — ስድስተኛ ሰዓት',
      message: '"ኢየሱስ ክርስቶስ ስለ ዓለሙ ሁሉ ሞተ" — ቀኑ ፮ ሰዓት ጸሎት። (ዮሐ. ፲፱፥፲፬)',
      emoji: '🙏',
    ),
    PrayerTime(
      hour: 15, minute: 0,
      ethiopianTime: 'ቀኑ ፱ ሰዓት',
      name: 'ቀኑ ፱ ሰዓት — ዘጠነኛ ሰዓት',
      message: '"ጌታ ነፍሱን አሳልፎ ሰጠ" — ቀኑ ፱ ሰዓት ጸሎት። ቅሴቃ ዘምሩ። (ሉቃ. ፳፫፥፵፬)',
      emoji: '✝️',
    ),
    PrayerTime(
      hour: 17, minute: 0,
      ethiopianTime: 'ቀኑ ፲፩ ሰዓት',
      name: 'ቀኑ ፲፩ ሰዓት — አስራ አንደኛ ሰዓት',
      message: '"የምሽቱ ጸሎት ቤተ ክርስቲያናዊ" — የቀኑ ምሽት ጸሎት ሰዓት ደርሷል።',
      emoji: '🌇',
    ),
    PrayerTime(
      hour: 21, minute: 0,
      ethiopianTime: 'ሌሊቱ ፫ ሰዓት',
      name: 'ሌሊቱ ፫ ሰዓት — የሌሊት ጸሎት',
      message: '"ጌታ ሆይ ይህን ሌሊት ሰላም አሳልፈኝ" — ሌሊቱ ፫ ሰዓት ጸሎት ሰዓት ደርሷል።',
      emoji: '🌙',
    ),
  ];

  static Future<void> initialize() async {}
  static Future<bool> requestPermission() async => false;
  static void showTest() {}
  static void dispose() {}
  static bool get isGranted => false;

  static PrayerTime get nextPrayer {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final p in prayerTimes) {
      if (p.totalMinutes > nowMinutes) return p;
    }
    return prayerTimes.first;
  }

  static Duration get timeUntilNext {
    final prayer = nextPrayer;
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, prayer.hour, prayer.minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));
    return next.difference(now);
  }
}
