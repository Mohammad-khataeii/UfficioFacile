import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, SupabaseClient;
import 'package:uuid/uuid.dart';

import '../../../app/supabase_bootstrap.dart';
import '../domain/auth_user.dart';
import 'auth_repository.dart';

class DeviceBindingService {
  DeviceBindingService(this._prefs);

  static const installationIdStorageKey =
      'ufficiofacile_bound_installation_id_v1';

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();
  bool? _supportsProfileMetadata;

  Future<String> getOrCreateInstallationId() async {
    final cached = _prefs.getString(installationIdStorageKey);
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }
    final created = _uuid.v4();
    await _prefs.setString(installationIdStorageKey, created);
    return created;
  }

  Future<void> enforceForSignedInUser(AuthUser user) async {
    final client = SupabaseBootstrap.client;
    if (client == null || !user.isAuthenticated) {
      throw const AuthFailure(
        'UfficioFacile needs a live Supabase session to finish sign-in.',
      );
    }

    final table = await _resolveProfileTable(client);
    final supportsMetadata = await _profileTableSupportsMetadata(client, table);
    if (!supportsMetadata) {
      assert(() {
        debugPrint(
          '[Auth] Profile metadata column is unavailable; skipping device binding until the latest profile migration is applied.',
        );
        return true;
      }());
      return;
    }
    final installationId = await getOrCreateInstallationId();
    final now = DateTime.now().toUtc().toIso8601String();
    final row = await client
        .from(table)
        .select('user_id, email, metadata')
        .eq('user_id', user.id)
        .maybeSingle();
    final existingMetadata = _jsonMap(row?['metadata']);
    final binding = _jsonMap(existingMetadata['device_binding']);
    final boundInstallationId = binding['installation_id'] as String?;
    if (boundInstallationId != null &&
        boundInstallationId.isNotEmpty &&
        boundInstallationId != installationId) {
      throw const AuthFailure(
        'This account is locked to another device. Use the original device or contact support.',
      );
    }

    final mergedMetadata = <String, dynamic>{
      ...existingMetadata,
      'device_binding': <String, dynamic>{
        ...binding,
        'installation_id': installationId,
        'platform': _platformLabel,
        'bound_at': binding['bound_at'] ?? now,
        'last_seen_at': now,
      },
    };

    await client.from(table).upsert(<String, dynamic>{
      'user_id': user.id,
      'email': user.email,
      'metadata': mergedMetadata,
    }, onConflict: 'user_id');
  }

  Future<String> _resolveProfileTable(SupabaseClient client) async {
    try {
      await client.from('ufficio_profiles').select('user_id').limit(1);
      return 'ufficio_profiles';
    } on PostgrestException {
      return 'ufficcio_profiles';
    }
  }

  Future<bool> _profileTableSupportsMetadata(
    SupabaseClient client,
    String table,
  ) async {
    final cached = _supportsProfileMetadata;
    if (cached != null) {
      return cached;
    }
    try {
      await client.from(table).select('metadata').limit(1);
      _supportsProfileMetadata = true;
      return true;
    } on PostgrestException catch (error) {
      if (_isMissingColumnError(error, 'metadata')) {
        _supportsProfileMetadata = false;
        return false;
      }
      rethrow;
    }
  }

  String get _platformLabel => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    TargetPlatform.macOS => 'macos',
    TargetPlatform.windows => 'windows',
    TargetPlatform.linux => 'linux',
    TargetPlatform.fuchsia => 'fuchsia',
  };
}

bool _isMissingColumnError(PostgrestException error, String columnName) {
  final message = <String>[
    error.message,
    (error.details ?? '').toString(),
    (error.hint ?? '').toString(),
  ].join(' ').toLowerCase();
  final column = columnName.toLowerCase();
  return message.contains(column) &&
      (message.contains('schema cache') ||
          message.contains('could not find') ||
          message.contains('column'));
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}
