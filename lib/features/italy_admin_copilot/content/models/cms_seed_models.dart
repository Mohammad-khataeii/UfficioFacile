import 'dart:convert';

import '../../domain/health_asl_guidance.dart';
import '../../domain/housing_rent_guidance.dart';
import '../../domain/rich_category_models.dart';

Map<String, String> localeMapFromPrimary(
  String en, {
  String? it,
  String? fr,
  String? es,
  String? fa,
  String? ar,
}) {
  final english = en.trim();
  final italian = (it == null || it.trim().isEmpty) ? english : it.trim();
  return {
    'en': english,
    'it': italian,
    'fr': (fr == null || fr.trim().isEmpty) ? english : fr.trim(),
    'es': (es == null || es.trim().isEmpty) ? english : es.trim(),
    'fa': (fa == null || fa.trim().isEmpty) ? italian : fa.trim(),
    'ar': (ar == null || ar.trim().isEmpty) ? english : ar.trim(),
  };
}

Map<String, String> normalizeLocaleMap(dynamic raw, {String fallback = ''}) {
  if (raw is Map<String, String>) {
    return localeMapFromPrimary(
      raw['en'] ?? fallback,
      it: raw['it'],
      fr: raw['fr'],
      es: raw['es'],
      fa: raw['fa'],
      ar: raw['ar'],
    );
  }
  if (raw is Map) {
    final values = raw.map(
      (key, value) => MapEntry(
        key.toString(),
        value == null ? '' : value.toString().trim(),
      ),
    );
    return localeMapFromPrimary(
      values['en'] ?? fallback,
      it: values['it'],
      fr: values['fr'],
      es: values['es'],
      fa: values['fa'],
      ar: values['ar'],
    );
  }
  final value = raw == null ? fallback : raw.toString();
  return localeMapFromPrimary(value, it: value);
}

class CmsSeedExternalSource {
  const CmsSeedExternalSource({
    required this.sourcePath,
    required this.categorySlug,
  });

  final String sourcePath;
  final String categorySlug;
}

class CmsContentBlockSeed {
  const CmsContentBlockSeed({
    required this.blockType,
    required this.title,
    required this.body,
    this.items = const [],
    this.sortOrder = 0,
    this.isActive = true,
    this.isPremium = false,
    this.warningLevel,
    this.metadata = const {},
  });

  final String blockType;
  final Map<String, String> title;
  final Map<String, String> body;
  final List<String> items;
  final int sortOrder;
  final bool isActive;
  final bool isPremium;
  final String? warningLevel;
  final Map<String, dynamic> metadata;

  factory CmsContentBlockSeed.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['items'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
    return CmsContentBlockSeed(
      blockType: map['block_type']?.toString() ?? 'info',
      title: normalizeLocaleMap(map['title']),
      body: normalizeLocaleMap(map['body']),
      items: rawItems,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      isPremium: map['is_premium'] as bool? ?? false,
      warningLevel: map['warning_level']?.toString(),
      metadata: _map(map['metadata']),
    );
  }

  Map<String, dynamic> toJson() => {
    'block_type': blockType,
    'title': title,
    'body': body,
    'items': items,
    'sort_order': sortOrder,
    'is_active': isActive,
    'is_premium': isPremium,
    if (warningLevel != null) 'warning_level': warningLevel,
    if (metadata.isNotEmpty) 'metadata': metadata,
  };
}

class CmsProcedureSeed {
  const CmsProcedureSeed({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.summary,
    this.whatIsIt = const {},
    this.whyYouMayNeedIt = const [],
    this.howToDoIt = const [],
    this.requiredDocuments = const [],
    this.optionalDocuments = const [],
    this.warnings = const [],
    this.commonMistakes = const [],
    this.officialLinks = const [],
    this.officialContacts = const [],
    this.checklist = const [],
    this.faqs = const [],
    this.status = 'published',
    this.sortOrder = 0,
    this.isActive = true,
    this.isPremium = false,
    this.verificationStatus = 'needsReview',
    this.lastVerifiedAt,
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
    this.blocks = const [],
    this.sources = const [],
  });

