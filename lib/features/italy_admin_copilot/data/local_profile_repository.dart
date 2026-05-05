import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/admin_copilot_profile.dart';
import 'profile_repository.dart';

class LocalAdminCopilotProfileRepository
    implements AdminCopilotProfileRepository {
  const LocalAdminCopilotProfileRepository(this._prefs);

  static const profileStorageKey = 'italy_life_admin_profile_v1';

  final SharedPreferences _prefs;

  @override
  Future<void> clearProfile() async {
    await _prefs.remove(profileStorageKey);
  }

  @override
  Future<AdminCopilotProfile?> getProfile() async {
    final raw = _prefs.getString(profileStorageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AdminCopilotProfile.fromJson(decoded);
      }
      if (decoded is Map) {
        return AdminCopilotProfile.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await _prefs.remove(profileStorageKey);
    }
    return null;
  }

  @override
  Future<AdminCopilotProfile> saveProfile(AdminCopilotProfile profile) async {
    await _prefs.setString(profileStorageKey, jsonEncode(profile.toJson()));
    return profile;
  }
}
