import 'premium_config.dart';

class UfficcioEntitlement {
  const UfficcioEntitlement({
    this.id,
    this.userId,
    this.plan = UfficioPlan.free,
    this.status = EntitlementStatus.active,
    this.source = 'system',
    this.premiumAccess = false,
    this.betaModeEnabled = true,
    this.paywallEnabled = false,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.trialEnd,
    this.cancelledAt,
    this.revokedAt,
    this.generatedPacksUsedThisMonth = 0,
    this.utilityComparisonsUsedThisMonth = 0,
    this.billAnalysesUsedThisMonth = 0,
    this.savedRequestsCount = 0,
    this.remindersCount = 0,
    this.documentsCount = 0,
    this.contactsCount = 0,
    this.costItemsCount = 0,
    this.householdMembersCount = 0,
    this.proofCasesCount = 0,
    this.freePackLimit = 5,
    this.savedRequestsLimit = 10,
    this.remindersLimit = 5,
    this.documentsLimit = 10,
    this.contactsLimit = 10,
    this.costItemsLimit = 5,
    this.householdMembersLimit = 2,
    this.proofCasesLimit = 2,
    this.utilityComparisonLimit = 3,
    this.billAnalysisLimit = 3,
    this.enabledPremiumProcedureIds = const [],
    this.lockedProcedureIds = const [],
    this.provider,
    this.providerCustomerId,
    this.providerSubscriptionId,
    this.createdAt,
    this.updatedAt,
    this.localDebugProEnabled = false,
  });

  final String? id;
  final String? userId;
  final UfficioPlan plan;
  final EntitlementStatus status;
  final String source;
  final bool premiumAccess;
  final bool betaModeEnabled;
  final bool paywallEnabled;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? trialEnd;
  final DateTime? cancelledAt;
  final DateTime? revokedAt;
  final int generatedPacksUsedThisMonth;
  final int utilityComparisonsUsedThisMonth;
  final int billAnalysesUsedThisMonth;
  final int savedRequestsCount;
  final int remindersCount;
  final int documentsCount;
  final int contactsCount;
  final int costItemsCount;
  final int householdMembersCount;
  final int proofCasesCount;
  final int freePackLimit;
  final int savedRequestsLimit;
  final int remindersLimit;
  final int documentsLimit;
  final int contactsLimit;
  final int costItemsLimit;
  final int householdMembersLimit;
  final int proofCasesLimit;
  final int utilityComparisonLimit;
  final int billAnalysisLimit;
  final List<String> enabledPremiumProcedureIds;
  final List<String> lockedProcedureIds;
  final String? provider;
  final String? providerCustomerId;
  final String? providerSubscriptionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool localDebugProEnabled;
  int get freePacksUsed => generatedPacksUsedThisMonth;

  bool get isProLike =>
      premiumAccess ||
      localDebugProEnabled ||
      plan == UfficioPlan.pro ||
      plan == UfficioPlan.consultant ||
      plan == UfficioPlan.premiumMonthly ||
      plan == UfficioPlan.premiumYearly ||
      plan == UfficioPlan.adminGrant;

