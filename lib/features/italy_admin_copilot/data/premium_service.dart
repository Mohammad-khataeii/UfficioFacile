import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_config.dart';
import '../../../app/supabase_bootstrap.dart';
import '../../admin_cms/domain/cms_models.dart';
import '../domain/premium_config.dart';
import '../domain/ufficio_catalog.dart';
import '../domain/ufficcio_entitlement.dart';
import 'local_analytics_service.dart';
import 'ufficcio_supabase_readiness.dart';

class LocalPremiumConfigRepository {
  LocalPremiumConfigRepository(this._prefs, {this.remoteLoader});

  static const storageKey = 'ufficiofacile_premium_config_v1';
  static const cachedPlansKey = 'ufficiofacile_plan_products_v1';
  static const cachedUnlocksKey = 'ufficiofacile_content_unlocks_v1';
  final SharedPreferences _prefs;
  final Future<Map<String, dynamic>> Function()? remoteLoader;

  Future<PremiumConfig> getConfig() async {
    var config = _defaultConfig;
    final raw = _prefs.getString(storageKey);
    try {
      if (raw != null && raw.isNotEmpty) {
        config = PremiumConfig.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
      }
    } catch (_) {}
    if (remoteLoader == null) {
      return config;
    }
    try {
      final remote = await remoteLoader!();
      config = config.copyWith(
        betaModeEnabled:
            _readBool(remote['betaModeEnabled']) ?? config.betaModeEnabled,
        paywallEnabled:
            _readBool(remote['paywallEnabled']) ?? config.paywallEnabled,
        showPremiumBadges:
            _readBool(remote['showPremiumBadges']) ?? config.showPremiumBadges,
        freePackLimit:
            _readInt(remote['freePackLimit']) ?? config.freePackLimit,
        freeSavedRequestsLimit:
            _readInt(remote['freeSavedRequestsLimit']) ??
            config.freeSavedRequestsLimit,
        freeRemindersLimit:
            _readInt(remote['freeRemindersLimit']) ?? config.freeRemindersLimit,
        freeDocumentsLimit:
            _readInt(remote['freeDocumentsLimit']) ?? config.freeDocumentsLimit,
        freeContactsLimit:
            _readInt(remote['freeContactsLimit']) ?? config.freeContactsLimit,
        freeCostItemsLimit:
            _readInt(remote['freeCostItemsLimit']) ?? config.freeCostItemsLimit,
        freeProofCasesLimit:
            _readInt(remote['freeProofCasesLimit']) ??
            config.freeProofCasesLimit,
        freeUtilityComparisonLimit:
            _readInt(remote['freeUtilityComparisonLimit']) ??
            config.freeUtilityComparisonLimit,
        freeBillAnalysisLimit:
            _readInt(remote['freeBillAnalysisLimit']) ??
            config.freeBillAnalysisLimit,
      );
    } catch (_) {}
    return config;
  }

  Future<PremiumConfig> saveConfig(PremiumConfig config) async {
    await _prefs.setString(storageKey, jsonEncode(config.toJson()));
    return config;
  }