  final String slug;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final Map<String, String> summary;
  final Map<String, String> whatIsIt;
  final List<dynamic> whyYouMayNeedIt;
  final List<dynamic> howToDoIt;
  final List<dynamic> requiredDocuments;
  final List<dynamic> optionalDocuments;
  final List<dynamic> warnings;
  final List<dynamic> commonMistakes;
  final List<dynamic> officialLinks;
  final List<dynamic> officialContacts;
  final List<dynamic> checklist;
  final List<dynamic> faqs;
  final String status;
  final int sortOrder;
  final bool isActive;
  final bool isPremium;
  final String verificationStatus;
  final String? lastVerifiedAt;
  final List<String> tags;
  final List<String> synonyms;
  final List<String> searchableKeywords;
  final String monetizationType;
  final bool allowSingleUnlock;
  final int? singleUnlockPriceCents;
  final String singleUnlockCurrency;
  final Map<String, String> premiumReason;
  final Map<String, String> premiumTeaser;
  final Map<String, dynamic> metadata;
  final List<CmsContentBlockSeed> blocks;
  final List<Map<String, dynamic>> sources;

  factory CmsProcedureSeed.fromMap(Map<String, dynamic> map) {
    final rawBlocks = (map['blocks'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) =>
              CmsContentBlockSeed.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
    return CmsProcedureSeed(
      slug: map['slug']?.toString() ?? '',
      title: normalizeLocaleMap(map['title']),
      subtitle: normalizeLocaleMap(map['subtitle']),
      summary: normalizeLocaleMap(map['summary']),
      whatIsIt: normalizeLocaleMap(map['what_is_it'] ?? map['summary']),
      whyYouMayNeedIt: _list(map['why_you_may_need_it']),
      howToDoIt: _list(map['how_to_do_it']),
      requiredDocuments: _list(
        map['required_documents'] ?? map['documents_needed'],
      ),
      optionalDocuments: _list(map['optional_documents']),
      warnings: _list(map['warnings']),
      commonMistakes: _list(map['common_mistakes']),
      officialLinks: _list(map['official_links']),
      officialContacts: _list(map['official_contacts']),
      checklist: _list(map['checklist']),
      faqs: _list(map['faq'] ?? map['faqs']),
      status: map['status']?.toString() ?? 'published',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      isActive: map['is_active'] as bool? ?? true,
      isPremium: map['is_premium'] as bool? ?? false,
      verificationStatus:
          map['verification_status']?.toString() ?? 'needsReview',
      lastVerifiedAt: map['last_verified_at']?.toString(),
      tags: _stringList(map['tags']),
      synonyms: _stringList(map['synonyms']),
      searchableKeywords: _stringList(
        map['searchable_keywords'] ?? map['searchableKeywords'],
      ),
      monetizationType: map['monetization_type']?.toString() ?? 'free',
      allowSingleUnlock: map['allow_single_unlock'] as bool? ?? true,
      singleUnlockPriceCents: (map['single_unlock_price_cents'] as num?)
          ?.toInt(),
      singleUnlockCurrency: map['single_unlock_currency']?.toString() ?? 'EUR',
      premiumReason: normalizeLocaleMap(map['premium_reason']),
      premiumTeaser: normalizeLocaleMap(
        map['premium_teaser'] ?? map['subtitle'] ?? map['summary'],
      ),
      metadata: _map(map['metadata']),
      blocks: rawBlocks,
      sources: (map['sources'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => _map(item))
          .toList(),
    );
  }

  Map<String, dynamic> toPublicSnapshot() => {
    'slug': slug,
    'title': title,
    'subtitle': subtitle,
    'summary': summary,
    'what_is_it': whatIsIt.isEmpty ? summary : whatIsIt,
    'blocks': blocks.map((item) => item.toJson()).toList(),
    if (sources.isNotEmpty) 'sources': sources,
  };

  Map<String, dynamic> toCmsRow(String categorySlug) {
    final normalizedBlocks = _normalizedBlocks(categorySlug, blocks);
    return {
      'id': slug,
      'slug': slug,
      'category_slug': categorySlug,
      'subcategory_slug': slug,
      'title': title,
      'subtitle': subtitle,
      'summary': summary,
      'what_is_it': whatIsIt.isEmpty ? summary : whatIsIt,
      'why_you_may_need_it': whyYouMayNeedIt,
      'how_to_do_it': howToDoIt,
      'required_documents': requiredDocuments,
      'optional_documents': optionalDocuments,
      'warnings': warnings,
      'common_mistakes': commonMistakes,
      'official_links': officialLinks,
      'official_contacts': officialContacts,
      'checklist': checklist,
      'faq': faqs,
      'status': status,
      'sort_order': sortOrder,
      'is_active': isActive,
      'is_premium': isPremium,
      'visibility': 'public',
      'verification_status': verificationStatus,
      'last_verified_at': lastVerifiedAt,
      'tags': tags,
      'synonyms': synonyms,
      'searchable_keywords': searchableKeywords,
      'monetization_type': monetizationType,
      'allow_single_unlock': allowSingleUnlock,
      'single_unlock_price_cents': singleUnlockPriceCents,
      'single_unlock_currency': singleUnlockCurrency,
      'premium_reason': premiumReason,
      'premium_teaser': premiumTeaser,
      'metadata': {
        ...metadata,
        'blocks': normalizedBlocks.map((item) => item.toJson()).toList(),
        if (sources.isNotEmpty) 'sources': sources,
      },
      'public_snapshot': {
        ...toPublicSnapshot(),
        'blocks': normalizedBlocks.map((item) => item.toJson()).toList(),
      },
    };
  }
}

class CmsCategorySeed {
  const CmsCategorySeed({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.sortOrder,
    this.icon,
    this.color,
    this.isActive = true,
    this.isPremium = false,
    this.verificationStatus = 'bundledFallback',
    this.lastVerifiedAt,
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
    this.procedures = const [],
    this.richCategorySnapshot,
    this.externalSource,
  });

  final String slug;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final Map<String, String> description;
  final int sortOrder;
  final String? icon;
  final String? color;
  final bool isActive;
  final bool isPremium;
  final String verificationStatus;
  final String? lastVerifiedAt;
  final List<String> tags;
  final List<String> synonyms;
  final List<String> searchableKeywords;
  final String monetizationType;
  final bool allowSingleUnlock;
  final int? singleUnlockPriceCents;
  final String singleUnlockCurrency;
  final Map<String, String> premiumReason;
  final Map<String, String> premiumTeaser;
  final Map<String, dynamic> metadata;
  final List<CmsProcedureSeed> procedures;
  final Map<String, dynamic>? richCategorySnapshot;
  final CmsSeedExternalSource? externalSource;

  bool get isExternalReference => externalSource != null;

  factory CmsCategorySeed.externalJsonReference({
    required String slug,
    required int sortOrder,
    required String sourcePath,
  }) {
    return CmsCategorySeed(
      slug: slug,
      title: localeMapFromPrimary(slug, it: slug),
      subtitle: const {},
      description: const {},
      sortOrder: sortOrder,
      isPremium: true,
      monetizationType: 'premium_money_value',
      allowSingleUnlock: true,
      singleUnlockCurrency: 'EUR',
      externalSource: CmsSeedExternalSource(
        sourcePath: sourcePath,
        categorySlug: slug,
      ),
    );
  }

  factory CmsCategorySeed.fromJsonMap(Map<String, dynamic> map) {
    final procedures = (map['procedures'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => CmsProcedureSeed.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
    return CmsCategorySeed(
      slug: map['slug']?.toString() ?? '',
      title: normalizeLocaleMap(map['title']),
      subtitle: normalizeLocaleMap(map['subtitle']),
      description: normalizeLocaleMap(map['description']),
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      icon: map['icon']?.toString(),
      color: map['color']?.toString(),
      isActive: map['is_active'] as bool? ?? true,
      isPremium: map['is_premium'] as bool? ?? false,
      verificationStatus:
          map['verification_status']?.toString() ?? 'needsReview',
      lastVerifiedAt: map['last_verified_at']?.toString(),
      tags: _stringList(map['tags']),
      synonyms: _stringList(map['synonyms']),
      searchableKeywords: _stringList(
        map['searchable_keywords'] ?? map['searchableKeywords'],
      ),
      monetizationType:
          map['monetization_type']?.toString() ??
          ((map['is_premium'] as bool? ?? false)
              ? 'premium_money_value'
              : 'free'),
      allowSingleUnlock: map['allow_single_unlock'] as bool? ?? true,
      singleUnlockPriceCents: (map['single_unlock_price_cents'] as num?)
          ?.toInt(),
      singleUnlockCurrency: map['single_unlock_currency']?.toString() ?? 'EUR',
      premiumReason: normalizeLocaleMap(map['premium_reason']),
      premiumTeaser: normalizeLocaleMap(
        map['premium_teaser'] ?? map['subtitle'] ?? map['description'],
      ),
      metadata: _map(map['metadata']),
      procedures: procedures,
      richCategorySnapshot: map['rich_category_snapshot'] is Map
          ? Map<String, dynamic>.from(
              map['rich_category_snapshot'] as Map<dynamic, dynamic>,
            )
          : null,
    );
  }

  factory CmsCategorySeed.fromRichGuidance({
    required RichCategoryGuidance guidance,
    required int sortOrder,
    required Map<String, String> localizedTitle,
    required Map<String, String> localizedSubtitle,
    required Map<String, String> localizedDescription,
    required bool isPremium,
    required String monetizationType,
    String? icon,
    String? color,
    List<String> tags = const [],
    List<String> synonyms = const [],
    List<String> searchableKeywords = const [],
    Map<String, String> premiumReason = const {},
    bool Function(String procedureSlug)? isProcedurePremium,
    int? Function(String procedureSlug)? procedureUnlockPriceCents,
    String Function(String procedureSlug)? procedureMonetizationType,
  }) {
    final procedures = guidance.subcategories.asMap().entries.map((entry) {
      final subcategory = entry.value;
      final premium = isProcedurePremium?.call(subcategory.id) ?? isPremium;
      return CmsProcedureSeed(
        slug: subcategory.id,
        title: localeMapFromPrimary(subcategory.title, it: subcategory.titleIt),
        subtitle: const {},
        summary: localeMapFromPrimary(
          subcategory.whatIsIt,
          it: subcategory.whatIsIt,
        ),
        whatIsIt: localeMapFromPrimary(
          subcategory.whatIsIt,
          it: subcategory.whatIsIt,
        ),
        whyYouMayNeedIt: List<dynamic>.from(subcategory.whyDoYouNeedIt),
        howToDoIt: List<dynamic>.from(subcategory.recommendedChannels),
        requiredDocuments: List<dynamic>.from(subcategory.documents),
        optionalDocuments: List<dynamic>.from(subcategory.extraDocuments),
        warnings: List<dynamic>.from(subcategory.warnings),
        officialContacts: List<dynamic>.from(subcategory.recommendedContacts),
        checklist: List<dynamic>.from(subcategory.documents),
        sortOrder: entry.key + 1,
        isActive: true,
        isPremium: premium,
        tags: _legacyProcedureTags(subcategory),
        synonyms: const [],
        searchableKeywords: _legacyProcedureKeywords(subcategory),
        monetizationType:
            procedureMonetizationType?.call(subcategory.id) ??
            (premium ? monetizationType : 'free'),
        allowSingleUnlock: premium,
        singleUnlockPriceCents: premium
            ? procedureUnlockPriceCents?.call(subcategory.id) ?? 399
            : null,
        premiumReason: premium ? premiumReason : const {},
        premiumTeaser: localeMapFromPrimary(
          subcategory.whatIsIt,
          it: subcategory.whatIsIt,
        ),
        blocks: _legacyBlocksForSubcategory(subcategory, premium),
        metadata: {
          'recommended_channels': subcategory.recommendedChannels,
          'recommended_contacts': subcategory.recommendedContacts,
          'outputs': subcategory.outputs,
        },
      );
    }).toList();

    return CmsCategorySeed(
      slug: guidance.id,
      title: localizedTitle,
      subtitle: localizedSubtitle,
      description: localizedDescription,
      sortOrder: sortOrder,
      icon: icon,
      color: color,
      isActive: true,
      isPremium: isPremium,
      verificationStatus: 'bundledFallback',
      tags: tags,
      synonyms: synonyms,
      searchableKeywords: searchableKeywords,
      monetizationType: monetizationType,
      allowSingleUnlock: isPremium,
      singleUnlockCurrency: 'EUR',
      premiumReason: premiumReason,
      premiumTeaser: localizedDescription,
      metadata: const {},
      procedures: procedures,
      richCategorySnapshot: guidance.toMap(),
    );
  }

  Map<String, dynamic> toCmsCategoryRow() => {
    'id': slug,
    'slug': slug,
    'internal_label': slug,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'short_description': description,
    'long_description': subtitle,
    'icon': icon,
    'color': color,
    'sort_order': sortOrder,
    'is_active': isActive,
    'is_premium': isPremium,
    'visibility': 'public',
    'verification_status': verificationStatus,
    'last_verified_at': lastVerifiedAt,
    'tags': tags,
    'synonyms': synonyms,
    'searchable_keywords': searchableKeywords,
    'monetization_type': monetizationType,
    'allow_single_unlock': allowSingleUnlock,
    'single_unlock_price_cents': singleUnlockPriceCents,
    'single_unlock_currency': singleUnlockCurrency,
    'premium_reason': premiumReason,
    'premium_teaser': premiumTeaser.isEmpty ? description : premiumTeaser,
    'metadata': metadata,
    'public_snapshot': toPublicSnapshot(),
  };

  Map<String, dynamic> toPublicSnapshot() => {
    'slug': slug,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'icon': icon,
    'color': color,
    'sort_order': sortOrder,
    'is_active': isActive,
    'is_premium': isPremium,
    'verification_status': verificationStatus,
    'tags': tags,
    'synonyms': synonyms,
    'searchable_keywords': searchableKeywords,
    'monetization_type': monetizationType,
    'allow_single_unlock': allowSingleUnlock,
    'single_unlock_price_cents': singleUnlockPriceCents,
    'single_unlock_currency': singleUnlockCurrency,
    'premium_reason': premiumReason,
    'premium_teaser': premiumTeaser.isEmpty ? description : premiumTeaser,
    'metadata': metadata,
    'procedures': procedures.map((item) => item.toPublicSnapshot()).toList(),
  };

  List<Map<String, dynamic>> toCmsProcedureRows() =>
      procedures.map((item) => item.toCmsRow(slug)).toList();
}

List<CmsContentBlockSeed> _normalizedBlocks(
  String categorySlug,
  List<CmsContentBlockSeed> blocks,
) {
  final normalized = List<CmsContentBlockSeed>.from(blocks);
  final text = jsonEncode(
    normalized.map((item) => item.toJson()).toList(),
  ).toLowerCase();
  if (categorySlug == 'loans-credit' &&
      !text.contains('credit') &&
      !text.contains('taeg')) {
    normalized.add(
      CmsContentBlockSeed(
        blockType: 'warning',
        title: localeMapFromPrimary(
          'Credit warning',
          it: 'Avvertenza sul credito',
          fr: 'Avertissement sur le crédit',
          es: 'Advertencia sobre el crédito',
          fa: 'هشدار درباره اعتبار',
          ar: 'تحذير حول الائتمان',
        ),
        body: localeMapFromPrimary(
          'This is credit, not free money. Compare TAEG, total cost, repayment duration, guarantees and late-payment consequences before signing.',
          it: 'Questo è credito, non denaro gratuito. Confronta TAEG, costo totale, durata del rimborso, garanzie e conseguenze dei ritardi prima di firmare.',
          fr: 'Il s’agit d’un crédit, pas d’argent gratuit. Comparez TAEG, coût total, durée de remboursement, garanties et conséquences des retards avant de signer.',
          es: 'Esto es crédito, no dinero gratis. Compara TAEG, coste total, duración del pago, garantías y consecuencias del retraso antes de firmar.',
          fa: 'این اعتبار است، نه پول رایگان. پیش از امضا TAEG، هزینه کل، مدت بازپرداخت، ضمانت‌ها و پیامد تأخیر را مقایسه کن.',
          ar: 'هذا ائتمان وليس مالاً مجانياً. قارن TAEG والتكلفة الإجمالية ومدة السداد والضمانات وعواقب التأخير قبل التوقيع.',
        ),
        sortOrder: normalized.length + 1,
        isActive: true,
        isPremium: false,
      ),
    );
  }
  if (categorySlug == 'bonuses-benefits' &&
      !text.contains('verify') &&
      !text.contains('application window') &&
      !text.contains('warning')) {
    normalized.add(
      CmsContentBlockSeed(
        blockType: 'warning',
        title: localeMapFromPrimary(
          'Check current rules',
          it: 'Controlla le regole attuali',
          fr: 'Vérifiez les règles actuelles',
          es: 'Verifica las reglas actuales',
          fa: 'قوانین فعلی را بررسی کن',
          ar: 'تحقق من القواعد الحالية',
        ),
        body: localeMapFromPrimary(
          'Eligibility depends on current rules, ISEE, residence, family status and application windows. Always verify the official page before applying.',
          it: 'L’idoneità dipende da regole attuali, ISEE, residenza, situazione familiare e finestre di domanda. Verifica sempre la pagina ufficiale prima di fare domanda.',
          fr: 'L’éligibilité dépend des règles en vigueur, de l’ISEE, de la résidence, de la situation familiale et des périodes d’ouverture. Vérifiez toujours la page officielle avant de demander.',
          es: 'La elegibilidad depende de las reglas actuales, el ISEE, la residencia, la situación familiar y las ventanas de solicitud. Verifica siempre la página oficial antes de solicitar.',
          fa: 'واجد شرایط بودن به قوانین فعلی، ISEE، محل اقامت، وضعیت خانوادگی و بازه درخواست بستگی دارد. همیشه قبل از اقدام صفحه رسمی را بررسی کن.',
          ar: 'تعتمد الأهلية على القواعد الحالية وISEE والإقامة والوضع العائلي وفترات التقديم. تحقق دائماً من الصفحة الرسمية قبل التقديم.',
        ),
        sortOrder: normalized.length + 1,
        isActive: true,
        isPremium: false,
      ),
    );
  }
  return normalized;
}

RichCategoryGuidance healthAslGuidanceToRichCategory(
  HealthAslGuidance guidance,
) {
  return RichCategoryGuidance(
    id: guidance.categoryId,
    title: guidance.title,
    titleIt: guidance.titleIt,
    region: guidance.region,
    city: guidance.city,
    shortDescription: guidance.shortDescription,
    mainUserQuestion: guidance.mainUserQuestion,
    routingLogicSummary:
        'Route the person to the correct ASL or support flow based on status, documents, and whether they need in-person help, information, or formal follow-up.',
    topWarning: guidance.topAnswer.body,
    contacts: {
      for (final entry in guidance.contacts.entries)
        entry.key: RichCategoryContact(
          id: entry.key,
          name: entry.value.name,
          address: entry.value.address,
          phone:
              entry.value.phone ??
              (entry.value.phones.isNotEmpty ? entry.value.phones.first : null),
          email: entry.value.email,
          pec: entry.value.pec,
          access: entry.value.accessMode,
          openingHours: entry.value.openingHours,
          warning: entry.value.warning,
          useFor: entry.value.useFor,
        ),
    },
    channelRules: guidance.channelRules
        .map(
          (item) => RichCategoryChannelRule(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
            priority: item.priority,
            useWhen: item.useWhen,
            address: item.address,
            warning: item.warning,
          ),
        )
        .toList(),
    commonDocuments: guidance.commonDocuments
        .map(
          (item) => RichCategoryDocument(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
          ),
        )
        .toList(),
    firstScreenQuestions: guidance.userSituationQuestions
        .map(
          (question) => RichCategoryQuestion(
            id: question.id,
            question: question.question,
            questionIt: question.questionIt,
            type: question.type,
            options: question.options
                .map(
                  (option) => RichCategoryQuestionOption(
                    id: option.id,
                    label: option.label,
                  ),
                )
                .toList(),
            showWhen: question.showWhen,
          ),
        )
        .toList(),
    subcategories: guidance.userFlows
        .map(
          (item) => RichCategorySubcategory(
            id: item.id,
            title: item.label,
            titleIt: item.labelIt,
            priority: 'high',
            whatIsIt: item.summary,
            whyDoYouNeedIt: [item.channelExplanation, item.whereToGo],
            recommendedChannels: [item.recommendedChannel],
            recommendedContacts: item.usefulContacts,
            documents: item.documents,
            extraDocuments: item.extraDocuments,
            warnings: item.warnings,
            outputs: item.outputs,
          ),
        )
        .toList(),
    outputGenerators: guidance.outputGenerators
        .map(
          (item) => RichCategoryOutputGenerator(
            id: item.id,
            title: item.title,
            titleIt: item.titleIt,
            outputType: item.outputType,
            sendTo: item.sendTo,
            templateIt: item.templateIt,
            templateBehavior: item.templateBehavior,
            warning: item.warning,
            items: item.items,
          ),
        )
        .toList(),
    routingRules: guidance.routingRules
        .map(
          (rule) => RichCategoryRoutingRule(
            conditions: rule.conditions,
            routeTo: rule.routeTo,
            note: rule.note,
          ),
        )
        .toList(),
  );
}

RichCategoryGuidance housingGuidanceToRichCategory(
  HousingRentGuidance guidance,
) {
  return RichCategoryGuidance(
    id: guidance.id,
    title: guidance.title,
    titleIt: guidance.titleIt,
    region: guidance.region,
    city: guidance.city,
    shortDescription: guidance.shortDescription,
    mainUserQuestion: guidance.mainUserQuestion,
    routingLogicSummary: guidance.routingLogicSummary,
    contacts: {
      for (final entry in guidance.contacts.entries)
        entry.key: RichCategoryContact(
          id: entry.value.id,
          name: entry.value.name,
          officeCode: entry.value.officeCode,
          address: entry.value.address,
          phone: entry.value.phone,
          email: entry.value.email,
          pec: entry.value.pec,
          openingHours: entry.value.openingHours,
          warning: entry.value.warning,
          useFor: entry.value.useFor,
        ),
    },
    channelRules: guidance.channelRules
        .map(
          (item) => RichCategoryChannelRule(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
            priority: item.priority,
            useWhen: item.useWhen,
            warning: item.warning,
          ),
        )
        .toList(),
    commonDocuments: guidance.commonDocuments
        .map(
          (item) => RichCategoryDocument(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
          ),
        )
        .toList(),
    subcategories: guidance.subcategories
        .map(
          (item) => RichCategorySubcategory(
            id: item.id,
            title: item.title,
            titleIt: item.titleIt,
            priority: item.priority,
            whatIsIt: item.whatIsIt,
            whyDoYouNeedIt: item.whyDoYouNeedIt,
            recommendedChannels: item.recommendedChannels,
            recommendedContacts: item.recommendedContacts,
            documents: item.documents,
            extraDocuments: item.extraDocuments,
            warnings: item.warnings,
            outputs: item.outputs,
          ),
        )
        .toList(),
    outputGenerators: guidance.outputGenerators
        .map(
          (item) => RichCategoryOutputGenerator(
            id: item.id,
            title: item.title,
            titleIt: item.titleIt,
            outputType: item.outputType,
            recipient: item.recipient,
            sendTo: item.sendTo,
            templateIt: item.templateIt,
          ),
        )
        .toList(),
  );
}

List<String> _legacyProcedureTags(RichCategorySubcategory subcategory) {
  return {
    ...subcategory.recommendedChannels.map((item) => item.toLowerCase()),
    ...subcategory.recommendedContacts.map((item) => item.toLowerCase()),
  }.toList();
}

List<String> _legacyProcedureKeywords(RichCategorySubcategory subcategory) {
  return {
    subcategory.title.toLowerCase(),
    subcategory.titleIt.toLowerCase(),
    ...subcategory.documents.map((item) => item.toLowerCase()),
    ...subcategory.whyDoYouNeedIt.map((item) => item.toLowerCase()),
  }.toList();
}

List<CmsContentBlockSeed> _legacyBlocksForSubcategory(
  RichCategorySubcategory subcategory,
  bool premium,
) {
  final blocks = <CmsContentBlockSeed>[
    CmsContentBlockSeed(
      blockType: 'intro',
      title: localeMapFromPrimary('Overview', it: 'Panoramica'),
      body: localeMapFromPrimary(
        subcategory.whatIsIt,
        it: subcategory.whatIsIt,
      ),
      sortOrder: 1,
      isActive: true,
      isPremium: false,
    ),
  ];
  if (subcategory.documents.isNotEmpty) {
    blocks.add(
      CmsContentBlockSeed(
        blockType: 'documents',
        title: localeMapFromPrimary(
          'Typical documents',
          it: 'Documenti tipici',
        ),
        body: localeMapFromPrimary(
          'Prepare the key documents before you start the request.',
          it: 'Prepara i documenti principali prima di iniziare la pratica.',
        ),
        items: subcategory.documents,
        sortOrder: blocks.length + 1,
        isActive: true,
        isPremium: premium,
      ),
    );
  }
  if (subcategory.warnings.isNotEmpty) {
    blocks.add(
      CmsContentBlockSeed(
        blockType: 'warning',
        title: localeMapFromPrimary('Watch out', it: 'Attenzione'),
        body: localeMapFromPrimary(
          subcategory.warnings.join('\n'),
          it: subcategory.warnings.join('\n'),
        ),
        sortOrder: blocks.length + 1,
        isActive: true,
        isPremium: premium,
      ),
    );
  }
  return blocks;
}

Map<String, dynamic> _map(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}

List<dynamic> _list(dynamic raw) {
  if (raw is List) return List<dynamic>.from(raw);
  if (raw == null) return const [];
  return [raw];
}

List<String> _stringList(dynamic raw) {
  return _list(raw)
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