  UfficcioEntitlement copyWith({
    String? id,
    String? userId,
    UfficioPlan? plan,
    EntitlementStatus? status,
    String? source,
    bool? premiumAccess,
    bool? betaModeEnabled,
    bool? paywallEnabled,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? trialEnd,
    DateTime? cancelledAt,
    DateTime? revokedAt,
    int? generatedPacksUsedThisMonth,
    int? freePacksUsed,
    int? utilityComparisonsUsedThisMonth,
    int? billAnalysesUsedThisMonth,
    int? savedRequestsCount,
    int? remindersCount,
    int? documentsCount,
    int? contactsCount,
    int? costItemsCount,
    int? householdMembersCount,
    int? proofCasesCount,
    int? freePackLimit,
    int? savedRequestsLimit,
    int? remindersLimit,
    int? documentsLimit,
    int? contactsLimit,
    int? costItemsLimit,
    int? householdMembersLimit,
    int? proofCasesLimit,
    int? utilityComparisonLimit,
    int? billAnalysisLimit,
    List<String>? enabledPremiumProcedureIds,
    List<String>? lockedProcedureIds,
    String? provider,
    String? providerCustomerId,
    String? providerSubscriptionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? localDebugProEnabled,
  }) {
    return UfficcioEntitlement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      source: source ?? this.source,
      premiumAccess: premiumAccess ?? this.premiumAccess,
      betaModeEnabled: betaModeEnabled ?? this.betaModeEnabled,
      paywallEnabled: paywallEnabled ?? this.paywallEnabled,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      trialEnd: trialEnd ?? this.trialEnd,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      revokedAt: revokedAt ?? this.revokedAt,
      generatedPacksUsedThisMonth:
          generatedPacksUsedThisMonth ??
          freePacksUsed ??
          this.generatedPacksUsedThisMonth,
      utilityComparisonsUsedThisMonth:
          utilityComparisonsUsedThisMonth ??
          this.utilityComparisonsUsedThisMonth,
      billAnalysesUsedThisMonth:
          billAnalysesUsedThisMonth ?? this.billAnalysesUsedThisMonth,
      savedRequestsCount: savedRequestsCount ?? this.savedRequestsCount,
      remindersCount: remindersCount ?? this.remindersCount,
      documentsCount: documentsCount ?? this.documentsCount,
      contactsCount: contactsCount ?? this.contactsCount,
      costItemsCount: costItemsCount ?? this.costItemsCount,
      householdMembersCount:
          householdMembersCount ?? this.householdMembersCount,
      proofCasesCount: proofCasesCount ?? this.proofCasesCount,
      freePackLimit: freePackLimit ?? this.freePackLimit,
      savedRequestsLimit: savedRequestsLimit ?? this.savedRequestsLimit,
      remindersLimit: remindersLimit ?? this.remindersLimit,
      documentsLimit: documentsLimit ?? this.documentsLimit,
      contactsLimit: contactsLimit ?? this.contactsLimit,
      costItemsLimit: costItemsLimit ?? this.costItemsLimit,
      householdMembersLimit:
          householdMembersLimit ?? this.householdMembersLimit,
      proofCasesLimit: proofCasesLimit ?? this.proofCasesLimit,
      utilityComparisonLimit:
          utilityComparisonLimit ?? this.utilityComparisonLimit,
      billAnalysisLimit: billAnalysisLimit ?? this.billAnalysisLimit,
      enabledPremiumProcedureIds:
          enabledPremiumProcedureIds ?? this.enabledPremiumProcedureIds,
      lockedProcedureIds: lockedProcedureIds ?? this.lockedProcedureIds,
      provider: provider ?? this.provider,
      providerCustomerId: providerCustomerId ?? this.providerCustomerId,
      providerSubscriptionId:
          providerSubscriptionId ?? this.providerSubscriptionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localDebugProEnabled: localDebugProEnabled ?? this.localDebugProEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'plan': plan.name,
    'status': status.name,
    'source': source,
    'premiumAccess': premiumAccess,
    'betaModeEnabled': betaModeEnabled,
    'paywallEnabled': paywallEnabled,
    'currentPeriodStart': currentPeriodStart?.toIso8601String(),
    'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
    'trialEnd': trialEnd?.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
    'revokedAt': revokedAt?.toIso8601String(),
    'generatedPacksUsedThisMonth': generatedPacksUsedThisMonth,
    'freePacksUsed': generatedPacksUsedThisMonth,
    'utilityComparisonsUsedThisMonth': utilityComparisonsUsedThisMonth,
    'billAnalysesUsedThisMonth': billAnalysesUsedThisMonth,
    'savedRequestsCount': savedRequestsCount,
    'remindersCount': remindersCount,
    'documentsCount': documentsCount,
    'contactsCount': contactsCount,
    'costItemsCount': costItemsCount,
    'householdMembersCount': householdMembersCount,
    'proofCasesCount': proofCasesCount,
    'freePackLimit': freePackLimit,
    'savedRequestsLimit': savedRequestsLimit,
    'remindersLimit': remindersLimit,
    'documentsLimit': documentsLimit,
    'contactsLimit': contactsLimit,
    'costItemsLimit': costItemsLimit,
    'householdMembersLimit': householdMembersLimit,
    'proofCasesLimit': proofCasesLimit,
    'utilityComparisonLimit': utilityComparisonLimit,
    'billAnalysisLimit': billAnalysisLimit,
    'enabledPremiumProcedureIds': enabledPremiumProcedureIds,
    'lockedProcedureIds': lockedProcedureIds,
    'provider': provider,
    'providerCustomerId': providerCustomerId,
    'providerSubscriptionId': providerSubscriptionId,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'localDebugProEnabled': localDebugProEnabled,
  };

