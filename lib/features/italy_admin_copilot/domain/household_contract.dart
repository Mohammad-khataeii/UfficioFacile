enum HouseholdContractType {
  electricity,
  gas,
  internet,
  mobile,
  rent,
  insurance,
  subscriptions,
  other,
}

HouseholdContractType householdContractTypeFromJson(String? value) {
  return HouseholdContractType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => HouseholdContractType.other,
  );
}

class HouseholdContract {
  const HouseholdContract({
    required this.id,
    required this.type,
    required this.providerName,
    required this.contractName,
    this.monthlyCost,
    this.annualCost,
    this.startDate,
    this.endDate,
    this.renewalDate,
    this.cancellationNoticeDays,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final HouseholdContractType type;
  final String providerName;
  final String contractName;
  final double? monthlyCost;
  final double? annualCost;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? renewalDate;
  final int? cancellationNoticeDays;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'providerName': providerName,
    'contractName': contractName,
    'monthlyCost': monthlyCost,
    'annualCost': annualCost,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'renewalDate': renewalDate?.toIso8601String(),
    'cancellationNoticeDays': cancellationNoticeDays,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory HouseholdContract.fromJson(
    Map<String, dynamic> json,
  ) => HouseholdContract(
    id: json['id'] as String? ?? '',
    type: householdContractTypeFromJson(json['type'] as String?),
    providerName: json['providerName'] as String? ?? '',
    contractName: json['contractName'] as String? ?? '',
    monthlyCost: (json['monthlyCost'] as num?)?.toDouble(),
    annualCost: (json['annualCost'] as num?)?.toDouble(),
    startDate: DateTime.tryParse(json['startDate'] as String? ?? ''),
    endDate: DateTime.tryParse(json['endDate'] as String? ?? ''),
    renewalDate: DateTime.tryParse(json['renewalDate'] as String? ?? ''),
    cancellationNoticeDays: json['cancellationNoticeDays'] as int?,
    notes: json['notes'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
