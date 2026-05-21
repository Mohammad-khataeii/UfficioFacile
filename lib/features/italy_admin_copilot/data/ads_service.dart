import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/app_config.dart';
import 'catalog_repository.dart';
import 'premium_service.dart';

class UfficioAdsConfig {
  const UfficioAdsConfig({
    this.enabled = false,
    this.provider = 'google_mobile_ads',
    this.testMode = false,
    this.screens = const <String>[],
    this.bannerUnitIdAndroid = '',
    this.bannerUnitIdIos = '',
    this.interstitialUnitIdAndroid = '',
    this.interstitialUnitIdIos = '',
  });

  final bool enabled;
  final String provider;
  final bool testMode;
  final List<String> screens;
  final String bannerUnitIdAndroid;
  final String bannerUnitIdIos;
  final String interstitialUnitIdAndroid;
  final String interstitialUnitIdIos;

  bool allowsScreen(String screen) =>
      screens.isEmpty || screens.contains(screen) || screens.contains('*');

  bool hasProductionUnitIdFor(TargetPlatform platform) {
    final banner = switch (platform) {
      TargetPlatform.iOS => bannerUnitIdIos,
      _ => bannerUnitIdAndroid,
    }.trim();
    final interstitial = switch (platform) {
      TargetPlatform.iOS => interstitialUnitIdIos,
      _ => interstitialUnitIdAndroid,
    }.trim();
    return banner.isNotEmpty || interstitial.isNotEmpty;
  }

  String bannerUnitId(TargetPlatform platform) {
    final configured = switch (platform) {
      TargetPlatform.iOS => bannerUnitIdIos,
      _ => bannerUnitIdAndroid,
    };
    if (configured.trim().isNotEmpty) {
      return configured.trim();
    }
    if (platform != TargetPlatform.iOS && platform != TargetPlatform.android) {
      return '';
    }
    if (!testMode) {
      return '';
    }
    return switch (platform) {
      TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2934735716',
      _ => 'ca-app-pub-3940256099942544/6300978111',
    };
  }

  UfficioAdsConfig mergeWithEnvironment({
    required UfficcioFacileConfig appConfig,
  }) {
    final environmentBannerAndroid = appConfig.admobBannerAndroid.trim();
    final environmentBannerIos = appConfig.admobBannerIos.trim();
    final environmentInterstitialAndroid = appConfig.admobInterstitialAndroid
        .trim();
    final environmentInterstitialIos = appConfig.admobInterstitialIos.trim();
    final resolvedBannerAndroid = environmentBannerAndroid.isNotEmpty
        ? environmentBannerAndroid
        : bannerUnitIdAndroid.trim();
    final resolvedBannerIos = environmentBannerIos.isNotEmpty
        ? environmentBannerIos
        : bannerUnitIdIos.trim();
    final resolvedInterstitialAndroid =
        environmentInterstitialAndroid.isNotEmpty
        ? environmentInterstitialAndroid
        : interstitialUnitIdAndroid.trim();
    final resolvedInterstitialIos = environmentInterstitialIos.isNotEmpty
        ? environmentInterstitialIos
        : interstitialUnitIdIos.trim();
    final wantsProductionAds =
        enabled &&
        provider == 'google_mobile_ads' &&
        !appConfig.admobTestMode &&
        (resolvedBannerAndroid.isNotEmpty ||
            resolvedBannerIos.isNotEmpty ||
            resolvedInterstitialAndroid.isNotEmpty ||
            resolvedInterstitialIos.isNotEmpty);
    final allowsTestMode =
        !appConfig.isProduction && (testMode || appConfig.admobTestMode);
    return UfficioAdsConfig(
      enabled: appConfig.isProduction ? wantsProductionAds : enabled,
      provider: provider,
      testMode: allowsTestMode,
      screens: screens,
      bannerUnitIdAndroid: resolvedBannerAndroid,
      bannerUnitIdIos: resolvedBannerIos,
      interstitialUnitIdAndroid: resolvedInterstitialAndroid,
      interstitialUnitIdIos: resolvedInterstitialIos,
    );
  }

  factory UfficioAdsConfig.fromPublicConfig(Map<String, dynamic> config) {
    final raw = config['freeUserAds'];
    if (raw is! Map) {
      return const UfficioAdsConfig();
    }
    final map = Map<String, dynamic>.from(raw);
    return UfficioAdsConfig(
      enabled: map['enabled'] == true,
      provider: (map['provider'] as String? ?? 'google_mobile_ads').trim(),
      testMode: map['testMode'] == true,
      screens: ((map['screens'] as List?) ?? const <String>[]).cast<String>(),
      bannerUnitIdAndroid: map['bannerUnitIdAndroid'] as String? ?? '',
      bannerUnitIdIos: map['bannerUnitIdIos'] as String? ?? '',
      interstitialUnitIdAndroid:
          map['interstitialUnitIdAndroid'] as String? ?? '',
      interstitialUnitIdIos: map['interstitialUnitIdIos'] as String? ?? '',
    );
  }
}

class UfficioAdsService {
  UfficioAdsService({
    required UfficcioFacileConfig appConfig,
    required CatalogRepository catalogRepository,
    required UfficioPremiumEntitlementService entitlementService,
  }) : _appConfig = appConfig,
       _catalogRepository = catalogRepository,
       _entitlementService = entitlementService;

  final UfficcioFacileConfig _appConfig;
  final CatalogRepository _catalogRepository;
  final UfficioPremiumEntitlementService _entitlementService;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    if (!_canInitializeSdk()) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  Future<UfficioAdsConfig> loadConfig() async {
    final config = await _catalogRepository.getAppPublicConfig();
    return UfficioAdsConfig.fromPublicConfig(
      config,
    ).mergeWithEnvironment(appConfig: _appConfig);
  }

  Future<bool> shouldShowAds(String screen) async {
    if (kIsWeb) return false;
    final entitlement = await _entitlementService.getCurrentEntitlement();
    if (entitlement.hasActivePremiumEntitlement) {
      return false;
    }
    final config = await loadConfig();
    if (!_isConfigSafeForCurrentFlavor(config)) {
      return false;
    }
    return config.enabled &&
        config.provider == 'google_mobile_ads' &&
        config.allowsScreen(screen);
  }

  bool _canInitializeSdk() {
    if (_appConfig.admobTestMode && !_appConfig.isProduction) {
      return true;
    }
    return _appConfig.hasProductionAdmobAppIdAndroid &&
        _appConfig.hasAnyProductionAdUnit;
  }

  bool _isConfigSafeForCurrentFlavor(UfficioAdsConfig config) {
    if (_appConfig.isProduction) {
      return (_appConfig.hasProductionAdmobAppIdAndroid &&
              config.hasProductionUnitIdFor(TargetPlatform.android)) ||
          config.hasProductionUnitIdFor(TargetPlatform.iOS);
    }
    if (config.testMode) {
      return true;
    }
    return config.hasProductionUnitIdFor(TargetPlatform.android) ||
        config.hasProductionUnitIdFor(TargetPlatform.iOS);
  }
}
