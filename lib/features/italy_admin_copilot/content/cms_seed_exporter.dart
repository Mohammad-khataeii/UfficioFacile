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
  final cmsContentBlocks = resolvedSeeds
      .expand(
        (category) => category.procedures.expand(
          (procedure) => procedure.blocks.asMap().entries.map(
            (entry) => {
              'id': '${category.slug}_${procedure.slug}_${entry.key}',
              'category_slug': category.slug,
              'procedure_slug': procedure.slug,
              ...entry.value.toJson(),
              'visibility': 'public',
              'config': entry.value.metadata,
            },
          ),
        ),
      )
      .toList();
  final cmsSources = resolvedSeeds
      .expand(
        (category) => category.procedures.expand(
          (procedure) => procedure.sources.map(
            (source) => {
              'category_slug': category.slug,
              'procedure_slug': procedure.slug,
              ...source,
            },
          ),
        ),
      )
      .toList();
  final richCategories = resolvedSeeds
      .map((item) => item.richCategorySnapshot)
      .whereType<Map<String, dynamic>>()
      .toList();
  final categories = resolvedSeeds
      .map((item) => item.toPublicSnapshot())
      .toList();

  Map<String, dynamic>? categoryBySlug(String slug) {
    for (final item in richCategories) {
      if (item['id'] == slug) return item;
    }
    return null;
  }

  return {
    'version': '1',
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'categories': categories,
    'cmsCategories': cmsCategories,
    'cmsProcedures': cmsProcedures,
    'cmsContentBlocks': cmsContentBlocks,
    'cmsSources': cmsSources,
    'cmsLinks': const [],
    'cmsContacts': const [],
    'cmsDocuments': const [],
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
    richCategorySnapshot: resolved.richCategorySnapshot,
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
    if (category['id'] == categorySlug &&
        category.containsKey('subcategories')) {
      return _canonicalCategoryToCmsSeedJson(category);
    }
  }
  throw StateError('Missing category "$categorySlug" in external seed.');
}

