enum RedFlagType {
  legalDispute,
  eviction,
  immigrationDeadline,
  medicalEmergency,
  unpaidLargeDebt,
  disconnectionRisk,
  falseDeclarationRisk,
  courtNotice,
  taxPenalty,
  aggressiveWording,
  missingRecipient,
  expiredDeadline,
}

class RedFlag {
  const RedFlag({
    required this.type,
    required this.message,
    required this.severity,
  });

  final RedFlagType type;
  final String message;
  final int severity;
}
