enum UtilityType { electricity, gas, dual }

enum UtilityPriceType { fixed, variable, indexed, unknown }

UtilityType utilityTypeFromJson(String? value) {
  return UtilityType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UtilityType.electricity,
  );
}

UtilityPriceType utilityPriceTypeFromJson(String? value) {
  return UtilityPriceType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UtilityPriceType.unknown,
  );
}

class UtilityOffer {
  const UtilityOffer({
    required this.providerName,
    required this.offerName,
    required this.utilityType,
    required this.priceType,
    this.fixedMonthlyFee,
    this.energyPriceKwh,
    this.gasPriceSmc,
    this.spread,
    this.estimatedAnnualCost,
    this.contractDuration,
    this.paymentMethod,
    this.activationCost,
    this.greenEnergy,
    this.notes,
  });

  final String providerName;
  final String offerName;
  final UtilityType utilityType;
  final UtilityPriceType priceType;
  final double? fixedMonthlyFee;
  final double? energyPriceKwh;
  final double? gasPriceSmc;
  final double? spread;
  final double? estimatedAnnualCost;
  final String? contractDuration;
  final String? paymentMethod;
  final double? activationCost;
  final String? greenEnergy;
  final String? notes;

  Map<String, dynamic> toJson() => {
    'providerName': providerName,
    'offerName': offerName,
    'utilityType': utilityType.name,
    'priceType': priceType.name,
    'fixedMonthlyFee': fixedMonthlyFee,
    'energyPriceKwh': energyPriceKwh,
    'gasPriceSmc': gasPriceSmc,
    'spread': spread,
    'estimatedAnnualCost': estimatedAnnualCost,
    'contractDuration': contractDuration,
    'paymentMethod': paymentMethod,
    'activationCost': activationCost,
    'greenEnergy': greenEnergy,
    'notes': notes,
  };

  factory UtilityOffer.fromJson(Map<String, dynamic> json) => UtilityOffer(
    providerName: json['providerName'] as String? ?? '',
    offerName: json['offerName'] as String? ?? '',
    utilityType: utilityTypeFromJson(json['utilityType'] as String?),
    priceType: utilityPriceTypeFromJson(json['priceType'] as String?),
    fixedMonthlyFee: (json['fixedMonthlyFee'] as num?)?.toDouble(),
    energyPriceKwh: (json['energyPriceKwh'] as num?)?.toDouble(),
    gasPriceSmc: (json['gasPriceSmc'] as num?)?.toDouble(),
    spread: (json['spread'] as num?)?.toDouble(),
    estimatedAnnualCost: (json['estimatedAnnualCost'] as num?)?.toDouble(),
    contractDuration: json['contractDuration'] as String?,
    paymentMethod: json['paymentMethod'] as String?,
    activationCost: (json['activationCost'] as num?)?.toDouble(),
    greenEnergy: json['greenEnergy'] as String?,
    notes: json['notes'] as String?,
  );
}
