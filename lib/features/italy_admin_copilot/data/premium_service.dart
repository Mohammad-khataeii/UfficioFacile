import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/premium_config.dart';
import '../domain/ufficcio_entitlement.dart';
import 'local_analytics_service.dart';
import 'ufficcio_supabase_readiness.dart';

class LocalPremiumConfigRepository {
  LocalPremiumConfigRepository(this._prefs, {this.remoteLoader});

  static const storageKey = 'ufficiofacile_premium_config_v1';
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
  betaModeEnabled: true,
  paywallEnabled: false,
  showPremiumBadges: true,
  freePackLimit: 5,
  freeSavedRequestsLimit: 10,
  freeRemindersLimit: 5,
  freeDocumentsLimit: 10,
  freeContactsLimit: 10,
  freeHouseholdMembersLimit: 2,
  freeProofCasesLimit: 2,
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
    FeatureKey.canoneRaiAdvanced,
    FeatureKey.telecomAdvanced,
    FeatureKey.serviceIntelligenceAdvanced,
    FeatureKey.officialLinksAdvanced,
  ],
  consultantFeatureKeys: [FeatureKey.consultantMode],
  trialDays: 7,
  allowLocalDebugPro: true,
);

class UfficioPremiumEntitlementService {
  UfficioPremiumEntitlementService(
    this._repository,
    this._configRepository, {
    required this.analytics,
  });

  final UfficcioEntitlementRepository _repository;
  final LocalPremiumConfigRepository _configRepository;
  final LocalAnalyticsService analytics;

  Future<PremiumConfig> getConfig() => _configRepository.getConfig();

  Future<UfficcioEntitlement> getCurrentEntitlement() async {
    final config = await getConfig();
    final entitlement = await _repository.getEntitlement();
    final normalized = await resetMonthlyUsageIfNeeded(
      entitlement.copyWith(
        betaModeEnabled: config.betaModeEnabled,
        paywallEnabled: config.paywallEnabled,
        freePackLimit: config.freePackLimit,
        savedRequestsLimit: config.freeSavedRequestsLimit,
        remindersLimit: config.freeRemindersLimit,
        documentsLimit: config.freeDocumentsLimit,
        contactsLimit: config.freeContactsLimit,
        householdMembersLimit: config.freeHouseholdMembersLimit,
        proofCasesLimit: config.freeProofCasesLimit,
        utilityComparisonLimit: config.freeUtilityComparisonLimit,
        billAnalysisLimit: config.freeBillAnalysisLimit,
        enabledPremiumProcedureIds: config.premiumProcedureIds,
        lockedProcedureIds: config.lockedProcedureIds,
      ),
    );
    if (normalized != entitlement) {
      await _repository.saveEntitlement(normalized);
    }
    return normalized;
  }

  Future<UfficioPlan> getCurrentPlan() async =>
      (await getCurrentEntitlement()).plan;

  Future<bool> isPro() async => (await getCurrentEntitlement()).isProLike;
  Future<bool> isBetaMode() async => (await getConfig()).betaModeEnabled;

  Future<bool> isPremiumProcedure(String procedureId) async {
    final config = await getConfig();
    return config.premiumProcedureIds.contains(procedureId) ||
        config.lockedProcedureIds.contains(procedureId);
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
        reason: 'Pro access active',
        isPremiumFeature: true,
      );
    }
    if (config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Beta access active',
        isPremiumFeature: true,
        blockedByBeta: true,
      );
    }
    if (!config.paywallEnabled) {
      return _allowedDecision(
        reason: 'Paywall disabled',
        isPremiumFeature: true,
      );
    }
    return _blockedDecision(
      reason: 'This procedure is part of Pro.',
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
      return _allowedDecision(reason: 'Pro generation enabled');
    }
    if (config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Beta access active',
        blockedByBeta: true,
        isPremiumFeature: true,
      );
    }
    if (!config.paywallEnabled) {
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
        reason: 'Pro access active',
        isPremiumFeature: true,
      );
    }
    if (config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Available during beta',
        isPremiumFeature: true,
        blockedByBeta: true,
      );
    }
    if (!config.paywallEnabled) {
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

  Future<UfficcioEntitlement> recordPackGenerated([String? procedureId]) async {
    final entitlement = await getCurrentEntitlement();
    final updated = entitlement.copyWith(
      generatedPacksUsedThisMonth: entitlement.generatedPacksUsedThisMonth + 1,
      updatedAt: DateTime.now(),
    );
    await analytics.trackPackGenerated(procedureId ?? 'pack');
    return _repository.saveEntitlement(updated);
  }

  Future<UfficcioEntitlement> recordUtilityComparison() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        utilityComparisonsUsedThisMonth:
            entitlement.utilityComparisonsUsedThisMonth + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordBillAnalysis() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        billAnalysesUsedThisMonth: entitlement.billAnalysesUsedThisMonth + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordSavedRequest() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        savedRequestsCount: entitlement.savedRequestsCount + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordReminderCreated() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        remindersCount: entitlement.remindersCount + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordDocumentAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        documentsCount: entitlement.documentsCount + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordContactAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        contactsCount: entitlement.contactsCount + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordHouseholdMemberAdded() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        householdMembersCount: entitlement.householdMembersCount + 1,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<UfficcioEntitlement> recordProofCaseCreated() async {
    final entitlement = await getCurrentEntitlement();
    return _repository.saveEntitlement(
      entitlement.copyWith(
        proofCasesCount: entitlement.proofCasesCount + 1,
        updatedAt: DateTime.now(),
      ),
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
    ];
  }

  String getUpgradeReason(FeatureKey feature) {
    switch (feature) {
      case FeatureKey.generatePack:
        return 'Pro unlocks more monthly request packs.';
      case FeatureKey.utilityComparison:
        return 'Pro unlocks advanced utility comparison tools.';
      case FeatureKey.billAnalysis:
        return 'Pro unlocks advanced bill analysis and complaint support.';
      case FeatureKey.consultantMode:
        return 'Consultant mode is planned for a future plan.';
      default:
        return 'This is a Pro feature.';
    }
  }

  Future<UfficcioEntitlement> activateLocalProForDebug() async {
    final entitlement = await getCurrentEntitlement();
    await analytics.trackStatusUpdated('local_debug_pro_enabled');
    return _repository.saveEntitlement(
      entitlement.copyWith(
        plan: UfficioPlan.pro,
        premiumAccess: true,
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
    upgradeTitle: 'This is a Pro feature.',
    upgradeMessage:
        'Pro unlocks advanced utility tools, Canone RAI flows, proof folders, document vault, cost tracking, and unlimited request packs.',
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
    upgradeTitle: 'This is a Pro feature.',
    upgradeMessage:
        'Pro unlocks advanced utility tools, Canone RAI flows, proof folders, document vault, cost tracking, and unlimited request packs.',
    recommendedPlan: feature == FeatureKey.consultantMode
        ? UfficioPlan.consultant
        : UfficioPlan.pro,
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
        reason: 'Pro access active',
        isPremiumFeature: true,
      );
    }
    if (config.betaModeEnabled) {
      return _allowedDecision(
        reason: 'Available during beta',
        isPremiumFeature: true,
        blockedByBeta: true,
      );
    }
    if (!config.paywallEnabled) {
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
}
