import 'dart:convert';

import 'category_registry.dart';
import 'models/cms_seed_models.dart';

typedef ExternalSeedLoader =
    Map<String, dynamic> Function(String sourcePath, String categorySlug);

Map<String, dynamic> buildCmsSeedBundle({
  required ExternalSeedLoader externalSeedLoader,
}) {
  final resolvedSeeds =
      cmsCategoryRegistry
          .map((seed) => _resolveSeed(seed, externalSeedLoader))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  final cmsCategories = resolvedSeeds
      .map((item) => item.toCmsCategoryRow())
      .toList();
  final cmsProcedures = resolvedSeeds
      .expand((item) => item.toCmsProcedureRows())
      .toList();
  final richCategories = resolvedSeeds
      .map((item) => item.richCategorySnapshot)
      .whereType<Map<String, dynamic>>()
      .toList();

  Map<String, dynamic>? categoryBySlug(String slug) {
    for (final item in richCategories) {
      if (item['id'] == slug) return item;
    }
    return null;
  }

  return {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'cmsCategories': cmsCategories,
    'cmsProcedures': cmsProcedures,
    'richCategories': richCategories,
    'healthCategory': categoryBySlug('health_asl'),
    'housingCategory': categoryBySlug('housing_rent'),
  };
}

CmsCategorySeed _resolveSeed(
  CmsCategorySeed seed,
  ExternalSeedLoader externalSeedLoader,
) {
  if (!seed.isExternalReference) return seed;
  final source = seed.externalSource!;
  final raw = externalSeedLoader(source.sourcePath, source.categorySlug);
  final resolved = CmsCategorySeed.fromJsonMap(raw);
  return CmsCategorySeed(
    slug: resolved.slug,
    title: resolved.title,
    subtitle: resolved.subtitle,
    description: resolved.description,
    sortOrder: seed.sortOrder,
    icon: resolved.icon,
    color: resolved.color,
    isActive: resolved.isActive,
    isPremium: resolved.isPremium,
    verificationStatus: resolved.verificationStatus,
    lastVerifiedAt: resolved.lastVerifiedAt,
    tags: resolved.tags,
    synonyms: resolved.synonyms,
    searchableKeywords: resolved.searchableKeywords,
    monetizationType: resolved.monetizationType,
    allowSingleUnlock: resolved.allowSingleUnlock,
    singleUnlockPriceCents: resolved.singleUnlockPriceCents,
    singleUnlockCurrency: resolved.singleUnlockCurrency,
    premiumReason: resolved.premiumReason,
    premiumTeaser: resolved.premiumTeaser,
    metadata: resolved.metadata,
    procedures: resolved.procedures,
  );
}

Map<String, dynamic> loadCategoryFromJsonText(String raw, String categorySlug) {
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final categories = (decoded['categories'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item));
  for (final category in categories) {
    if (category['slug'] == categorySlug) {
      return category;
    }
  }
  throw StateError('Missing category "$categorySlug" in external seed.');
}