  Future<List<Map<String, dynamic>>> getCachedPlanProducts() async {
    final raw = _prefs.getString(cachedPlansKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return ((jsonDecode(raw) as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCachedPlanProducts(List<Map<String, dynamic>> items) async {
    await _prefs.setString(cachedPlansKey, jsonEncode(items));
  }

  Future<List<Map<String, dynamic>>> getCachedContentUnlocks() async {
    final raw = _prefs.getString(cachedUnlocksKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return ((jsonDecode(raw) as List?) ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveCachedContentUnlocks(
    List<Map<String, dynamic>> items,
  ) async {
    await _prefs.setString(cachedUnlocksKey, jsonEncode(items));
  }
}

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  return null;
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

const PremiumConfig _defaultConfig = PremiumConfig(
  betaModeEnabled: false,
  paywallEnabled: true,
  showPremiumBadges: true,
  freePackLimit: 3,
  freeSavedRequestsLimit: 5,
  freeRemindersLimit: 5,
  freeDocumentsLimit: 5,
  freeContactsLimit: 5,
  freeCostItemsLimit: 5,
  freeHouseholdMembersLimit: 2,
  freeProofCasesLimit: 5,
  freeUtilityComparisonLimit: 3,
  freeBillAnalysisLimit: 3,
  premiumProcedureIds: [
    'ENERGY_SUPPLIER_COMPARISON',
    'HIGH_BILL_COMPLAINT',
    'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
    'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
    'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
    'INTERNET_PHONE_CANCELLATION',
    'TELECOM_WRONG_BILL_COMPLAINT',
    'SERVICE_NOT_WORKING_COMPLAINT',
    'MODEM_RETURN_OR_CHARGE_DISPUTE',
  ],
  lockedProcedureIds: [],
  proFeatureKeys: [
    FeatureKey.proofFolder,
    FeatureKey.householdContracts,
    FeatureKey.householdMembers,
    FeatureKey.exportFullPack,
    FeatureKey.bulkExport,
    FeatureKey.utilityComparison,
    FeatureKey.billAnalysis,
    FeatureKey.costDashboard,
    FeatureKey.canoneRaiAdvanced,
    FeatureKey.telecomAdvanced,
    FeatureKey.serviceIntelligenceAdvanced,
    FeatureKey.officialLinksAdvanced,
    FeatureKey.premiumGuides,
    FeatureKey.advancedScanner,
    FeatureKey.deadlineReminders,
    FeatureKey.bonusFinderAdvanced,
    FeatureKey.loanComparisonAdvanced,
    FeatureKey.privateConsultancy,
    FeatureKey.priorityProblemRequest,
  ],
  consultantFeatureKeys: [FeatureKey.consultantMode],
  trialDays: 7,
  allowLocalDebugPro: false,
);

class PlanProduct {
  const PlanProduct({
    required this.productKey,
    required this.planType,
    required this.billingInterval,
    required this.amountCents,
    required this.currency,
    required this.isActive,
    required this.sortOrder,
    required this.title,
    required this.description,
    required this.features,
    required this.limits,
    required this.providerMetadata,
  });

  final String productKey;
  final String planType;
  final String billingInterval;
  final int amountCents;
  final String currency;
  final bool isActive;
  final int sortOrder;
  final Map<String, dynamic> title;
  final Map<String, dynamic> description;
  final Map<String, dynamic> features;
  final Map<String, dynamic> limits;
  final Map<String, dynamic> providerMetadata;

  factory PlanProduct.fromJson(Map<String, dynamic> json) => PlanProduct(
    productKey: json['product_key'] as String? ?? '',
    planType: json['plan_type'] as String? ?? 'free',
    billingInterval: json['billing_interval'] as String? ?? 'none',
    amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'EUR',
    isActive: json['is_active'] as bool? ?? true,
    sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    title: _jsonMap(json['title']),
    description: _jsonMap(json['description']),
    features: _jsonMap(json['features']),
    limits: _jsonMap(json['limits']),
    providerMetadata: _jsonMap(json['provider_metadata']),
  );

  Map<String, dynamic> toJson() => {
    'product_key': productKey,
    'plan_type': planType,
    'billing_interval': billingInterval,
    'amount_cents': amountCents,
    'currency': currency,
    'is_active': isActive,
    'sort_order': sortOrder,
    'title': title,
    'description': description,
    'features': features,
    'limits': limits,
    'provider_metadata': providerMetadata,
  };
}

class UserContentUnlock {
  const UserContentUnlock({
    required this.userId,
    required this.categorySlug,
    required this.procedureSlug,
    required this.status,
    this.unlockType = 'single_purchase',
    this.productKey = 'subcategory_unlock',
    this.amountCents,
    this.currency = 'EUR',
    this.provider,
    this.expiresAt,
    this.revokedAt,
    this.metadata = const {},
  });

  final String userId;
  final String categorySlug;
  final String procedureSlug;
  final String status;
  final String unlockType;
  final String productKey;
  final int? amountCents;
  final String currency;
  final String? provider;
  final DateTime? expiresAt;
  final DateTime? revokedAt;
  final Map<String, dynamic> metadata;

  bool get isActive {
    if (status != 'active') return false;
    if (revokedAt != null) return false;
    if (expiresAt != null && expiresAt!.isBefore(DateTime.now())) return false;
    return true;
  }

  factory UserContentUnlock.fromJson(Map<String, dynamic> json) =>
      UserContentUnlock(
        userId: json['user_id'] as String? ?? '',
        categorySlug: json['category_slug'] as String? ?? '',
        procedureSlug: json['procedure_slug'] as String? ?? '',
        status: json['status'] as String? ?? 'active',
        unlockType: json['unlock_type'] as String? ?? 'single_purchase',
        productKey: json['product_key'] as String? ?? 'subcategory_unlock',
        amountCents: (json['amount_cents'] as num?)?.toInt(),
        currency: json['currency'] as String? ?? 'EUR',
        provider: json['provider'] as String?,
        expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
        revokedAt: DateTime.tryParse(json['revoked_at'] as String? ?? ''),
        metadata: _jsonMap(json['metadata']),
      );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'category_slug': categorySlug,
    'procedure_slug': procedureSlug,
    'status': status,
    'unlock_type': unlockType,
    'product_key': productKey,
    'amount_cents': amountCents,
    'currency': currency,
    'provider': provider,
    'expires_at': expiresAt?.toIso8601String(),
    'revoked_at': revokedAt?.toIso8601String(),
    'metadata': metadata,
  };
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

class UfficioPremiumEntitlementService {
  UfficioPremiumEntitlementService(
    this._repository,
    this._configRepository, {
    required this.analytics,
  });

  final UfficcioEntitlementRepository _repository;
  final LocalPremiumConfigRepository _configRepository;
  final LocalAnalyticsService analytics;
  static const _runtimeConfig = UfficcioFacileConfig.fromEnv;

  bool get _canUseLocalBypassConfig =>
      _runtimeConfig.isDevelopment && SupabaseBootstrap.client == null;

  Future<PremiumConfig> getConfig() => _configRepository.getConfig();

  Future<UfficcioEntitlement> getCurrentEntitlement() async {
    final config = await getConfig();
    final entitlement = await _repository.getEntitlement();
    final allowLocalDebugPro =
        config.allowLocalDebugPro && _canUseLocalBypassConfig;
    final resetLocalDebug =
        entitlement.localDebugProEnabled && !allowLocalDebugPro;
    final normalized = await resetMonthlyUsageIfNeeded(
      entitlement.copyWith(
        plan: resetLocalDebug && entitlement.plan == UfficioPlan.pro
            ? UfficioPlan.free
            : entitlement.plan,
        premiumAccess: resetLocalDebug ? false : entitlement.premiumAccess,
        betaModeEnabled: config.betaModeEnabled,
        paywallEnabled: config.paywallEnabled,
        freePackLimit: config.freePackLimit,
        problemRequestsLimit: 2,
        consultancyRequestsLimit: 2,
        savedRequestsLimit: config.freeSavedRequestsLimit,
        remindersLimit: config.freeRemindersLimit,
        documentsLimit: config.freeDocumentsLimit,
        contactsLimit: config.freeContactsLimit,
        costItemsLimit: config.freeCostItemsLimit,
        householdMembersLimit: config.freeHouseholdMembersLimit,
        proofCasesLimit: config.freeProofCasesLimit,
        utilityComparisonLimit: config.freeUtilityComparisonLimit,
        billAnalysisLimit: config.freeBillAnalysisLimit,
        enabledPremiumProcedureIds: config.premiumProcedureIds,
        lockedProcedureIds: config.lockedProcedureIds,
        localDebugProEnabled:
            allowLocalDebugPro && entitlement.localDebugProEnabled,
      ),
    );
    if (normalized != entitlement) {
      await _repository.saveEntitlement(normalized);
    }
    return normalized;
  }

  Future<UfficioPlan> getCurrentPlan() async =>
      (await getCurrentEntitlement()).plan;

  Future<List<PlanProduct>> getPlanProducts() async {
    final cached = (await _configRepository.getCachedPlanProducts())
        .map(PlanProduct.fromJson)
        .toList();
    final remote = await _loadRemotePlanProducts();
    if (remote.isNotEmpty) {
      await _configRepository.saveCachedPlanProducts(
        remote.map((item) => item.toJson()).toList(),
      );
      return remote;
    }
    return cached.isNotEmpty ? cached : _defaultPlanProducts;
  }

  Future<List<UserContentUnlock>> getContentUnlocks() async {
    final cached = (await _configRepository.getCachedContentUnlocks())
        .map(UserContentUnlock.fromJson)
        .toList();
    final remote = await _loadRemoteContentUnlocks();
    if (remote.isNotEmpty) {
      await _configRepository.saveCachedContentUnlocks(
        remote.map((item) => item.toJson()).toList(),
      );
      return remote;
    }
    return cached;
  }

  Future<String?> createCheckoutUrl({
    required String productKey,
    String? categorySlug,
    String? procedureSlug,
  }) async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return null;
    }
    try {
      final response = await client.functions.invoke(
        'create-checkout-session',
        body: <String, dynamic>{
          'product_key': productKey,
          if (categorySlug != null && categorySlug.isNotEmpty)
            'category_slug': categorySlug,
          if (procedureSlug != null && procedureSlug.isNotEmpty)
            'procedure_slug': procedureSlug,
        },
      );
      final data = response.data;
      if (data is Map &&
          data['url'] is String &&
          (data['url'] as String).isNotEmpty) {
        return data['url'] as String;
      }
      if (data is Map && data['checkout_url'] is String) {
        return data['checkout_url'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isPro() async => (await getCurrentEntitlement()).isProLike;
  Future<bool> isBetaMode() async => (await getConfig()).betaModeEnabled;

  Future<bool> isPremiumProcedure(String procedureId) async {
    final config = await getConfig();
    return config.premiumProcedureIds.contains(procedureId) ||
        config.lockedProcedureIds.contains(procedureId);
  }

  Future<ContentAccessResult> canAccessCmsProcedure(
    CmsProcedure procedure, {
    bool adminPreview = false,
  }) async {
    if (!procedure.isPremium) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.freeContent,
        message: 'This guide is available on the free plan.',
      );
    }

    final entitlement = await getCurrentEntitlement();
    if (adminPreview) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.adminPreview,
        message: 'Admin preview override is active.',
      );
    }
    if (entitlement.isProLike) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.premiumSubscription,
        message: 'Included with Premium.',
        alreadyUnlocked: true,
      );
    }

    final unlocks = await getContentUnlocks();
    final unlocked = unlocks.any(
      (item) =>
          item.categorySlug == procedure.categorySlug &&
          item.procedureSlug == procedure.slug &&
          item.isActive,
    );
    if (unlocked) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.singleUnlock,
        message: 'This guide was unlocked for your account.',
        alreadyUnlocked: true,
      );
    }

    return ContentAccessResult(
      allowed: false,
      reason: ContentAccessReason.locked,
      message:
          'Premium gives you full access to all guides, plus 2 problem requests and 2 private consultancies every month.',
      unlockOptions: const <UnlockOption>[UnlockOption.premium],
      requiresPremium: true,
    );
  }

  Future<ContentAccessResult> canAccessCatalogProcedure(
    UfficioProcedure procedure, {
    bool adminPreview = false,
  }) async {
    if (!procedure.isPremiumOnly) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.freeContent,
        message: 'This guide is available on the free plan.',
      );
    }

