enum AppBackendMode { local, supabase }

class UfficcioFacileConfig {
  const UfficcioFacileConfig({
    required this.appName,
    required this.backendMode,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.syncEnabledByDefault,
    required this.adminDebugEnabled,
    required this.betaModeEnabled,
    required this.paywallEnabled,
    required this.analyticsEnabledByDefault,
  });

  static const appNameValue = 'UfficioFacile';

  static const fromEnv = UfficcioFacileConfig(
    appName: appNameValue,
    backendMode: _backendMode,
    supabaseUrl: _supabaseUrl,
    supabaseAnonKey: _supabaseAnonKey,
    syncEnabledByDefault: _syncEnabled,
    adminDebugEnabled: _adminDebugEnabled,
    betaModeEnabled: _betaModeEnabled,
    paywallEnabled: _paywallEnabled,
    analyticsEnabledByDefault: _analyticsEnabled,
  );

  final String appName;
  final AppBackendMode backendMode;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool syncEnabledByDefault;
  final bool adminDebugEnabled;
  final bool betaModeEnabled;
  final bool paywallEnabled;
  final bool analyticsEnabledByDefault;

  bool get hasSupabaseCredentials =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get isSupabaseEnabled =>
      backendMode == AppBackendMode.supabase && hasSupabaseCredentials;

  String get backendLabel => isSupabaseEnabled ? 'supabase' : 'local';

  static const _backendModeString = String.fromEnvironment(
    'UFFICCIOFACILE_BACKEND_MODE',
    defaultValue: String.fromEnvironment(
      'APP_BACKEND_MODE',
      defaultValue: String.fromEnvironment(
        'GYMPAL_BACKEND_MODE',
        defaultValue: 'local',
      ),
    ),
  );

  static const _backendMode = _backendModeString == 'supabase'
      ? AppBackendMode.supabase
      : AppBackendMode.local;

  static const _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  static const _syncEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_SYNC',
    defaultValue: false,
  );
  static const _adminDebugEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_ADMIN_DEBUG',
    defaultValue: false,
  );
  static const _betaModeEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_BETA_MODE',
    defaultValue: true,
  );
  static const _paywallEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_PAYWALL',
    defaultValue: false,
  );
  static const _analyticsEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_ANALYTICS',
    defaultValue: true,
  );
}
