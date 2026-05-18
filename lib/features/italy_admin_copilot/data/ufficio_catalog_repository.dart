import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../admin_cms/data/cms_repository.dart';
import '../../admin_cms/domain/cms_models.dart';
import '../content/ufficio_catalog_exporter.dart';
import '../domain/ufficio_city.dart';
import '../domain/ufficio_catalog.dart';
import 'ufficio_city_registry.dart';

enum UfficioCatalogLoadStatus { success, unavailable, invalid }

class UfficioCatalogUnavailableException implements Exception {
  const UfficioCatalogUnavailableException(this.city);

  final UfficioCity city;

  @override
  String toString() =>
      'No verified catalog is available for ${city.label} (${city.slug}).';
}

class UfficioCatalogLoadResult {
  const UfficioCatalogLoadResult._({
    required this.status,
    required this.city,
    this.catalog,
    this.error,
    this.assetPath,
  });

  factory UfficioCatalogLoadResult.success({
    required UfficioCity city,
    required UfficioCatalog catalog,
    required String assetPath,
  }) => UfficioCatalogLoadResult._(
    status: UfficioCatalogLoadStatus.success,
    city: city,
    catalog: catalog,
    assetPath: assetPath,
  );

  factory UfficioCatalogLoadResult.unavailable({required UfficioCity city}) =>
      UfficioCatalogLoadResult._(
        status: UfficioCatalogLoadStatus.unavailable,
        city: city,
      );

  factory UfficioCatalogLoadResult.invalid({
    required UfficioCity city,
    required Object error,
    String? assetPath,
  }) => UfficioCatalogLoadResult._(
    status: UfficioCatalogLoadStatus.invalid,
    city: city,
    error: error,
    assetPath: assetPath,
  );

  final UfficioCatalogLoadStatus status;
  final UfficioCity city;
  final UfficioCatalog? catalog;
  final Object? error;
  final String? assetPath;

  bool get isSuccess => status == UfficioCatalogLoadStatus.success;
  bool get isUnavailable => status == UfficioCatalogLoadStatus.unavailable;
}

class UfficioCatalogRepository {
  UfficioCatalogRepository(
    this._cmsRepository, {
    Future<String> Function()? selectedCitySlugLoader,
  }) : _selectedCitySlugLoader = selectedCitySlugLoader;

  final CmsRepository _cmsRepository;
  final Future<String> Function()? _selectedCitySlugLoader;

  static const _bundledAssetPath = 'assets/catalog/ufficio_catalog.v1.json';
  static const _legacyBundledAssetPaths = <String>[
    'apps/admin/data/cms_bundled_content_export.json',
    'docs/generated/cms_bundled_content_export.json',
  ];
  static const _remoteTimeout = Duration(seconds: 3);
  static const _legacyFallbackFromEnv = bool.fromEnvironment(
    'UFFICIOFACILE_ALLOW_LEGACY_CATALOG_FALLBACK',
    defaultValue: false,
  );

  bool get _allowLegacyFallback => _legacyFallbackFromEnv || !kReleaseMode;

  Future<String> _selectedCitySlug() async {
    final loaded = await _selectedCitySlugLoader?.call();
    return UfficioCityRegistry.normalizeSlug(loaded);
  }

  Future<UfficioCatalog> loadCatalog() async {
    final result = await loadCatalogResult();
    if (result.catalog != null) {
      return result.catalog!;
    }
    if (result.isUnavailable) {
      throw UfficioCatalogUnavailableException(result.city);
    }
    throw FlutterError(
      'Catalog could not be loaded for ${result.city.label} (${result.city.slug}).',
    );
  }

