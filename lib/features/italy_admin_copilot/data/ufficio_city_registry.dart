import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/ufficio_city.dart';

class UfficioCityRegistry {
  static const legacyTorinoCatalogAsset =
      'assets/catalog/ufficio_catalog.v1.json';
  static Future<Set<String>>? _assetManifestKeysFuture;

  static const List<UfficioCity> _knownCities = <UfficioCity>[
    UfficioCity(
      slug: 'torino',
      label: 'Torino',
      region: 'Piemonte',
      isAvailable: true,
      bundledCatalogAsset: legacyTorinoCatalogAsset,
    ),
    UfficioCity(
      slug: 'milano',
      label: 'Milano',
      region: 'Lombardia',
      isAvailable: false,
    ),
    UfficioCity(
      slug: 'roma',
      label: 'Roma',
      region: 'Lazio',
      isAvailable: false,
    ),
    UfficioCity(
      slug: 'bologna',
      label: 'Bologna',
      region: 'Emilia-Romagna',
      isAvailable: false,
    ),
  ];

  static List<UfficioCity> get knownCities =>
      List<UfficioCity>.unmodifiable(_knownCities);

  static String normalizeSlug(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return 'torino';
    return normalized;
  }

  static UfficioCity baseCityForSlug(String? raw) {
    final slug = normalizeSlug(raw);
    for (final city in _knownCities) {
      if (city.slug == slug) return city;
    }
    return UfficioCity(
      slug: slug,
      label: _humanizeSlug(slug),
      region: '',
      isAvailable: false,
    );
  }

  static List<String> bundledAssetCandidates(String? raw) {
    final slug = normalizeSlug(raw);
    final primary = cityCatalogAssetPath(slug);
    if (slug == 'torino') {
      return <String>[legacyTorinoCatalogAsset, primary];
    }
    return <String>[primary];
  }

  static String cityCatalogAssetPath(String rawSlug) =>
      'assets/catalog/ufficio_catalog.${normalizeSlug(rawSlug)}.v1.json';

  static Future<UfficioCity> resolveCity(String? raw) async {
    final city = baseCityForSlug(raw);
    final candidates = bundledAssetCandidates(city.slug);
    for (final assetPath in candidates) {
      if (await assetExists(assetPath)) {
        return city.copyWith(isAvailable: true, bundledCatalogAsset: assetPath);
      }
    }
    return city.copyWith(
      isAvailable: city.slug == 'torino',
      bundledCatalogAsset: city.slug == 'torino'
          ? legacyTorinoCatalogAsset
          : null,
    );
  }

  static Future<List<UfficioCity>> resolveKnownCities() async {
    final resolved = <UfficioCity>[];
    for (final city in _knownCities) {
      resolved.add(await resolveCity(city.slug));
    }
    return resolved;
  }

  static Future<bool> assetExists(String assetPath) async {
    try {
      final manifestKeys = await _loadAssetManifestKeys();
      if (manifestKeys.isNotEmpty) {
        return manifestKeys.contains(assetPath);
      }
    } catch (_) {
      // Fall back to a direct asset load only when the manifest is unavailable.
      // This keeps normal web startup from spamming 404s for missing city files.
    }
    try {
      await rootBundle.loadString(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Set<String>> _loadAssetManifestKeys() {
    final cached = _assetManifestKeysFuture;
    if (cached != null) {
      return cached;
    }
    final future = rootBundle.loadStructuredData<Set<String>>(
      'AssetManifest.bin.json',
      (value) async {
        if (value.trim().isEmpty) {
          return <String>{};
        }
        final decoded = Map<String, dynamic>.from(
          const JsonDecoder().convert(value) as Map,
        );
        return decoded.keys.toSet();
      },
    );
    _assetManifestKeysFuture = future;
    return future;
  }

  static String _humanizeSlug(String slug) {
    return slug
        .split('_')
        .expand((part) => part.split('-'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
