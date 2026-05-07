import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/usage_event.dart';
import 'analytics_service.dart';
import 'ufficcio_supabase_readiness.dart';

class LocalAnalyticsService implements AnalyticsService {
  LocalAnalyticsService(this._prefs, {UfficcioAnalyticsSanitizer? sanitizer})
    : _sanitizer = sanitizer ?? UfficcioAnalyticsSanitizer();

  static const storageKey = 'italy_life_admin_usage_events_v1';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();
  final UfficcioAnalyticsSanitizer _sanitizer;

  List<UsageEvent> listEvents() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => UsageEvent.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> _track(
    String eventName, {
    String? procedureId,
    String? category,
    Map<String, dynamic> metadata = const {},
  }) async {
    final safeMetadata = _sanitizer.sanitize(metadata);
    final items = listEvents()
      ..insert(
        0,
        UsageEvent(
          id: _uuid.v4(),
          eventName: eventName,
          createdAt: DateTime.now(),
          procedureId: procedureId,
          category: category,
          metadata: safeMetadata,
        ),
      );
    await _prefs.setString(
      storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> trackCopilotOpened() => _track('app_opened');

  @override
  Future<void> trackPackCopied(String procedureId, String copyType) => _track(
    'pack_copied',
    procedureId: procedureId,
    metadata: {'copyType': copyType},
  );

  @override
  Future<void> trackPackGenerated(String procedureId) =>
      _track('pack_generated', procedureId: procedureId);

  @override
  Future<void> trackProcedureSelected(String procedureId) =>
      _track('procedure_opened', procedureId: procedureId);

  @override
  Future<void> trackProcedureStarted(String procedureId) =>
      _track('form_started', procedureId: procedureId);

  @override
  Future<void> trackRequestSaved(String procedureId) =>
      _track('request_saved', procedureId: procedureId);

  @override
  Future<void> trackStatusUpdated(String status) =>
      _track('status_updated', metadata: {'status': status});

  @override
  Future<void> trackValidationFailed(String procedureId) =>
      _track('validation_failed', procedureId: procedureId);
}
