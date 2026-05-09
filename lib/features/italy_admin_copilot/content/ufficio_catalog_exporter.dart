import '../domain/ufficio_catalog.dart';

Map<String, dynamic> buildUfficioCatalogBundleFromCmsSeed(
  Map<String, dynamic> cmsSeedBundle,
) {
  final categories =
      (cmsSeedBundle['categories'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );

  return <String, dynamic>{
    'version': 1,
    'updatedAt': DateTime.now().toUtc().toIso8601String().split('T').first,
    'languages': const <String>['en', 'it', 'fr', 'es', 'fa', 'ar'],
    'categories': categories.map(_buildCategory).toList(),
  };
}

Map<String, dynamic> _buildCategory(Map<String, dynamic> category) {
  final procedures =
      (category['procedures'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );

  final groups = <String, List<Map<String, dynamic>>>{};
  for (final procedure in procedures) {
    final key =
        procedure['subcategory_slug']?.toString() ??
        procedure['slug']?.toString() ??
        'procedure';
    groups.putIfAbsent(key, () => <Map<String, dynamic>>[]).add(procedure);
  }

  final subcategories = groups.entries.toList()
    ..sort((a, b) {
      final aOrder = (a.value.first['sort_order'] as num?)?.toInt() ?? 0;
      final bOrder = (b.value.first['sort_order'] as num?)?.toInt() ?? 0;
      return aOrder.compareTo(bOrder);
    });

  final builtSubcategories = subcategories.map((entry) {
    final first = entry.value.first;
    final subcategoryTitle = ufficioLocalizedTextFromJson(
      (first['metadata'] as Map?)?['subcategory_title'] ?? first['title'],
    );
    final subcategoryDescription = ufficioLocalizedTextFromJson(
      (first['metadata'] as Map?)?['subcategory_description'] ??
          first['summary'] ??
          first['premium_teaser'],
    );
    final builtProcedures = entry.value.map((procedure) {
      return _buildProcedure(
        categoryId: category['slug']?.toString() ?? '',
        subcategoryId: entry.key,
        procedure: procedure,
      );
    }).toList();
    final hasPremiumContent = builtProcedures.any(
      (item) => item['isPremiumOnly'] == true || _sectionHasPremium(item),
    );
    return <String, dynamic>{
      'id': entry.key,
      'categoryId': category['slug'],
      'sortOrder': (first['sort_order'] as num?)?.toInt() ?? 0,
      'isPremiumOnly': builtProcedures.every(
        (item) => item['isPremiumOnly'] == true,
      ),
      'hasPremiumContent': hasPremiumContent,
      'title': subcategoryTitle,
      'description': subcategoryDescription,
      'procedures': builtProcedures,
    };
  }).toList();

  final hasPremiumContent = builtSubcategories.any(
    (item) =>
        item['hasPremiumContent'] == true || item['isPremiumOnly'] == true,
  );

  return <String, dynamic>{
    'id': category['slug'],
    'icon': category['icon']?.toString() ?? 'folder_open',
    'sortOrder': (category['sort_order'] as num?)?.toInt() ?? 0,
    'isPremiumOnly': category['is_premium'] as bool? ?? false,
    'hasPremiumContent': hasPremiumContent,
    'title': ufficioLocalizedTextFromJson(category['title']),
    'description': ufficioLocalizedTextFromJson(
      category['description'] ?? category['subtitle'],
    ),
    'subcategories': builtSubcategories,
  };
}

Map<String, dynamic> _buildProcedure({
  required String categoryId,
  required String subcategoryId,
  required Map<String, dynamic> procedure,
}) {
  final isPremium = procedure['is_premium'] as bool? ?? false;
  final sections = <Map<String, dynamic>>[];

  void addTextSection(
    String key,
    dynamic title,
    dynamic body, {
    required bool isPremiumOnly,
  }) {
    final localizedBody = _normalizeSectionBody(body);
    if (localizedBody.values.every((item) => item.trim().isEmpty)) return;
    sections.add(<String, dynamic>{
      'type': 'text',
      'key': key,
      'title': ufficioLocalizedTextFromJson(title),
      'body': localizedBody,
      'isPremiumOnly': isPremiumOnly,
    });
  }

  void addChecklistSection(
    String key,
    dynamic title,
    dynamic items, {
    required bool isPremiumOnly,
  }) {
    final localizedItems = _normalizeItems(items);
    if (localizedItems.values.every((list) => list.isEmpty)) return;
    sections.add(<String, dynamic>{
      'type': 'checklist',
      'key': key,
      'title': ufficioLocalizedTextFromJson(title),
      'items': localizedItems,
      'isPremiumOnly': isPremiumOnly,
    });
  }

  addTextSection(
    'what_it_is',
    const <String, String>{
      'en': 'What it is',
      'it': 'Cos’è',
      'fr': 'Ce que c’est',
      'es': 'Qué es',
      'fa': 'چیست',
      'ar': 'ما هو',
    },
    procedure['what_is_it'] ?? procedure['summary'],
    isPremiumOnly: false,
  );
  addChecklistSection(
    'when_you_need_it',
    const <String, String>{
      'en': 'When you need it',
      'it': 'Quando ti serve',
      'fr': 'Quand vous en avez besoin',
      'es': 'Cuándo lo necesitas',
      'fa': 'چه زمانی لازم است',
      'ar': 'متى تحتاج إليه',
    },
    procedure['why_you_may_need_it'],
    isPremiumOnly: false,
  );
  addChecklistSection(
    'how_to_do_it',
    const <String, String>{
      'en': 'How to do it',
      'it': 'Come fare',
      'fr': 'Comment faire',
      'es': 'Cómo hacerlo',
      'fa': 'چطور انجام دهی',
      'ar': 'كيفية القيام به',
    },
    procedure['how_to_do_it'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'documents_needed',
    const <String, String>{
      'en': 'Documents needed',
      'it': 'Documenti necessari',
      'fr': 'Documents nécessaires',
      'es': 'Documentos necesarios',
      'fa': 'مدارک لازم',
      'ar': 'المستندات المطلوبة',
    },
    procedure['required_documents'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'cost',
    const <String, String>{
      'en': 'Cost',
      'it': 'Costo',
      'fr': 'Coût',
      'es': 'Costo',
      'fa': 'هزینه',
      'ar': 'التكلفة',
    },
    procedure['costs'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'timeline',
    const <String, String>{
      'en': 'Timeline',
      'it': 'Tempi',
      'fr': 'Délais',
      'es': 'Plazos',
      'fa': 'زمان‌بندی',
      'ar': 'المدة',
    },
    procedure['timing'],
    isPremiumOnly: isPremium,
  );
  addChecklistSection(
    'warnings',
    const <String, String>{
      'en': 'Warnings',
      'it': 'Avvertenze',
      'fr': 'Avertissements',
      'es': 'Advertencias',
      'fa': 'هشدارها',
      'ar': 'تحذيرات',
    },
    procedure['warnings'],
    isPremiumOnly: false,
  );

  final blocks =
      (procedure['blocks'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort(
          (a, b) => ((a['sort_order'] as num?)?.toInt() ?? 0).compareTo(
            (b['sort_order'] as num?)?.toInt() ?? 0,
          ),
        );
  for (final block in blocks) {
    final blockBody = _normalizeSectionBody(block['body']);
    final blockItems = _normalizeItems(block['items']);
    if (blockBody.values.every((item) => item.trim().isEmpty) &&
        blockItems.values.every((item) => item.isEmpty)) {
      continue;
    }
    sections.add(<String, dynamic>{
      'type': blockItems.values.any((item) => item.isNotEmpty)
          ? 'checklist'
          : 'text',
      'key': block['block_type']?.toString() ?? 'info',
      'title': ufficioLocalizedTextFromJson(block['title']),
      'body': blockBody,
      'items': blockItems,
      'isPremiumOnly': (block['is_premium'] as bool? ?? false) || isPremium,
    });
  }

  final warnings = _normalizeSectionBodyFromList(procedure['warnings']);
  return <String, dynamic>{
    'id': procedure['slug'],
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'sortOrder': (procedure['sort_order'] as num?)?.toInt() ?? 0,
    'isPremiumOnly': isPremium,
    'requiresAuth': false,
    'title': ufficioLocalizedTextFromJson(procedure['title']),
    'shortDescription': ufficioLocalizedTextFromJson(
      procedure['summary'] ?? procedure['subtitle'],
    ),
    'tags': (procedure['tags'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .toList(),
    'sections': sections,
    'officialLinks': _buildOfficialLinks(procedure),
    'contacts': _buildContacts(procedure),
    'warnings': warnings,
    'premiumTeaser': ufficioLocalizedTextFromJson(
      procedure['premium_teaser'] ?? procedure['summary'],
    ),
  };
}

bool _sectionHasPremium(Map<String, dynamic> procedure) {
  final sections =
      (procedure['sections'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>();
  for (final section in sections) {
    if (section['isPremiumOnly'] == true) return true;
  }
  return false;
}

Map<String, String> _normalizeSectionBody(dynamic value) {
  if (value is Map) {
    final localized = ufficioLocalizedTextFromJson(value);
    if (localized.isNotEmpty) return localized;
  }
  if (value is List) {
    return _normalizeSectionBodyFromList(value);
  }
  if (value is String && value.trim().isNotEmpty) {
    return <String, String>{'en': value.trim(), 'it': value.trim()};
  }
  return const <String, String>{};
}

Map<String, String> _normalizeSectionBodyFromList(dynamic value) {
  if (value is List) {
    final texts = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (texts.isNotEmpty) {
      final joined = texts.join('\n');
      return <String, String>{'en': joined, 'it': joined};
    }
  }
  return const <String, String>{};
}

Map<String, List<String>> _normalizeItems(dynamic value) {
  if (value is Map) {
    final result = <String, List<String>>{};
    for (final entry in value.entries) {
      final itemValue = entry.value;
      if (itemValue is List) {
        result[entry.key.toString()] = itemValue
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();
      } else if (itemValue is String && itemValue.trim().isNotEmpty) {
        result[entry.key.toString()] = <String>[itemValue.trim()];
      }
    }
    return result;
  }
  if (value is List) {
    final items = value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isNotEmpty) {
      return <String, List<String>>{'en': items, 'it': items};
    }
  }
  if (value is String && value.trim().isNotEmpty) {
    return <String, List<String>>{
      'en': <String>[value.trim()],
      'it': <String>[value.trim()],
    };
  }
  return const <String, List<String>>{};
}

List<Map<String, dynamic>> _buildOfficialLinks(Map<String, dynamic> procedure) {
  final links = <Map<String, dynamic>>[];
  final sources = (procedure['sources'] as List<dynamic>? ?? const <dynamic>[])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item));
  for (final source in sources) {
    final url = source['url']?.toString() ?? '';
    if (url.trim().isEmpty) continue;
    links.add(<String, dynamic>{
      'label': ufficioLocalizedTextFromJson(
        source['title'] ?? source['label'] ?? source['authority'],
      ),
      'url': url,
      'type': source['source_type']?.toString() ?? 'official',
    });
  }
  final officialLinks =
      (procedure['official_links'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty);
  for (final item in officialLinks) {
    links.add(<String, dynamic>{
      'label': <String, String>{'en': item, 'it': item},
      'url': '',
      'type': 'reference',
    });
  }
  return links;
}

List<Map<String, dynamic>> _buildContacts(Map<String, dynamic> procedure) {
  final contacts = <Map<String, dynamic>>[];
  final officialContacts =
      (procedure['official_contacts'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty);
  for (final item in officialContacts) {
    contacts.add(<String, dynamic>{
      'label': <String, String>{'en': item, 'it': item},
      'value': item,
      'type': 'reference',
    });
  }
  return contacts;
}
