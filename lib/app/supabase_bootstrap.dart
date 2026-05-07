import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_config.dart';

class SupabaseBootstrapResult {
  const SupabaseBootstrapResult({
    required this.configured,
    required this.initialized,
    this.error,
  });

  final bool configured;
  final bool initialized;
  final Object? error;
}

class SupabaseBootstrap {
  static bool _initialized = false;

  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static Future<SupabaseBootstrapResult> initializeIfNeeded(
    UfficcioFacileConfig config,
  ) async {
    if (!config.isSupabaseEnabled) {
      return const SupabaseBootstrapResult(
        configured: false,
        initialized: false,
      );
    }
    if (_initialized) {
      return const SupabaseBootstrapResult(configured: true, initialized: true);
    }
    try {
      await Supabase.initialize(
        url: config.supabaseUrl,
        anonKey: config.supabaseAnonKey,
      );
      _initialized = true;
      return const SupabaseBootstrapResult(configured: true, initialized: true);
    } catch (error) {
      return SupabaseBootstrapResult(
        configured: true,
        initialized: false,
        error: error,
      );
    }
  }
}