  Future<UfficioCatalogLoadResult> loadCatalogResult({String? citySlug}) async {
    final resolvedCity = await UfficioCityRegistry.resolveCity(
      citySlug ?? await _selectedCitySlug(),
    );
    final bundled = await _loadBundledCatalogForCity(resolvedCity);
    if (!bundled.isSuccess || bundled.catalog == null) {
      return bundled;
    }
    final bundledCatalog = bundled.catalog!;
    try {
      final values = await Future.wait<Object>(<Future<Object>>[
        _cmsRepository.listCategories(),
        _cmsRepository.listProcedures(),
      ]).timeout(_remoteTimeout);
      final categories = values[0] as List<CmsCategory>;
      final procedures = values[1] as List<CmsProcedure>;
      if (categories.isEmpty && procedures.isEmpty) {
        return bundled;
      }
      return UfficioCatalogLoadResult.success(
        city: resolvedCity,
        catalog: _mergeCatalog(
          bundledCatalog,
          categories: categories,
          procedures: procedures,
        ),
        assetPath: bundled.assetPath ?? '',
      );
    } catch (error) {
      assert(() {
        debugPrint('[Catalog] Falling back to bundled catalog: $error');
        return true;
      }());
      return bundled;
    }
  }

  Future<UfficioProcedure?> loadProcedureDetail({
    required String categoryId,
    required String subcategoryId,
    required String procedureId,
  }) async {
    final result = await loadCatalogResult();
    if (result.catalog == null) {
      if (result.isUnavailable) {
        throw UfficioCatalogUnavailableException(result.city);
      }
      if (result.error != null) {
        throw result.error!;
      }
      return null;
    }
    final catalog = result.catalog!;
    final bundledProcedure =
        catalog.findProcedure(categoryId, subcategoryId, procedureId) ??
        catalog.findProcedureInCategory(categoryId, procedureId);
    final resolvedSubcategoryId =
        bundledProcedure?.subcategoryId.isNotEmpty == true
        ? bundledProcedure!.subcategoryId
        : subcategoryId;
    try {
      final procedures = await _cmsRepository
          .listProcedures(categorySlug: categoryId)
          .timeout(_remoteTimeout);
      CmsProcedure? remoteProcedure;
      for (final item in procedures) {
        if (item.slug == procedureId && item.categorySlug == categoryId) {
          remoteProcedure = item;
          break;
        }
      }
      if (remoteProcedure == null) {
        return bundledProcedure;
      }
      final blocks = await _cmsRepository
          .listBlocksByProcedure(categoryId, procedureId)
          .timeout(_remoteTimeout);
      return _mergeProcedure(
        bundledProcedure,
        remoteProcedure,
        blocks,
        subcategoryId: resolvedSubcategoryId,
      );
    } catch (_) {
      return bundledProcedure;
    }
  }

