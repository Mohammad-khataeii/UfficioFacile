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
    return blocks
        .asMap()
        .entries
        .map(
          (entry) => CmsContentBlock.fromJson({
            'id': '${procedureSlug}_${entry.key}',
            'procedure_slug': procedureSlug,
            ...entry.value,
            'title': entry.value['title'] ?? const <String, dynamic>{},
            'body': entry.value['body'] ?? const <String, dynamic>{},
            'config': entry.value['metadata'] ?? const <String, dynamic>{},
            'visibility': 'public',
          }),
        )
        .toList();
  }

  @override
  Future<List<CmsCategory>> listCategories() async {
    final categories = await _loadBundledCategories();
    return categories.map(CmsCategory.fromJson).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<CmsProcedure>> listProcedures({String? categorySlug}) async {
    final all = (await _loadBundledProcedures())
        .map(CmsProcedure.fromJson)
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
    return (decoded['cmsCategories'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadBundledProcedures() async {
    final decoded = await loadCanonicalBundle();
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
}