  factory UfficcioEntitlement.fromJson(Map<String, dynamic> json) {
    return UfficcioEntitlement(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      plan: UfficioPlan.values.firstWhere(
        (item) => item.name == json['plan'],
        orElse: () => UfficioPlan.free,
      ),
      status: EntitlementStatus.values.firstWhere(
        (item) => item.name == json['status'],
        orElse: () => EntitlementStatus.active,
      ),
      source: json['source'] as String? ?? 'system',
      premiumAccess: json['premiumAccess'] as bool? ?? false,
      betaModeEnabled: json['betaModeEnabled'] as bool? ?? true,
      paywallEnabled: json['paywallEnabled'] as bool? ?? false,
      currentPeriodStart: DateTime.tryParse(
        json['currentPeriodStart'] as String? ?? '',
      ),
      currentPeriodEnd: DateTime.tryParse(
        json['currentPeriodEnd'] as String? ?? '',
      ),
      trialEnd: DateTime.tryParse(json['trialEnd'] as String? ?? ''),
      cancelledAt: DateTime.tryParse(json['cancelledAt'] as String? ?? ''),
      revokedAt: DateTime.tryParse(json['revokedAt'] as String? ?? ''),
      generatedPacksUsedThisMonth:
          json['generatedPacksUsedThisMonth'] as int? ??
          json['freePacksUsed'] as int? ??
          0,
      utilityComparisonsUsedThisMonth:
          json['utilityComparisonsUsedThisMonth'] as int? ?? 0,
      billAnalysesUsedThisMonth: json['billAnalysesUsedThisMonth'] as int? ?? 0,
      savedRequestsCount: json['savedRequestsCount'] as int? ?? 0,
      remindersCount: json['remindersCount'] as int? ?? 0,
      documentsCount: json['documentsCount'] as int? ?? 0,
      contactsCount: json['contactsCount'] as int? ?? 0,
      costItemsCount: json['costItemsCount'] as int? ?? 0,
      householdMembersCount: json['householdMembersCount'] as int? ?? 0,
      proofCasesCount: json['proofCasesCount'] as int? ?? 0,
      freePackLimit: json['freePackLimit'] as int? ?? 5,
      savedRequestsLimit: json['savedRequestsLimit'] as int? ?? 10,
      remindersLimit: json['remindersLimit'] as int? ?? 5,
      documentsLimit: json['documentsLimit'] as int? ?? 10,
      contactsLimit: json['contactsLimit'] as int? ?? 10,
      costItemsLimit: json['costItemsLimit'] as int? ?? 5,
      householdMembersLimit: json['householdMembersLimit'] as int? ?? 2,
      proofCasesLimit: json['proofCasesLimit'] as int? ?? 2,
      utilityComparisonLimit: json['utilityComparisonLimit'] as int? ?? 3,
      billAnalysisLimit: json['billAnalysisLimit'] as int? ?? 3,
      enabledPremiumProcedureIds:
          ((json['enabledPremiumProcedureIds'] as List?) ?? []).cast<String>(),
      lockedProcedureIds: ((json['lockedProcedureIds'] as List?) ?? [])
          .cast<String>(),
      provider: json['provider'] as String?,
      providerCustomerId: json['providerCustomerId'] as String?,
      providerSubscriptionId: json['providerSubscriptionId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      localDebugProEnabled: json['localDebugProEnabled'] as bool? ?? false,
    );
  }
}