  Future<UfficioCatalogLoadResult> _loadBundledCatalogForCity(
    UfficioCity city,
  ) async {
    Object? invalidAssetError;
    String? invalidAssetPath;
    for (final assetPath in UfficioCityRegistry.bundledAssetCandidates(
      city.slug,
    )) {
      final assetExists = await UfficioCityRegistry.assetExists(assetPath);
      if (!assetExists) {
        continue;
      }
      try {
        final raw = await rootBundle.loadString(assetPath);
        return UfficioCatalogLoadResult.success(
          city: city.copyWith(
            isAvailable: true,
            bundledCatalogAsset: assetPath,
          ),
          catalog: _catalogFromDecodedJson(jsonDecode(raw)),
          assetPath: assetPath,
        );
      } catch (error) {
        invalidAssetError = error;
        invalidAssetPath = assetPath;
        assert(() {
          debugPrint('[Catalog] Failed to load city asset $assetPath: $error');
          return true;
        }());
      }
    }

    if (invalidAssetError != null) {
      return UfficioCatalogLoadResult.invalid(
        city: city,
        error: invalidAssetError,
        assetPath: invalidAssetPath,
      );
    }

    if (city.slug != 'torino') {
      return UfficioCatalogLoadResult.unavailable(
        city: city.copyWith(isAvailable: false),
      );
    }

    try {
      final raw = await rootBundle.loadString(_bundledAssetPath);
      return UfficioCatalogLoadResult.success(
        city: city.copyWith(
          isAvailable: true,
          bundledCatalogAsset: _bundledAssetPath,
        ),
        catalog: _catalogFromDecodedJson(jsonDecode(raw)),
        assetPath: _bundledAssetPath,
      );
    } catch (error) {
      assert(() {
        debugPrint(
          '[Catalog] Canonical asset missing or unreadable, trying legacy fallback: $error',
        );
        return true;
      }());
      if (!_allowLegacyFallback) {
        return UfficioCatalogLoadResult.invalid(
          city: city,
          error: FlutterError(
            'Catalog could not be loaded. The canonical asset '
            '"assets/catalog/ufficio_catalog.v1.json" is missing or unreadable.',
          ),
          assetPath: _bundledAssetPath,
        );
      }
    }

    for (final assetPath in _legacyBundledAssetPaths) {
      try {
        final raw = await rootBundle.loadString(assetPath);
        final decoded = jsonDecode(raw);
        final normalized = decoded is Map<String, dynamic>
            ? decoded
            : (decoded is Map
                  ? decoded.map((key, value) => MapEntry(key.toString(), value))
                  : null);
        if (normalized == null) continue;
        final catalogBundle = buildUfficioCatalogBundleFromCmsSeed(normalized);
        return UfficioCatalogLoadResult.success(
          city: city.copyWith(
            isAvailable: true,
            bundledCatalogAsset: assetPath,
          ),
          catalog: UfficioCatalog.fromJson(catalogBundle),
          assetPath: assetPath,
        );
      } catch (error) {
        assert(() {
          debugPrint('[Catalog] Legacy fallback failed for $assetPath: $error');
          return true;
        }());
      }
    }

    return UfficioCatalogLoadResult.invalid(
      city: city,
      error: const FormatException(
        'Bundled catalog assets are missing or malformed.',
      ),
    );
  }

  UfficioCatalog _catalogFromDecodedJson(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return UfficioCatalog.fromJson(decoded);
    }
    if (decoded is Map) {
      return UfficioCatalog.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    throw const FormatException('Bundled catalog JSON must be an object.');
  }

  UfficioCatalog _mergeCatalog(
    UfficioCatalog bundled, {
    required List<CmsCategory> categories,
    required List<CmsProcedure> procedures,
  }) {
    final categoryRows = <String, CmsCategory>{
      for (final category in categories.where((item) => item.isActive))
        category.slug: category,
    };
    final proceduresByCategory = <String, List<CmsProcedure>>{};
    for (final procedure in procedures.where((item) => item.isActive)) {
      proceduresByCategory
          .putIfAbsent(procedure.categorySlug, () => <CmsProcedure>[])
          .add(procedure);
    }

    final merged = <UfficioCategory>[];
    final seen = <String>{};

    for (final category in bundled.categories) {
      final remoteCategory = categoryRows[category.id];
      final remoteProcedures =
          proceduresByCategory[category.id] ?? const <CmsProcedure>[];
      merged.add(_mergeCategory(category, remoteCategory, remoteProcedures));
      seen.add(category.id);
    }

    for (final entry in categoryRows.entries) {
      if (seen.contains(entry.key)) continue;
      final procedures =
          proceduresByCategory[entry.key] ?? const <CmsProcedure>[];
      merged.add(_categoryFromRemote(entry.value, procedures));
    }

    merged.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return UfficioCatalog(
      version: bundled.version,
      updatedAt: bundled.updatedAt,
      languages: bundled.languages,
      categories: merged,
    );
  }

