import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'connected_product_data.dart';
import 'premium_service.dart';

class NotificationPreferences {
  const NotificationPreferences({
    this.enabled = true,
    this.deadlines = true,
    this.checklist = true,
    this.costs = true,
    this.premium = true,
    this.promotions = true,
  });

  final bool enabled;
  final bool deadlines;
  final bool checklist;
  final bool costs;
  final bool premium;
  final bool promotions;

  NotificationPreferences copyWith({
    bool? enabled,
    bool? deadlines,
    bool? checklist,
    bool? costs,
    bool? premium,
    bool? promotions,
  }) => NotificationPreferences(
    enabled: enabled ?? this.enabled,
    deadlines: deadlines ?? this.deadlines,
    checklist: checklist ?? this.checklist,
    costs: costs ?? this.costs,
    premium: premium ?? this.premium,
    promotions: promotions ?? this.promotions,
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'deadlines': deadlines,
    'checklist': checklist,
    'costs': costs,
    'premium': premium,
    'promotions': promotions,
  };

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      NotificationPreferences(
        enabled: json['enabled'] as bool? ?? true,
        deadlines: json['deadlines'] as bool? ?? true,
        checklist: json['checklist'] as bool? ?? true,
        costs: json['costs'] as bool? ?? true,
        premium: json['premium'] as bool? ?? true,
        promotions: json['promotions'] as bool? ?? true,
      );
}

class NotificationInboxItem {
  const NotificationInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.targetRoute,
    this.targetId,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final String? targetRoute;
  final String? targetId;
}

class UfficioNotificationService {
  UfficioNotificationService({
    required SharedPreferences prefs,
    required ConnectedUserDataRepository userDataRepository,
    required UfficioPremiumEntitlementService entitlementService,
  }) : _prefs = prefs,
       _userDataRepository = userDataRepository,
       _entitlementService = entitlementService;

