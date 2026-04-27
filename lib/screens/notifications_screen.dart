import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/colors.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/models/scheduled_notification.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/viewmodels/notification_viewmodel.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('notifications')),
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          if (vm.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.notifications_off_outlined,
                        size: 36, color: kPrimary.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 16),
                  Text(t.get('no_notifications'),
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'PoppinsRegular',
                          fontSize: 14)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = vm.notifications[i];
              return _NotificationTile(notification: n, vm: vm, t: t);
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: kGradientPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddSheet(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    final granted = await NotificationService.requestPermission();
    print('[NotifScreen] Permission granted: $granted');
    if (!context.mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission denied')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddNotificationSheet(),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final ScheduledNotification notification;
  final NotificationViewModel vm;
  final AppLocalizations t;

  const _NotificationTile({
    required this.notification,
    required this.vm,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final n = notification;
    final timeStr =
        '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';

    String scheduleLabel;
    switch (n.repeat) {
      case NotificationRepeat.daily:
        scheduleLabel = '${t.get('repeat_daily')} · $timeStr';
      case NotificationRepeat.weekly:
        final dayName = _weekdayName(n.weekday ?? 1, t);
        scheduleLabel = '${t.get('repeat_weekly')} · $dayName · $timeStr';
      case NotificationRepeat.once:
        final d = n.oneTimeDate;
        scheduleLabel = d != null
            ? '${t.get('repeat_once')} · '
                '${d.day.toString().padLeft(2, '0')}.'
                '${d.month.toString().padLeft(2, '0')}.'
                '${d.year} $timeStr'
            : t.get('repeat_once');
    }

    final IconData icon = n.repeat == NotificationRepeat.once
        ? Icons.alarm_rounded
        : Icons.notifications_active_rounded;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: n.isActive
                    ? kPrimary.withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon,
                  size: 22,
                  color: n.isActive
                      ? kPrimary
                      : colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: TextStyle(
                        fontFamily: 'PoppinsMedium',
                        fontSize: 14,
                        color: n.isActive
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      )),
                  const SizedBox(height: 2),
                  Text(n.body,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'PoppinsLight',
                          color: colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: n.isActive
                          ? kPrimary.withValues(alpha: 0.08)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(scheduleLabel,
                        style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'PoppinsRegular',
                            color: n.isActive
                                ? kPrimary
                                : colorScheme.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            Column(
              children: [
                Switch(
                  value: n.isActive,
                  onChanged: (_) => vm.toggle(n.id),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kDanger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: kDanger, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.get('delete_notification'),
            style: const TextStyle(fontFamily: 'PoppinsMedium')),
        content: Text(notification.title,
            style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'PoppinsRegular')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.get('cancel'),
                  style: TextStyle(color: colorScheme.onSurfaceVariant))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.get('delete'),
                  style: const TextStyle(
                      color: kDanger, fontFamily: 'PoppinsMedium'))),
        ],
      ),
    );
    if (confirmed == true) await vm.remove(notification.id);
  }

  String _weekdayName(int wd, AppLocalizations t) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return t.get(keys[(wd - 1).clamp(0, 6)]);
  }
}

// ── Add notification bottom sheet ────────────────────────────────────────────

class _AddNotificationSheet extends StatefulWidget {
  const _AddNotificationSheet();

  @override
  State<_AddNotificationSheet> createState() => _AddNotificationSheetState();
}

