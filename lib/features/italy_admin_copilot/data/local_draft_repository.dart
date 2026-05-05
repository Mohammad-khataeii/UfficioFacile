import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/draft.dart';
import 'draft_repository.dart';

class LocalDraftRepository implements DraftRepository {
  const LocalDraftRepository(this._prefs);

  static const storageKey = 'italy_life_admin_drafts_v1';

  final SharedPreferences _prefs;

  List<DraftEntry> _read() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .whereType<Map>()
          .map((item) => DraftEntry.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _write(List<DraftEntry> items) async {
    await _prefs.setString(
      storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteDraft(String procedureId) async {
    final items = _read()
      ..removeWhere((item) => item.procedureId == procedureId);
    await _write(items);
  }

  @override
  Future<DraftEntry?> getDraft(String procedureId) async {
    for (final item in _read()) {
      if (item.procedureId == procedureId) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<DraftEntry>> listDrafts() async => _read();

  @override
  Future<void> saveDraft(DraftEntry draft) async {
    final items = _read()
      ..removeWhere((item) => item.procedureId == draft.procedureId);
    items.add(draft);
    await _write(items);
  }
}
