import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_state.dart';
import 'onboarding_repository.dart';

class LocalOnboardingRepository implements OnboardingRepository {
  const LocalOnboardingRepository(this._prefs);

  static const storageKey = 'ufficio_onboarding_seen';
  static const legacyStorageKey = 'italy_life_admin_onboarding_completed_v1';

  final SharedPreferences _prefs;

  @override
  Future<OnboardingState> getState() async {
    try {
      final seen = _prefs.getBool(storageKey);
      if (seen != null) {
        return OnboardingState(
          completed: seen,
          completedAt: seen ? DateTime.now() : null,
        );
      }
    } catch (_) {
      // Older installs may still have a string value under the new key.
    }
    for (final key in <String>[storageKey, legacyStorageKey]) {
      final raw = _prefs.getString(key);
      if (raw == null || raw.isEmpty) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return OnboardingState.fromJson(decoded);
        }
        if (decoded is Map) {
          return OnboardingState.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {}
      if (raw == 'true' || raw == 'false') {
        return OnboardingState(
          completed: raw == 'true',
          completedAt: raw == 'true' ? DateTime.now() : null,
        );
      }
    }
    return const OnboardingState(completed: false);
  }

  @override
  Future<void> setCompleted(bool completed) async {
    final state = OnboardingState(
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    );
    await _prefs.setBool(storageKey, completed);
    await _prefs.setString(legacyStorageKey, jsonEncode(state.toJson()));
  }
}
