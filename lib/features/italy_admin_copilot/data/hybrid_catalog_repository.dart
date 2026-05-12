import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/catalog_models.dart';
import 'bundled_catalog_repository.dart';
import 'catalog_repository.dart';
import 'supabase_catalog_repository.dart';

class HybridCatalogRepository implements CatalogRepository {
  HybridCatalogRepository({
    required BundledCatalogRepository bundled,
    SupabaseCatalogRepository? remote,
    SharedPreferences? prefs,
  }) : _bundled = bundled,
       _remote = remote,
       _prefs = prefs;

  final BundledCatalogRepository _bundled;
  final SupabaseCatalogRepository? _remote;
  final SharedPreferences? _prefs;

  static const _linksCacheKey = 'ufficio_catalog_links_cache_v1';
  static const _providersCacheKey = 'ufficio_catalog_providers_cache_v1';
  static const _guidanceCacheKey = 'ufficio_catalog_guidance_cache_v1';
  static const _termsCacheKey = 'ufficio_catalog_terms_cache_v1';

  bool _usingFallback = false;
  bool _remoteAvailable = false;
  DateTime? _lastFetchAt;

  Future<T> _load<T>({
    required String? cacheKey,
    required Future<T> Function() bundled,
    required Future<T> Function() remote,
    required bool Function(T value) isEmpty,
    dynamic Function(T value)? encode,
    T Function(dynamic decoded)? decode,
  }) async {
    if (_remote == null) {
      _usingFallback = true;
      return bundled();
    }
    try {
      final value = await remote().timeout(const Duration(seconds: 3));
      _remoteAvailable = true;
      _usingFallback = isEmpty(value);
      _lastFetchAt = DateTime.now();
      if (!_usingFallback &&
          cacheKey != null &&
          _prefs != null &&
          encode != null) {
        await _prefs.setString(cacheKey, jsonEncode(encode(value)));
      }
      if (!_usingFallback) {
        return value;
      }
    } catch (_) {
      _remoteAvailable = false;
      _usingFallback = true;
    }
    if (cacheKey != null && _prefs != null && decode != null) {
      final raw = _prefs.getString(cacheKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          return decode(jsonDecode(raw));
        } catch (_) {}
      }
    }
    return bundled();
  }

  @override
  Future<List<CatalogSource>> listCatalogSources() => _load(
    cacheKey: null,
    bundled: _bundled.listCatalogSources,
    remote: () => _remote!.listCatalogSources(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<OfficialLink>> listOfficialLinks() => _load(
    cacheKey: _linksCacheKey,
    bundled: _bundled.listOfficialLinks,
    remote: () => _remote!.listOfficialLinks(),
    isEmpty: (value) => value.isEmpty,
    encode: (value) => value.map((item) => item.toJson()).toList(),
    decode: (decoded) => (decoded as List)
        .map((item) => OfficialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
  );

  @override
  Future<List<OfficialContact>> listOfficialContacts() => _load(
    cacheKey: null,
    bundled: _bundled.listOfficialContacts,
    remote: () => _remote!.listOfficialContacts(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<ServiceProvider>> listServiceProviders() => _load(
    cacheKey: _providersCacheKey,
    bundled: _bundled.listServiceProviders,
    remote: () => _remote!.listServiceProviders(),
    isEmpty: (value) => value.isEmpty,
    encode: (value) => value.map((item) => item.toJson()).toList(),
    decode: (decoded) => (decoded as List)
        .map(
          (item) => ServiceProvider.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(),
  );

  @override
  Future<List<ProviderForm>> listProviderForms() => _load(
    cacheKey: null,
    bundled: _bundled.listProviderForms,
    remote: () => _remote!.listProviderForms(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<ProviderContactOption>> listProviderContactOptions() => _load(
    cacheKey: null,
    bundled: _bundled.listProviderContactOptions,
    remote: () => _remote!.listProviderContactOptions(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<RegionGuidance>> listRegionGuidance() => _load(
    cacheKey: null,
    bundled: _bundled.listRegionGuidance,
    remote: () => _remote!.listRegionGuidance(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<CityGuidance>> listCityGuidance() => _load(
    cacheKey: null,
    bundled: _bundled.listCityGuidance,
    remote: () => _remote!.listCityGuidance(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<AuthorityGuidance>> listAuthorityGuidance() => _load(
    cacheKey: null,
    bundled: _bundled.listAuthorityGuidance,
    remote: () => _remote!.listAuthorityGuidance(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<ProcedureGuidance>> listProcedureGuidance() => _load(
    cacheKey: _guidanceCacheKey,
    bundled: _bundled.listProcedureGuidance,
    remote: () => _remote!.listProcedureGuidance(),
    isEmpty: (value) => value.isEmpty,
    encode: (value) => value.map((item) => item.toJson()).toList(),
    decode: (decoded) => (decoded as List)
        .map(
          (item) => ProcedureGuidance.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(),
  );

  @override
  Future<List<SourceReference>> listSourceReferences() => _load(
    cacheKey: null,
    bundled: _bundled.listSourceReferences,
    remote: () => _remote!.listSourceReferences(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<List<ServiceTerm>> listServiceTerms() => _load(
    cacheKey: _termsCacheKey,
    bundled: _bundled.listServiceTerms,
    remote: () => _remote!.listServiceTerms(),
    isEmpty: (value) => value.isEmpty,
    encode: (value) => value.map((item) => item.toJson()).toList(),
    decode: (decoded) => (decoded as List)
        .map((item) => ServiceTerm.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
  );

  @override
  Future<List<SubmissionChannel>> listSubmissionChannels() => _load(
    cacheKey: null,
    bundled: _bundled.listSubmissionChannels,
    remote: () => _remote!.listSubmissionChannels(),
    isEmpty: (value) => value.isEmpty,
  );

  @override
  Future<ProcedureGuidance?> getProcedureGuidance(String procedureId) async {
    final all = await listProcedureGuidance();
    for (final item in all) {
      if (item.procedureId == procedureId) return item;
    }
    return null;
  }

  @override
  Future<ServiceProvider?> getProvider(String providerId) async {
    final all = await listServiceProviders();
    for (final item in all) {
      if (item.id == providerId) return item;
    }
    return null;
  }

  @override
  Future<List<ServiceProvider>> getProvidersByCategory(String category) async =>
      (await listServiceProviders())
          .where((item) => item.category == category)
          .toList();

  @override
  Future<CityGuidance?> getCityGuidance(String city) async {
    final all = await listCityGuidance();
    for (final item in all) {
      if (item.city.toLowerCase() == city.toLowerCase()) return item;
    }
    return null;
  }

  @override
  Future<RegionGuidance?> getRegionGuidance(String region) async {
    final all = await listRegionGuidance();
    for (final item in all) {
      if (item.region.toLowerCase() == region.toLowerCase()) return item;
    }
    return null;
  }

  @override
  Future<ServiceTerm?> getTerm(String termId) async {
    final all = await listServiceTerms();
    for (final item in all) {
      if (item.id == termId) return item;
    }
    return null;
  }

  @override
  Future<List<Object>> searchCatalog(String query) async {
    final bundledResults = await _bundled.searchCatalog(query);
    if (_remote == null) {
      return bundledResults;
    }

    try {
      final remoteResults = await _remote
          .searchCatalog(query)
          .timeout(const Duration(seconds: 3));
      _remoteAvailable = true;
      _usingFallback = remoteResults.isEmpty;
      _lastFetchAt = DateTime.now();
      return _mergeSearchResults(bundledResults, remoteResults);
    } catch (_) {
      _remoteAvailable = false;
      _usingFallback = true;
      return bundledResults;
    }
  }

  List<Object> _mergeSearchResults(
    List<Object> bundledResults,
    List<Object> remoteResults,
  ) {
    final seenKeys = <String>{};
    final merged = <Object>[];

    void addAll(Iterable<Object> items) {
      for (final item in items) {
        final key = _searchResultKey(item);
        if (key == null || seenKeys.add(key)) {
          merged.add(item);
        }
      }
    }

    addAll(remoteResults);
    addAll(bundledResults);
    return merged;
  }

  String? _searchResultKey(Object item) {
    if (item is OfficialLink) {
      return 'official-link:${item.id}';
    }
    if (item is ServiceProvider) {
      return 'service-provider:${item.id}';
    }
    if (item is ProcedureGuidance) {
      return 'procedure-guidance:${item.procedureId}';
    }
    return item.toString();
  }

  @override
  Future<Map<String, dynamic>> getAppPublicConfig() async {
    if (_remote == null) return _bundled.getAppPublicConfig();
    try {
      final remote = await _remote.getAppPublicConfig().timeout(
        const Duration(seconds: 3),
      );
      if (remote.isNotEmpty) return remote;
    } catch (_) {}
    return _bundled.getAppPublicConfig();
  }

  @override
  Future<Map<String, dynamic>> getPremiumPublicConfig() async {
    if (_remote == null) return _bundled.getPremiumPublicConfig();
    try {
      final remote = await _remote.getPremiumPublicConfig().timeout(
        const Duration(seconds: 3),
      );
      if (remote.isNotEmpty) return remote;
    } catch (_) {}
    return _bundled.getPremiumPublicConfig();
  }

  @override
  Future<CatalogHealthSnapshot> getHealthSnapshot() async {
    final links = await listOfficialLinks();
    final providers = await listServiceProviders();
    final procedures = await listProcedureGuidance();
    final refs = await listSourceReferences();
    return CatalogHealthSnapshot(
      remoteConfigured: _remote != null,
      remoteAvailable: _remoteAvailable,
      usingFallback: _usingFallback || _remote == null,
      lastFetchAt: _lastFetchAt,
      itemCounts: {
        'officialLinks': links.length,
        'providers': providers.length,
        'procedureGuidance': procedures.length,
        'sourceReferences': refs.length,
      },
    );
  }
}
