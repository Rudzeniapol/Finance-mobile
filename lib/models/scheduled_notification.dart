import 'dart:convert';

enum NotificationRepeat { once, daily, weekly }

class ScheduledNotification {
  final int id;
  final String title;
  final String body;
  final NotificationRepeat repeat;
  final int hour;
  final int minute;
  final int? weekday; // 1 = Mon … 7 = Sun (for weekly)
  final DateTime? oneTimeDate; // for once
  final bool isActive;

  const ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.repeat,
    required this.hour,
    required this.minute,
    this.weekday,
    this.oneTimeDate,
    this.isActive = true,
  });

  ScheduledNotification copyWith({bool? isActive}) => ScheduledNotification(
        id: id,
        title: title,
        body: body,
        repeat: repeat,
        hour: hour,
        minute: minute,
        weekday: weekday,
        oneTimeDate: oneTimeDate,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'repeat': repeat.name,
        'hour': hour,
        'minute': minute,
        'weekday': weekday,
        'oneTimeDate': oneTimeDate?.toIso8601String(),
        'isActive': isActive,
      };

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) =>
      ScheduledNotification(
        id: json['id'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
        repeat: NotificationRepeat.values.firstWhere(
          (e) => e.name == json['repeat'],
          orElse: () => NotificationRepeat.once,
        ),
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        weekday: json['weekday'] as int?,
        oneTimeDate: json['oneTimeDate'] != null
            ? DateTime.parse(json['oneTimeDate'] as String)
            : null,
        isActive: json['isActive'] as bool? ?? true,
      );

  static String encodeList(List<ScheduledNotification> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ScheduledNotification> decodeList(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list
        .map((e) =>
            ScheduledNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