class _AddNotificationSheetState extends State<_AddNotificationSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  NotificationRepeat _repeat = NotificationRepeat.daily;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  int _weekday = 1;
  DateTime _oneTimeDate = DateTime.now().add(const Duration(hours: 1));
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _oneTimeDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _oneTimeDate = DateTime(
          picked.year, picked.month, picked.day, _time.hour, _time.minute));
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    try {
      final vm = context.read<NotificationViewModel>();
      final t = AppLocalizations.of(context, listen: false);

      final n = ScheduledNotification(
        id: vm.nextId,
        title: title,
        body: body.isEmpty ? t.get('notification_default_body') : body,
        repeat: _repeat,
        hour: _time.hour,
        minute: _time.minute,
        weekday: _repeat == NotificationRepeat.weekly ? _weekday : null,
        oneTimeDate: _repeat == NotificationRepeat.once ? _oneTimeDate : null,
      );

      await vm.add(n);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final mediaHeight = MediaQuery.of(context).size.height;

    return Container(
      height: mediaHeight * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              Text(t.get('add_notification'),
                  style: const TextStyle(
                      fontFamily: 'PoppinsMedium', fontSize: 20)),
              const SizedBox(height: 24),

              // Title
              _FieldLabel(text: t.get('notification_title')),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: t.get('notification_title_hint'),
                  prefixIcon: Icon(Icons.title_rounded,
                      size: 20, color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 20),

              // Body
              _FieldLabel(text: t.get('notification_body')),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: t.get('notification_body_hint'),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.message_outlined,
                        size: 20, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Repeat type
              _FieldLabel(text: t.get('notification_repeat')),
              const SizedBox(height: 10),
              _RepeatSelector(
                  selected: _repeat,
                  t: t,
                  onChanged: (r) => setState(() => _repeat = r)),
              const SizedBox(height: 24),

              // Time picker
              _FieldLabel(text: t.get('notification_time')),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 20, color: kPrimary),
                      const SizedBox(width: 12),
                      Text(
                        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                            fontFamily: 'PoppinsMedium', fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              // Weekly: day picker
              if (_repeat == NotificationRepeat.weekly) ...[
                const SizedBox(height: 24),
                _FieldLabel(text: t.get('notification_weekday')),
                const SizedBox(height: 10),
                _WeekdayPicker(
                    selected: _weekday,
                    t: t,
                    onChanged: (d) => setState(() => _weekday = d)),
              ],

              // Once: date picker
              if (_repeat == NotificationRepeat.once) ...[
                const SizedBox(height: 24),
                _FieldLabel(text: t.get('notification_date')),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 20, color: kPrimary),
                        const SizedBox(width: 12),
                        Text(
                          '${_oneTimeDate.day.toString().padLeft(2, '0')}.${_oneTimeDate.month.toString().padLeft(2, '0')}.${_oneTimeDate.year}',
                          style: const TextStyle(
                              fontFamily: 'PoppinsMedium', fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: kGradientPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(t.get('schedule'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'PoppinsMedium',
                                fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontFamily: 'PoppinsMedium',
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}

class _RepeatSelector extends StatelessWidget {
  final NotificationRepeat selected;
  final AppLocalizations t;
  final ValueChanged<NotificationRepeat> onChanged;

  const _RepeatSelector(
      {required this.selected, required this.t, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: NotificationRepeat.values.map((r) {
        final label = switch (r) {
          NotificationRepeat.once => t.get('repeat_once'),
          NotificationRepeat.daily => t.get('repeat_daily'),
          NotificationRepeat.weekly => t.get('repeat_weekly'),
        };
        final active = selected == r;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                gradient: active ? kGradientPrimary : null,
                color: active ? null : kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : kPrimary,
                    fontSize: 13,
                    fontFamily: active ? 'PoppinsMedium' : 'PoppinsRegular',
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  final int selected;
  final AppLocalizations t;
  final ValueChanged<int> onChanged;

  const _WeekdayPicker(
      {required this.selected, required this.t, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const keys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    return Row(
      children: List.generate(7, (i) {
        final wd = i + 1;
        final active = selected == wd;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(wd),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: active ? kGradientPrimary : null,
                color: active ? null : kPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  t.get(keys[i]),
                  style: TextStyle(
                    color: active ? Colors.white : kPrimary,
                    fontSize: 12,
                    fontFamily: active ? 'PoppinsMedium' : 'PoppinsRegular',
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
