// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class NotificationService {
  static Timer? _timer;
  static bool _permissionGranted = false;
  static final Set<String> _notifiedKeys = {};

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

  static Future<void> initialize() async {
    _permissionGranted = html.Notification.permission == 'granted';
    if (_permissionGranted) {
      _startTimer();
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final result = await html.Notification.requestPermission();
      _permissionGranted = result == 'granted';
      if (_permissionGranted) {
        _startTimer();
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
    return _permissionGranted;
  }

  static void _startTimer() {
    _timer?.cancel();
    _checkPrayerTimes();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkPrayerTimes());
  }

  static void _checkPrayerTimes() {
    if (!_permissionGranted) return;
    final now = DateTime.now();
    final key = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';

    for (final prayer in prayerTimes) {
      final prayerKey = '$key-${prayer.hour}';
      if (!_notifiedKeys.contains(prayerKey) &&
          now.hour == prayer.hour &&
          now.minute == prayer.minute) {
        _show(prayer);
        _notifiedKeys.add(prayerKey);
        if (_notifiedKeys.length > 200) _notifiedKeys.clear();
      }
    }
  }

  static void _show(PrayerTime prayer) {
    try {
      final n = html.Notification(
        '${prayer.emoji} ${prayer.name}',
        body: prayer.message,
        icon: 'icons/Icon-192.png',
        tag: 'prayer-${prayer.hour}',
      );
      Timer(const Duration(seconds: 12), n.close);
    } catch (e) {
      debugPrint('Show notification error: $e');
    }
  }

  static void showTest() {
    _show(const PrayerTime(
      hour: 0, minute: 0,
      ethiopianTime: 'ሙከራ',
      name: 'ሰ/ት/ቤት ጸሎት ሰዓቶች ተዘጋጅቷል ✓',
      message: 'ሁሉም የጸሎት ሰዓቶች ማሳወቂያ ተቀብለዋል። ይጸልዩ!',
      emoji: '✅',
    ));
  }

  static void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  static bool get isGranted => _permissionGranted;

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
