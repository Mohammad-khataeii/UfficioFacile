import 'utility_offer.dart';

enum UtilityRiskFlag {
  missingEstimatedAnnualCost,
  unclearPriceType,
  missingFixedFee,
  missingConsumption,
  canoneRaiIncluded,
  unclearContractDuration,
  unilateralChangesSuspected,
  unclearPaymentMethod,
  unclearResidentStatus,
  unclearActivationCost,
}

class UtilityComparisonInput {
  const UtilityComparisonInput({
    required this.utilityType,
    required this.currentProvider,
    this.currentOfferName,
    this.currentMonthlyCost,
    this.currentAnnualCost,
    this.currentConsumptionKwh,
    this.currentGasSmc,
    this.residentDomestic,
    this.currentPriceType,
    this.currentPowerKw,
    this.paymentMethod,
    this.hasCanoneRaiCharge,
    this.contractEndDate,
    this.noticedUnilateralChange,
    this.lastBillAmount,
    this.previousBillAmount,
    required this.offers,
  });

  final UtilityType utilityType;
  final String currentProvider;
  final String? currentOfferName;
  final double? currentMonthlyCost;
  final double? currentAnnualCost;
  final double? currentConsumptionKwh;
  final double? currentGasSmc;
  final bool? residentDomestic;
  final UtilityPriceType? currentPriceType;
  final double? currentPowerKw;
  final String? paymentMethod;
  final bool? hasCanoneRaiCharge;
  final DateTime? contractEndDate;
  final bool? noticedUnilateralChange;
  final double? lastBillAmount;
  final double? previousBillAmount;
  final List<UtilityOffer> offers;

  Map<String, dynamic> toJson() => {
    'utilityType': utilityType.name,
    'currentProvider': currentProvider,
    'currentOfferName': currentOfferName,
    'currentMonthlyCost': currentMonthlyCost,
    'currentAnnualCost': currentAnnualCost,
    'currentConsumptionKwh': currentConsumptionKwh,
    'currentGasSmc': currentGasSmc,
    'residentDomestic': residentDomestic,
    'currentPriceType': currentPriceType?.name,
    'currentPowerKw': currentPowerKw,
    'paymentMethod': paymentMethod,
    'hasCanoneRaiCharge': hasCanoneRaiCharge,
    'contractEndDate': contractEndDate?.toIso8601String(),
    'noticedUnilateralChange': noticedUnilateralChange,
    'lastBillAmount': lastBillAmount,
    'previousBillAmount': previousBillAmount,
    'offers': offers.map((item) => item.toJson()).toList(),
  };

  factory UtilityComparisonInput.fromJson(
    Map<String, dynamic> json,
  ) => UtilityComparisonInput(
    utilityType: utilityTypeFromJson(json['utilityType'] as String?),
    currentProvider: json['currentProvider'] as String? ?? '',
    currentOfferName: json['currentOfferName'] as String?,
    currentMonthlyCost: (json['currentMonthlyCost'] as num?)?.toDouble(),
    currentAnnualCost: (json['currentAnnualCost'] as num?)?.toDouble(),
    currentConsumptionKwh: (json['currentConsumptionKwh'] as num?)?.toDouble(),
    currentGasSmc: (json['currentGasSmc'] as num?)?.toDouble(),
    residentDomestic: json['residentDomestic'] as bool?,
    currentPriceType: utilityPriceTypeFromJson(
      json['currentPriceType'] as String?,
    ),
    currentPowerKw: (json['currentPowerKw'] as num?)?.toDouble(),
    paymentMethod: json['paymentMethod'] as String?,
    hasCanoneRaiCharge: json['hasCanoneRaiCharge'] as bool?,
    contractEndDate: DateTime.tryParse(
      json['contractEndDate'] as String? ?? '',
    ),
    noticedUnilateralChange: json['noticedUnilateralChange'] as bool?,
    lastBillAmount: (json['lastBillAmount'] as num?)?.toDouble(),
    previousBillAmount: (json['previousBillAmount'] as num?)?.toDouble(),
    offers: ((json['offers'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => UtilityOffer.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
  );
}

class UtilityComparisonResult {
  const UtilityComparisonResult({
    required this.bestOfferName,
    required this.estimatedAnnualSavings,
    required this.estimatedMonthlySavings,
    required this.riskFlags,
    required this.missingData,
    required this.checklistBeforeSwitching,
    required this.providerQuestions,
    required this.explanation,
    required this.disclaimer,
  });

  final String bestOfferName;
  final double estimatedAnnualSavings;
  final double estimatedMonthlySavings;
  final List<UtilityRiskFlag> riskFlags;
  final List<String> missingData;
  final List<String> checklistBeforeSwitching;
  final List<String> providerQuestions;
  final String explanation;
  final String disclaimer;

  Map<String, dynamic> toJson() => {
    'bestOfferName': bestOfferName,
    'estimatedAnnualSavings': estimatedAnnualSavings,
    'estimatedMonthlySavings': estimatedMonthlySavings,
    'riskFlags': riskFlags.map((item) => item.name).toList(),
    'missingData': missingData,
    'checklistBeforeSwitching': checklistBeforeSwitching,
    'providerQuestions': providerQuestions,
    'explanation': explanation,
    'disclaimer': disclaimer,
  };

  factory UtilityComparisonResult.fromJson(Map<String, dynamic> json) =>
      UtilityComparisonResult(
        bestOfferName: json['bestOfferName'] as String? ?? '',
        estimatedAnnualSavings:
            (json['estimatedAnnualSavings'] as num?)?.toDouble() ?? 0,
        estimatedMonthlySavings:
            (json['estimatedMonthlySavings'] as num?)?.toDouble() ?? 0,
        riskFlags: ((json['riskFlags'] as List?) ?? [])
            .cast<String>()
            .map(
              (item) => UtilityRiskFlag.values.firstWhere(
                (flag) => flag.name == item,
                orElse: () => UtilityRiskFlag.missingEstimatedAnnualCost,
              ),
            )
            .toList(),
        missingData: ((json['missingData'] as List?) ?? []).cast<String>(),
        checklistBeforeSwitching:
            ((json['checklistBeforeSwitching'] as List?) ?? []).cast<String>(),
        providerQuestions: ((json['providerQuestions'] as List?) ?? [])
            .cast<String>(),
        explanation: json['explanation'] as String? ?? '',
        disclaimer: json['disclaimer'] as String? ?? '',
      );
}
