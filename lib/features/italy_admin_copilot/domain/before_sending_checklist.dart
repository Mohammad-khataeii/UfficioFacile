class BeforeSendingChecklist {
  const BeforeSendingChecklist({
    required this.requestId,
    required this.personalDataChecked,
    required this.recipientVerified,
    required this.attachmentsReady,
    required this.placeholdersRemoved,
    required this.statementTruthful,
    required this.officialRulesVerified,
    required this.proofSaved,
    required this.skipFuturePrompt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String requestId;
  final bool personalDataChecked;
  final bool recipientVerified;
  final bool attachmentsReady;
  final bool placeholdersRemoved;
  final bool statementTruthful;
  final bool officialRulesVerified;
  final bool proofSaved;
  final bool skipFuturePrompt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get canMarkSent =>
      personalDataChecked &&
      recipientVerified &&
      attachmentsReady &&
      placeholdersRemoved &&
      statementTruthful;

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'personalDataChecked': personalDataChecked,
    'recipientVerified': recipientVerified,
    'attachmentsReady': attachmentsReady,
    'placeholdersRemoved': placeholdersRemoved,
    'statementTruthful': statementTruthful,
    'officialRulesVerified': officialRulesVerified,
    'proofSaved': proofSaved,
    'skipFuturePrompt': skipFuturePrompt,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory BeforeSendingChecklist.fromJson(
    Map<String, dynamic> json,
  ) => BeforeSendingChecklist(
    requestId: json['requestId'] as String? ?? '',
    personalDataChecked: json['personalDataChecked'] as bool? ?? false,
    recipientVerified: json['recipientVerified'] as bool? ?? false,
    attachmentsReady: json['attachmentsReady'] as bool? ?? false,
    placeholdersRemoved: json['placeholdersRemoved'] as bool? ?? false,
    statementTruthful: json['statementTruthful'] as bool? ?? false,
    officialRulesVerified: json['officialRulesVerified'] as bool? ?? false,
    proofSaved: json['proofSaved'] as bool? ?? false,
    skipFuturePrompt: json['skipFuturePrompt'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
