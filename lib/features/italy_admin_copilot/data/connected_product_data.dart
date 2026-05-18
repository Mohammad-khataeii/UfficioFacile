import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/catalog_models.dart';
import '../domain/ufficio_catalog.dart';
import 'catalog_repository.dart';
import 'ufficio_catalog_repository.dart';

enum UfficioPremiumVisibility { free, premiumPreview, premiumOnly, hidden }

enum ConnectedChecklistStatus { todo, inProgress, done, skipped }

enum ConnectedDeadlineStatus { upcoming, dueSoon, overdue, done, canceled }

enum ConnectedCostStatus { estimated, confirmed, paid, disputed, waived }

class CatalogLocationSelection {
  const CatalogLocationSelection({
    this.city = '',
    this.region = '',
    this.province = '',
    this.postcode = '',
  });

  final String city;
  final String region;
  final String province;
  final String postcode;

  bool get hasLocation => city.trim().isNotEmpty || region.trim().isNotEmpty;
}

class ConnectedProcedureRecord {
  const ConnectedProcedureRecord({
    required this.categoryId,
    required this.subcategoryId,
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.description,
    required this.steps,
    required this.whenYouNeedIt,
    required this.preparationChecklist,
    required this.documentsRequired,
    required this.costs,
    required this.timelines,
    required this.channels,
    required this.warnings,
    required this.officialLinks,
    required this.officialContacts,
    required this.relatedProcedureIds,
    required this.tags,
    required this.premiumVisibility,
    this.requiredPlan,
    this.localVariationNote,
  });

  final String categoryId;
  final String subcategoryId;
  final String id;
  final String slug;
  final String title;
  final String summary;
  final String description;
  final List<String> steps;
  final List<String> whenYouNeedIt;
  final List<String> preparationChecklist;
  final List<String> documentsRequired;
  final List<String> costs;
  final List<String> timelines;
  final List<String> channels;
  final List<String> warnings;
  final List<UfficioOfficialLink> officialLinks;
  final List<UfficioContact> officialContacts;
  final List<String> relatedProcedureIds;
  final List<String> tags;
  final UfficioPremiumVisibility premiumVisibility;
  final String? requiredPlan;
  final String? localVariationNote;
}

class ConnectedSubcategoryRecord {
  const ConnectedSubcategoryRecord({
    required this.categoryId,
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.premiumVisibility,
    required this.procedures,
  });

  final String categoryId;
  final String id;
  final String slug;
  final String title;
  final String description;
  final int sortOrder;
  final UfficioPremiumVisibility premiumVisibility;
  final List<ConnectedProcedureRecord> procedures;
}

class ConnectedCategoryRecord {
  const ConnectedCategoryRecord({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.icon,
    required this.sortOrder,
    required this.premiumVisibility,
    required this.subcategories,
    required this.officialLinks,
    required this.officialContacts,
  });

  final String id;
  final String slug;
  final String title;
  final String description;
  final String icon;
  final int sortOrder;
  final UfficioPremiumVisibility premiumVisibility;
  final List<ConnectedSubcategoryRecord> subcategories;
  final List<UfficioOfficialLink> officialLinks;
  final List<UfficioContact> officialContacts;
}

class CatalogSearchResult {
  const CatalogSearchResult({
    required this.categoryId,
    required this.categoryTitle,
    required this.subcategoryId,
    required this.subcategoryTitle,
    required this.procedureId,
    required this.procedureTitle,
    required this.reason,
    required this.score,
    required this.premiumVisibility,
    required this.locationLabel,
  });

  final String categoryId;
  final String categoryTitle;
  final String subcategoryId;
  final String subcategoryTitle;
  final String procedureId;
  final String procedureTitle;
  final String reason;
  final int score;
  final UfficioPremiumVisibility premiumVisibility;
  final String locationLabel;
}

class ProblemIntakeResult {
  const ProblemIntakeResult({
    required this.normalizedQuery,
    required this.clarifyingQuestions,
    required this.results,
    required this.snapshot,
  });

  final String normalizedQuery;
  final List<String> clarifyingQuestions;
  final List<CatalogSearchResult> results;
  final SituationScanRecord snapshot;
}

class SituationScanRecord {
  const SituationScanRecord({
    required this.id,
    required this.city,
    required this.region,
    required this.statusTags,
    required this.problemTags,
    required this.urgency,
    required this.matchedProcedureIds,
    required this.recommendedDocuments,
    required this.recommendedDeadlines,
    required this.recommendedCostItems,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });

  final String id;
  final String? userId;
  final String city;
  final String region;
  final List<String> statusTags;
  final List<String> problemTags;
  final Map<String, dynamic> urgency;
  final List<String> matchedProcedureIds;
  final List<String> recommendedDocuments;
  final List<String> recommendedDeadlines;
  final List<String> recommendedCostItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'city': city,
    'region': region,
    'statusTags': statusTags,
    'problemTags': problemTags,
    'urgency': urgency,
    'matchedProcedureIds': matchedProcedureIds,
    'recommendedDocuments': recommendedDocuments,
    'recommendedDeadlines': recommendedDeadlines,
    'recommendedCostItems': recommendedCostItems,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SituationScanRecord.fromJson(
    Map<String, dynamic> json,
  ) => SituationScanRecord(
    id: json['id'] as String? ?? '',
    userId: json['userId'] as String?,
    city: json['city'] as String? ?? '',
    region: json['region'] as String? ?? '',
    statusTags: ((json['statusTags'] as List?) ?? const []).cast<String>(),
    problemTags: ((json['problemTags'] as List?) ?? const []).cast<String>(),
    urgency: Map<String, dynamic>.from(
      (json['urgency'] as Map?) ?? const <String, dynamic>{},
    ),
    matchedProcedureIds: ((json['matchedProcedureIds'] as List?) ?? const [])
        .cast<String>(),
    recommendedDocuments: ((json['recommendedDocuments'] as List?) ?? const [])
        .cast<String>(),
    recommendedDeadlines: ((json['recommendedDeadlines'] as List?) ?? const [])
        .cast<String>(),
    recommendedCostItems: ((json['recommendedCostItems'] as List?) ?? const [])
        .cast<String>(),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class ChecklistItemRecord {
  const ChecklistItemRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.sourceType,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.sourceProcedureId,
    this.dueDate,
    this.categorySlug,
    this.procedureSlug,
    this.documentRequired,
    this.officialLink,
    this.note,
  });