    final entitlement = await getCurrentEntitlement();
    if (adminPreview) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.adminPreview,
        message: 'Admin preview override is active.',
      );
    }
    if (entitlement.isProLike) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.premiumSubscription,
        message: 'Included with Premium.',
        alreadyUnlocked: true,
      );
    }

    final unlocks = await getContentUnlocks();
    final unlocked = unlocks.any(
      (item) =>
          item.categorySlug == procedure.categoryId &&
          item.procedureSlug == procedure.id &&
          item.isActive,
    );
    if (unlocked) {
      return const ContentAccessResult(
        allowed: true,
        reason: ContentAccessReason.singleUnlock,
        message: 'This guide was unlocked for your account.',
        alreadyUnlocked: true,
      );
    }

    return ContentAccessResult(
      allowed: false,
      reason: ContentAccessReason.locked,
      message:
          'Premium gives you full access to all guides, plus 2 problem requests and 2 private consultancies every month.',
      unlockOptions: const <UnlockOption>[UnlockOption.premium],
      requiresPremium: true,
    );
  }

  Future<EntitlementDecision> canAccessCategory(
    UfficioCategory category,
  ) async {
    if (category.isPremiumOnly) {
      return _allowedDecision(
        reason: 'Premium category shell.',
        isPremiumFeature: true,
      );
    }
    return canAccessCatalogPath(category: category);
  }

  Future<EntitlementDecision> canAccessSubcategory(
    UfficioSubcategory subcategory,
  ) async {
    return canAccessCatalogPath(subcategory: subcategory);
  }

  Future<EntitlementDecision> canAccessProcedure(
    UfficioProcedure procedure,
  ) async {
    return canAccessCatalogPath(procedure: procedure);
  }

  Future<EntitlementDecision> canAccessSection(
    UfficioContentSection section,
  ) async {
    return canAccessCatalogPath(section: section);
  }

  Future<EntitlementDecision> canAccessCatalogPath({
    UfficioCategory? category,
    UfficioSubcategory? subcategory,
    UfficioProcedure? procedure,
    UfficioContentSection? section,
  }) async {
    final isLocked =
        (category?.isPremiumOnly ?? false) ||
        (subcategory?.isPremiumOnly ?? false) ||
        (procedure?.isPremiumOnly ?? false) ||
        (section?.isPremiumOnly ?? false);
    if (isLocked) {
      return _catalogLockedDecision();
    }
    final hasPremiumContent =
        (category?.hasPremiumContent ?? false) ||
        (subcategory?.hasPremiumContent ?? false) ||
        (procedure?.hasPremiumContent ?? false);
    if (section != null) {
      return _allowedDecision(reason: 'Free section');
    }
    if (procedure != null) {
      return _allowedDecision(
        reason: hasPremiumContent
            ? 'Free guide with some Premium content inside.'
            : 'Free guide.',
        isPremiumFeature: hasPremiumContent,
      );
    }
    if (subcategory != null) {
      return _allowedDecision(
        reason: hasPremiumContent
            ? 'Free subcategory with some Premium content inside.'
            : 'Free subcategory.',
        isPremiumFeature: hasPremiumContent,
      );
    }
    if (category != null) {
      return _allowedDecision(
        reason: hasPremiumContent
            ? 'This category contains Premium content.'
            : 'Free category.',
        isPremiumFeature: hasPremiumContent,
      );
    }
    return _allowedDecision(reason: 'Free content');
  }

  Future<EntitlementDecision> canUseProcedure(String procedureId) async {
    final config = await getConfig();
    final entitlement = await getCurrentEntitlement();
    final isPremiumProcedure = config.premiumProcedureIds.contains(procedureId);
    if (!isPremiumProcedure) {
      return _allowedDecision(reason: 'Free procedure');
    }
    if (entitlement.isProLike) {
      return _allowedDecision(
        reason: 'Paid access active',
        isPremiumFeature: true,
      );
    }
    if (_canUseLocalBypassConfig && config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Beta access active',
        isPremiumFeature: true,
        blockedByBeta: true,
      );
    }
    if (_canUseLocalBypassConfig && !config.paywallEnabled) {
      return _allowedDecision(
        reason: 'Paywall disabled',
        isPremiumFeature: true,
      );
    }
    return _blockedDecision(
      reason: 'This procedure is included in Plus or Premium.',
      feature: FeatureKey.serviceIntelligenceAdvanced,
    );
  }

  Future<EntitlementDecision> canGeneratePack([String? procedureId]) async {
    final entitlement = await getCurrentEntitlement();
    final config = await getConfig();
    if (procedureId != null) {
      final procedureDecision = await canUseProcedure(procedureId);
      if (!procedureDecision.allowed) return procedureDecision;
    }
    if (entitlement.isProLike) {
      return _allowedDecision(reason: 'Paid generation enabled');
    }
    if (_canUseLocalBypassConfig && config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Beta access active',
        blockedByBeta: true,
        isPremiumFeature: true,
      );
    }
    if (_canUseLocalBypassConfig && !config.paywallEnabled) {
      return _allowedDecision(reason: 'Paywall disabled');
    }
    final used = entitlement.generatedPacksUsedThisMonth;
    final limit = entitlement.freePackLimit;
    if (used < limit) {
      return _allowedDecision(
        reason: 'Free usage remaining',
        used: used,
        limit: limit,
      );
    }
    await analytics.trackStatusUpdated('free_limit_reached');
    return _blockedDecision(
      reason: 'Free pack limit reached.',
      feature: FeatureKey.generatePack,
      used: used,
      limit: limit,
    );
  }

  Future<EntitlementDecision> canSaveRequest() =>
      _checkCountLimit(FeatureKey.saveRequest);
  Future<EntitlementDecision> canCreateReminder() =>
      _checkCountLimit(FeatureKey.createReminder);
  Future<EntitlementDecision> canAddDocument() =>
      _checkCountLimit(FeatureKey.documentVault);
  Future<EntitlementDecision> canAddContact() =>
      _checkCountLimit(FeatureKey.officialLinksAdvanced);
  Future<EntitlementDecision> canAddHouseholdMember() =>
      _checkCountLimit(FeatureKey.householdMembers);
  Future<EntitlementDecision> canCreateProofCase() =>
      _checkCountLimit(FeatureKey.proofFolder);
  Future<EntitlementDecision> canRunUtilityComparison() =>
      _checkCountLimit(FeatureKey.utilityComparison);
  Future<EntitlementDecision> canRunBillAnalysis() =>
      _checkCountLimit(FeatureKey.billAnalysis);
  Future<EntitlementDecision> canExportFullPack() =>
      canUseFeature(FeatureKey.exportFullPack);

  Future<EntitlementDecision> canUseFeature(FeatureKey feature) async {
    final config = await getConfig();
    final entitlement = await getCurrentEntitlement();
    final isProFeature =
        config.proFeatureKeys.contains(feature) ||
        config.consultantFeatureKeys.contains(feature);
    if (!isProFeature) {
      return _allowedDecision(reason: 'Feature available on Free');
    }
    if (entitlement.isProLike) {
      return _allowedDecision(
        reason: 'Paid access active',
        isPremiumFeature: true,
      );
    }
    if (_canUseLocalBypassConfig && config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Available during beta',
        isPremiumFeature: true,
        blockedByBeta: true,
      );
    }
    if (_canUseLocalBypassConfig && !config.paywallEnabled) {
      return _allowedDecision(
        reason: 'Paywall disabled',
        isPremiumFeature: true,
      );
    }
    return _blockedDecision(
      reason: getUpgradeReason(feature),
      feature: feature,
    );
  }

  Future<EntitlementDecision> canSubmitProblemRequest() async {
    final entitlement = await getCurrentEntitlement();
    if (!entitlement.hasActivePremiumEntitlement) {
      return _allowedDecision(reason: 'Problem requests are available.');
    }
    final used = entitlement.problemRequestsUsedThisMonth;
    final limit = entitlement.problemRequestsLimit;
    if (used < limit) {
      return _allowedDecision(
        reason: 'Monthly Premium request available.',
        isPremiumFeature: true,
        used: used,
        limit: limit,
      );
    }
    return EntitlementDecision(
      allowed: false,
      isPremiumFeature: true,
      reason:
          'You have used your 2 monthly requests. Your limit resets next month.',
      upgradeTitle: 'Monthly limit reached',
      upgradeMessage:
          'You have used your 2 monthly requests. Your limit resets next month.',
      recommendedPlan: UfficioPlan.premiumMonthly,
      used: used,
      limit: limit,
      remainingUsage: 0,
    );
  }

  Future<EntitlementDecision> canSubmitConsultancyRequest() async {
    final entitlement = await getCurrentEntitlement();
    if (!entitlement.hasActivePremiumEntitlement) {
      return _allowedDecision(reason: 'Private consultancy request available.');
    }
    final used = entitlement.consultancyRequestsUsedThisMonth;
    final limit = entitlement.consultancyRequestsLimit;
    if (used < limit) {
      return _allowedDecision(
        reason: 'Monthly Premium consultancy available.',
        isPremiumFeature: true,
        used: used,
        limit: limit,
      );
    }
    return EntitlementDecision(
      allowed: false,
      isPremiumFeature: true,
      reason:
          'You have used your 2 monthly requests. Your limit resets next month.',
      upgradeTitle: 'Monthly limit reached',
      upgradeMessage:
          'You have used your 2 monthly requests. Your limit resets next month.',
      recommendedPlan: UfficioPlan.premiumMonthly,
      used: used,
      limit: limit,
      remainingUsage: 0,
    );
  }

  Future<UfficcioEntitlement> _persistUsageUpdate({
    required UfficcioEntitlement updated,
    required String counterKey,
  }) async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (client != null && user != null) {
      try {
        await client.rpc(
          'increment_ufficio_usage_counter',
          params: <String, dynamic>{
            'counter_key': counterKey,
            'delta_amount': 1,
          },
        );
        return getCurrentEntitlement();
      } catch (_) {}
    }
    return _repository.saveEntitlement(updated);
  }

  Future<UfficcioEntitlement> recordPackGenerated([String? procedureId]) async {
    final entitlement = await getCurrentEntitlement();
    final updated = entitlement.copyWith(
      generatedPacksUsedThisMonth: entitlement.generatedPacksUsedThisMonth + 1,
      updatedAt: DateTime.now(),
    );
    await analytics.trackPackGenerated(procedureId ?? 'pack');
    return _persistUsageUpdate(
      updated: updated,
      counterKey: 'generated_packs_used',
    );
  }

  Future<UfficcioEntitlement> recordUtilityComparison() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        utilityComparisonsUsedThisMonth:
            entitlement.utilityComparisonsUsedThisMonth + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'utility_comparisons_used',
    );
  }

  Future<UfficcioEntitlement> recordBillAnalysis() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        billAnalysesUsedThisMonth: entitlement.billAnalysesUsedThisMonth + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'bill_analyses_used',
    );
  }

  Future<UfficcioEntitlement> recordSavedRequest() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        savedRequestsCount: entitlement.savedRequestsCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'saved_requests_used',
    );
  }

  Future<UfficcioEntitlement> recordReminderCreated() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        remindersCount: entitlement.remindersCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'reminders_used',
    );
  }

  Future<UfficcioEntitlement> recordDocumentAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        documentsCount: entitlement.documentsCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'documents_used',
    );
  }

  Future<UfficcioEntitlement> recordContactAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        contactsCount: entitlement.contactsCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'contacts_used',
    );
  }

  Future<UfficcioEntitlement> recordCostItemAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        costItemsCount: entitlement.costItemsCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'cost_items_used',
    );
  }

  Future<UfficcioEntitlement> recordHouseholdMemberAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        householdMembersCount: entitlement.householdMembersCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'household_members_used',
    );
  }

  Future<UfficcioEntitlement> recordProofCaseCreated() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        proofCasesCount: entitlement.proofCasesCount + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'proof_cases_used',
    );
  }

  Future<UfficcioEntitlement> recordProblemRequestSubmitted() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        problemRequestsUsedThisMonth:
            entitlement.problemRequestsUsedThisMonth + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'problem_requests_used',
    );
  }

  Future<UfficcioEntitlement> recordConsultancyRequestSubmitted() async {
    final entitlement = await getCurrentEntitlement();
    return _persistUsageUpdate(
      updated: entitlement.copyWith(
        consultancyRequestsUsedThisMonth:
            entitlement.consultancyRequestsUsedThisMonth + 1,
        updatedAt: DateTime.now(),
      ),
      counterKey: 'consultancy_requests_used',
    );
  }

  Future<UfficcioEntitlement> resetMonthlyUsageIfNeeded(
    UfficcioEntitlement entitlement,
  ) async {
    final now = DateTime.now();
    final start = entitlement.currentPeriodStart;
    if (start == null || start.year != now.year || start.month != now.month) {
      return entitlement.copyWith(
        currentPeriodStart: DateTime(now.year, now.month),
        currentPeriodEnd: DateTime(now.year, now.month + 1, 0),
        generatedPacksUsedThisMonth: 0,
        problemRequestsUsedThisMonth: 0,
        consultancyRequestsUsedThisMonth: 0,
        utilityComparisonsUsedThisMonth: 0,
        billAnalysesUsedThisMonth: 0,
      );
    }
    return entitlement;
  }

  Future<List<UsageSummaryItem>> getUsageSummary() async {
    final entitlement = await getCurrentEntitlement();
    return [
      UsageSummaryItem(
        label: 'Generated packs',
        used: entitlement.generatedPacksUsedThisMonth,
        limit: entitlement.freePackLimit,
      ),
      UsageSummaryItem(
        label: 'Problem requests',
        used: entitlement.problemRequestsUsedThisMonth,
        limit: entitlement.problemRequestsLimit,
      ),
      UsageSummaryItem(
        label: 'Private consultancies',
        used: entitlement.consultancyRequestsUsedThisMonth,
        limit: entitlement.consultancyRequestsLimit,
      ),
      UsageSummaryItem(
        label: 'Saved requests',
        used: entitlement.savedRequestsCount,
        limit: entitlement.savedRequestsLimit,
      ),
      UsageSummaryItem(
        label: 'Reminders',
        used: entitlement.remindersCount,
        limit: entitlement.remindersLimit,
      ),
      UsageSummaryItem(
        label: 'Documents',
        used: entitlement.documentsCount,
        limit: entitlement.documentsLimit,
      ),
      UsageSummaryItem(
        label: 'Utility comparisons',
        used: entitlement.utilityComparisonsUsedThisMonth,
        limit: entitlement.utilityComparisonLimit,
      ),
      UsageSummaryItem(
        label: 'Cost items',
        used: entitlement.costItemsCount,
        limit: entitlement.costItemsLimit,
      ),
    ];
  }

  String getUpgradeReason(FeatureKey feature) {
    switch (feature) {
      case FeatureKey.generatePack:
        return 'Premium unlocks higher monthly usage and full guides.';
      case FeatureKey.utilityComparison:
        return 'Premium unlocks advanced utility comparison tools.';
      case FeatureKey.billAnalysis:
        return 'Premium unlocks advanced bill analysis and complaint support.';
      case FeatureKey.costDashboard:
        return 'Premium unlocks the full cost dashboard and higher limits.';
      case FeatureKey.privateConsultancy:
        return 'Premium includes 2 private consultancies per month.';
      case FeatureKey.bonusFinderAdvanced:
        return 'Premium unlocks the full bonus finder and money-saving guidance.';
      case FeatureKey.loanComparisonAdvanced:
        return 'Premium unlocks the full loan comparison guidance.';
      case FeatureKey.consultantMode:
        return 'Premium gives you full access to UfficioFacile.';
      default:
        return 'This is a Premium feature.';
    }
  }

  Future<UfficcioEntitlement> activateLocalProForDebug() async {
    if (!_canUseLocalBypassConfig) {
      return getCurrentEntitlement();
    }
    final entitlement = await getCurrentEntitlement();
    await analytics.trackStatusUpdated('local_debug_pro_enabled');
    return _repository.saveEntitlement(
      entitlement.copyWith(
        plan: UfficioPlan.pro,
        premiumAccess: true,
        source: 'local_debug',
        localDebugProEnabled: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> deactivateLocalProForDebug() async {
    final entitlement = await getCurrentEntitlement();
    await analytics.trackStatusUpdated('local_debug_pro_disabled');
    return _repository.saveEntitlement(
      entitlement.copyWith(
        plan: UfficioPlan.free,
        premiumAccess: false,
        localDebugProEnabled: false,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<EntitlementDecision> _catalogLockedDecision() async {
    final entitlement = await getCurrentEntitlement();
    if (entitlement.isProLike) {
      return _allowedDecision(
        reason: 'Paid access active',
        isPremiumFeature: true,
      );
    }

    return const EntitlementDecision(
      allowed: false,
      isPremiumFeature: true,
      reason: 'This guide is part of UfficioFacile Premium.',
      upgradeTitle: 'Premium',
      upgradeMessage:
          'Premium gives you full access to all guides, plus 2 problem requests and 2 private consultancies every month.',
      recommendedPlan: UfficioPlan.premiumMonthly,
    );
  }

  Future<void> setBetaMode(bool enabled) async {
    final config = await getConfig();
    await _configRepository.saveConfig(
      config.copyWith(betaModeEnabled: enabled),
    );
  }

  Future<void> setPaywallEnabled(bool enabled) async {
    final config = await getConfig();
    await _configRepository.saveConfig(
      config.copyWith(paywallEnabled: enabled),
    );
  }

  Future<void> saveConfig(PremiumConfig config) =>
      _configRepository.saveConfig(config);

  Future<UfficcioEntitlement> resetUsageCounters() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        generatedPacksUsedThisMonth: 0,
        utilityComparisonsUsedThisMonth: 0,
        billAnalysesUsedThisMonth: 0,
        savedRequestsCount: 0,
        remindersCount: 0,
        documentsCount: 0,
        contactsCount: 0,
        costItemsCount: 0,
        householdMembersCount: 0,
        proofCasesCount: 0,
        updatedAt: DateTime.now(),
      ),
    );
  }

  EntitlementDecision _allowedDecision({
    required String reason,
    bool isPremiumFeature = false,
    bool blockedByBeta = false,
    int? used,
    int? limit,
  }) => EntitlementDecision(
    allowed: true,
    isPremiumFeature: isPremiumFeature,
    reason: reason,
    upgradeTitle: 'Premium',
    upgradeMessage:
        'Premium gives you full access to all guides, plus 2 problem requests and 2 private consultancies every month.',
    blockedByBeta: blockedByBeta,
    used: used,
    limit: limit,
    remainingUsage: used != null && limit != null
        ? (limit - used).clamp(0, limit)
        : null,
  );

  EntitlementDecision _blockedDecision({
    required String reason,
    required FeatureKey feature,
    int? used,
    int? limit,
  }) => EntitlementDecision(
    allowed: false,
    isPremiumFeature: true,
    reason: reason,
    upgradeTitle: 'Premium',
    upgradeMessage:
        'Premium gives you full access to all guides, plus 2 problem requests and 2 private consultancies every month.',
    recommendedPlan: UfficioPlan.premiumMonthly,
    used: used,
    limit: limit,
    remainingUsage: used != null && limit != null
        ? (limit - used).clamp(0, limit)
        : null,
  );

  Future<EntitlementDecision> _checkCountLimit(FeatureKey feature) async {
    final config = await getConfig();
    final entitlement = await getCurrentEntitlement();
    if (entitlement.isProLike) {
      return _allowedDecision(
        reason: 'Paid access active',
        isPremiumFeature: true,
      );
    }
    if (_canUseLocalBypassConfig && config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Available during beta',
        isPremiumFeature: true,
        blockedByBeta: true,
      );
    }
    if (_canUseLocalBypassConfig && !config.paywallEnabled) {
      return _allowedDecision(reason: 'Paywall disabled');
    }

    late int used;
    late int limit;
    switch (feature) {
      case FeatureKey.saveRequest:
        used = entitlement.savedRequestsCount;
        limit = entitlement.savedRequestsLimit;
      case FeatureKey.createReminder:
        used = entitlement.remindersCount;
        limit = entitlement.remindersLimit;
      case FeatureKey.documentVault:
        used = entitlement.documentsCount;
        limit = entitlement.documentsLimit;
      case FeatureKey.officialLinksAdvanced:
        used = entitlement.contactsCount;
        limit = entitlement.contactsLimit;
      case FeatureKey.costDashboard:
        used = entitlement.costItemsCount;
        limit = entitlement.costItemsLimit;
      case FeatureKey.householdMembers:
        used = entitlement.householdMembersCount;
        limit = entitlement.householdMembersLimit;
      case FeatureKey.proofFolder:
        used = entitlement.proofCasesCount;
        limit = entitlement.proofCasesLimit;
      case FeatureKey.utilityComparison:
        used = entitlement.utilityComparisonsUsedThisMonth;
        limit = entitlement.utilityComparisonLimit;
      case FeatureKey.billAnalysis:
        used = entitlement.billAnalysesUsedThisMonth;
        limit = entitlement.billAnalysisLimit;
      default:
        return canUseFeature(feature);
    }
    if (used < limit) {
      return _allowedDecision(
        reason: 'Free usage remaining',
        used: used,
        limit: limit,
      );
    }
    return _blockedDecision(
      reason: getUpgradeReason(feature),
      feature: feature,
      used: used,
      limit: limit,
    );
  }

  Future<List<PlanProduct>> _loadRemotePlanProducts() async {
    final client = SupabaseBootstrap.client;
    if (client == null) {
      return const [];
    }
    try {
      final rows = await client
          .from('ufficio_plan_products')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .timeout(const Duration(seconds: 3));
      return rows
          .whereType<Map>()
          .map((item) => PlanProduct.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<UserContentUnlock>> _loadRemoteContentUnlocks() async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return const [];
    }
    try {
      final rows = await client
          .from('ufficio_user_content_unlocks')
          .select()
          .eq('user_id', user.id)
          .timeout(const Duration(seconds: 3));
      return rows
          .whereType<Map>()
          .map(
            (item) =>
                UserContentUnlock.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

final List<PlanProduct> _defaultPlanProducts = <PlanProduct>[
  PlanProduct(
    productKey: 'free',
    planType: 'free',
    billingInterval: 'none',
    amountCents: 0,
    currency: 'EUR',
    isActive: true,
    sortOrder: 0,
    title: const {'en': 'Free', 'it': 'Gratis'},
    description: const {
      'en': 'Basic access with limits.',
      'it': 'Accesso base con limiti.',
    },
    features: const {'premium_sections': false, 'priority_requests': false},
    limits: const {
      'generated_packs_per_month': 3,
      'saved_requests_limit': 5,
      'documents_limit': 5,
      'contacts_limit': 5,
      'cost_items_limit': 5,
      'consultancy_included_per_month': 0,
    },
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'plus_monthly',
    planType: 'subscription',
    billingInterval: 'month',
    amountCents: 499,
    currency: 'EUR',
    isActive: false,
    sortOrder: 1,
    title: const {
      'en': 'Plus Monthly',
      'it': 'Plus mensile',
      'fr': 'Plus mensuel',
      'es': 'Plus mensual',
      'fa': 'پلاس ماهانه',
      'ar': 'بلس شهري',
    },
    description: const {
      'en': 'More usage, priority requests, and expanded tools.',
      'it': 'Più utilizzo, richieste prioritarie e strumenti estesi.',
      'fr': 'Plus d’utilisations, demandes prioritaries et outils étendus.',
      'es': 'Más uso, solicitudes prioritarias y herramientas ampliadas.',
      'fa': 'استفاده بیشتر، درخواست‌های اولویت‌دار و ابزارهای گسترده‌تر.',
      'ar': 'استخدام أكثر وطلبات ذات أولوية وأدوات موسعة.',
    },
    features: const {'premium_sections': false, 'priority_requests': true},
    limits: const {
      'generated_packs_per_month': 20,
      'saved_requests_limit': 50,
      'documents_limit': 50,
      'contacts_limit': 50,
      'cost_items_limit': 50,
      'consultancy_included_per_month': 0,
    },
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'plus_yearly',
    planType: 'subscription',
    billingInterval: 'year',
    amountCents: 3999,
    currency: 'EUR',
    isActive: false,
    sortOrder: 2,
    title: const {
      'en': 'Plus Yearly',
      'it': 'Plus annuale',
      'fr': 'Plus annuel',
      'es': 'Plus anual',
      'fa': 'پلاس سالانه',
      'ar': 'بلس سنوي',
    },
    description: const {
      'en': 'One-year Plus access with better value.',
      'it': 'Accesso Plus per un anno con prezzo migliore.',
      'fr': 'Accès Plus d’un an avec meilleur prix.',
      'es': 'Acceso Plus de un año con mejor valor.',
      'fa': 'دسترسی پلاس یک‌ساله با ارزش بهتر.',
      'ar': 'وصول بلس لمدة سنة بقيمة أفضل.',
    },
    features: const {'premium_sections': false, 'priority_requests': true},
    limits: const {
      'generated_packs_per_month': 20,
      'saved_requests_limit': 50,
      'documents_limit': 50,
      'contacts_limit': 50,
      'cost_items_limit': 50,
      'consultancy_included_per_month': 0,
    },
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'premium_monthly',
    planType: 'subscription',
    billingInterval: 'month',
    amountCents: 999,
    currency: 'EUR',
    isActive: true,
    sortOrder: 3,
    title: const {
      'en': 'Premium Monthly',
      'it': 'Premium mensile',
      'fr': 'Premium mensuel',
      'es': 'Premium mensual',
      'fa': 'پریمیوم ماهانه',
      'ar': 'بريميوم شهري',
    },
    description: const {
      'en':
          'Full access to UfficioFacile guides, plus 2 problem requests and 2 private consultancies per month.',
      'it':
          'Accesso completo alle guide di UfficioFacile, più 2 richieste problema e 2 consulenze private al mese.',
      'fr':
          'Accès complet aux guides UfficioFacile, plus 2 demandes de problème et 2 consultations privées par mois.',
      'es':
          'Acceso completo a las guías de UfficioFacile, más 2 solicitudes de problema y 2 consultorías privadas al mes.',
      'fa':
          'دسترسی کامل به راهنماهای UfficioFacile، به‌علاوه ۲ درخواست مشکل و ۲ مشاوره خصوصی در هر ماه.',
      'ar':
          'وصول كامل إلى أدلة UfficioFacile، بالإضافة إلى طلبي مشكلة واستشارتين خاصتين كل شهر.',
    },
    features: const {
      'all_premium_guides': true,
      'problem_requests_per_month': 2,
      'private_consultancies_per_month': 2,
    },
    limits: const {
      'generated_packs_per_month': 100,
      'saved_requests_limit': 500,
      'documents_limit': 500,
      'contacts_limit': 500,
      'cost_items_limit': 500,
      'problem_requests_per_month': 2,
      'consultancy_included_per_month': 2,
    },
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'premium_yearly',
    planType: 'subscription',
    billingInterval: 'year',
    amountCents: 7999,
    currency: 'EUR',
    isActive: true,
    sortOrder: 4,
    title: const {
      'en': 'Premium Yearly',
      'it': 'Premium annuale',
      'fr': 'Premium annuel',
      'es': 'Premium anual',
      'fa': 'پریمیوم سالانه',
      'ar': 'بريميوم سنوي',
    },
    description: const {
      'en':
          'Full access to UfficioFacile guides, plus 2 problem requests and 2 private consultancies per month.',
      'it':
          'Accesso completo alle guide di UfficioFacile, più 2 richieste problema e 2 consulenze private al mese.',
      'fr':
          'Accès complet aux guides UfficioFacile, plus 2 demandes de problème et 2 consultations privées par mois.',
      'es':
          'Acceso completo a las guías de UfficioFacile, más 2 solicitudes de problema y 2 consultorías privadas al mes.',
      'fa':
          'دسترسی کامل به راهنماهای UfficioFacile، به‌علاوه ۲ درخواست مشکل و ۲ مشاوره خصوصی در هر ماه.',
      'ar':
          'وصول كامل إلى أدلة UfficioFacile، بالإضافة إلى طلبي مشكلة واستشارتين خاصتين كل شهر.',
    },
    features: const {
      'all_premium_guides': true,
      'problem_requests_per_month': 2,
      'private_consultancies_per_month': 2,
    },
    limits: const {
      'generated_packs_per_month': 100,
      'saved_requests_limit': 500,
      'documents_limit': 500,
      'contacts_limit': 500,
      'cost_items_limit': 500,
      'problem_requests_per_month': 2,
      'consultancy_included_per_month': 2,
    },
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'consultancy_one_shot',
    planType: 'one_time',
    billingInterval: 'one_time',
    amountCents: 1499,
    currency: 'EUR',
    isActive: false,
    sortOrder: 6,
    title: const {
      'en': 'One-shot Consultancy',
      'it': 'Consulenza una tantum',
      'fr': 'Consultation ponctuelle',
      'es': 'Consultoría puntual',
      'fa': 'مشاوره تک‌مرحله‌ای',
      'ar': 'استشارة لمرة واحدة',
    },
    description: const {
      'en': 'Pay once for one private consultancy request.',
      'it': 'Paga una volta per una richiesta di consulenza privata.',
      'fr': 'Payez une fois pour une demande de consultation privée.',
      'es': 'Paga una vez por una solicitud de consultoría privada.',
      'fa': 'برای یک درخواست مشاوره خصوصی یک بار پرداخت کن.',
      'ar': 'ادفع مرة واحدة مقابل طلب استشارة خاصة.',
    },
    features: const {'private_consultancy': true},
    limits: const {'procedure_count': 1},
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'subcategory_unlock',
    planType: 'one_time',
    billingInterval: 'one_time',
    amountCents: 399,
    currency: 'EUR',
    isActive: false,
    sortOrder: 5,
    title: const {
      'en': 'Single Guide Unlock',
      'it': 'Sblocco guida singola',
      'fr': 'Déblocage d’un guide',
      'es': 'Desbloqueo de una guía',
      'fa': 'باز کردن یک راهنما',
      'ar': 'فتح دليل واحد',
    },
    description: const {
      'en': 'Unlock one premium guide without subscribing.',
      'it': 'Sblocca una guida premium senza abbonarti.',
      'fr': 'Débloquez un guide premium sans abonnement.',
      'es': 'Desbloquea una guía premium sin suscribirte.',
      'fa': 'یک راهنمای پریمیوم را بدون اشتراک باز کن.',
      'ar': 'افتح دليلاً بريميوم واحداً من دون اشتراك.',
    },
    features: const {'unlocks_single_procedure': true},
    limits: const {'procedure_count': 1},
    providerMetadata: const {},
  ),
  PlanProduct(
    productKey: 'admin_grant',
    planType: 'admin_only',
    billingInterval: 'none',
    amountCents: 0,
    currency: 'EUR',
    isActive: true,
    sortOrder: 7,
    title: const {
      'en': 'Admin Grant',
      'it': 'Grant admin',
      'fr': 'Attribution admin',
      'es': 'Concesión admin',
      'fa': 'اعطای ادمین',
      'ar': 'منح إداري',
    },
    description: const {
      'en': 'Internal administrative entitlement grant.',
      'it': 'Concessione interna amministrativa.',
      'fr': 'Attribution administrative interne.',
      'es': 'Concesión administrativa interna.',
      'fa': 'اعطای داخلی مدیریتی.',
      'ar': 'منح إداري داخلي.',
    },
    features: const {'premium_sections': true, 'priority_requests': true},
    limits: const {
      'generated_packs_per_month': 100,
      'saved_requests_limit': 500,
      'documents_limit': 500,
      'contacts_limit': 500,
      'cost_items_limit': 500,
      'consultancy_included_per_month': 2,
    },
    providerMetadata: const {},
  ),
];