  UfficioCategory _mergeCategory(
    UfficioCategory bundled,
    CmsCategory? remote,
    List<CmsProcedure> remoteProcedures,
  ) {
    if (remote == null && remoteProcedures.isEmpty) return bundled;
    final grouped = <String, List<CmsProcedure>>{};
    for (final procedure in remoteProcedures) {
      final groupId = procedure.subcategorySlug ?? procedure.slug;
      grouped.putIfAbsent(groupId, () => <CmsProcedure>[]).add(procedure);
    }

    final nextSubcategories = <UfficioSubcategory>[];
    final seen = <String>{};

    for (final subcategory in bundled.subcategories) {
      final remoteGroup = grouped[subcategory.id] ?? const <CmsProcedure>[];
      if (remoteGroup.isEmpty) {
        nextSubcategories.add(subcategory);
      } else {
        nextSubcategories.add(_mergeSubcategory(subcategory, remoteGroup));
      }
      seen.add(subcategory.id);
    }

    nextSubcategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final title = remote?.title.isNotEmpty == true
        ? Map<String, String>.from(
            remote!.title.map((key, value) => MapEntry(key, value.toString())),
          )
        : bundled.title;
    final description = remote?.shortDescription.isNotEmpty == true
        ? Map<String, String>.from(
            remote!.shortDescription.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          )
        : bundled.description;
    final hasPremiumContent = nextSubcategories.any(
      (item) => item.hasPremiumContent || item.isPremiumOnly,
    );
    return UfficioCategory(
      id: bundled.id,
      icon: remote?.iconName ?? bundled.icon,
      sortOrder: remote?.sortOrder ?? bundled.sortOrder,
      isPremiumOnly: remote?.isPremium ?? bundled.isPremiumOnly,
      hasPremiumContent: hasPremiumContent,
      title: title,
      description: description,
      subcategories: nextSubcategories,
    );
  }

  UfficioSubcategory _mergeSubcategory(
    UfficioSubcategory bundled,
    List<CmsProcedure> remoteGroup,
  ) {
    final byId = <String, CmsProcedure>{
      for (final procedure in remoteGroup) procedure.slug: procedure,
    };
    final procedures = <UfficioProcedure>[];
    final seen = <String>{};
    for (final procedure in bundled.procedures) {
      final remoteProcedure = byId[procedure.id];
      if (remoteProcedure == null) {
        procedures.add(procedure);
      } else {
        procedures.add(
          _mergeProcedure(
            procedure,
            remoteProcedure,
            const <CmsContentBlock>[],
            subcategoryId: bundled.id,
          ),
        );
      }
      seen.add(procedure.id);
    }
    for (final remoteProcedure in remoteGroup) {
      if (seen.contains(remoteProcedure.slug)) continue;
      procedures.add(
        _mergeProcedure(
          null,
          remoteProcedure,
          const <CmsContentBlock>[],
          subcategoryId: bundled.id,
        ),
      );
    }
    procedures.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return UfficioSubcategory(
      id: bundled.id,
      categoryId: bundled.categoryId,
      sortOrder: remoteGroup.first.sortOrder,
      isPremiumOnly: procedures.every((item) => item.isPremiumOnly),
      hasPremiumContent: procedures.any((item) => item.hasPremiumContent),
      title: bundled.title,
      description: bundled.description,
      procedures: procedures,
    );
  }

