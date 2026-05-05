import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_state.dart';
import 'onboarding_repository.dart';

class LocalOnboardingRepository implements OnboardingRepository {
  const LocalOnboardingRepository(this._prefs);

  static const storageKey = 'italy_life_admin_onboarding_completed_v1';

  final SharedPreferences _prefs;

  @override
  Future<OnboardingState> getState() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const OnboardingState(completed: false);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return OnboardingState.fromJson(decoded);
      }
      if (decoded is Map) {
        return OnboardingState.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return const OnboardingState(completed: false);
  }

  @override
  Future<void> setCompleted(bool completed) async {
    final state = OnboardingState(
      completed: completed,
      completedAt: completed ? DateTime.now() : null,
    );
    await _prefs.setString(storageKey, jsonEncode(state.toJson()));
  }
}
