import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/models/scheduled_notification.dart';
import 'package:my_app/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  static const _prefsKey = 'scheduled_notifications';

  List<ScheduledNotification> _notifications = [];

  List<ScheduledNotification> get notifications =>
      List.unmodifiable(_notifications);

  NotificationViewModel() {
    _load();
  }

  // ── Persistence ──────────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json != null) {
      _notifications = ScheduledNotification.decodeList(json);
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, ScheduledNotification.encodeList(_notifications));
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  Future<void> add(ScheduledNotification n) async {
    _notifications.add(n);
    await NotificationService.scheduleNotification(n);
    await _save();
    notifyListeners();
  }

  Future<void> remove(int id) async {
    _notifications.removeWhere((n) => n.id == id);
    await NotificationService.cancel(id);
    await _save();
    notifyListeners();
  }

  Future<void> toggle(int id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final updated =
        _notifications[idx].copyWith(isActive: !_notifications[idx].isActive);
    _notifications[idx] = updated;
    await NotificationService.scheduleNotification(updated);
    await _save();
    notifyListeners();
  }

  /// Returns an ID that is guaranteed to be unique in the current list.
  int get nextId {
    if (_notifications.isEmpty) return 1;
    return _notifications.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