  UfficioCategory _categoryFromRemote(
    CmsCategory remote,
    List<CmsProcedure> procedures,
  ) {
    final grouped = <String, List<CmsProcedure>>{};
    for (final procedure in procedures) {
      final groupId = procedure.subcategorySlug ?? procedure.slug;
      grouped.putIfAbsent(groupId, () => <CmsProcedure>[]).add(procedure);
    }
    final subcategories =
        grouped.entries
            .map(
              (entry) => _subcategoryFromRemoteGroup(
                remote.slug,
                entry.key,
                entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return UfficioCategory(
      id: remote.slug,
      icon: remote.iconName ?? 'folder_open',
      sortOrder: remote.sortOrder,
      isPremiumOnly: remote.isPremium,
      hasPremiumContent: subcategories.any(
        (item) => item.isPremiumOnly || item.hasPremiumContent,
      ),
      title: Map<String, String>.from(
        remote.title.map((key, value) => MapEntry(key, value.toString())),
      ),
      description: Map<String, String>.from(
        (remote.shortDescription.isNotEmpty
                ? remote.shortDescription
                : remote.longDescription)
            .map((key, value) => MapEntry(key, value.toString())),
      ),
      subcategories: subcategories,
    );
  }

  UfficioSubcategory _subcategoryFromRemoteGroup(
    String categoryId,
    String subcategoryId,
    List<CmsProcedure> procedures,
  ) {
    final first = procedures.first;
    final mapped =
        procedures
            .map(
              (procedure) => _mergeProcedure(
                null,
                procedure,
                const <CmsContentBlock>[],
                subcategoryId: subcategoryId,
              ),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return UfficioSubcategory(
      id: subcategoryId,
      categoryId: categoryId,
      sortOrder: first.sortOrder,
      isPremiumOnly: mapped.every((item) => item.isPremiumOnly),
      hasPremiumContent: mapped.any((item) => item.hasPremiumContent),
      title: Map<String, String>.from(
        first.title.map((key, value) => MapEntry(key, value.toString())),
      ),
      description: Map<String, String>.from(
        (first.summary.isNotEmpty ? first.summary : first.subtitle).map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      ),
      procedures: mapped,
    );
  }

  UfficioProcedure _mergeProcedure(
    UfficioProcedure? bundled,
    CmsProcedure remote,
    List<CmsContentBlock> remoteBlocks, {
    required String subcategoryId,
  }) {
    final bundledSections = _dedupeSections(<UfficioContentSection>[
      ...?bundled?.sections.where(
        (section) => !section.key.startsWith('remote_block_'),
      ),
    ]);
    final remoteSections = remoteBlocks.isNotEmpty
        ? _blockSectionsFromRemote(remote, remoteBlocks)
        : _coreSectionsFromRemote(remote);
    final sections = bundledSections.isNotEmpty
        ? bundledSections
        : _dedupeSections(remoteSections);
    final officialLinks = bundled?.officialLinks.isNotEmpty == true
        ? bundled!.officialLinks
        : _officialLinksFromRemote(remote);
    final contacts = bundled?.contacts.isNotEmpty == true
        ? bundled!.contacts
        : _contactsFromRemote(remote);
    return UfficioProcedure(
      id: remote.slug,
      categoryId: remote.categorySlug,
      subcategoryId: subcategoryId,
      sortOrder: remote.sortOrder,
      isPremiumOnly: remote.isPremium,
      requiresAuth: false,
      title: Map<String, String>.from(
        remote.title.map((key, value) => MapEntry(key, value.toString())),
      ),
      shortDescription: Map<String, String>.from(
        (remote.summary.isNotEmpty ? remote.summary : remote.subtitle).map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      ),
      tags: remote.tags,
      sections: sections,
      officialLinks: officialLinks,
      contacts: contacts,
      warnings: remote.warnings.isNotEmpty
          ? Map<String, String>.from(
              remote.warnings.map(
                (key, value) => MapEntry(key, value.toString()),
              ),
            )
          : (bundled?.warnings ?? const <String, String>{}),
      premiumTeaser: remote.premiumTeaser.isNotEmpty
          ? Map<String, String>.from(
              remote.premiumTeaser.map(
                (key, value) => MapEntry(key, value.toString()),
              ),
            )
          : (bundled?.premiumTeaser ?? const <String, String>{}),
    );
  }

  List<UfficioContentSection> _coreSectionsFromRemote(CmsProcedure procedure) {
    final sections = <UfficioContentSection>[];

    void addText(
      String key,
      String enTitle,
      dynamic body, {
      required bool isPremiumOnly,
    }) {
      final localized = _stringMap(body);
      if (localized.isEmpty) return;
      sections.add(
        UfficioContentSection(
          type: 'text',
          key: key,
          title: <String, String>{'en': enTitle, 'it': enTitle},
          body: localized,
          isPremiumOnly: isPremiumOnly,
        ),
      );
    }

    addText(
      'what_it_is',
      'What it is',
      procedure.whatIsIt.isNotEmpty ? procedure.whatIsIt : procedure.summary,
      isPremiumOnly: false,
    );
    addText(
      'when_you_need_it',
      'When you need it',
      procedure.whyYouNeedIt,
      isPremiumOnly: false,
    );
    addText(
      'how_to_do_it',
      'How to do it',
      procedure.howToDoIt,
      isPremiumOnly: procedure.isPremium,
    );
    addText(
      'documents_needed',
      'Documents needed',
      procedure.documentsNeeded,
      isPremiumOnly: procedure.isPremium,
    );
    addText(
      'costs_and_timing',
      'Cost and timeline',
      procedure.costsAndTiming,
      isPremiumOnly: procedure.isPremium,
    );
    addText('warnings', 'Warnings', procedure.warnings, isPremiumOnly: false);
    return sections;
  }

  List<UfficioContentSection> _blockSectionsFromRemote(
    CmsProcedure procedure,
    List<CmsContentBlock> blocks,
  ) {
    return blocks
        .where((item) => item.isActive)
        .map(
          (block) => UfficioContentSection(
            type: block.items.isNotEmpty ? 'checklist' : 'text',
            key: 'remote_block_${block.id}',
            title: Map<String, String>.from(
              block.title.map((key, value) => MapEntry(key, value.toString())),
            ),
            body: Map<String, String>.from(
              block.body.map((key, value) => MapEntry(key, value.toString())),
            ),
            items: <String, List<String>>{
              'en': block.items.map((item) => item.toString()).toList(),
              'it': block.items.map((item) => item.toString()).toList(),
            },
            isPremiumOnly: block.isPremium || procedure.isPremium,
          ),
        )
        .toList();
  }

  Map<String, String> _stringMap(Map<String, dynamic> raw) {
    return raw.map((key, value) => MapEntry(key, value.toString()));
  }

  List<UfficioContentSection> _dedupeSections(
    Iterable<UfficioContentSection> sections,
  ) {
    final result = <UfficioContentSection>[];
    final seenKeys = <String>{};
    final seenContent = <String>{};
    for (final section in sections) {
      final keyFingerprint = _normalizedSectionKey(section);
      final contentFingerprint = _sectionContentFingerprint(section);
      final duplicateByKey = keyFingerprint.isNotEmpty
          ? seenKeys.contains(keyFingerprint)
          : false;
      final duplicateByContent = seenContent.contains(contentFingerprint);
      if (duplicateByKey || duplicateByContent) {
        continue;
      }
      if (keyFingerprint.isNotEmpty) {
        seenKeys.add(keyFingerprint);
      }
      seenContent.add(contentFingerprint);
      result.add(section);
    }
    return result;
  }

  String _normalizedSectionKey(UfficioContentSection section) =>
      _normalizeToken(section.key);

  String _sectionContentFingerprint(UfficioContentSection section) =>
      '${_normalizeToken(section.type)}|${_normalizedLocalizedText(section.title)}'
      '|${_normalizedLocalizedText(section.body)}|${_normalizedSectionItems(section.items)}';

  String _normalizedLocalizedText(Map<String, String> value) {
    final entries = value.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map(
          (entry) =>
              '${_normalizeToken(entry.key)}:${_normalizeToken(entry.value)}',
        )
        .join('|');
  }

  String _normalizedSectionItems(Map<String, List<String>> items) {
    final entries = items.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map(
          (entry) =>
              '${_normalizeToken(entry.key)}:${entry.value.map(_normalizeToken).join(',')}',
        )
        .join('|');
  }

  String _normalizeToken(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  List<UfficioOfficialLink> _officialLinksFromRemote(CmsProcedure remote) {
    return remote.officialLinks
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(UfficioOfficialLink.fromJson)
        .where((item) => item.url.trim().isNotEmpty)
        .toList();
  }

  List<UfficioContact> _contactsFromRemote(CmsProcedure remote) {
    return remote.officialContacts
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(UfficioContact.fromJson)
        .where((item) => item.value.trim().isNotEmpty)
        .toList();
  }

}
