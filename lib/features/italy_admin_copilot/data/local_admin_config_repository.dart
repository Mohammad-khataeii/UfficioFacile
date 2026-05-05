import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/admin_config.dart';
import 'admin_config_repository.dart';

class LocalAdminConfigRepository implements AdminConfigRepository {
  const LocalAdminConfigRepository(this._prefs);

  static const storageKey = 'italy_life_admin_admin_config_v1';

  final SharedPreferences _prefs;

  @override
  Future<AdminConfig> getConfig() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const AdminConfig();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AdminConfig.fromJson(decoded);
      }
      if (decoded is Map) {
        return AdminConfig.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return const AdminConfig();
  }

  @override
  Future<AdminConfig> saveConfig(AdminConfig config) async {
    await _prefs.setString(storageKey, jsonEncode(config.toJson()));
    return config;
  }
}
