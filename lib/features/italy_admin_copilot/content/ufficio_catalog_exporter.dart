import '../domain/ufficio_catalog.dart';

Map<String, dynamic> buildUfficioCatalogBundleFromCmsSeed(
  Map<String, dynamic> cmsSeedBundle,
) {
  final canonicalRichCategories = _extractCanonicalRichCategories(
    cmsSeedBundle,
  );
  if (canonicalRichCategories.isNotEmpty) {
    return <String, dynamic>{
      'version': 1,
      'updatedAt': DateTime.now().toUtc().toIso8601String().split('T').first,
      'languages': const <String>['en', 'it', 'fr', 'es', 'fa', 'ar'],
      'categories': canonicalRichCategories
        ..sort(
          (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
        ),
    };
  }

  final categories = _flatRows(cmsSeedBundle['cmsCategories']);
  final procedures = _flatRows(cmsSeedBundle['cmsProcedures']);
  final proceduresByCategory = <String, List<Map<String, dynamic>>>{};
  for (final procedure in procedures) {
    final categoryId = procedure['category_slug']?.toString() ?? '';
    if (categoryId.isEmpty) continue;
    proceduresByCategory
        .putIfAbsent(categoryId, () => <Map<String, dynamic>>[])
        .add(procedure);
  }

  final builtCategories =
      categories.map((category) {
        final categoryId =
            category['slug']?.toString() ?? category['id']?.toString() ?? '';
        final grouped = _groupProcedures(
          proceduresByCategory[categoryId] ?? const <Map<String, dynamic>>[],
        );
        final builtSubcategories =
            grouped.map((group) {
              final builtProcedures =
                  group.procedures
                      .map(
                        (procedure) => _normalizeProcedure(
                          procedure,
                          categoryId: categoryId,
                          subcategoryId: group.id,
                        ),
                      )
                      .toList()
                    ..sort(
                      (a, b) => (a['sortOrder'] as int).compareTo(
                        b['sortOrder'] as int,
                      ),
                    );
              final hasPremiumContent = builtProcedures.any(
                (item) =>
                    item['isPremiumOnly'] == true ||
                    _sectionsHavePremium(item['sections'] as List<dynamic>?),
              );
              return <String, dynamic>{
                'id': group.id,
                'categoryId': categoryId,
                'sortOrder': group.sortOrder,
                'isPremiumOnly':
                    builtProcedures.isNotEmpty &&
                    builtProcedures.every(
                      (item) => item['isPremiumOnly'] == true,
                    ),
                'hasPremiumContent': hasPremiumContent,
                'title': group.title,
                'description': group.description,
                'procedures': builtProcedures,
              };
            }).toList()..sort(
              (a, b) =>
                  (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
            );

        final title = _sanitizeLocalizedText(
          ufficioLocalizedTextFromJson(category['title']),
        );
        final description = _sanitizeLocalizedText(
          ufficioLocalizedTextFromJson(
            category['description'] ?? category['short_description'],
          ),
        );
        return <String, dynamic>{
          'id': categoryId,
          'icon': category['icon']?.toString() ?? 'folder_open',
          'sortOrder': (category['sort_order'] as num?)?.toInt() ?? 0,
          'isPremiumOnly': category['is_premium'] as bool? ?? false,
          'hasPremiumContent': builtSubcategories.any(
            (item) =>
                item['hasPremiumContent'] == true ||
                item['isPremiumOnly'] == true,
          ),
          'title': title,
          'description': description,
          'subcategories': builtSubcategories,
        };
      }).toList()..sort(
        (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
      );

  return <String, dynamic>{
    'version': 1,
    'updatedAt': DateTime.now().toUtc().toIso8601String().split('T').first,
    'languages': const <String>['en', 'it', 'fr', 'es', 'fa', 'ar'],
    'categories': builtCategories,
  };
}

List<Map<String, dynamic>> _extractCanonicalRichCategories(
  Map<String, dynamic> cmsSeedBundle,
) {
  final rawCategories =
      (cmsSeedBundle['richCategories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => item.containsKey('subcategories'))
          .toList();
  if (rawCategories.isEmpty) {
    return const <Map<String, dynamic>>[];
  }
  return rawCategories.map(_normalizeCanonicalCategory).toList();
}

Map<String, dynamic> _normalizeCanonicalCategory(Map<String, dynamic> raw) {
  final categoryId = raw['id']?.toString() ?? raw['slug']?.toString() ?? '';
  final rawSubcategories =
      (raw['subcategories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sortOrder'] as num?)?.toInt() ?? 0).compareTo(
            (b['sortOrder'] as num?)?.toInt() ?? 0,
          ),
        );
  final subcategories = rawSubcategories
      .map(
        (item) => _normalizeCanonicalSubcategory(item, categoryId: categoryId),
      )
      .toList();
  return <String, dynamic>{
    'id': categoryId,
    'icon': raw['icon']?.toString() ?? 'folder_open',
    'sortOrder':
        (raw['sortOrder'] as num?)?.toInt() ??
        (raw['sort_order'] as num?)?.toInt() ??
        0,
    'isPremiumOnly':
        raw['isPremiumOnly'] as bool? ??
        raw['is_premium_only'] as bool? ??
        false,
    'hasPremiumContent':
        raw['hasPremiumContent'] as bool? ??
        raw['has_premium_content'] as bool? ??
        subcategories.any((item) => item['hasPremiumContent'] == true),
    'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['title'])),
    'description': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(raw['description']),
    ),
    'subcategories': subcategories,
  };
}

Map<String, dynamic> _normalizeCanonicalSubcategory(
  Map<String, dynamic> raw, {
  required String categoryId,
}) {
  final subcategoryId = raw['id']?.toString() ?? '';
  final procedures =
      (raw['procedures'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => _normalizeProcedure(
              item,
              categoryId: categoryId,
              subcategoryId: subcategoryId,
            ),
          )
          .toList()
        ..sort(
          (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
        );
  return <String, dynamic>{
    'id': subcategoryId,
    'categoryId': categoryId,
    'sortOrder':
        (raw['sortOrder'] as num?)?.toInt() ??
        (raw['sort_order'] as num?)?.toInt() ??
        0,
    'isPremiumOnly':
        raw['isPremiumOnly'] as bool? ??
        raw['is_premium_only'] as bool? ??
        false,
    'hasPremiumContent':
        raw['hasPremiumContent'] as bool? ??
        raw['has_premium_content'] as bool? ??
        procedures.any(
          (item) =>
              item['isPremiumOnly'] == true ||
              _sectionsHavePremium(item['sections'] as List<dynamic>?),
        ),
    'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['title'])),
    'description': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(raw['description']),
    ),
    'procedures': procedures,
  };
}

Map<String, dynamic> _normalizeProcedure(
  Map<String, dynamic> raw, {
  required String categoryId,
  required String subcategoryId,
}) {
  final sections = _normalizeSections(raw);
  return <String, dynamic>{
    'id': raw['id']?.toString() ?? raw['slug']?.toString() ?? '',
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'sortOrder':
        (raw['sortOrder'] as num?)?.toInt() ??
        (raw['sort_order'] as num?)?.toInt() ??
        0,
    'isPremiumOnly':
        raw['isPremiumOnly'] as bool? ?? raw['is_premium'] as bool? ?? false,
    'requiresAuth': raw['requiresAuth'] as bool? ?? false,
    'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['title'])),
    'shortDescription': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(
        raw['shortDescription'] ?? raw['subtitle'] ?? raw['summary'],
      ),
    ),
    'tags': _stringList(raw['tags']),
    'sections': sections,
    'officialLinks': _listOfMaps(
      raw['officialLinks'] ?? raw['official_links'] ?? const <dynamic>[],
    ),
    'contacts': _listOfMaps(
      raw['contacts'] ?? raw['official_contacts'] ?? const <dynamic>[],
    ),
    'warnings': _stringList(raw['warnings']),
    'premiumTeaser': _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(
        raw['premiumTeaser'] ?? raw['premium_teaser'],
      ),
    ),
  };
}

List<Map<String, dynamic>> _normalizeSections(Map<String, dynamic> raw) {
  final directSections =
      (raw['sections'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
  if (directSections.isNotEmpty) {
    return directSections.map(_normalizeSection).toList()..sort(
      (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
    );
  }

  final metadata = raw['metadata'];
  final metadataBlocks = metadata is Map
      ? (metadata['blocks'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : const <Map<String, dynamic>>[];
  if (metadataBlocks.isNotEmpty) {
    return metadataBlocks.map(_normalizeBlockAsSection).toList()..sort(
      (a, b) => (a['sortOrder'] as int).compareTo(b['sortOrder'] as int),
    );
  }

  final fallbackSections = <Map<String, dynamic>>[];
  void addTextSection(String key, dynamic title, dynamic body) {
    final localizedBody = _sanitizeLocalizedText(
      ufficioLocalizedTextFromJson(body),
    );
    if (localizedBody.values.every((value) => value.trim().isEmpty)) return;
    fallbackSections.add(<String, dynamic>{
      'type': 'text',
      'key': key,
      'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(title)),
      'body': localizedBody,
      'isPremiumOnly': false,
      'sortOrder': fallbackSections.length + 1,
    });
  }

  void addChecklistSection(String key, dynamic title, dynamic items) {
    final localizedItems = _normalizeLocalizedItems(items);
    if (localizedItems.values.every((value) => value.isEmpty)) return;
    fallbackSections.add(<String, dynamic>{
      'type': 'checklist',
      'key': key,
      'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(title)),
      'items': localizedItems,
      'isPremiumOnly': false,
      'sortOrder': fallbackSections.length + 1,
    });
  }

  addTextSection('what_it_is', const {
    'en': 'What it is',
    'it': 'Cos’è',
  }, raw['what_is_it']);
  addChecklistSection('when_you_need_it', const {
    'en': 'When you need it',
    'it': 'Quando serve',
  }, raw['why_you_may_need_it']);
  addChecklistSection('how_to_do_it', const {
    'en': 'How to do it',
    'it': 'Come fare',
  }, raw['how_to_do_it']);
  addChecklistSection('documents_needed', const {
    'en': 'Documents needed',
    'it': 'Documenti necessari',
  }, raw['required_documents'] ?? raw['documents_needed']);
  addChecklistSection('watch_out', const {
    'en': 'Watch out',
    'it': 'Attenzione',
  }, raw['warnings']);
  return fallbackSections;
}

Map<String, dynamic> _normalizeSection(Map<String, dynamic> raw) {
  return <String, dynamic>{
    'type': raw['type']?.toString() ?? 'text',
    'key': raw['key']?.toString() ?? 'info',
    'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['title'])),
    if (raw.containsKey('body'))
      'body': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['body'])),
    if (raw.containsKey('items'))
      'items': _normalizeLocalizedItems(raw['items']),
    'isPremiumOnly':
        raw['isPremiumOnly'] as bool? ?? raw['is_premium'] as bool? ?? false,
    'sortOrder':
        (raw['sortOrder'] as num?)?.toInt() ??
        (raw['sort_order'] as num?)?.toInt() ??
        0,
  };
}

Map<String, dynamic> _normalizeBlockAsSection(Map<String, dynamic> raw) {
  final metadata = raw['metadata'];
  final localizedItems = metadata is Map && metadata['localized_items'] is Map
      ? _normalizeLocalizedItems(metadata['localized_items'])
      : _normalizeLocalizedItems(raw['items']);
  return <String, dynamic>{
    'type': raw['block_type']?.toString() == 'checklist' ? 'checklist' : 'text',
    'key': raw['block_type']?.toString() ?? 'info',
    'title': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['title'])),
    'body': _sanitizeLocalizedText(ufficioLocalizedTextFromJson(raw['body'])),
    if (localizedItems.values.any((value) => value.isNotEmpty))
      'items': localizedItems,
    'isPremiumOnly':
        raw['is_premium'] as bool? ?? raw['isPremiumOnly'] as bool? ?? false,
    'sortOrder':
        (raw['sort_order'] as num?)?.toInt() ??
        (raw['sortOrder'] as num?)?.toInt() ??
        0,
  };
}

List<_ProcedureGroup> _groupProcedures(List<Map<String, dynamic>> procedures) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  final subcategoryMeta = <String, Map<String, dynamic>>{};
  for (final procedure in procedures) {
    final metadata = procedure['metadata'];
    final metadataMap = metadata is Map
        ? Map<String, dynamic>.from(metadata)
        : const <String, dynamic>{};
    final groupId =
        metadataMap['canonical_subcategory_id']?.toString() ??
        procedure['subcategory_slug']?.toString() ??
        procedure['slug']?.toString() ??
        '';
    grouped.putIfAbsent(groupId, () => <Map<String, dynamic>>[]).add(procedure);
    subcategoryMeta[groupId] = metadataMap;
  }

  return grouped.entries.map((entry) {
    final meta = subcategoryMeta[entry.key] ?? const <String, dynamic>{};
    return _ProcedureGroup(
      id: entry.key,
      sortOrder:
          (meta['canonical_subcategory_sort_order'] as num?)?.toInt() ?? 0,
      title: _sanitizeLocalizedText(
        ufficioLocalizedTextFromJson(
          meta['canonical_subcategory_title'] ?? _humanizeIdentifier(entry.key),
        ),
      ),
      description: _sanitizeLocalizedText(
        ufficioLocalizedTextFromJson(meta['canonical_subcategory_description']),
      ),
      procedures: entry.value
        ..sort((a, b) {
          return ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          );
        }),
    );
  }).toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

bool _sectionsHavePremium(List<dynamic>? sections) {
  return (sections ?? const <dynamic>[]).whereType<Map>().any(
    (section) =>
        section['isPremiumOnly'] == true || section['is_premium'] == true,
  );
}

Map<String, String> _sanitizeLocalizedText(Map<String, String> values) {
  return values.map((key, value) => MapEntry(key, _sanitizeText(value)));
}

String _sanitizeText(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return text;
  final replacements = <RegExp, String>{
    RegExp(r'\bidentity_document\b', caseSensitive: false): 'Identity document',
    RegExp(r'\brental_contract\b', caseSensitive: false): 'Rental contract',
    RegExp(r'\bregistration_receipt\b', caseSensitive: false):
        'Registration receipt',
    RegExp(r'\btax_code_card\b', caseSensitive: false): 'Codice fiscale',
    RegExp(r'\bresidence_certificate\b', caseSensitive: false):
        'Residence certificate',
    RegExp(r'\bwork_contract\b', caseSensitive: false): 'Work contract',
    RegExp(r'\bpermesso_receipt\b', caseSensitive: false):
        'Permesso renewal receipt',
    RegExp(r'\bmissing_documents_integration\b', caseSensitive: false):
        'Missing document integration',
    RegExp(r'\bpec_formal_complaint_operator\b', caseSensitive: false):
        'Formal PEC complaint to the provider',
  };
  for (final entry in replacements.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }
  return text;
}

Map<String, List<String>> _normalizeLocalizedItems(dynamic raw) {
  if (raw is Map) {
    final result = <String, List<String>>{};
    raw.forEach((key, value) {
      result[key.toString()] = (value as List<dynamic>? ?? const <dynamic>[])
          .map((item) => _sanitizeText(item.toString()))
          .where((item) => item.trim().isNotEmpty)
          .toList();
    });
    return result;
  }
  if (raw is List) {
    final items = raw
        .map((item) => _sanitizeText(item.toString()))
        .where((item) => item.trim().isNotEmpty)
        .toList();
    return <String, List<String>>{'en': items, 'it': items};
  }
  return const <String, List<String>>{};
}

List<Map<String, dynamic>> _flatRows(dynamic raw) {
  return (raw as List<dynamic>? ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<Map<String, dynamic>> _listOfMaps(dynamic raw) {
  return (raw as List<dynamic>? ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> _stringList(dynamic raw) {
  if (raw is Map) {
    return raw.values
        .map((value) => value?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return (raw as List<dynamic>? ?? const <dynamic>[])
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _humanizeIdentifier(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[-_]+'), ' ').trim();
  if (cleaned.isEmpty) return raw;
  return cleaned
      .split(RegExp(r'\s+'))
      .map((part) {
        if (part.isEmpty) return part;
        return '${part[0].toUpperCase()}${part.substring(1)}';
      })
      .join(' ');
}

class _ProcedureGroup {
  const _ProcedureGroup({
    required this.id,
    required this.sortOrder,
    required this.title,
    required this.description,
    required this.procedures,
  });

  final String id;
  final int sortOrder;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<Map<String, dynamic>> procedures;
}
