class InsuranceSearchInput {
  const InsuranceSearchInput({
    required this.city,
    required this.region,
    required this.citizenshipGroup,
    required this.status,
    required this.durationMonths,
    required this.needsPermessoSupport,
    required this.needsEmergencyOnly,
    required this.needsGpAccess,
    required this.needsHospitalCoverage,
    required this.needsSpecialistCoverage,
    required this.needsMedicationCoverage,
    required this.languagePreference,
    required this.alreadyHasSsn,
    required this.hasResidenza,
    required this.hasDomicileInTorino,
    this.age,
    this.budgetMonthly,
  });

  final String city;
  final String region;
  final String citizenshipGroup;
  final String status;
  final int durationMonths;
  final bool needsPermessoSupport;
  final bool needsEmergencyOnly;
  final bool needsGpAccess;
  final bool needsHospitalCoverage;
  final bool needsSpecialistCoverage;
  final bool needsMedicationCoverage;
  final String languagePreference;
  final bool alreadyHasSsn;
  final bool hasResidenza;
  final bool hasDomicileInTorino;
  final int? age;
  final double? budgetMonthly;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'city': city,
    'region': region,
    'citizenshipGroup': citizenshipGroup,
    'status': status,
    'durationMonths': durationMonths,
    'needsPermessoSupport': needsPermessoSupport,
    'needsEmergencyOnly': needsEmergencyOnly,
    'needsGpAccess': needsGpAccess,
    'needsHospitalCoverage': needsHospitalCoverage,
    'needsSpecialistCoverage': needsSpecialistCoverage,
    'needsMedicationCoverage': needsMedicationCoverage,
    'languagePreference': languagePreference,
    'alreadyHasSsn': alreadyHasSsn,
    'hasResidenza': hasResidenza,
    'hasDomicileInTorino': hasDomicileInTorino,
    'age': age,
    'budgetMonthly': budgetMonthly,
  };
}

class InsuranceOffer {
  const InsuranceOffer({
    required this.providerName,
    required this.productName,
    required this.priceText,
    required this.coverageSummary,
    required this.coverageItems,
    required this.exclusions,
    required this.waitingPeriods,
    required this.deductible,
    required this.maxCoverageAmount,
    required this.suitableFor,
    required this.notSuitableFor,
    required this.adminUsefulness,
    required this.buyUrl,
    required this.policyUrl,
    required this.sourceUrl,
    required this.sourceOwner,
    required this.retrievedAt,
    required this.confidence,
    required this.warnings,
    required this.rankReason,
    this.monthlyPrice,
    this.annualPrice,
    this.currency = 'EUR',
  });

  final String providerName;
  final String productName;
  final double? monthlyPrice;
  final double? annualPrice;
  final String currency;
  final String priceText;
  final String coverageSummary;
  final List<String> coverageItems;
  final List<String> exclusions;
  final String waitingPeriods;
  final String deductible;
  final String maxCoverageAmount;
  final String suitableFor;
  final String notSuitableFor;
  final String adminUsefulness;
  final String buyUrl;
  final String policyUrl;
  final String sourceUrl;
  final String sourceOwner;
  final DateTime retrievedAt;
  final double confidence;
  final List<String> warnings;
  final String rankReason;

  factory InsuranceOffer.fromJson(Map<String, dynamic> json) => InsuranceOffer(
    providerName: json['providerName'] as String? ?? '',
    productName: json['productName'] as String? ?? '',
    monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble(),
    annualPrice: (json['annualPrice'] as num?)?.toDouble(),
    currency: json['currency'] as String? ?? 'EUR',
    priceText: json['priceText'] as String? ?? '',
    coverageSummary: json['coverageSummary'] as String? ?? '',
    coverageItems: ((json['coverageItems'] as List?) ?? const <dynamic>[])
        .cast<String>(),
    exclusions: ((json['exclusions'] as List?) ?? const <dynamic>[])
        .cast<String>(),
    waitingPeriods: json['waitingPeriods'] as String? ?? '',
    deductible: json['deductible'] as String? ?? '',
    maxCoverageAmount: json['maxCoverageAmount'] as String? ?? '',
    suitableFor: json['suitableFor'] as String? ?? '',
    notSuitableFor: json['notSuitableFor'] as String? ?? '',
    adminUsefulness: json['adminUsefulness'] as String? ?? '',
    buyUrl: json['buyUrl'] as String? ?? '',
    policyUrl: json['policyUrl'] as String? ?? '',
    sourceUrl: json['sourceUrl'] as String? ?? '',
    sourceOwner: json['sourceOwner'] as String? ?? '',
    retrievedAt:
        DateTime.tryParse(json['retrievedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    warnings: ((json['warnings'] as List?) ?? const <dynamic>[]).cast<String>(),
    rankReason: json['rankReason'] as String? ?? '',
  );
}

class InsuranceSearchResult {
  const InsuranceSearchResult({
    required this.ok,
    required this.liveAvailable,
    required this.offers,
    required this.warnings,
    required this.retrievedAt,
    this.unavailableReason = '',
    this.topRecommendedOffer,
    this.cheapestOffer,
    this.bestCoverageOffer,
    this.bestStudentFitOffer,
  });

  final bool ok;
  final bool liveAvailable;
  final List<InsuranceOffer> offers;
  final List<String> warnings;
  final DateTime retrievedAt;
  final String unavailableReason;
  final String? topRecommendedOffer;
  final String? cheapestOffer;
  final String? bestCoverageOffer;
  final String? bestStudentFitOffer;

  factory InsuranceSearchResult.fromJson(
    Map<String, dynamic> json,
  ) => InsuranceSearchResult(
    ok: json['ok'] as bool? ?? false,
    liveAvailable: json['liveAvailable'] as bool? ?? false,
    offers: ((json['offers'] as List?) ?? const <dynamic>[])
        .whereType<Map>()
        .map((item) => InsuranceOffer.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    warnings: ((json['warnings'] as List?) ?? const <dynamic>[]).cast<String>(),
    retrievedAt:
        DateTime.tryParse(json['retrievedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    unavailableReason: json['unavailableReason'] as String? ?? '',
    topRecommendedOffer: json['topRecommendedOffer'] as String?,
    cheapestOffer: json['cheapestOffer'] as String?,
    bestCoverageOffer: json['bestCoverageOffer'] as String?,
    bestStudentFitOffer: json['bestStudentFitOffer'] as String?,
  );
}
