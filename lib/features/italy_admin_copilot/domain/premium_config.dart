enum UfficioPlan {
  free,
  plusMonthly,
  plusYearly,
  pro,
  consultant,
  premiumMonthly,
  premiumYearly,
  consultancyOneShot,
  adminGrant,
  lifetime,
  trial,
}

enum EntitlementStatus { active, trialing, expired, cancelled, beta }

enum FeatureKey {
  generatePack,
  saveRequest,
  createReminder,
  documentVault,
  proofFolder,
  householdContracts,
  householdMembers,
  utilityComparison,
  billAnalysis,
  canoneRaiAdvanced,
  telecomAdvanced,
  exportFullPack,
  bulkExport,
  remoteSync,
  consultantMode,
  adminPanel,
  advancedTemplates,
  serviceIntelligenceAdvanced,
  officialLinksAdvanced,
  costDashboard,
  premiumGuides,
  advancedScanner,
  deadlineReminders,
  bonusFinderAdvanced,
  loanComparisonAdvanced,
  privateConsultancy,
  priorityProblemRequest,
}

class PremiumConfig {
  const PremiumConfig({
    this.betaModeEnabled = false,
    this.paywallEnabled = true,
    this.showPremiumBadges = true,
    this.freePackLimit = 5,
    this.freeSavedRequestsLimit = 10,
    this.freeRemindersLimit = 5,
    this.freeDocumentsLimit = 10,
    this.freeContactsLimit = 10,
    this.freeCostItemsLimit = 5,
    this.freeHouseholdMembersLimit = 2,
    this.freeProofCasesLimit = 2,
    this.freeUtilityComparisonLimit = 3,
    this.freeBillAnalysisLimit = 3,
    this.premiumProcedureIds = const [],
    this.lockedProcedureIds = const [],
    this.proFeatureKeys = const [],
    this.consultantFeatureKeys = const [FeatureKey.consultantMode],
    this.trialDays = 7,
    this.allowLocalDebugPro = false,
  });

  final bool betaModeEnabled;
  final bool paywallEnabled;
  final bool showPremiumBadges;
  final int freePackLimit;
  final int freeSavedRequestsLimit;
  final int freeRemindersLimit;
  final int freeDocumentsLimit;
  final int freeContactsLimit;
  final int freeCostItemsLimit;
  final int freeHouseholdMembersLimit;
  final int freeProofCasesLimit;
  final int freeUtilityComparisonLimit;
  final int freeBillAnalysisLimit;
  final List<String> premiumProcedureIds;
  final List<String> lockedProcedureIds;
  final List<FeatureKey> proFeatureKeys;
  final List<FeatureKey> consultantFeatureKeys;
  final int trialDays;
  final bool allowLocalDebugPro;

  PremiumConfig copyWith({
    bool? betaModeEnabled,
    bool? paywallEnabled,
    bool? showPremiumBadges,
    int? freePackLimit,
    int? freeSavedRequestsLimit,
    int? freeRemindersLimit,
    int? freeDocumentsLimit,
    int? freeContactsLimit,
    int? freeCostItemsLimit,
    int? freeHouseholdMembersLimit,
    int? freeProofCasesLimit,
    int? freeUtilityComparisonLimit,
    int? freeBillAnalysisLimit,
    List<String>? premiumProcedureIds,
    List<String>? lockedProcedureIds,
    List<FeatureKey>? proFeatureKeys,
    List<FeatureKey>? consultantFeatureKeys,
    int? trialDays,
    bool? allowLocalDebugPro,
  }) {
    return PremiumConfig(
      betaModeEnabled: betaModeEnabled ?? this.betaModeEnabled,
      paywallEnabled: paywallEnabled ?? this.paywallEnabled,
      showPremiumBadges: showPremiumBadges ?? this.showPremiumBadges,
      freePackLimit: freePackLimit ?? this.freePackLimit,
      freeSavedRequestsLimit:
          freeSavedRequestsLimit ?? this.freeSavedRequestsLimit,
      freeRemindersLimit: freeRemindersLimit ?? this.freeRemindersLimit,
      freeDocumentsLimit: freeDocumentsLimit ?? this.freeDocumentsLimit,
      freeContactsLimit: freeContactsLimit ?? this.freeContactsLimit,
      freeCostItemsLimit: freeCostItemsLimit ?? this.freeCostItemsLimit,
      freeHouseholdMembersLimit:
          freeHouseholdMembersLimit ?? this.freeHouseholdMembersLimit,
      freeProofCasesLimit: freeProofCasesLimit ?? this.freeProofCasesLimit,
      freeUtilityComparisonLimit:
          freeUtilityComparisonLimit ?? this.freeUtilityComparisonLimit,
      freeBillAnalysisLimit:
          freeBillAnalysisLimit ?? this.freeBillAnalysisLimit,
      premiumProcedureIds: premiumProcedureIds ?? this.premiumProcedureIds,
      lockedProcedureIds: lockedProcedureIds ?? this.lockedProcedureIds,
      proFeatureKeys: proFeatureKeys ?? this.proFeatureKeys,
      consultantFeatureKeys:
          consultantFeatureKeys ?? this.consultantFeatureKeys,
      trialDays: trialDays ?? this.trialDays,
      allowLocalDebugPro: allowLocalDebugPro ?? this.allowLocalDebugPro,
    );
  }

