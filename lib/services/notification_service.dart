export 'notification_service_stub.dart'
    if (dart.library.html) 'notification_service_web.dart'
    if (dart.library.io) 'notification_service_mobile.dart';

class PrayerTime {
  final int hour; // International 24h time
  final int minute;
  final String name;
  final String ethiopianTime;
  final String message;
  final String emoji;

  const PrayerTime({
    required this.hour,
    required this.minute,
    required this.name,
    required this.ethiopianTime,
    required this.message,
    required this.emoji,
  });

  int get totalMinutes => hour * 60 + minute;
}
