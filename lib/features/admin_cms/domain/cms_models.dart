class CmsCategory {
  const CmsCategory({
    required this.id,
    required this.slug,
    this.parentSlug,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    this.iconName,
    this.colorToken,
    required this.sortOrder,
    required this.isActive,
    required this.isPremium,
    required this.visibility,
    this.tags = const [],
    this.synonyms = const [],
    this.searchableKeywords = const [],
    this.monetizationType = 'free',
    this.allowSingleUnlock = true,
    this.singleUnlockPriceCents,
    this.singleUnlockCurrency = 'EUR',
    this.premiumReason = const {},
    this.premiumTeaser = const {},
    this.metadata = const {},
  });

  final String id;
  final String slug;
  final String? parentSlug;
  final Map<String, dynamic> title;
  final Map<String, dynamic> shortDescription;
  final Map<String, dynamic> longDescription;
  final String? iconName;
  final String? colorToken;
  final int sortOrder;
  final bool isActive;
  final bool isPremium;
  final String visibility;
  final List<String> tags;
  final List<String> synonyms;
  final List<String> searchableKeywords;
  final String monetizationType;
  final bool allowSingleUnlock;
  final int? singleUnlockPriceCents;
  final String singleUnlockCurrency;
  final Map<String, dynamic> premiumReason;
  final Map<String, dynamic> premiumTeaser;
  final Map<String, dynamic> metadata;

  factory CmsCategory.fromJson(Map<String, dynamic> json) {
    final description = _mapValue(json['description']);
    final shortDescription = _mapValue(json['short_description']);
    final subtitle = _mapValue(json['subtitle']);
    return CmsCategory(
      id: json['id'] as String? ?? json['slug'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      parentSlug: json['parent_slug'] as String?,
      title: _mapValue(json['title']),
      shortDescription: shortDescription.isNotEmpty
          ? shortDescription
          : description,
      longDescription: _firstNonEmptyMap([
        _mapValue(json['long_description']),
        description,
        subtitle,
      ]),
      iconName: json['icon_name'] as String? ?? json['icon'] as String?,
      colorToken: json['color_token'] as String? ?? json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      visibility: json['visibility'] as String? ?? 'public',
      tags: _stringList(json['tags']),
      synonyms: _stringList(json['synonyms']),
      searchableKeywords: _stringList(
        json['searchable_keywords'] ?? json['searchableKeywords'],
      ),
      monetizationType: json['monetization_type'] as String? ?? 'free',
      allowSingleUnlock: json['allow_single_unlock'] as bool? ?? true,
      singleUnlockPriceCents: (json['single_unlock_price_cents'] as num?)
          ?.toInt(),
      singleUnlockCurrency: json['single_unlock_currency'] as String? ?? 'EUR',
      premiumReason: _mapValue(json['premium_reason']),
      premiumTeaser: _mapValue(json['premium_teaser']),
      metadata: _mapValue(json['metadata']),
    );
  }
}

class CmsProcedure {
  const CmsProcedure({
    required this.id,
    required this.slug,
    required this.categorySlug,
    this.subcategorySlug,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.whatIsIt,
    required this.whyYouNeedIt,
    required this.howToDoIt,
    required this.documentsNeeded,
    required this.costsAndTiming,
    required this.commonMistakes,
    required this.warnings,
    required this.officialLinks,
    required this.officialContacts,
    required this.checklist,
    required this.faqs,
    required this.premiumNotes,
    required this.ctaConfig,
    required this.verificationStatus,
    this.lastVerifiedAt,
    required this.sortOrder,
    required this.isActive,
    required this.isPremium,
    required this.visibility,
    this.tags = const [],
    this.synonyms = const [],
    this.searchableKeywords = const [],
    this.monetizationType = 'free',
    this.allowSingleUnlock = true,
    this.singleUnlockPriceCents,
    this.singleUnlockCurrency = 'EUR',
    this.premiumReason = const {},
    this.premiumTeaser = const {},
    this.metadata = const {},
  });

  final String id;
  final String slug;
  final String categorySlug;
  final String? subcategorySlug;
  final Map<String, dynamic> title;
  final Map<String, dynamic> subtitle;
  final Map<String, dynamic> summary;
  final Map<String, dynamic> whatIsIt;
  final Map<String, dynamic> whyYouNeedIt;
  final Map<String, dynamic> howToDoIt;
  final Map<String, dynamic> documentsNeeded;
  final Map<String, dynamic> costsAndTiming;
  final Map<String, dynamic> commonMistakes;
  final Map<String, dynamic> warnings;
  final List<dynamic> officialLinks;
  final List<dynamic> officialContacts;
  final List<dynamic> checklist;
  final List<dynamic> faqs;
  final Map<String, dynamic> premiumNotes;
  final Map<String, dynamic> ctaConfig;
  final String verificationStatus;
  final DateTime? lastVerifiedAt;
  final int sortOrder;
  final bool isActive;
  final bool isPremium;
  final String visibility;
  final List<String> tags;
  final List<String> synonyms;
  final List<String> searchableKeywords;
  final String monetizationType;
  final bool allowSingleUnlock;
  final int? singleUnlockPriceCents;
  final String singleUnlockCurrency;
  final Map<String, dynamic> premiumReason;
  final Map<String, dynamic> premiumTeaser;
  final Map<String, dynamic> metadata;

  factory CmsProcedure.fromJson(Map<String, dynamic> json) => CmsProcedure(
    id: json['id'] as String? ?? json['slug'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    categorySlug: json['category_slug'] as String? ?? '',
    subcategorySlug: json['subcategory_slug'] as String?,
    title: _mapValue(json['title']),
    subtitle: _mapValue(json['subtitle']),
    summary: _firstNonEmptyMap([
      _mapValue(json['summary']),
      _mapValue(json['what_is_it']),
    ]),
    whatIsIt: _mapValue(json['what_is_it']),
    whyYouNeedIt: _mapOrListValue(
      json['why_you_need_it'] ?? json['why_you_may_need_it'],
    ),
    howToDoIt: _mapOrListValue(json['how_to_do_it']),
    documentsNeeded: _mapOrListValue(
      json['documents_needed'] ?? json['required_documents'],
    ),
    costsAndTiming: _mapOrListValue(
      json['costs_and_timing'] ??
          {'en': _combineLists(json['costs'], json['timing'])},
    ),
    commonMistakes: _mapOrListValue(json['common_mistakes']),
    warnings: _mapOrListValue(json['warnings']),
    officialLinks: (json['official_links'] as List?) ?? const [],
    officialContacts: (json['official_contacts'] as List?) ?? const [],
    checklist:
        (json['checklist'] as List?) ??
        (json['required_documents'] as List?) ??
        const [],
    faqs: (json['faqs'] as List?) ?? (json['faq'] as List?) ?? const [],
    premiumNotes: _mapOrListValue(
      json['premium_notes'] ?? json['premium_only_guidance'],
    ),
    ctaConfig: _mapValue(json['cta_config']),
    verificationStatus: json['verification_status'] as String? ?? 'needsReview',
    lastVerifiedAt: DateTime.tryParse(
      json['last_verified_at'] as String? ?? '',
    ),
    sortOrder: json['sort_order'] as int? ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    isPremium: json['is_premium'] as bool? ?? false,
    visibility: json['visibility'] as String? ?? 'public',
    tags: _stringList(json['tags']),
    synonyms: _stringList(json['synonyms']),
    searchableKeywords: _stringList(
      json['searchable_keywords'] ?? json['searchableKeywords'],
    ),
    monetizationType: json['monetization_type'] as String? ?? 'free',
    allowSingleUnlock: json['allow_single_unlock'] as bool? ?? true,
    singleUnlockPriceCents: (json['single_unlock_price_cents'] as num?)
        ?.toInt(),
    singleUnlockCurrency: json['single_unlock_currency'] as String? ?? 'EUR',
    premiumReason: _mapValue(json['premium_reason']),
    premiumTeaser: _mapValue(json['premium_teaser']),
    metadata: _mapValue(json['metadata']),
  );
}

class CmsContentBlock {
  const CmsContentBlock({
    required this.id,
    required this.procedureSlug,
    required this.blockType,
    required this.title,
    required this.body,
    required this.items,
    required this.config,
    required this.sortOrder,
    required this.isActive,
    required this.isPremium,
    required this.visibility,
    this.monetizationType = 'free',
    this.allowSingleUnlock = true,
    this.singleUnlockPriceCents,
    this.singleUnlockCurrency = 'EUR',
    this.premiumReason = const {},
    this.premiumTeaser = const {},
  });

  final String id;
  final String procedureSlug;
  final String blockType;
  final Map<String, dynamic> title;
  final Map<String, dynamic> body;
  final List<dynamic> items;
  final Map<String, dynamic> config;
  final int sortOrder;
  final bool isActive;
  final bool isPremium;
  final String visibility;
  final String monetizationType;
  final bool allowSingleUnlock;
  final int? singleUnlockPriceCents;
  final String singleUnlockCurrency;
  final Map<String, dynamic> premiumReason;
  final Map<String, dynamic> premiumTeaser;

  factory CmsContentBlock.fromJson(Map<String, dynamic> json) =>
      CmsContentBlock(
        id: json['id'] as String? ?? '',
        procedureSlug: json['procedure_slug'] as String? ?? '',
        blockType: json['block_type'] as String? ?? 'info',
        title: Map<String, dynamic>.from((json['title'] as Map?) ?? const {}),
        body: Map<String, dynamic>.from((json['body'] as Map?) ?? const {}),
        items: (json['items'] as List?) ?? const [],
        config: Map<String, dynamic>.from((json['config'] as Map?) ?? const {}),
        sortOrder: json['sort_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
        isPremium: json['is_premium'] as bool? ?? false,
        visibility: json['visibility'] as String? ?? 'public',
        monetizationType: json['monetization_type'] as String? ?? 'free',
        allowSingleUnlock: json['allow_single_unlock'] as bool? ?? true,
        singleUnlockPriceCents: (json['single_unlock_price_cents'] as num?)
            ?.toInt(),
        singleUnlockCurrency:
            json['single_unlock_currency'] as String? ?? 'EUR',
        premiumReason: _mapValue(json['premium_reason']),
        premiumTeaser: _mapValue(json['premium_teaser']),
      );
}

Map<String, dynamic> _mapValue(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return const {};
}

Map<String, dynamic> _firstNonEmptyMap(List<Map<String, dynamic>> values) {
  for (final value in values) {
    if (value.isNotEmpty) return value;
  }
  return const {};
}

Map<String, dynamic> _mapOrListValue(dynamic raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  if (raw is List) {
    return {
      'en': raw.whereType<Object>().map((item) => item.toString()).join('\n'),
    };
  }
  return const {};
}

List<String> _stringList(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Object>().map((item) => item.toString()).toList();
  }
  if (raw is Map) {
    return raw.values
        .whereType<Object>()
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  return const [];
}

String _combineLists(dynamic first, dynamic second) {
  final parts = <String>[..._stringList(first), ..._stringList(second)];
  return parts.join('\n');
}
