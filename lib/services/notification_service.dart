import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:my_app/models/scheduled_notification.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // ── Initialisation ──────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Request POST_NOTIFICATIONS permission on Android 13+.
  static Future<bool> requestPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return (await impl?.requestNotificationsPermission()) ?? false;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static AndroidNotificationDetails get _androidDetails =>
      const AndroidNotificationDetails(
        'myfinance_reminders',
        'MyFinance Reminders',
        channelDescription: 'Finance reminders and scheduled alerts',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

  static NotificationDetails get _details =>
      NotificationDetails(android: _androidDetails);

  /// Computes the next [tz.TZDateTime] matching [hour]:[minute].
  /// If [weekday] is provided (1=Mon … 7=Sun) advances to that day.
  static tz.TZDateTime _nextInstance(int hour, int minute, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (weekday != null) {
      while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    } else if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ── Schedule / Cancel ────────────────────────────────────────────────────────

  static Future<void> scheduleNotification(ScheduledNotification n) async {
    await cancel(n.id); // always cancel old instance first
    if (!n.isActive) return;

    switch (n.repeat) {
      case NotificationRepeat.once:
        if (n.oneTimeDate == null) return;
        final when = tz.TZDateTime.from(n.oneTimeDate!, tz.local);
        if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;
        await _plugin.zonedSchedule(
          n.id, n.title, n.body, when, _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case NotificationRepeat.daily:
        await _plugin.zonedSchedule(
          n.id, n.title, n.body,
          _nextInstance(n.hour, n.minute),
          _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

      case NotificationRepeat.weekly:
        await _plugin.zonedSchedule(
          n.id, n.title, n.body,
          _nextInstance(n.hour, n.minute, weekday: n.weekday),
          _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
    }
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);
  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();
}
