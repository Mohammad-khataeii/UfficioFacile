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
  final Map<String, dynamic> metadata;

  factory CmsCategory.fromJson(Map<String, dynamic> json) => CmsCategory(
    id: json['id'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    parentSlug: json['parent_slug'] as String?,
    title: Map<String, dynamic>.from((json['title'] as Map?) ?? const {}),
    shortDescription: Map<String, dynamic>.from(
      (json['short_description'] as Map?) ?? const {},
    ),
    longDescription: Map<String, dynamic>.from(
      (json['long_description'] as Map?) ?? const {},
    ),
    iconName: json['icon_name'] as String?,
    colorToken: json['color_token'] as String?,
    sortOrder: json['sort_order'] as int? ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    isPremium: json['is_premium'] as bool? ?? false,
    visibility: json['visibility'] as String? ?? 'public',
    metadata: Map<String, dynamic>.from((json['metadata'] as Map?) ?? const {}),
  );
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
  final Map<String, dynamic> metadata;

  factory CmsProcedure.fromJson(Map<String, dynamic> json) => CmsProcedure(
    id: json['id'] as String? ?? '',
    slug: json['slug'] as String? ?? '',
    categorySlug: json['category_slug'] as String? ?? '',
    subcategorySlug: json['subcategory_slug'] as String?,
    title: Map<String, dynamic>.from((json['title'] as Map?) ?? const {}),
    subtitle: Map<String, dynamic>.from((json['subtitle'] as Map?) ?? const {}),
    summary: Map<String, dynamic>.from((json['summary'] as Map?) ?? const {}),
    whatIsIt: Map<String, dynamic>.from(
      (json['what_is_it'] as Map?) ?? const {},
    ),
    whyYouNeedIt: Map<String, dynamic>.from(
      (json['why_you_need_it'] as Map?) ?? const {},
    ),
    howToDoIt: Map<String, dynamic>.from(
      (json['how_to_do_it'] as Map?) ?? const {},
    ),
    documentsNeeded: Map<String, dynamic>.from(
      (json['documents_needed'] as Map?) ?? const {},
    ),
    costsAndTiming: Map<String, dynamic>.from(
      (json['costs_and_timing'] as Map?) ?? const {},
    ),
    commonMistakes: Map<String, dynamic>.from(
      (json['common_mistakes'] as Map?) ?? const {},
    ),
    warnings: Map<String, dynamic>.from((json['warnings'] as Map?) ?? const {}),
    officialLinks: (json['official_links'] as List?) ?? const [],
    officialContacts: (json['official_contacts'] as List?) ?? const [],
    checklist: (json['checklist'] as List?) ?? const [],
    faqs: (json['faqs'] as List?) ?? const [],
    premiumNotes: Map<String, dynamic>.from(
      (json['premium_notes'] as Map?) ?? const {},
    ),
    ctaConfig: Map<String, dynamic>.from(
      (json['cta_config'] as Map?) ?? const {},
    ),
    verificationStatus: json['verification_status'] as String? ?? 'needsReview',
    lastVerifiedAt: DateTime.tryParse(
      json['last_verified_at'] as String? ?? '',
    ),
    sortOrder: json['sort_order'] as int? ?? 0,
    isActive: json['is_active'] as bool? ?? true,
    isPremium: json['is_premium'] as bool? ?? false,
    visibility: json['visibility'] as String? ?? 'public',
    metadata: Map<String, dynamic>.from((json['metadata'] as Map?) ?? const {}),
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
      );
}
