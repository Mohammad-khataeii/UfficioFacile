class SituationDetectedCategory {
  const SituationDetectedCategory({
    required this.id,
    required this.localizedName,
  });

  final String id;
  final String localizedName;
}

class SituationDetectedRisk {
  const SituationDetectedRisk({
    required this.id,
    required this.localizedMessage,
    required this.severity,
  });

  final String id;
  final String localizedMessage;
  final int severity;
}

class SituationScanResult {
  const SituationScanResult({
    required this.detectedCategories,
    required this.recommendedProcedures,
    required this.detectedRisks,
    required this.suggestedDocuments,
    required this.suggestedDeadlines,
    required this.suggestedNextActions,
    required this.suggestedContacts,
    required this.explanationLocalized,
    required this.confidence,
    required this.requiresProfessionalAdvice,
    this.safetyWarning,
  });

  final List<SituationDetectedCategory> detectedCategories;
  final List<String> recommendedProcedures;
  final List<SituationDetectedRisk> detectedRisks;
  final List<String> suggestedDocuments;
  final List<String> suggestedDeadlines;
  final List<String> suggestedNextActions;
  final List<String> suggestedContacts;
  final String explanationLocalized;
  final double confidence;
  final bool requiresProfessionalAdvice;
  final String? safetyWarning;
}