Map<String, dynamic> _canonicalCategoryToCmsSeedJson(
  Map<String, dynamic> category,
) {
  final subcategories =
      (category['subcategories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sortOrder'] as num?)?.toInt() ?? 0).compareTo(
            (b['sortOrder'] as num?)?.toInt() ?? 0,
          ),
        );

  final procedures = <Map<String, dynamic>>[];
  for (final subcategory in subcategories) {
    final rawProcedures =
        (subcategory['procedures'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
          ..sort(
            (a, b) => ((a['sortOrder'] as num?)?.toInt() ?? 0).compareTo(
              (b['sortOrder'] as num?)?.toInt() ?? 0,
            ),
          );
    for (final procedure in rawProcedures) {
      procedures.add(
        _canonicalProcedureToCmsSeedJson(
          category: category,
          subcategory: subcategory,
          procedure: procedure,
        ),
      );
    }
  }

  final categorySlug = category['id']?.toString() ?? '';
  final categoryIsPremium =
      ((category['isPremiumOnly'] as bool?) ?? false) ||
      categorySlug == 'bonuses-benefits' ||
      categorySlug == 'loans-credit';

  return <String, dynamic>{
    'slug': category['id'],
    'title': _localeMap(category['title']),
    'subtitle': _localeMap(category['description']),
    'description': _localeMap(category['description']),
    'sort_order': (category['sortOrder'] as num?)?.toInt() ?? 0,
    'icon': category['icon']?.toString(),
    'is_active': true,
    'is_premium': categoryIsPremium,
    'verification_status': 'canonical',
    'tags': const <String>[],
    'synonyms': const <String>[],
    'searchable_keywords': const <String>[],
    'monetization_type': categoryIsPremium ? 'premium_money_value' : 'free',
    'allow_single_unlock': true,
    'single_unlock_currency': 'EUR',
    'premium_reason': const <String, String>{},
    'premium_teaser': _localeMap(category['description']),
    'metadata': <String, dynamic>{
      'canonical_source_path': 'assets/catalog/ufficio_catalog.v1.json',
      'has_premium_content': category['hasPremiumContent'] as bool? ?? false,
      'contacts': _listOfMaps(category['contacts']),
      'official_links': _listOfMaps(category['officialLinks']),
      'subcategories': subcategories
          .map(
            (subcategory) => <String, dynamic>{
              'id': subcategory['id']?.toString() ?? '',
              'title': _localeMap(subcategory['title']),
              'description': _localeMap(subcategory['description']),
              'sort_order': (subcategory['sortOrder'] as num?)?.toInt() ?? 0,
              'is_premium_only': subcategory['isPremiumOnly'] as bool? ?? false,
              'has_premium_content':
                  subcategory['hasPremiumContent'] as bool? ?? false,
              'procedure_count':
                  (subcategory['procedures'] as List<dynamic>? ?? const [])
                      .length,
            },
          )
          .toList(),
    },
    'procedures': procedures,
    'rich_category_snapshot': category,
  };
}

Map<String, dynamic> _canonicalProcedureToCmsSeedJson({
  required Map<String, dynamic> category,
  required Map<String, dynamic> subcategory,
  required Map<String, dynamic> procedure,
}) {
  final sections =
      (procedure['sections'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sortOrder'] as num?)?.toInt() ?? 0).compareTo(
            (b['sortOrder'] as num?)?.toInt() ?? 0,
          ),
        );

  final whatItIs = _sectionLocalizedBody(sections, 'what_it_is');
  final summary = _firstNonEmptyLocalizedText([
    _localeMap(procedure['shortDescription']),
    whatItIs,
  ]);
  final premiumTeaser = _firstNonEmptyLocalizedText([
    _sectionLocalizedBody(sections, 'premium_help'),
    _sectionLocalizedBody(sections, 'premium_comparison'),
    _sectionLocalizedBody(sections, 'premium_template'),
    summary,
  ]);
  final procedureSlug = procedure['id']?.toString() ?? '';
  final canonicalSubcategoryId = subcategory['id']?.toString() ?? '';
  final derivedToolType =
      switch (procedureSlug) {
        'bonus_finder' => 'bonus_finder',
        'which_bonus_to_check' => 'bonus_finder',
        'loan_comparison' => 'loan_comparison',
        'loan_comparison_checklist' => 'loan_comparison',
        _ => null,
      } ??
      switch (canonicalSubcategoryId) {
        'bonus_finder' => 'bonus_finder',
        'compare_loans_safely' => 'loan_comparison',
        _ => null,
      };

  return <String, dynamic>{
    'slug': procedure['id'],
    'title': _localeMap(procedure['title']),
    'subtitle': _localeMap(procedure['shortDescription']),
    'summary': summary,
    'what_is_it': whatItIs,
    'why_you_may_need_it': _sectionItems(sections, 'when_you_need_it'),
    'how_to_do_it': _sectionItems(sections, 'how_to_do_it'),
    'required_documents': _sectionItems(sections, 'documents_needed'),
    'optional_documents': const <dynamic>[],
    'warnings': _sectionItems(sections, 'watch_out'),
    'common_mistakes': _sectionItems(sections, 'common_mistakes'),
    'official_links': _listOfMaps(procedure['officialLinks']),
    'official_contacts': _listOfMaps(procedure['contacts']),
    'checklist': _sectionItems(sections, 'documents_needed'),
    'faq': const <dynamic>[],
    'status': 'published',
    'sort_order': (procedure['sortOrder'] as num?)?.toInt() ?? 0,
    'is_active': true,
    'is_premium': procedure['isPremiumOnly'] as bool? ?? false,
    'verification_status': 'canonical',
    'tags': _stringList(procedure['tags']),
    'synonyms': const <String>[],
    'searchable_keywords': _procedureKeywords(
      procedure: procedure,
      subcategory: subcategory,
    ),
    'monetization_type': (procedure['isPremiumOnly'] as bool? ?? false)
        ? 'premium_money_value'
        : 'free',
    'allow_single_unlock': true,
    'single_unlock_currency': 'EUR',
    'premium_reason': const <String, String>{},
    'premium_teaser': premiumTeaser,
    'metadata': <String, dynamic>{
      'canonical_source_path': 'assets/catalog/ufficio_catalog.v1.json',
      'canonical_category_id': category['id']?.toString() ?? '',
      'canonical_subcategory_id': subcategory['id']?.toString() ?? '',
      'canonical_subcategory_title': _localeMap(subcategory['title']),
      'canonical_subcategory_description': _localeMap(
        subcategory['description'],
      ),
      'canonical_subcategory_sort_order':
          (subcategory['sortOrder'] as num?)?.toInt() ?? 0,
      'canonical_subcategory_is_premium_only':
          subcategory['isPremiumOnly'] as bool? ?? false,
      'canonical_subcategory_has_premium_content':
          subcategory['hasPremiumContent'] as bool? ?? false,
      'blocks': sections.map(_canonicalSectionToBlock).toList(),
      ...?derivedToolType == null ? null : {'tool_type': derivedToolType},
    },
    'blocks': sections.map(_canonicalSectionToBlock).toList(),
  };
}

Map<String, dynamic> _canonicalSectionToBlock(Map<String, dynamic> section) {
  final body = _localeMap(section['body']);
  final itemsByLocale = <String, List<String>>{};
  final rawItems = section['items'];
  if (rawItems is Map) {
    rawItems.forEach((key, value) {
      itemsByLocale[key.toString()] = (value as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    });
  }
  final fallbackItems =
      itemsByLocale['en'] ??
      itemsByLocale['it'] ??
      itemsByLocale.values.firstWhere(
        (value) => value.isNotEmpty,
        orElse: () => const <String>[],
      );
  return <String, dynamic>{
    'block_type': section['key']?.toString() ?? 'info',
    'title': _localeMap(section['title']),
    'body': body,
    'items': fallbackItems,
    'sort_order': (section['sortOrder'] as num?)?.toInt() ?? 0,
    'is_active': true,
    'is_premium': section['isPremiumOnly'] as bool? ?? false,
    'metadata': <String, dynamic>{
      'localized_items': itemsByLocale,
      'original_type': section['type']?.toString() ?? 'text',
    },
  };
}

Map<String, String> _sectionLocalizedBody(
  List<Map<String, dynamic>> sections,
  String key,
) {
  for (final section in sections) {
    if (section['key']?.toString() == key) {
      return _localeMap(section['body']);
    }
  }
  return const <String, String>{};
}

List<dynamic> _sectionItems(List<Map<String, dynamic>> sections, String key) {
  for (final section in sections) {
    if (section['key']?.toString() != key) continue;
    final raw = section['items'];
    if (raw is List) {
      return raw.toList();
    }
    if (raw is Map) {
      final english = raw['en'];
      if (english is List && english.isNotEmpty) {
        return english.map((item) => item.toString()).toList();
      }
      final italian = raw['it'];
      if (italian is List && italian.isNotEmpty) {
        return italian.map((item) => item.toString()).toList();
      }
      for (final value in raw.values) {
        if (value is List && value.isNotEmpty) {
          return value.map((item) => item.toString()).toList();
        }
      }
    }
    break;
  }
  return const <dynamic>[];
}

Map<String, String> _firstNonEmptyLocalizedText(
  List<Map<String, String>> options,
) {
  for (final option in options) {
    if (option.values.any((value) => value.trim().isNotEmpty)) {
      return option;
    }
  }
  return const <String, String>{};
}

Map<String, String> _localeMap(dynamic raw) {
  if (raw is Map<String, String>) {
    return Map<String, String>.from(raw);
  }
  if (raw is Map) {
    return raw.map(
      (key, value) => MapEntry(key.toString(), value?.toString().trim() ?? ''),
    );
  }
  if (raw is String && raw.trim().isNotEmpty) {
    return <String, String>{'en': raw.trim(), 'it': raw.trim()};
  }
  return const <String, String>{};
}

List<Map<String, dynamic>> _listOfMaps(dynamic raw) {
  return (raw as List<dynamic>? ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> _stringList(dynamic raw) {
  return (raw as List<dynamic>? ?? const <dynamic>[])
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _procedureKeywords({
  required Map<String, dynamic> procedure,
  required Map<String, dynamic> subcategory,
}) {
  final values = <String>{
    procedure['id']?.toString() ?? '',
    subcategory['id']?.toString() ?? '',
  };
  final title = _localeMap(procedure['title']);
  final description = _localeMap(procedure['shortDescription']);
  final subcategoryTitle = _localeMap(subcategory['title']);
  values.addAll(title.values);
  values.addAll(description.values);
  values.addAll(subcategoryTitle.values);
  return values.where((item) => item.trim().isNotEmpty).toList();
}
