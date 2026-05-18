import '../../../app/localization_utils.dart';

typedef UfficioLocalizedText = Map<String, String>;

UfficioLocalizedText ufficioLocalizedTextFromJson(dynamic raw) {
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

String ufficioLocalizedValue(
  UfficioLocalizedText values,
  String languageCode, {
  String fallback = '',
}) => resolveLocalizedTextValue(values, languageCode, fallback: fallback);

class UfficioCatalog {
  const UfficioCatalog({
    required this.version,
    required this.updatedAt,
    required this.languages,
    required this.categories,
  });

  final int version;
  final String updatedAt;
  final List<String> languages;
  final List<UfficioCategory> categories;

  factory UfficioCatalog.fromJson(Map<String, dynamic> json) {
    final rawCategories =
        (json['categories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) =>
                  UfficioCategory.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return UfficioCatalog(
      version: (json['version'] as num?)?.toInt() ?? 1,
      updatedAt: json['updatedAt']?.toString() ?? '',
      languages: (json['languages'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      categories: rawCategories,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'version': version,
    'updatedAt': updatedAt,
    'languages': languages,
    'categories': categories.map((item) => item.toJson()).toList(),
  };

  UfficioCategory? findCategory(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  UfficioSubcategory? findSubcategory(String categoryId, String subcategoryId) {
    final category = findCategory(categoryId);
    if (category == null) return null;
    for (final subcategory in category.subcategories) {
      if (subcategory.id == subcategoryId) return subcategory;
    }
    return null;
  }

  UfficioProcedure? findProcedure(
    String categoryId,
    String subcategoryId,
    String procedureId,
  ) {
    final subcategory = findSubcategory(categoryId, subcategoryId);
    if (subcategory == null) return null;
    for (final procedure in subcategory.procedures) {
      if (procedure.id == procedureId) return procedure;
    }
    return null;
  }

  UfficioProcedure? findProcedureInCategory(
    String categoryId,
    String procedureId,
  ) {
    final category = findCategory(categoryId);
    if (category == null) return null;
    for (final subcategory in category.subcategories) {
      for (final procedure in subcategory.procedures) {
        if (procedure.id == procedureId) return procedure;
      }
    }
    return null;
  }

  String? findSubcategoryIdForProcedure(String categoryId, String procedureId) {
    final category = findCategory(categoryId);
    if (category == null) return null;
    for (final subcategory in category.subcategories) {
      for (final procedure in subcategory.procedures) {
        if (procedure.id == procedureId) return subcategory.id;
      }
    }
    return null;
  }
}

class UfficioCategory {
  const UfficioCategory({
    required this.id,
    required this.icon,
    required this.sortOrder,
    required this.isPremiumOnly,
    required this.hasPremiumContent,
    required this.title,
    required this.description,
    this.officialLinks = const <UfficioOfficialLink>[],
    this.contacts = const <UfficioContact>[],
    required this.subcategories,
  });

  final String id;
  final String icon;
  final int sortOrder;
  final bool isPremiumOnly;
  final bool hasPremiumContent;
  final UfficioLocalizedText title;
  final UfficioLocalizedText description;
  final List<UfficioOfficialLink> officialLinks;
  final List<UfficioContact> contacts;
  final List<UfficioSubcategory> subcategories;

  int get procedureCount =>
      subcategories.fold<int>(0, (sum, item) => sum + item.procedures.length);

  factory UfficioCategory.fromJson(Map<String, dynamic> json) {
    final subcategories =
        (json['subcategories'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => UfficioSubcategory.fromJson(
                Map<String, dynamic>.from(item),
                categoryId: json['id']?.toString() ?? '',
              ),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final hasPremiumContent =
        json['hasPremiumContent'] as bool? ??
        json['has_premium_content'] as bool? ??
        subcategories.any((item) => item.hasPremiumContent);
    return UfficioCategory(
      id: json['id']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'folder_open',
      sortOrder:
          (json['sortOrder'] as num?)?.toInt() ??
          (json['sort_order'] as num?)?.toInt() ??
          0,
      isPremiumOnly:
          json['isPremiumOnly'] as bool? ??
          json['is_premium_only'] as bool? ??
          false,
      hasPremiumContent: hasPremiumContent,
      title: ufficioLocalizedTextFromJson(json['title']),
      description: ufficioLocalizedTextFromJson(json['description']),
      officialLinks:
          (json['officialLinks'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (item) => UfficioOfficialLink.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      contacts: (json['contacts'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => UfficioContact.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      subcategories: subcategories,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'icon': icon,
    'sortOrder': sortOrder,
    'isPremiumOnly': isPremiumOnly,
    'hasPremiumContent': hasPremiumContent,
    'title': title,
    'description': description,
    'officialLinks': officialLinks.map((item) => item.toJson()).toList(),
    'contacts': contacts.map((item) => item.toJson()).toList(),
    'subcategories': subcategories.map((item) => item.toJson()).toList(),
  };
}

class UfficioSubcategory {
  const UfficioSubcategory({
    required this.id,
    required this.categoryId,
    required this.sortOrder,
    required this.isPremiumOnly,
    required this.hasPremiumContent,
    required this.title,
    required this.description,
    required this.procedures,
  });

  final String id;
  final String categoryId;
  final int sortOrder;
  final bool isPremiumOnly;
  final bool hasPremiumContent;
  final UfficioLocalizedText title;
  final UfficioLocalizedText description;
  final List<UfficioProcedure> procedures;

  factory UfficioSubcategory.fromJson(
    Map<String, dynamic> json, {
    required String categoryId,
  }) {
    final procedures =
        (json['procedures'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map>()
            .map(
              (item) => UfficioProcedure.fromJson(
                Map<String, dynamic>.from(item),
                categoryId: categoryId,
                subcategoryId: json['id']?.toString() ?? '',
              ),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final hasPremiumContent =
        json['hasPremiumContent'] as bool? ??
        json['has_premium_content'] as bool? ??
        procedures.any((item) => item.hasPremiumContent);
    return UfficioSubcategory(
      id: json['id']?.toString() ?? '',
      categoryId: categoryId,
      sortOrder:
          (json['sortOrder'] as num?)?.toInt() ??
          (json['sort_order'] as num?)?.toInt() ??
          0,
      isPremiumOnly:
          json['isPremiumOnly'] as bool? ??
          json['is_premium_only'] as bool? ??
          false,
      hasPremiumContent: hasPremiumContent,
      title: ufficioLocalizedTextFromJson(json['title']),
      description: ufficioLocalizedTextFromJson(json['description']),
      procedures: procedures,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'categoryId': categoryId,
    'sortOrder': sortOrder,
    'isPremiumOnly': isPremiumOnly,
    'hasPremiumContent': hasPremiumContent,
    'title': title,
    'description': description,
    'procedures': procedures.map((item) => item.toJson()).toList(),
  };
}

class UfficioProcedure {
  const UfficioProcedure({
    required this.id,
    required this.categoryId,
    required this.subcategoryId,
    required this.sortOrder,
    required this.isPremiumOnly,
    required this.requiresAuth,
    required this.title,
    required this.shortDescription,
    required this.tags,
    required this.sections,
    required this.officialLinks,
    required this.contacts,
    required this.warnings,
    required this.premiumTeaser,
  });

  final String id;
  final String categoryId;
  final String subcategoryId;
  final int sortOrder;
  final bool isPremiumOnly;
  final bool requiresAuth;
  final UfficioLocalizedText title;
  final UfficioLocalizedText shortDescription;
  final List<String> tags;
  final List<UfficioContentSection> sections;
  final List<UfficioOfficialLink> officialLinks;
  final List<UfficioContact> contacts;
  final UfficioLocalizedText warnings;
  final UfficioLocalizedText premiumTeaser;

  bool get hasPremiumContent =>
      isPremiumOnly || sections.any((item) => item.isPremiumOnly);

  factory UfficioProcedure.fromJson(
    Map<String, dynamic> json, {
    required String categoryId,
    required String subcategoryId,
  }) {
    final sections = (json['sections'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map>()
        .map(
          (item) =>
              UfficioContentSection.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
    return UfficioProcedure(
      id: json['id']?.toString() ?? '',
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      sortOrder:
          (json['sortOrder'] as num?)?.toInt() ??
          (json['sort_order'] as num?)?.toInt() ??
          0,
      isPremiumOnly:
          json['isPremiumOnly'] as bool? ??
          json['is_premium_only'] as bool? ??
          false,
      requiresAuth:
          json['requiresAuth'] as bool? ??
          json['requires_auth'] as bool? ??
          false,
      title: ufficioLocalizedTextFromJson(json['title']),
      shortDescription: ufficioLocalizedTextFromJson(
        json['shortDescription'] ?? json['short_description'],
      ),
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(),
      sections: sections,
      officialLinks:
          (json['officialLinks'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (item) => UfficioOfficialLink.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
      contacts: (json['contacts'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (item) => UfficioContact.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      warnings: ufficioLocalizedTextFromJson(json['warnings']),
      premiumTeaser: ufficioLocalizedTextFromJson(
        json['premiumTeaser'] ?? json['premium_teaser'],
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'sortOrder': sortOrder,
    'isPremiumOnly': isPremiumOnly,
    'requiresAuth': requiresAuth,
    'title': title,
    'shortDescription': shortDescription,
    'tags': tags,
    'sections': sections.map((item) => item.toJson()).toList(),
    'officialLinks': officialLinks.map((item) => item.toJson()).toList(),
    'contacts': contacts.map((item) => item.toJson()).toList(),
    'warnings': warnings,
    'premiumTeaser': premiumTeaser,
  };
}

class UfficioContentSection {
  const UfficioContentSection({
    required this.type,
    required this.key,
    required this.title,
    this.body = const <String, String>{},
    this.items = const <String, List<String>>{},
    this.isPremiumOnly = false,
  });

  final String type;
  final String key;
  final UfficioLocalizedText title;
  final UfficioLocalizedText body;
  final Map<String, List<String>> items;
  final bool isPremiumOnly;

  factory UfficioContentSection.fromJson(Map<String, dynamic> json) {
    final rawItems = <String, List<String>>{};
    final itemsJson = json['items'];
    if (itemsJson is Map) {
      for (final entry in itemsJson.entries) {
        final value = entry.value;
        if (value is List) {
          rawItems[entry.key.toString()] = value
              .map((item) => item.toString())
              .toList();
        }
      }
    }
    return UfficioContentSection(
      type: json['type']?.toString() ?? 'text',
      key: json['key']?.toString() ?? '',
      title: ufficioLocalizedTextFromJson(json['title']),
      body: ufficioLocalizedTextFromJson(json['body']),
      items: rawItems,
      isPremiumOnly:
          json['isPremiumOnly'] as bool? ??
          json['is_premium_only'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type,
    'key': key,
    'title': title,
    'body': body,
    'items': items,
    'isPremiumOnly': isPremiumOnly,
  };
}

class UfficioOfficialLink {
  const UfficioOfficialLink({
    required this.label,
    required this.url,
    required this.type,
  });

  final UfficioLocalizedText label;
  final String url;
  final String type;

  factory UfficioOfficialLink.fromJson(Map<String, dynamic> json) =>
      UfficioOfficialLink(
        label: ufficioLocalizedTextFromJson(json['label']),
        url: json['url']?.toString() ?? '',
        type: json['type']?.toString() ?? 'official',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'url': url,
    'type': type,
  };
}

class UfficioContact {
  const UfficioContact({
    required this.label,
    required this.value,
    required this.type,
    this.notes = const <String, String>{},
  });

  final UfficioLocalizedText label;
  final String value;
  final String type;
  final UfficioLocalizedText notes;

  factory UfficioContact.fromJson(Map<String, dynamic> json) => UfficioContact(
    label: ufficioLocalizedTextFromJson(json['label']),
    value: json['value']?.toString() ?? '',
    type: json['type']?.toString() ?? 'text',
    notes: ufficioLocalizedTextFromJson(json['notes']),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'value': value,
    'type': type,
    'notes': notes,
  };
}