  final SharedPreferences _prefs;
  final ConnectedUserDataRepository _userDataRepository;
  final UfficioPremiumEntitlementService _entitlementService;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _preferencesKey = 'ufficio_notification_preferences_v1';
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      _initialized = true;
      return;
    }
    tz.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<NotificationPreferences> getPreferences() async {
    final raw = _prefs.getString(_preferencesKey);
    if (raw == null || raw.isEmpty) {
      return const NotificationPreferences();
    }
    try {
      return NotificationPreferences.fromJson(
        Map<String, dynamic>.from(_decodeJson(raw) as Map),
      );
    } catch (_) {
      return const NotificationPreferences();
    }
  }

  Future<NotificationPreferences> savePreferences(
    NotificationPreferences preferences,
  ) async {
    await _prefs.setString(_preferencesKey, _encodeJson(preferences.toJson()));
    await syncScheduledNotifications();
    return preferences;
  }

  Future<bool> requestPermissionIfNeeded() async {
    await initialize();
    if (kIsWeb) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    final macosGranted = await macos?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return androidGranted ?? iosGranted ?? macosGranted ?? true;
  }

  Future<void> syncScheduledNotifications() async {
    await initialize();
    if (kIsWeb) return;
    final preferences = await getPreferences();
    await _plugin.cancelAll();
    if (!preferences.enabled) return;
    final granted = await requestPermissionIfNeeded();
    if (!granted) return;

    final deadlines = await _userDataRepository.listDeadlines();
    final checklist = await _userDataRepository.listChecklistItems();
    final costs = await _userDataRepository.listCostItems();
    final entitlement = await _entitlementService.getCurrentEntitlement();

    final now = DateTime.now();
    for (final item in deadlines) {
      if (!preferences.deadlines ||
          !item.reminderEnabled ||
          item.status == ConnectedDeadlineStatus.done ||
          item.status == ConnectedDeadlineStatus.canceled) {
        continue;
      }
      final reminderAt = item.dueDate.subtract(
        Duration(days: item.reminderOffsetDays),
      );
      if (reminderAt.isAfter(now)) {
        await _scheduleAt(
          id: _notificationId(item.id, 'deadline_before'),
          title: item.title,
          body: 'Due on ${_formatDate(item.dueDate)}. ${item.description}',
          when: reminderAt,
        );
      }
      if (item.dueDate.isAfter(now)) {
        await _scheduleAt(
          id: _notificationId(item.id, 'deadline_due'),
          title: item.title,
          body: 'Today is the due date. ${item.description}',
          when: item.dueDate,
        );
      }
    }

    for (final item in checklist) {
      if (!preferences.checklist ||
          item.dueDate == null ||
          item.status == ConnectedChecklistStatus.done ||
          item.status == ConnectedChecklistStatus.skipped) {
        continue;
      }
      final dueDate = item.dueDate!;
      final reminderAt = dueDate.subtract(const Duration(days: 2));
      if (reminderAt.isAfter(now)) {
        await _scheduleAt(
          id: _notificationId(item.id, 'checklist_before'),
          title: item.title,
          body: 'Checklist item due on ${_formatDate(dueDate)}.',
          when: reminderAt,
        );
      }
      if (dueDate.isAfter(now)) {
        await _scheduleAt(
          id: _notificationId(item.id, 'checklist_due'),
          title: item.title,
          body: 'Checklist item due today.',
          when: dueDate,
        );
      }
    }

    for (final item in costs) {
      if (!preferences.costs ||
          item.dueDate == null ||
          item.status == ConnectedCostStatus.paid ||
          item.status == ConnectedCostStatus.waived) {
        continue;
      }
      final dueDate = item.dueDate!;
      final reminderAt = dueDate.subtract(const Duration(days: 3));
      if (reminderAt.isAfter(now)) {
        await _scheduleAt(
          id: _notificationId(item.id, 'cost_before'),
          title: item.title,
          body: 'Check this payment before ${_formatDate(dueDate)}.',
          when: reminderAt,
        );
      }
    }

    if (preferences.premium &&
        entitlement.hasActivePremiumEntitlement &&
        entitlement.currentPeriodEnd != null) {
      final renewalReminder = entitlement.currentPeriodEnd!.subtract(
        const Duration(days: 3),
      );
      if (renewalReminder.isAfter(now)) {
        await _scheduleAt(
          id: _notificationId(
            entitlement.userId ?? 'current_user',
            'premium_renewal',
          ),
          title: 'Premium plan',
          body:
              'Your premium access is due to end on ${_formatDate(entitlement.currentPeriodEnd!)}.',
          when: renewalReminder,
        );
      }
    }
  }

  Future<List<NotificationInboxItem>> buildInbox() async {
    final deadlines = await _userDataRepository.listDeadlines();
    final checklist = await _userDataRepository.listChecklistItems();
    final costs = await _userDataRepository.listCostItems();
    final scans = await _userDataRepository.listScans();
    final entitlement = await _entitlementService.getCurrentEntitlement();
    final now = DateTime.now();
    final items = <NotificationInboxItem>[];

    for (final item in deadlines) {
      if (item.status == ConnectedDeadlineStatus.done ||
          item.status == ConnectedDeadlineStatus.canceled) {
        continue;
      }
      final difference = item.dueDate.difference(now).inDays;
      if (difference <= 7) {
        items.add(
          NotificationInboxItem(
            id: 'deadline_${item.id}',
            title: item.title,
            body: difference < 0
                ? 'This deadline is overdue.'
                : difference == 0
                ? 'This deadline is today.'
                : 'Due in $difference day${difference == 1 ? '' : 's'}.',
            type: 'deadline',
            createdAt: item.updatedAt,
            targetRoute: '/life-admin/deadlines',
            targetId: item.id,
          ),
        );
      }
    }

    for (final item in checklist) {
      if (item.dueDate == null ||
          item.status == ConnectedChecklistStatus.done ||
          item.status == ConnectedChecklistStatus.skipped) {
        continue;
      }
      if (item.dueDate!.isBefore(now.add(const Duration(days: 5)))) {
        items.add(
          NotificationInboxItem(
            id: 'checklist_${item.id}',
            title: item.title,
            body: 'Checklist step to finish soon.',
            type: 'checklist',
            createdAt: item.updatedAt,
            targetRoute: '/life-admin/checklist',
            targetId: item.id,
          ),
        );
      }
    }

    for (final item in costs) {
      if (item.dueDate == null ||
          item.status == ConnectedCostStatus.paid ||
          item.status == ConnectedCostStatus.waived) {
        continue;
      }
      if (item.dueDate!.isBefore(now.add(const Duration(days: 7)))) {
        items.add(
          NotificationInboxItem(
            id: 'cost_${item.id}',
            title: item.title,
            body: 'Check this cost before the due date.',
            type: 'cost',
            createdAt: item.updatedAt,
            targetRoute: '/life-admin/costs',
            targetId: item.id,
          ),
        );
      }
    }

    if (scans.isNotEmpty) {
      final latestScan = scans.first;
      final deadline = latestScan.urgency['deadlineDate']?.toString() ?? '';
      final late = latestScan.urgency['alreadyLate'] == true;
      if (late || deadline.isNotEmpty) {
        items.add(
          NotificationInboxItem(
            id: 'scan_${latestScan.id}',
            title: 'Situation scan',
            body: late
                ? 'One of your scanned items is already late.'
                : 'You saved a case with a deadline to watch.',
            type: 'scan',
            createdAt: latestScan.updatedAt,
            targetRoute: '/life-admin/scan',
            targetId: latestScan.id,
          ),
        );
      }
    }

    if (entitlement.hasActivePremiumEntitlement &&
        entitlement.currentPeriodEnd != null &&
        entitlement.currentPeriodEnd!.isBefore(
          now.add(const Duration(days: 7)),
        )) {
      items.add(
        NotificationInboxItem(
          id: 'premium_${entitlement.userId ?? 'current'}',
          title: 'Premium plan',
          body:
              'Your current access ends on ${_formatDate(entitlement.currentPeriodEnd!)}.',
          type: 'premium',
          createdAt: entitlement.updatedAt ?? now,
          targetRoute: '/life-admin/plan',
        ),
      );
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    final scheduled = _normalizeTime(when);
    if (scheduled.isBefore(DateTime.now())) return;
    const android = AndroidNotificationDetails(
      'ufficio_reminders',
      'Ufficio reminders',
      channelDescription: 'Deadlines, checklist, and payment reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  DateTime _normalizeTime(DateTime value) {
    if (value.hour == 0 && value.minute == 0) {
      return DateTime(value.year, value.month, value.day, 9);
    }
    return value;
  }

  int _notificationId(String value, String suffix) =>
      Object.hash(value, suffix) & 0x7fffffff;

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  Object _decodeJson(String raw) => jsonDecode(raw);
  String _encodeJson(Map<String, dynamic> value) => jsonEncode(value);
}