  Map<String, dynamic> toJson() => {
    'betaModeEnabled': betaModeEnabled,
    'paywallEnabled': paywallEnabled,
    'showPremiumBadges': showPremiumBadges,
    'freePackLimit': freePackLimit,
    'freeSavedRequestsLimit': freeSavedRequestsLimit,
    'freeRemindersLimit': freeRemindersLimit,
    'freeDocumentsLimit': freeDocumentsLimit,
    'freeContactsLimit': freeContactsLimit,
    'freeCostItemsLimit': freeCostItemsLimit,
    'freeHouseholdMembersLimit': freeHouseholdMembersLimit,
    'freeProofCasesLimit': freeProofCasesLimit,
    'freeUtilityComparisonLimit': freeUtilityComparisonLimit,
    'freeBillAnalysisLimit': freeBillAnalysisLimit,
    'premiumProcedureIds': premiumProcedureIds,
    'lockedProcedureIds': lockedProcedureIds,
    'proFeatureKeys': proFeatureKeys.map((item) => item.name).toList(),
    'consultantFeatureKeys': consultantFeatureKeys
        .map((item) => item.name)
        .toList(),
    'trialDays': trialDays,
    'allowLocalDebugPro': allowLocalDebugPro,
  };

  factory PremiumConfig.fromJson(Map<String, dynamic> json) => PremiumConfig(
    betaModeEnabled: json['betaModeEnabled'] as bool? ?? false,
    paywallEnabled: json['paywallEnabled'] as bool? ?? true,
    showPremiumBadges: json['showPremiumBadges'] as bool? ?? true,
    freePackLimit: json['freePackLimit'] as int? ?? 5,
    freeSavedRequestsLimit: json['freeSavedRequestsLimit'] as int? ?? 10,
    freeRemindersLimit: json['freeRemindersLimit'] as int? ?? 5,
    freeDocumentsLimit: json['freeDocumentsLimit'] as int? ?? 10,
    freeContactsLimit: json['freeContactsLimit'] as int? ?? 10,
    freeCostItemsLimit: json['freeCostItemsLimit'] as int? ?? 5,
    freeHouseholdMembersLimit: json['freeHouseholdMembersLimit'] as int? ?? 2,
    freeProofCasesLimit: json['freeProofCasesLimit'] as int? ?? 2,
    freeUtilityComparisonLimit: json['freeUtilityComparisonLimit'] as int? ?? 3,
    freeBillAnalysisLimit: json['freeBillAnalysisLimit'] as int? ?? 3,
    premiumProcedureIds: ((json['premiumProcedureIds'] as List?) ?? [])
        .cast<String>(),
    lockedProcedureIds: ((json['lockedProcedureIds'] as List?) ?? [])
        .cast<String>(),
    proFeatureKeys: ((json['proFeatureKeys'] as List?) ?? [])
        .map(
          (item) => FeatureKey.values.firstWhere(
            (value) => value.name == item,
            orElse: () => FeatureKey.generatePack,
          ),
        )
        .toList(),
    consultantFeatureKeys: ((json['consultantFeatureKeys'] as List?) ?? [])
        .map(
          (item) => FeatureKey.values.firstWhere(
            (value) => value.name == item,
            orElse: () => FeatureKey.consultantMode,
          ),
        )
        .toList(),
    trialDays: json['trialDays'] as int? ?? 7,
    allowLocalDebugPro: json['allowLocalDebugPro'] as bool? ?? false,
  );
}

enum ContentAccessReason {
  freeContent,
  premiumSubscription,
  singleUnlock,
  adminPreview,
  locked,
}

enum UnlockOption { premium, singlePurchase, consultancy }

class ContentAccessResult {
  const ContentAccessResult({
    required this.allowed,
    required this.reason,
    required this.message,
    this.unlockOptions = const <UnlockOption>[],
    this.singleUnlockPriceCents,
    this.singleUnlockCurrency = 'EUR',
    this.requiresPremium = false,
    this.alreadyUnlocked = false,
  });

  final bool allowed;
  final ContentAccessReason reason;
  final String message;
  final List<UnlockOption> unlockOptions;
  final int? singleUnlockPriceCents;
  final String singleUnlockCurrency;
  final bool requiresPremium;
  final bool alreadyUnlocked;
}

class EntitlementDecision {
  const EntitlementDecision({
    required this.allowed,
    required this.isPremiumFeature,
    required this.reason,
    required this.upgradeTitle,
    required this.upgradeMessage,
    this.remainingUsage,
    this.limit,
    this.used,
    this.blockedByBeta = false,
    this.recommendedPlan = UfficioPlan.pro,
  });

  final bool allowed;
  final bool isPremiumFeature;
  final String reason;
  final String upgradeTitle;
  final String upgradeMessage;
  final int? remainingUsage;
  final int? limit;
  final int? used;
  final bool blockedByBeta;
  final UfficioPlan recommendedPlan;
}

class UsageSummaryItem {
  const UsageSummaryItem({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final int used;
  final int limit;
}
