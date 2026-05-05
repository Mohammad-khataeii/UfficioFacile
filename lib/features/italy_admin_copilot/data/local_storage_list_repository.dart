import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageListRepository<T> {
  const LocalStorageListRepository({
    required SharedPreferences prefs,
    required String storageKey,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  }) : _prefs = prefs,
       _storageKey = storageKey,
       _fromJson = fromJson,
       _toJson = toJson;

  final SharedPreferences _prefs;
  final String _storageKey;
  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  List<T> readAll() {
    final raw = _prefs.getString(_storageKey);
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
          .map((item) => _fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> writeAll(List<T> items) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(items.map(_toJson).toList()),
    );
  }
}
