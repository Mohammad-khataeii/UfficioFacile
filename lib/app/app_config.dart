enum AppBackendMode { local, supabase }

enum UfficioFacileFlavor { development, staging, production }

class UfficcioFacileConfig {
  const UfficcioFacileConfig({
    required this.appName,
    this.flavor = UfficioFacileFlavor.development,
    required this.backendMode,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.syncEnabledByDefault,
    required this.adminDebugEnabled,
    required this.betaModeEnabled,
    required this.paywallEnabled,
    required this.analyticsEnabledByDefault,
    this.admobAppIdAndroid = '',
    this.admobAppIdIos = '',
    this.admobBannerAndroid = '',
    this.admobBannerIos = '',
    this.admobInterstitialAndroid = '',
    this.admobInterstitialIos = '',
    this.admobTestMode = false,
    this.allowLocalFallback = false,
  });

  static const appNameValue = 'UfficioFacile';
  static const supportEmail = 'support@ufficiofacile.app';
  static const privacyPolicyUrlPlaceholder =
      'https://ufficio-facile.vercel.app/privacy';

  static const fromEnv = UfficcioFacileConfig(
    appName: appNameValue,
    flavor: _flavor,
    backendMode: _backendMode,
    supabaseUrl: _supabaseUrl,
    supabaseAnonKey: _supabaseAnonKey,
    syncEnabledByDefault: _syncEnabled,
    adminDebugEnabled: _adminDebugEnabled,
    betaModeEnabled: _betaModeEnabled,
    paywallEnabled: _paywallEnabled,
    analyticsEnabledByDefault: _analyticsEnabled,
    admobAppIdAndroid: _admobAppIdAndroid,
    admobAppIdIos: _admobAppIdIos,
    admobBannerAndroid: _admobBannerAndroid,
    admobBannerIos: _admobBannerIos,
    admobInterstitialAndroid: _admobInterstitialAndroid,
    admobInterstitialIos: _admobInterstitialIos,
    admobTestMode: _admobTestMode,
    allowLocalFallback: _allowLocalFallback,
  );

  final String appName;
  final UfficioFacileFlavor flavor;
  final AppBackendMode backendMode;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final bool syncEnabledByDefault;
  final bool adminDebugEnabled;
  final bool betaModeEnabled;
  final bool paywallEnabled;
  final bool analyticsEnabledByDefault;
  final String admobAppIdAndroid;
  final String admobAppIdIos;
  final String admobBannerAndroid;
  final String admobBannerIos;
  final String admobInterstitialAndroid;
  final String admobInterstitialIos;
  final bool admobTestMode;
  final bool allowLocalFallback;

  bool get isProduction => flavor == UfficioFacileFlavor.production;
  bool get isStaging => flavor == UfficioFacileFlavor.staging;
  bool get isDevelopment => flavor == UfficioFacileFlavor.development;

  bool get hasSupabaseCredentials =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get isSupabaseEnabled =>
      backendMode == AppBackendMode.supabase && hasSupabaseCredentials;

  String get backendLabel => backendMode.name;

  String get flavorLabel => switch (flavor) {
    UfficioFacileFlavor.development => 'development',
    UfficioFacileFlavor.staging => 'staging',
    UfficioFacileFlavor.production => 'production',
  };

  bool get mustFailLoudOnMissingSupabase =>
      backendMode == AppBackendMode.supabase;

  bool get canFallbackToLocalMode => false;

  bool get hasProductionAdmobAppIdAndroid =>
      admobAppIdAndroid.trim().isNotEmpty;

  bool get hasAnyProductionAdUnit =>
      admobBannerAndroid.trim().isNotEmpty ||
      admobBannerIos.trim().isNotEmpty ||
      admobInterstitialAndroid.trim().isNotEmpty ||
      admobInterstitialIos.trim().isNotEmpty;

  static const _backendMode = AppBackendMode.supabase;

  static const _flavorString = String.fromEnvironment(
    'UFFICCIOFACILE_FLAVOR',
    defaultValue: 'development',
  );
  static const _flavor = _flavorString == 'production'
      ? UfficioFacileFlavor.production
      : _flavorString == 'staging'
      ? UfficioFacileFlavor.staging
      : UfficioFacileFlavor.development;

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
    defaultValue: false,
  );
  static const _paywallEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_PAYWALL',
    defaultValue: true,
  );
  static const _analyticsEnabled = bool.fromEnvironment(
    'UFFICCIOFACILE_ENABLE_ANALYTICS',
    defaultValue: true,
  );
  static const _admobAppIdAndroid = String.fromEnvironment(
    'UFFICIOFACILE_ADMOB_APP_ID_ANDROID',
    defaultValue: String.fromEnvironment(
      'UFFICCIOFACILE_ADMOB_APP_ID_ANDROID',
      defaultValue: '',
    ),
  );
  static const _admobAppIdIos = String.fromEnvironment(
    'UFFICIOFACILE_ADMOB_APP_ID_IOS',
    defaultValue: String.fromEnvironment(
      'UFFICCIOFACILE_ADMOB_APP_ID_IOS',
      defaultValue: '',
    ),
  );
  static const _admobBannerAndroid = String.fromEnvironment(
    'UFFICIOFACILE_ADMOB_BANNER_ANDROID',
    defaultValue: '',
  );
  static const _admobBannerIos = String.fromEnvironment(
    'UFFICIOFACILE_ADMOB_BANNER_IOS',
    defaultValue: '',
  );
  static const _admobInterstitialAndroid = String.fromEnvironment(
    'UFFICIOFACILE_ADMOB_INTERSTITIAL_ANDROID',
    defaultValue: '',
  );
  static const _admobInterstitialIos = String.fromEnvironment(
    'UFFICIOFACILE_ADMOB_INTERSTITIAL_IOS',
    defaultValue: '',
  );
  static const _admobTestMode = bool.fromEnvironment(
    'UFFICIOFACILE_ADMOB_TEST_MODE',
    defaultValue: false,
  );
  static const _allowLocalFallback = bool.fromEnvironment(
    'UFFICCIOFACILE_ALLOW_LOCAL_FALLBACK',
    defaultValue: false,
  );
}
