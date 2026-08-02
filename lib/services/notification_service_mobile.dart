import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _permissionGranted = false;

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
    tz.initializeTimeZones();
    // Default fallback to Addis Ababa timezone for Orthodox users
    try {
      tz.setLocalLocation(tz.getLocation('Africa/Addis_Ababa'));
    } catch (_) {
      // Fallback if zone not loaded
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle when notification is clicked
      },
    );

    // Check if permission is already granted
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      _permissionGranted = granted ?? false;
      if (_permissionGranted) {
        await _scheduleAllPrayers();
      }
    }
  }

  static Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      _permissionGranted = granted ?? false;
      if (_permissionGranted) {
        await _scheduleAllPrayers();
      }
      return _permissionGranted;
    }
    return false;
  }

  static Future<void> _scheduleAllPrayers() async {
    // Cancel any previously scheduled notifications to avoid duplicates
    await _plugin.cancelAll();

    final local = tz.local;
    for (int i = 0; i < prayerTimes.length; i++) {
      final prayer = prayerTimes[i];
      final now = tz.TZDateTime.now(local);
      var scheduledDate = tz.TZDateTime(
        local,
        now.year,
        now.month,
        now.day,
        prayer.hour,
        prayer.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        i, // Unique notification ID
        '${prayer.emoji} ${prayer.name}',
        prayer.message,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'የጸሎት ሰዓት ማሳወቂያ',
            channelDescription: 'የሰንበት ትምህርት የጸሎት ሰዓታት ማሳሰቢያ',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
    }
  }

  static void showTest() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'ሙከራ',
      channelDescription: 'የማሳወቂያ ሙከራ ቻናል',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      99,
      '✅ ሰ/ት/ቤት ጸሎት ሰዓቶች ተዘጋጅቷል',
      'ሁሉም የጸሎት ሰዓቶች ማሳወቂያ በተሳካ ሁኔታ ተቀብለዋል። ይጸልዩ!',
      details,
    );
  }

  static void dispose() {}

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
