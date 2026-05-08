import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/cms_models.dart';
import 'cms_repository.dart';

class LocalCmsRepository implements CmsRepository {
  const LocalCmsRepository();

  static const _bundledExportAssetPaths = [
    'apps/admin/data/cms_bundled_content_export.json',
    'docs/generated/cms_bundled_content_export.json',
  ];

  @override
  Future<void> addRevision({
    required String entityType,
    String? entityId,
    String? entitySlug,
    required String action,
    Map<String, dynamic>? beforeValue,
    Map<String, dynamic>? afterValue,
  }) async {}

  @override
  Future<List<CmsContentBlock>> listBlocks(String procedureSlug) async {
    final bundle = await loadCanonicalBundle();
    final canonicalCategories = _loadCanonicalCategoriesTree(bundle);

    for (final category in canonicalCategories) {
      final procedures = (category['procedures'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item));
      for (final procedure in procedures) {
        if (procedure['slug'] != procedureSlug) continue;
        final blocks = (procedure['blocks'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        return _safeBlocks(blocks, procedureSlug);
      }
    }

    final explicitBlocks =
        (bundle['cmsContentBlocks'] as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .where((item) => item['procedure_slug'] == procedureSlug)
            .toList();
    if (explicitBlocks.isNotEmpty) {
      return _safeBlocks(explicitBlocks, procedureSlug);
    }

    final procedures = await _loadBundledProcedures();
    final procedure = procedures.firstWhere(
      (item) => item['slug'] == procedureSlug,
      orElse: () => const <String, dynamic>{},
    );
    final snapshot = Map<String, dynamic>.from(
      (procedure['public_snapshot'] as Map?) ??
          (procedure['metadata'] as Map?) ??
          const <String, dynamic>{},
    );
    final blocks =
        ((snapshot['blocks'] as List<dynamic>?) ??
                ((procedure['metadata'] as Map?)?['blocks']
                    as List<dynamic>?) ??
                const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
    return _safeBlocks(blocks, procedureSlug);
  }

  @override
  Future<List<CmsCategory>> listCategories() async {
    final categories = await _loadBundledCategories();
    return _safeCategories(categories)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<CmsProcedure>> listProcedures({String? categorySlug}) async {
    final all = (await _loadBundledProcedures())
        .map(_safeProcedure)
        .whereType<CmsProcedure>()
        .toList();
    final filtered = categorySlug == null || categorySlug.isEmpty
        ? all
        : all.where((item) => item.categorySlug == categorySlug).toList();
    filtered.sort((a, b) {
      final categoryCompare = a.categorySlug.compareTo(b.categorySlug);
      if (categoryCompare != 0) return categoryCompare;
      return a.sortOrder.compareTo(b.sortOrder);
    });
    return filtered;
  }

  @override
  Future<void> saveBlock(Map<String, dynamic> values) async {}

  @override
  Future<void> saveCategory(Map<String, dynamic> values) async {}

  @override
  Future<void> saveDraft({
    required String entityType,
    required String entitySlug,
    required Map<String, dynamic> draftValue,
    required String status,
  }) async {}

  @override
  Future<void> saveProcedure(Map<String, dynamic> values) async {}

  Future<Map<String, dynamic>> loadCanonicalBundle() async {
    final raw = await _loadBundledRaw();
    if (raw == null || raw.trim().isEmpty) {
      return const <String, dynamic>{};
    }
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> _loadBundledCategories() async {
    final decoded = await loadCanonicalBundle();
    final canonical = _loadCanonicalCategoriesTree(decoded);
    if (canonical.isNotEmpty) {
      return canonical
          .asMap()
          .entries
          .map((entry) => _canonicalCategoryToCmsRow(entry.value, entry.key))
          .toList();
    }
    return (decoded['cmsCategories'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadBundledProcedures() async {
    final decoded = await loadCanonicalBundle();
    final canonical = _loadCanonicalCategoriesTree(decoded);
    if (canonical.isNotEmpty) {
      return canonical.expand(_canonicalProcedureRows).toList();
    }
    return (decoded['cmsProcedures'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<String?> _loadBundledRaw() async {
    for (final assetPath in _bundledExportAssetPaths) {
      try {
        return await rootBundle.loadString(assetPath);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _loadCanonicalCategoriesTree(
    Map<String, dynamic> decoded,
  ) {
    return (decoded['categories'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _canonicalCategoryToCmsRow(
    Map<String, dynamic> category,
    int index,
  ) {
    return {
      'id': category['slug'],
      'slug': category['slug'],
      'internal_label': category['slug'],
      'title': category['title'] ?? const <String, dynamic>{},
      'subtitle': category['subtitle'] ?? const <String, dynamic>{},
      'description': category['description'] ?? const <String, dynamic>{},
      'short_description': category['description'] ?? const <String, dynamic>{},
      'long_description': category['subtitle'] ?? const <String, dynamic>{},
      'icon': category['icon'],
      'color': category['color'],
      'sort_order': category['sort_order'] ?? index,
      'is_active': category['is_active'] ?? true,
      'is_premium': category['is_premium'] ?? false,
      'verification_status':
          category['verification_status'] ?? 'bundledFallback',
      'tags': category['tags'] ?? const [],
      'synonyms': category['synonyms'] ?? const [],
      'searchable_keywords': category['searchable_keywords'] ?? const [],
      'monetization_type': category['monetization_type'] ?? 'free',
      'allow_single_unlock': category['allow_single_unlock'] ?? true,
      'single_unlock_price_cents': category['single_unlock_price_cents'],
      'single_unlock_currency': category['single_unlock_currency'] ?? 'EUR',
      'premium_reason': category['premium_reason'] ?? const <String, dynamic>{},
      'premium_teaser':
          category['premium_teaser'] ??
          category['description'] ??
          const <String, dynamic>{},
      'metadata': category['metadata'] ?? const <String, dynamic>{},
      'public_snapshot': category,
    };
  }

  Iterable<Map<String, dynamic>> _canonicalProcedureRows(
    Map<String, dynamic> category,
  ) sync* {
    final categorySlug = category['slug']?.toString() ?? '';
    final procedures = (category['procedures'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item));
    for (final procedure in procedures) {
      yield {
        'id': procedure['slug'],
        'slug': procedure['slug'],
        'category_slug': procedure['category_slug'] ?? categorySlug,
        'title': procedure['title'] ?? const <String, dynamic>{},
        'subtitle': procedure['subtitle'] ?? const <String, dynamic>{},
        'summary': procedure['summary'] ?? const <String, dynamic>{},
        'what_is_it':
            procedure['what_is_it'] ??
            procedure['summary'] ??
            const <String, dynamic>{},
        'status': procedure['status'] ?? 'published',
        'sort_order': procedure['sort_order'] ?? 0,
        'is_active': procedure['is_active'] ?? true,
        'is_premium': procedure['is_premium'] ?? false,
        'verification_status':
            procedure['verification_status'] ?? 'bundledFallback',
        'tags': procedure['tags'] ?? const [],
        'synonyms': procedure['synonyms'] ?? const [],
        'searchable_keywords': procedure['searchable_keywords'] ?? const [],
        'monetization_type': procedure['monetization_type'] ?? 'free',
        'allow_single_unlock': procedure['allow_single_unlock'] ?? true,
        'single_unlock_price_cents': procedure['single_unlock_price_cents'],
        'single_unlock_currency': procedure['single_unlock_currency'] ?? 'EUR',
        'premium_reason':
            procedure['premium_reason'] ?? const <String, dynamic>{},
        'premium_teaser':
            procedure['premium_teaser'] ??
            procedure['summary'] ??
            const <String, dynamic>{},
        'metadata': {
          ...(procedure['metadata'] as Map? ?? const <String, dynamic>{}),
          'blocks': procedure['blocks'] ?? const [],
        },
        'public_snapshot': procedure,
      };
    }
  }

  List<CmsCategory> _safeCategories(List<Map<String, dynamic>> rows) {
    final result = <CmsCategory>[];
    for (final row in rows) {
      try {
        result.add(CmsCategory.fromJson(row));
      } catch (_) {}
    }
    return result;
  }

  CmsProcedure? _safeProcedure(Map<String, dynamic> row) {
    try {
      return CmsProcedure.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  List<CmsContentBlock> _safeBlocks(
    List<Map<String, dynamic>> rows,
    String procedureSlug,
  ) {
    final result = <CmsContentBlock>[];
    for (final entry in rows.asMap().entries) {
      try {
        result.add(
          CmsContentBlock.fromJson({
            'id': rows[entry.key]['id'] ?? '${procedureSlug}_${entry.key}',
            'procedure_slug':
                rows[entry.key]['procedure_slug'] ?? procedureSlug,
            ...rows[entry.key],
            'title': rows[entry.key]['title'] ?? const <String, dynamic>{},
            'body': rows[entry.key]['body'] ?? const <String, dynamic>{},
            'config':
                rows[entry.key]['config'] ??
                rows[entry.key]['metadata'] ??
                const <String, dynamic>{},
            'visibility': rows[entry.key]['visibility'] ?? 'public',
          }),
        );
      } catch (_) {}
    }
    return result;
  }
}
