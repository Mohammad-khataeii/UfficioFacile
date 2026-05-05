class CanoneRaiDecisionInput {
  const CanoneRaiDecisionInput({
    this.billHolderName,
    this.codiceFiscale,
    this.billInOwnName,
    this.hasTv,
    this.otherHouseholdPays,
    this.requestType,
    this.year,
    this.alreadyPaid,
    this.hasOfficialAccess,
    this.needsDeadlineReminder,
  });

  final String? billHolderName;
  final String? codiceFiscale;
  final bool? billInOwnName;
  final bool? hasTv;
  final bool? otherHouseholdPays;
  final String? requestType;
  final String? year;
  final bool? alreadyPaid;
  final bool? hasOfficialAccess;
  final bool? needsDeadlineReminder;
}

class CanoneRaiDecisionResult {
  const CanoneRaiDecisionResult({
    required this.possiblePath,
    required this.requiredChecks,
    required this.documentsNeeded,
    required this.warnings,
    required this.officialReminder,
    required this.suggestedProcedureId,
  });

  final String possiblePath;
  final List<String> requiredChecks;
  final List<String> documentsNeeded;
  final List<String> warnings;
  final String officialReminder;
  final String suggestedProcedureId;
}
