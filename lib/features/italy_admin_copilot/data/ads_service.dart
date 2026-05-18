import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  String bannerUnitId(TargetPlatform platform) {
    final configured = switch (platform) {
      TargetPlatform.iOS => bannerUnitIdIos,
      _ => bannerUnitIdAndroid,
    };
    if (configured.trim().isNotEmpty) {
      return configured.trim();
    }
    return switch (platform) {
      TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2934735716',
      _ => 'ca-app-pub-3940256099942544/6300978111',
    };
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
    required CatalogRepository catalogRepository,
    required UfficioPremiumEntitlementService entitlementService,
  }) : _catalogRepository = catalogRepository,
       _entitlementService = entitlementService;

  final CatalogRepository _catalogRepository;
  final UfficioPremiumEntitlementService _entitlementService;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  Future<UfficioAdsConfig> loadConfig() async {
    final config = await _catalogRepository.getAppPublicConfig();
    return UfficioAdsConfig.fromPublicConfig(config);
  }

  Future<bool> shouldShowAds(String screen) async {
    if (kIsWeb) return false;
    final entitlement = await _entitlementService.getCurrentEntitlement();
    if (entitlement.hasActivePremiumEntitlement) {
      return false;
    }
    final config = await loadConfig();
    return config.enabled &&
        config.provider == 'google_mobile_ads' &&
        config.allowsScreen(screen);
  }
}