  final String id;
  final String? userId;
  final String title;
  final String description;
  final String sourceType;
  final String? sourceProcedureId;
  final ConnectedChecklistStatus status;
  final DateTime? dueDate;
  final int priority;
  final String? categorySlug;
  final String? procedureSlug;
  final String? documentRequired;
  final String? officialLink;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChecklistItemRecord copyWith({
    ConnectedChecklistStatus? status,
    DateTime? dueDate,
    String? note,
  }) => ChecklistItemRecord(
    id: id,
    userId: userId,
    title: title,
    description: description,
    sourceType: sourceType,
    sourceProcedureId: sourceProcedureId,
    status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate,
    priority: priority,
    categorySlug: categorySlug,
    procedureSlug: procedureSlug,
    documentRequired: documentRequired,
    officialLink: officialLink,
    note: note ?? this.note,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'sourceType': sourceType,
    'sourceProcedureId': sourceProcedureId,
    'status': status.name,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
    'categorySlug': categorySlug,
    'procedureSlug': procedureSlug,
    'documentRequired': documentRequired,
    'officialLink': officialLink,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ChecklistItemRecord.fromJson(
    Map<String, dynamic> json,
  ) => ChecklistItemRecord(
    id: json['id'] as String? ?? '',
    userId: json['userId'] as String?,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    sourceType: json['sourceType'] as String? ?? 'manual',
    sourceProcedureId: json['sourceProcedureId'] as String?,
    status: ConnectedChecklistStatus.values.firstWhere(
      (item) => item.name == json['status'],
      orElse: () => ConnectedChecklistStatus.todo,
    ),
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
    priority: (json['priority'] as num?)?.toInt() ?? 1,
    categorySlug: json['categorySlug'] as String?,
    procedureSlug: json['procedureSlug'] as String?,
    documentRequired: json['documentRequired'] as String?,
    officialLink: json['officialLink'] as String?,
    note: json['note'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class DeadlineRecord {
  const DeadlineRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.sourceType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.sourceProcedureId,
    this.categorySlug,
    this.procedureSlug,
    this.reminderEnabled = true,
    this.reminderOffsetDays = 7,
    this.officialLink,
  });

  final String id;
  final String? userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String sourceType;
  final String? sourceProcedureId;
  final String? categorySlug;
  final String? procedureSlug;
  final ConnectedDeadlineStatus status;
  final bool reminderEnabled;
  final int reminderOffsetDays;
  final String? officialLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'sourceType': sourceType,
    'sourceProcedureId': sourceProcedureId,
    'categorySlug': categorySlug,
    'procedureSlug': procedureSlug,
    'status': status.name,
    'reminderEnabled': reminderEnabled,
    'reminderOffsetDays': reminderOffsetDays,
    'officialLink': officialLink,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DeadlineRecord.fromJson(Map<String, dynamic> json) => DeadlineRecord(
    id: json['id'] as String? ?? '',
    userId: json['userId'] as String?,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    dueDate:
        DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
    sourceType: json['sourceType'] as String? ?? 'manual',
    sourceProcedureId: json['sourceProcedureId'] as String?,
    categorySlug: json['categorySlug'] as String?,
    procedureSlug: json['procedureSlug'] as String?,
    status: ConnectedDeadlineStatus.values.firstWhere(
      (item) => item.name == json['status'],
      orElse: () => ConnectedDeadlineStatus.upcoming,
    ),
    reminderEnabled: json['reminderEnabled'] as bool? ?? true,
    reminderOffsetDays: (json['reminderOffsetDays'] as num?)?.toInt() ?? 7,
    officialLink: json['officialLink'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class SavedProcedureRecord {
  const SavedProcedureRecord({
    required this.id,
    required this.categorySlug,
    required this.subcategorySlug,
    required this.procedureSlug,
    required this.createdAt,
    this.userId,
  });

  final String id;
  final String? userId;
  final String categorySlug;
  final String subcategorySlug;
  final String procedureSlug;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'categorySlug': categorySlug,
    'subcategorySlug': subcategorySlug,
    'procedureSlug': procedureSlug,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavedProcedureRecord.fromJson(Map<String, dynamic> json) =>
      SavedProcedureRecord(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String?,
        categorySlug: json['categorySlug'] as String? ?? '',
        subcategorySlug: json['subcategorySlug'] as String? ?? '',
        procedureSlug: json['procedureSlug'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class ConnectedCostItemRecord {
  const ConnectedCostItemRecord({
    required this.id,
    required this.title,
    required this.amountMin,
    required this.amountMax,
    required this.frequency,
    required this.status,
    required this.sourceType,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.sourceProcedureId,
    this.dueDate,
    this.categorySlug,
    this.providerName,
    this.officialLink,
    this.notes,
  });

  final String id;
  final String? userId;
  final String title;
  final double amountMin;
  final double amountMax;
  final String frequency;
  final ConnectedCostStatus status;
  final String sourceType;
  final String? sourceProcedureId;
  final DateTime? dueDate;
  final String? categorySlug;
  final String? providerName;
  final String? officialLink;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'amountMin': amountMin,
    'amountMax': amountMax,
    'frequency': frequency,
    'status': status.name,
    'sourceType': sourceType,
    'sourceProcedureId': sourceProcedureId,
    'dueDate': dueDate?.toIso8601String(),
    'categorySlug': categorySlug,
    'providerName': providerName,
    'officialLink': officialLink,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ConnectedCostItemRecord.fromJson(
    Map<String, dynamic> json,
  ) => ConnectedCostItemRecord(
    id: json['id'] as String? ?? '',
    userId: json['userId'] as String?,
    title: json['title'] as String? ?? '',
    amountMin: (json['amountMin'] as num?)?.toDouble() ?? 0,
    amountMax: (json['amountMax'] as num?)?.toDouble() ?? 0,
    frequency: json['frequency'] as String? ?? 'unknown',
    status: ConnectedCostStatus.values.firstWhere(
      (item) => item.name == json['status'],
      orElse: () => ConnectedCostStatus.estimated,
    ),
    sourceType: json['sourceType'] as String? ?? 'manual',
    sourceProcedureId: json['sourceProcedureId'] as String?,
    dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
    categorySlug: json['categorySlug'] as String?,
    providerName: json['providerName'] as String?,
    officialLink: json['officialLink'] as String?,
    notes: json['notes'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class ProviderRecord {
  const ProviderRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.officialWebsite,
    required this.supportUrl,
    required this.complaintUrl,
    required this.cancellationUrl,
    required this.pec,
    required this.email,
    required this.phone,
    required this.notes,
    required this.lastVerifiedAt,
  });

  final String id;
  final String name;
  final String category;
  final String officialWebsite;
  final String supportUrl;
  final String complaintUrl;
  final String cancellationUrl;
  final String pec;
  final String email;
  final String phone;
  final String notes;
  final DateTime? lastVerifiedAt;
}

class OfferSuggestion {
  const OfferSuggestion({
    required this.providerId,
    required this.providerName,
    required this.suggestionType,
    required this.score,
    required this.reasons,
    required this.warnings,
    required this.officialLinks,
    required this.requiredUserChecks,
    required this.lastVerifiedAt,
  });

  final String providerId;
  final String providerName;
  final String suggestionType;
  final int score;
  final List<String> reasons;
  final List<String> warnings;
  final List<String> officialLinks;
  final List<String> requiredUserChecks;
  final DateTime? lastVerifiedAt;
}

class ConnectedCatalogService {
  ConnectedCatalogService({
    required UfficioCatalogRepository catalogRepository,
    required CatalogRepository publicCatalogRepository,
  }) : _catalogRepository = catalogRepository,
       _publicCatalogRepository = publicCatalogRepository;

  final UfficioCatalogRepository _catalogRepository;
  final CatalogRepository _publicCatalogRepository;

  static const Map<String, List<String>> _synonyms = {
    'tessera sanitaria': ['health card', 'ssn', 'doctor', 'asl'],
    'medico di base': ['doctor', 'family doctor', 'general practitioner'],
    'asl': ['health office', 'ssn', 'doctor'],
    'residenza': ['residence', 'anagrafe', 'comune'],
    'permesso di soggiorno': ['residence permit', 'questura'],
    'isee': ['dsu', 'caf', 'income declaration'],
    'naspi': ['unemployment', 'inps', 'patronato'],
    'pec': ['certified email'],
    'raccomandata': ['registered mail'],
    'disdetta': ['cancel internet', 'cancellation'],
    'voltura': ['contract transfer', 'utilities move'],
    'subentro': ['reactivation', 'new activation'],
    'bolletta': ['bill', 'utility bill', 'high bill'],
    'conguaglio': ['adjustment bill'],
    'reclamo': ['complaint'],
    'conciliazione': ['conciliation', 'agcom', 'arera'],
    'agcom': ['conciliaweb', 'telecom complaint'],
    'arera': ['portale offerte', 'energy complaint'],
    'canone rai': ['rai', 'tv fee'],
    'contratto affitto': ['rental contract', 'deposit', 'landlord'],
    'deposito cauzionale': ['deposit return'],
    'assicurazione sanitaria studenti': ['student health insurance'],
  };

  Future<List<ConnectedCategoryRecord>> loadConnectedCatalog({
    required String languageCode,
    CatalogLocationSelection location = const CatalogLocationSelection(),
  }) async {
    final result = await _catalogRepository.loadCatalogResult(
      citySlug: location.city.trim().isEmpty ? null : location.city.trim(),
    );
    final catalog = result.catalog;
    if (catalog == null) {
      return const <ConnectedCategoryRecord>[];
    }
    return catalog.categories
        .map(
          (category) => ConnectedCategoryRecord(
            id: category.id,
            slug: category.id,
            title: ufficioLocalizedValue(
              category.title,
              languageCode,
              fallback: category.id,
            ),
            description: ufficioLocalizedValue(
              category.description,
              languageCode,
            ),
            icon: category.icon,
            sortOrder: category.sortOrder,
            premiumVisibility: _premiumForCategory(category),
            officialLinks: category.officialLinks,
            officialContacts: category.contacts,
            subcategories: category.subcategories
                .map(
                  (subcategory) => ConnectedSubcategoryRecord(
                    categoryId: category.id,
                    id: subcategory.id,
                    slug: subcategory.id,
                    title: ufficioLocalizedValue(
                      subcategory.title,
                      languageCode,
                      fallback: subcategory.id,
                    ),
                    description: ufficioLocalizedValue(
                      subcategory.description,
                      languageCode,
                    ),
                    sortOrder: subcategory.sortOrder,
                    premiumVisibility: _premiumForSubcategory(subcategory),
                    procedures: subcategory.procedures
                        .map(
                          (procedure) => _toConnectedProcedure(
                            category: category,
                            subcategory: subcategory,
                            procedure: procedure,
                            languageCode: languageCode,
                            location: location,
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Future<List<CatalogSearchResult>> searchCatalog({
    required String query,
    required String languageCode,
    CatalogLocationSelection location = const CatalogLocationSelection(),
    String? categoryId,
    String? subcategoryId,
    String? channel,
    bool includePremium = true,
  }) async {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return const <CatalogSearchResult>[];
    }
    final categories = await loadConnectedCatalog(
      languageCode: languageCode,
      location: location,
    );
    final expandedTokens = _expandedTokens(normalizedQuery);
    final results = <CatalogSearchResult>[];
    for (final category in categories) {
      if (categoryId != null && category.id != categoryId) continue;
      for (final subcategory in category.subcategories) {
        if (subcategoryId != null && subcategory.id != subcategoryId) continue;
        for (final procedure in subcategory.procedures) {
          if (!includePremium &&
              procedure.premiumVisibility ==
                  UfficioPremiumVisibility.premiumOnly) {
            continue;
          }
          if (channel != null &&
              channel.isNotEmpty &&
              !procedure.channels.any(
                (item) => _normalize(item).contains(_normalize(channel)),
              )) {
            continue;
          }
          final score = _scoreProcedure(
            procedure: procedure,
            category: category,
            subcategory: subcategory,
            normalizedQuery: normalizedQuery,
            expandedTokens: expandedTokens,
          );
          if (score <= 0) continue;
          results.add(
            CatalogSearchResult(
              categoryId: category.id,
              categoryTitle: category.title,
              subcategoryId: subcategory.id,
              subcategoryTitle: subcategory.title,
              procedureId: procedure.slug,
              procedureTitle: procedure.title,
              reason: _matchReason(
                procedure: procedure,
                category: category,
                subcategory: subcategory,
                normalizedQuery: normalizedQuery,
              ),
              score: score,
              premiumVisibility: procedure.premiumVisibility,
              locationLabel: location.city.trim().isNotEmpty
                  ? location.city.trim()
                  : (location.region.trim().isNotEmpty
                        ? location.region.trim()
                        : 'National/default'),
            ),
          );
        }
      }
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(20).toList();
  }

  Future<ProblemIntakeResult> startFromProblem({
    required String query,
    required String languageCode,
    CatalogLocationSelection location = const CatalogLocationSelection(),
    List<String> statusTags = const <String>[],
  }) async {
    final results = await searchCatalog(
      query: query,
      languageCode: languageCode,
      location: location,
    );
    final clarifying = <String>[
      if (location.city.trim().isEmpty) 'Which city should I use?',
      if (_mentionsBilling(query) && !_mentionsProvider(query))
        'Which provider is involved?',
      if (_mentionsDeadline(query)) 'What is the date?',
    ].take(3).toList();
    final top = results.take(3).toList();
    final snapshot = SituationScanRecord(
      id: const Uuid().v4(),
      city: location.city,
      region: location.region,
      statusTags: statusTags,
      problemTags: _expandedTokens(_normalize(query)).take(8).toList(),
      urgency: {
        'alreadyLate': _normalize(query).contains('late'),
        'receivedRejection': _normalize(query).contains('reject'),
        'paymentRisk': _mentionsBilling(query),
      },
      matchedProcedureIds: top.map((item) => item.procedureId).toList(),
      recommendedDocuments: top
          .expand((item) => [item.procedureTitle, item.reason])
          .toSet()
          .toList(),
      recommendedDeadlines: top.map((item) => item.reason).toList(),
      recommendedCostItems: top.map((item) => item.procedureTitle).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return ProblemIntakeResult(
      normalizedQuery: _normalize(query),
      clarifyingQuestions: clarifying,
      results: results,
      snapshot: snapshot,
    );
  }

  Future<SituationScanRecord> scanSituation({
    required String languageCode,
    required CatalogLocationSelection location,
    required List<String> statusTags,
    required List<String> adminNeeds,
    required Map<String, dynamic> urgency,
  }) async {
    final combinedQuery = [
      ...statusTags,
      ...adminNeeds,
      if (urgency['receivedRejection'] == true) 'rejected',
      if (urgency['paymentRisk'] == true) 'high bill',
      if (urgency['serviceInterruptionRisk'] == true) 'service interruption',
    ].join(' ');
    final results = await searchCatalog(
      query: combinedQuery,
      languageCode: languageCode,
      location: location,
    );
    final procedures = await proceduresBySlugs(
      languageCode: languageCode,
      procedureSlugs: results.take(5).map((item) => item.procedureId).toList(),
      location: location,
    );
    return SituationScanRecord(
      id: const Uuid().v4(),
      city: location.city,
      region: location.region,
      statusTags: statusTags,
      problemTags: adminNeeds,
      urgency: urgency,
      matchedProcedureIds: procedures.map((item) => item.slug).toList(),
      recommendedDocuments: procedures
          .expand((item) => item.documentsRequired)
          .toSet()
          .toList(),
      recommendedDeadlines: procedures
          .expand((item) => item.timelines)
          .toSet()
          .toList(),
      recommendedCostItems: procedures
          .expand((item) => item.costs)
          .toSet()
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<List<ConnectedProcedureRecord>> proceduresBySlugs({
    required String languageCode,
    required List<String> procedureSlugs,
    CatalogLocationSelection location = const CatalogLocationSelection(),
  }) async {
    final categories = await loadConnectedCatalog(
      languageCode: languageCode,
      location: location,
    );
    final matches = <ConnectedProcedureRecord>[];
    final wanted = procedureSlugs.toSet();
    for (final category in categories) {
      for (final subcategory in category.subcategories) {
        for (final procedure in subcategory.procedures) {
          if (wanted.contains(procedure.slug)) {
            matches.add(procedure);
          }
        }
      }
    }
    return matches;
  }

  Future<List<ProviderRecord>> providers() async {
    final providers = await _publicCatalogRepository.listServiceProviders();
    return providers
        .map(
          (item) => ProviderRecord(
            id: item.id,
            name: item.name,
            category: item.category,
            officialWebsite: item.websiteUrl ?? '',
            supportUrl: item.customerAreaUrl ?? '',
            complaintUrl: item.complaintPageUrl ?? '',
            cancellationUrl: item.cancellationPageUrl ?? '',
            pec: _providerContactValue(item, 'pec'),
            email: _providerContactValue(item, 'email'),
            phone: _providerContactValue(item, 'phone'),
            notes: item.warnings['en'] ?? '',
            lastVerifiedAt: item.lastVerifiedAt,
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<OfferSuggestion>> compareTelecom({
    required String serviceType,
    required String currentProvider,
    required double monthlyBudget,
    required String speedNeed,
  }) async {
    final all = await providers();
    final telecom = all.where((item) => item.category == 'telecom').toList();
    return telecom.map((provider) {
      var score = 20;
      final reasons = <String>[];
      final warnings = <String>[
        'Price must be checked on the official provider page.',
      ];
      if (provider.name.toLowerCase() != currentProvider.toLowerCase()) {
        score += 12;
        reasons.add('Different provider from your current one.');
      }
      if (serviceType.contains('home')) {
        reasons.add('Check the official coverage page before switching.');
      }
      if (monthlyBudget > 0) {
        reasons.add('Use your budget to shortlist official offer pages.');
      }
      if (speedNeed.trim().isNotEmpty) {
        reasons.add('Compare upload/download speed and lock-in terms.');
      }
      return OfferSuggestion(
        providerId: provider.id,
        providerName: provider.name,
        suggestionType: provider.officialWebsite.isEmpty
            ? 'not_enough_data'
            : 'check_offer',
        score: score,
        reasons: reasons,
        warnings: warnings,
        officialLinks: [
          if (provider.officialWebsite.isNotEmpty) provider.officialWebsite,
          if (provider.cancellationUrl.isNotEmpty) provider.cancellationUrl,
          if (provider.complaintUrl.isNotEmpty) provider.complaintUrl,
        ],
        requiredUserChecks: const [
          'Check coverage on the official page.',
          'Check activation, modem, and cancellation costs.',
          'Check complaint and conciliation channels before signing.',
        ],
        lastVerifiedAt: provider.lastVerifiedAt,
      );
    }).toList()..sort((a, b) => b.score.compareTo(a.score));
  }

  Future<List<OfferSuggestion>> compareUtilities({
    required String serviceType,
    required double currentMonthlyCost,
    required String preference,
  }) async {
    final all = await providers();
    final utility = all
        .where(
          (item) =>
              item.category == 'electricity' ||
              item.category == 'gas' ||
              item.category == 'dualEnergy',
        )
        .toList();
    return utility
        .map(
          (provider) => OfferSuggestion(
            providerId: provider.id,
            providerName: provider.name,
            suggestionType: 'official_tool',
            score: 30 + (currentMonthlyCost > 120 ? 10 : 0),
            reasons: [
              'Use Portale Offerte as the main comparison reference.',
              if (preference.trim().isNotEmpty)
                'Filter official comparisons by your contract preference.',
            ],
            warnings: const [
              'This app does not claim to show every real-time offer.',
              'Price must be checked on the official provider page.',
            ],
            officialLinks: [
              'https://www.ilportaleofferte.it/portaleOfferte/',
              if (provider.officialWebsite.isNotEmpty) provider.officialWebsite,
              if (provider.complaintUrl.isNotEmpty) provider.complaintUrl,
            ],
            requiredUserChecks: const [
              'Check fixed vs variable conditions on Portale Offerte.',
              'Check complaint and refund channels before switching.',
              'Verify all contract terms on the provider page.',
            ],
            lastVerifiedAt: provider.lastVerifiedAt,
          ),
        )
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }

  ConnectedProcedureRecord _toConnectedProcedure({
    required UfficioCategory category,
    required UfficioSubcategory subcategory,
    required UfficioProcedure procedure,
    required String languageCode,
    required CatalogLocationSelection location,
  }) {
    final steps = _sectionItems(procedure, languageCode, const ['steps']);
    final whenYouNeedIt = _sectionItems(procedure, languageCode, const [
      'why',
      'need',
      'eligibility',
      'who_needs',
    ]);
    final preparationChecklist = _sectionItems(procedure, languageCode, const [
      'checklist',
      'before',
      'prepare',
    ]);
    final documents = _sectionItems(procedure, languageCode, const [
      'document',
      'documents',
      'required_document',
      'documenti',
    ]);
    final costs = _sectionItems(procedure, languageCode, const [
      'cost',
      'costs',
      'fees',
    ]);
    final timelines = _sectionItems(procedure, languageCode, const [
      'timing',
      'timeline',
      'deadline',
    ]);
    final channels = _sectionItems(procedure, languageCode, const [
      'channel',
      'online',
      'pec',
      'email',
      'mail',
      'phone',
    ]);
    final warnings = _sectionTexts(procedure, languageCode, const [
      'warning',
      'warnings',
    ]);
    final officialLinks = procedure.officialLinks.isNotEmpty
        ? procedure.officialLinks
        : category.officialLinks;
    final officialContacts = procedure.contacts.isNotEmpty
        ? procedure.contacts
        : category.contacts;
    return ConnectedProcedureRecord(
      categoryId: category.id,
      subcategoryId: subcategory.id,
      id: procedure.id,
      slug: procedure.id,
      title: ufficioLocalizedValue(
        procedure.title,
        languageCode,
        fallback: procedure.id,
      ),
      summary: ufficioLocalizedValue(procedure.shortDescription, languageCode),
      description: _procedureDescription(procedure, languageCode),
      steps: steps,
      whenYouNeedIt: whenYouNeedIt,
      preparationChecklist: preparationChecklist,
      documentsRequired: documents,
      costs: costs,
      timelines: timelines,
      channels: channels,
      warnings: warnings.isNotEmpty
          ? warnings
          : _splitLines(
              ufficioLocalizedValue(procedure.warnings, languageCode),
            ),
      officialLinks: officialLinks,
      officialContacts: officialContacts,
      relatedProcedureIds: procedure.tags
          .where((item) => item.startsWith('related:'))
          .map((item) => item.replaceFirst('related:', ''))
          .toList(),
      tags: procedure.tags,
      premiumVisibility: _premiumForProcedure(procedure),
      requiredPlan:
          _premiumForProcedure(procedure) == UfficioPremiumVisibility.free
          ? null
          : 'premium',
      localVariationNote: location.city.trim().isEmpty
          ? null
          : 'Local details may vary. Check the official office link before sending documents.',
    );
  }

  int _scoreProcedure({
    required ConnectedProcedureRecord procedure,
    required ConnectedCategoryRecord category,
    required ConnectedSubcategoryRecord subcategory,
    required String normalizedQuery,
    required List<String> expandedTokens,
  }) {
    final haystack = _normalize(
      [
        procedure.title,
        procedure.summary,
        procedure.description,
        category.title,
        subcategory.title,
        ...procedure.tags,
        ...procedure.steps,
        ...procedure.documentsRequired,
        ...procedure.channels,
        ...procedure.warnings,
        ...procedure.officialContacts.map((item) => item.value),
        ...procedure.officialContacts.map(
          (item) => ufficioLocalizedValue(item.label, 'en'),
        ),
      ].join(' '),
    );
    var score = 0;
    if (_normalize(procedure.title) == normalizedQuery) score += 120;
    if (_normalize(procedure.title).contains(normalizedQuery)) score += 80;
    if (_normalize(subcategory.title).contains(normalizedQuery)) score += 35;
    if (_normalize(category.title).contains(normalizedQuery)) score += 20;
    if (haystack.contains(normalizedQuery)) score += 25;
    for (final token in expandedTokens) {
      if (token.isEmpty) continue;
      if (_normalize(procedure.title).contains(token)) {
        score += 22;
      } else if (haystack.contains(token)) {
        score += 10;
      }
    }
    return score;
  }

  String _matchReason({
    required ConnectedProcedureRecord procedure,
    required ConnectedCategoryRecord category,
    required ConnectedSubcategoryRecord subcategory,
    required String normalizedQuery,
  }) {
    if (_normalize(procedure.title) == normalizedQuery) {
      return 'Exact procedure title match.';
    }
    if (_normalize(procedure.title).contains(normalizedQuery)) {
      return 'Matched the procedure title.';
    }
    if (procedure.documentsRequired.any(
      (item) => _normalize(item).contains(normalizedQuery),
    )) {
      return 'Matched a required document.';
    }
    if (procedure.officialContacts.any(
      (item) =>
          _normalize(item.value).contains(normalizedQuery) ||
          _normalize(
            ufficioLocalizedValue(item.label, 'en'),
          ).contains(normalizedQuery),
    )) {
      return 'Matched an office or contact.';
    }
    if (_normalize(subcategory.title).contains(normalizedQuery)) {
      return 'Matched the subcategory.';
    }
    return 'Matched the category and procedure text.';
  }

  List<String> _sectionItems(
    UfficioProcedure procedure,
    String languageCode,
    List<String> keyHints,
  ) {
    final items = <String>[];
    for (final section in procedure.sections) {
      final sectionKey = '${section.type} ${section.key}'.toLowerCase();
      if (!keyHints.any((hint) => sectionKey.contains(hint))) continue;
      items.addAll(_localizedSectionItems(section, languageCode));
      items.addAll(_localizedSectionBodyLines(section, languageCode));
    }
    return _dedupeLines(items);
  }

  List<String> _sectionTexts(
    UfficioProcedure procedure,
    String languageCode,
    List<String> keyHints,
  ) {
    final items = <String>[];
    for (final section in procedure.sections) {
      final sectionKey = '${section.type} ${section.key}'.toLowerCase();
      if (!keyHints.any((hint) => sectionKey.contains(hint))) continue;
      items.addAll(_localizedSectionBodyLines(section, languageCode));
      items.addAll(_localizedSectionItems(section, languageCode));
    }
    return _dedupeLines(items);
  }

  String _procedureDescription(
    UfficioProcedure procedure,
    String languageCode,
  ) {
    final intro = procedure.sections.firstWhere(
      (section) =>
          section.type == 'text' ||
          section.key.contains('what') ||
          section.key.contains('intro'),
      orElse: () =>
          const UfficioContentSection(type: 'text', key: '', title: {}),
    );
    final body = ufficioLocalizedValue(intro.body, languageCode);
    if (body.trim().isNotEmpty) return body;
    return ufficioLocalizedValue(procedure.shortDescription, languageCode);
  }

  UfficioPremiumVisibility _premiumForCategory(UfficioCategory category) {
    if (category.isPremiumOnly) return UfficioPremiumVisibility.premiumOnly;
    return UfficioPremiumVisibility.free;
  }

  UfficioPremiumVisibility _premiumForSubcategory(
    UfficioSubcategory subcategory,
  ) {
    if (subcategory.isPremiumOnly) return UfficioPremiumVisibility.premiumOnly;
    return UfficioPremiumVisibility.free;
  }

  UfficioPremiumVisibility _premiumForProcedure(UfficioProcedure procedure) {
    if (procedure.isPremiumOnly) return UfficioPremiumVisibility.premiumOnly;
    return UfficioPremiumVisibility.free;
  }

  String _normalize(String value) => value.toLowerCase().trim();

  List<String> _expandedTokens(String normalizedQuery) {
    final tokens = normalizedQuery
        .split(RegExp(r'[^a-z0-9àèéìòù_]+'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
    final expanded = <String>{...tokens, normalizedQuery};
    for (final entry in _synonyms.entries) {
      if (normalizedQuery.contains(entry.key)) {
        expanded.addAll(entry.value.map(_normalize));
      }
      if (entry.value.any(
        (item) => normalizedQuery.contains(_normalize(item)),
      )) {
        expanded.add(entry.key);
      }
    }
    return expanded.toList();
  }

  List<String> _splitLines(String value) => value
      .split(RegExp(r'[\n\r]+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  List<String> _localizedSectionItems(
    UfficioContentSection section,
    String languageCode,
  ) {
    final primary = section.items[languageCode] ?? const <String>[];
    if (primary.isNotEmpty) {
      return _dedupeLines(primary);
    }
    final italian = section.items['it'] ?? const <String>[];
    if (italian.isNotEmpty) {
      return _dedupeLines(italian);
    }
    final english = section.items['en'] ?? const <String>[];
    return _dedupeLines(english);
  }

  List<String> _localizedSectionBodyLines(
    UfficioContentSection section,
    String languageCode,
  ) {
    final localizedBody = ufficioLocalizedValue(section.body, languageCode);
    if (localizedBody.trim().isNotEmpty) {
      return _splitLines(localizedBody);
    }
    final italian = section.body['it'] ?? '';
    if (italian.trim().isNotEmpty) {
      return _splitLines(italian);
    }
    final english = section.body['en'] ?? '';
    return _splitLines(english);
  }

  List<String> _dedupeLines(List<String> raw) {
    final seen = <String>{};
    final result = <String>[];
    for (final item in raw) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) continue;
      final normalized = _normalize(trimmed);
      if (seen.add(normalized)) {
        result.add(trimmed);
      }
    }
    return result;
  }

  String _providerContactValue(ServiceProvider provider, String type) {
    for (final option in provider.contactOptions) {
      if (option.contactType == type) {
        return option.value ?? '';
      }
    }
    return '';
  }

  bool _mentionsBilling(String value) {
    final normalized = _normalize(value);
    return normalized.contains('bill') ||
        normalized.contains('bolletta') ||
        normalized.contains('electricity') ||
        normalized.contains('gas');
  }

  bool _mentionsProvider(String value) {
    final normalized = _normalize(value);
    return const [
      'tim',
      'vodafone',
      'windtre',
      'fastweb',
      'iliad',
      'enel',
      'edison',
      'a2a',
      'iren',
    ].any(normalized.contains);
  }

  bool _mentionsDeadline(String value) {
    final normalized = _normalize(value);
    return normalized.contains('deadline') ||
        normalized.contains('scadenza') ||
        normalized.contains('expire') ||
        normalized.contains('renew');
  }
}

class ConnectedUserDataRepository {
  ConnectedUserDataRepository({
    required SharedPreferences prefs,
    SupabaseClient? client,
  }) : _prefs = prefs,
       _client = client;

  final SharedPreferences _prefs;
  final SupabaseClient? _client;

  static const _scanKey = 'connected_situation_scans_v1';
  static const _checklistKey = 'connected_checklist_items_v1';
  static const _deadlineKey = 'connected_deadlines_v1';
  static const _savedProcedureKey = 'connected_saved_procedures_v1';
  static const _costKey = 'connected_cost_items_v2';

  String? get _userId => _client?.auth.currentUser?.id;
  bool get _remoteEnabled => _client != null && _userId != null;

  Future<List<SituationScanRecord>> listScans() async {
    if (_remoteEnabled) {
      try {
        final rows = await _client!
            .from('ufficio_situation_scans')
            .select()
            .order('updated_at', ascending: false);
        return rows.map((item) => _scanFromSupabase(item)).toList();
      } catch (_) {}
    }
    return _readLocalList(_scanKey, SituationScanRecord.fromJson);
  }

  Future<void> saveScan(SituationScanRecord item) async {
    final next = await listScans();
    next.removeWhere((existing) => existing.id == item.id);
    next.insert(0, item);
    await _writeLocalList(
      _scanKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!
            .from('ufficio_situation_scans')
            .upsert(_scanToSupabase(item));
      } catch (_) {}
    }
  }

  Future<List<ChecklistItemRecord>> listChecklistItems() async {
    if (_remoteEnabled) {
      try {
        final rows = await _client!
            .from('ufficio_checklist_items')
            .select()
            .order('updated_at', ascending: false);
        return rows.map((item) => _checklistFromSupabase(item)).toList();
      } catch (_) {}
    }
    return _readLocalList(_checklistKey, ChecklistItemRecord.fromJson);
  }

  Future<void> saveChecklistItem(ChecklistItemRecord item) async {
    final next = await listChecklistItems();
    next.removeWhere((existing) => existing.id == item.id);
    next.insert(0, item);
    await _writeLocalList(
      _checklistKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!
            .from('ufficio_checklist_items')
            .upsert(_checklistToSupabase(item));
      } catch (_) {}
    }
  }

  Future<void> deleteChecklistItem(String id) async {
    final next = await listChecklistItems()
      ..removeWhere((item) => item.id == id);
    await _writeLocalList(
      _checklistKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!.from('ufficio_checklist_items').delete().eq('id', id);
      } catch (_) {}
    }
  }

  Future<List<DeadlineRecord>> listDeadlines() async {
    if (_remoteEnabled) {
      try {
        final rows = await _client!
            .from('ufficio_deadlines')
            .select()
            .order('due_date', ascending: true);
        return rows.map((item) => _deadlineFromSupabase(item)).toList();
      } catch (_) {}
    }
    return _readLocalList(_deadlineKey, DeadlineRecord.fromJson);
  }

  Future<void> saveDeadline(DeadlineRecord item) async {
    final next = await listDeadlines();
    next.removeWhere((existing) => existing.id == item.id);
    next.add(item);
    await _writeLocalList(
      _deadlineKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!
            .from('ufficio_deadlines')
            .upsert(_deadlineToSupabase(item));
      } catch (_) {}
    }
  }

  Future<void> deleteDeadline(String id) async {
    final next = await listDeadlines()
      ..removeWhere((item) => item.id == id);
    await _writeLocalList(
      _deadlineKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!.from('ufficio_deadlines').delete().eq('id', id);
      } catch (_) {}
    }
  }

  Future<List<SavedProcedureRecord>> listSavedProcedures() async {
    if (_remoteEnabled) {
      try {
        final rows = await _client!
            .from('ufficio_saved_procedures')
            .select()
            .order('created_at', ascending: false);
        return rows.map((item) => _savedProcedureFromSupabase(item)).toList();
      } catch (_) {}
    }
    return _readLocalList(_savedProcedureKey, SavedProcedureRecord.fromJson);
  }

  Future<void> saveProcedure(SavedProcedureRecord item) async {
    final next = await listSavedProcedures();
    next.removeWhere(
      (existing) =>
          existing.categorySlug == item.categorySlug &&
          existing.procedureSlug == item.procedureSlug,
    );
    next.insert(0, item);
    await _writeLocalList(
      _savedProcedureKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!
            .from('ufficio_saved_procedures')
            .upsert(_savedProcedureToSupabase(item));
      } catch (_) {}
    }
  }

  Future<List<ConnectedCostItemRecord>> listCostItems() async {
    if (_remoteEnabled) {
      try {
        final rows = await _client!
            .from('ufficio_cost_items')
            .select()
            .order('updated_at', ascending: false);
        return rows.map((item) => _costItemFromSupabase(item)).toList();
      } catch (_) {}
    }
    return _readLocalList(_costKey, ConnectedCostItemRecord.fromJson);
  }

  Future<void> saveCostItem(ConnectedCostItemRecord item) async {
    final next = await listCostItems();
    next.removeWhere((existing) => existing.id == item.id);
    next.insert(0, item);
    await _writeLocalList(
      _costKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!
            .from('ufficio_cost_items')
            .upsert(_costItemToSupabase(item));
      } catch (_) {}
    }
  }

  Future<void> deleteCostItem(String id) async {
    final next = await listCostItems()
      ..removeWhere((item) => item.id == id);
    await _writeLocalList(
      _costKey,
      next.map((entry) => entry.toJson()).toList(),
    );
    if (_remoteEnabled) {
      try {
        await _client!.from('ufficio_cost_items').delete().eq('id', id);
      } catch (_) {}
    }
  }

  Future<List<T>> _readLocalList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return <T>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <T>[];
    return decoded
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> _writeLocalList(String key, List<Map<String, dynamic>> value) =>
      _prefs.setString(key, jsonEncode(value));

  Map<String, dynamic> _scanToSupabase(SituationScanRecord item) => {
    'id': item.id,
    'user_id': _userId,
    'city': item.city,
    'region': item.region,
    'status_tags': item.statusTags,
    'problem_tags': item.problemTags,
    'urgency': item.urgency,
    'matched_procedures': item.matchedProcedureIds,
    'recommended_documents': item.recommendedDocuments,
    'recommended_deadlines': item.recommendedDeadlines,
    'recommended_cost_items': item.recommendedCostItems,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };

  SituationScanRecord _scanFromSupabase(
    Map<String, dynamic> json,
  ) => SituationScanRecord(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String?,
    city: json['city'] as String? ?? '',
    region: json['region'] as String? ?? '',
    statusTags: ((json['status_tags'] as List?) ?? const []).cast<String>(),
    problemTags: ((json['problem_tags'] as List?) ?? const []).cast<String>(),
    urgency: Map<String, dynamic>.from(
      (json['urgency'] as Map?) ?? const <String, dynamic>{},
    ),
    matchedProcedureIds: ((json['matched_procedures'] as List?) ?? const [])
        .cast<String>(),
    recommendedDocuments: ((json['recommended_documents'] as List?) ?? const [])
        .cast<String>(),
    recommendedDeadlines: ((json['recommended_deadlines'] as List?) ?? const [])
        .cast<String>(),
    recommendedCostItems:
        ((json['recommended_cost_items'] as List?) ?? const []).cast<String>(),
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.now(),
  );

  Map<String, dynamic> _checklistToSupabase(ChecklistItemRecord item) => {
    'id': item.id,
    'user_id': _userId,
    'source_type': item.sourceType,
    'source_procedure_id': item.sourceProcedureId,
    'title': item.title,
    'description': item.description,
    'status': item.status.name,
    'due_date': item.dueDate?.toIso8601String(),
    'priority': item.priority,
    'category_slug': item.categorySlug,
    'procedure_slug': item.procedureSlug,
    'document_required': item.documentRequired,
    'official_link': item.officialLink,
    'note': item.note,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };

  ChecklistItemRecord _checklistFromSupabase(Map<String, dynamic> json) =>
      ChecklistItemRecord(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        sourceType: json['source_type'] as String? ?? 'manual',
        sourceProcedureId: json['source_procedure_id'] as String?,
        status: ConnectedChecklistStatus.values.firstWhere(
          (item) => item.name == json['status'],
          orElse: () => ConnectedChecklistStatus.todo,
        ),
        dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
        priority: (json['priority'] as num?)?.toInt() ?? 1,
        categorySlug: json['category_slug'] as String?,
        procedureSlug: json['procedure_slug'] as String?,
        documentRequired: json['document_required'] as String?,
        officialLink: json['official_link'] as String?,
        note: json['note'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> _deadlineToSupabase(DeadlineRecord item) => {
    'id': item.id,
    'user_id': _userId,
    'title': item.title,
    'description': item.description,
    'due_date': item.dueDate.toIso8601String(),
    'source_type': item.sourceType,
    'source_procedure_id': item.sourceProcedureId,
    'category_slug': item.categorySlug,
    'procedure_slug': item.procedureSlug,
    'status': item.status.name,
    'reminder_enabled': item.reminderEnabled,
    'reminder_offset_days': item.reminderOffsetDays,
    'official_link': item.officialLink,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };

  DeadlineRecord _deadlineFromSupabase(
    Map<String, dynamic> json,
  ) => DeadlineRecord(
    id: json['id'] as String? ?? '',
    userId: json['user_id'] as String?,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    dueDate:
        DateTime.tryParse(json['due_date'] as String? ?? '') ?? DateTime.now(),
    sourceType: json['source_type'] as String? ?? 'manual',
    sourceProcedureId: json['source_procedure_id'] as String?,
    categorySlug: json['category_slug'] as String?,
    procedureSlug: json['procedure_slug'] as String?,
    status: ConnectedDeadlineStatus.values.firstWhere(
      (item) => item.name == json['status'],
      orElse: () => ConnectedDeadlineStatus.upcoming,
    ),
    reminderEnabled: json['reminder_enabled'] as bool? ?? true,
    reminderOffsetDays: (json['reminder_offset_days'] as num?)?.toInt() ?? 7,
    officialLink: json['official_link'] as String?,
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.now(),
  );

  Map<String, dynamic> _savedProcedureToSupabase(SavedProcedureRecord item) => {
    'id': item.id,
    'user_id': _userId,
    'category_slug': item.categorySlug,
    'subcategory_slug': item.subcategorySlug,
    'procedure_slug': item.procedureSlug,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.createdAt.toIso8601String(),
  };

  SavedProcedureRecord _savedProcedureFromSupabase(Map<String, dynamic> json) =>
      SavedProcedureRecord(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String?,
        categorySlug: json['category_slug'] as String? ?? '',
        subcategorySlug: json['subcategory_slug'] as String? ?? '',
        procedureSlug: json['procedure_slug'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> _costItemToSupabase(ConnectedCostItemRecord item) => {
    'id': item.id,
    'user_id': _userId,
    'title': item.title,
    'amount_min': item.amountMin,
    'amount_max': item.amountMax,
    'currency': 'EUR',
    'frequency': item.frequency,
    'status': item.status.name,
    'source_type': item.sourceType,
    'source_procedure_id': item.sourceProcedureId,
    'due_date': item.dueDate?.toIso8601String(),
    'category_slug': item.categorySlug,
    'provider_name': item.providerName,
    'official_link': item.officialLink,
    'notes': item.notes,
    'created_at': item.createdAt.toIso8601String(),
    'updated_at': item.updatedAt.toIso8601String(),
  };

  ConnectedCostItemRecord _costItemFromSupabase(Map<String, dynamic> json) =>
      ConnectedCostItemRecord(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String?,
        title: json['title'] as String? ?? '',
        amountMin: (json['amount_min'] as num?)?.toDouble() ?? 0,
        amountMax: (json['amount_max'] as num?)?.toDouble() ?? 0,
        frequency: json['frequency'] as String? ?? 'unknown',
        status: ConnectedCostStatus.values.firstWhere(
          (item) => item.name == json['status'],
          orElse: () => ConnectedCostStatus.estimated,
        ),
        sourceType: json['source_type'] as String? ?? 'manual',
        sourceProcedureId: json['source_procedure_id'] as String?,
        dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
        categorySlug: json['category_slug'] as String?,
        providerName: json['provider_name'] as String?,
        officialLink: json['official_link'] as String?,
        notes: json['notes'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
