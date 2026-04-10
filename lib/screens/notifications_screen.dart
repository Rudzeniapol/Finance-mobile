import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/locals/app_localizations.dart';
import 'package:my_app/models/scheduled_notification.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/viewmodels/notification_viewmodel.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
                  Icon(Icons.notifications_off_outlined,
                      size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(t.get('no_notifications'),
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: vm.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = vm.notifications[i];
              return _NotificationTile(notification: n, vm: vm, t: t);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    // Request permission before showing the sheet
    await NotificationService.requestPermission();
    if (!context.mounted) return;
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

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          n.repeat == NotificationRepeat.once
              ? Icons.alarm
              : Icons.notifications_active,
          color: n.isActive ? Colors.blue : Colors.grey,
        ),
        title: Text(n.title,
            style: TextStyle(
              fontFamily: 'PoppinsMedium',
              color: n.isActive
                  ? colorScheme.onSurface
                  : Colors.grey,
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.body,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(scheduleLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: n.isActive ? Colors.blue : Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: n.isActive,
              activeColor: Colors.blue,
              onChanged: (_) => vm.toggle(n.id),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.get('delete_notification')),
        content: Text(notification.title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.get('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.get('delete'),
                  style: const TextStyle(color: Colors.redAccent))),
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
  int _weekday = 1; // Monday
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
      setState(() => _oneTimeDate =
          DateTime(picked.year, picked.month, picked.day, _time.hour, _time.minute));
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

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
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text(t.get('add_notification'),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              // Title
              _fieldLabel(t.get('notification_title')),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                decoration: _inputDecoration(t.get('notification_title_hint')),
              ),
              const SizedBox(height: 16),

              // Body
              _fieldLabel(t.get('notification_body')),
              const SizedBox(height: 6),
              TextField(
                controller: _bodyCtrl,
                maxLines: 2,
                decoration: _inputDecoration(t.get('notification_body_hint')),
              ),
              const SizedBox(height: 20),

              // Repeat type
              _fieldLabel(t.get('notification_repeat')),
              const SizedBox(height: 8),
              _RepeatSelector(
                  selected: _repeat,
                  t: t,
                  onChanged: (r) => setState(() => _repeat = r)),
              const SizedBox(height: 20),

              // Time picker
              _fieldLabel(t.get('notification_time')),
              const SizedBox(height: 6),
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
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 10),
                      Text(
                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ),
              ),

              // Weekly: day picker
              if (_repeat == NotificationRepeat.weekly) ...[
                const SizedBox(height: 20),
                _fieldLabel(t.get('notification_weekday')),
                const SizedBox(height: 8),
                _WeekdayPicker(
                    selected: _weekday,
                    t: t,
                    onChanged: (d) => setState(() => _weekday = d)),
              ],

              // Once: date picker
              if (_repeat == NotificationRepeat.once) ...[
                const SizedBox(height: 20),
                _fieldLabel(t.get('notification_date')),
                const SizedBox(height: 6),
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
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 10),
                        Text(
                            '${_oneTimeDate.day.toString().padLeft(2, '0')}.${_oneTimeDate.month.toString().padLeft(2, '0')}.${_oneTimeDate.year}'),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(t.get('schedule'),
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'PoppinsMedium')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontFamily: 'PoppinsMedium', fontSize: 13, color: Colors.grey),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
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
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:
                    active ? Colors.blue : Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.blue,
                    fontSize: 12,
                    fontFamily: 'PoppinsRegular',
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
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? Colors.blue : Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  t.get(keys[i]),
                  style: TextStyle(
                    color: active ? Colors.white : Colors.blue,
                    fontSize: 11,
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
