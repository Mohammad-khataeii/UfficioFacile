import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/procedure_template_override.dart';
import 'template_override_repository.dart';

class LocalProcedureTemplateOverrideRepository
    implements ProcedureTemplateOverrideRepository {
  const LocalProcedureTemplateOverrideRepository(this._prefs);

  static const storageKey = 'italy_life_admin_template_overrides_v1';

  final SharedPreferences _prefs;

  @override
  Future<List<ProcedureTemplateOverride>> listOverrides() async {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map(
            (item) => ProcedureTemplateOverride.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveOverride(ProcedureTemplateOverride override) async {
    final items = await listOverrides()
      ..removeWhere((item) => item.procedureId == override.procedureId)
      ..add(override);
    await _prefs.setString(
      storageKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
