enum RequestReadinessLevel { low, medium, high, ready }

class RequestReadiness {
  const RequestReadiness({
    required this.score,
    required this.level,
    required this.missingRequiredFields,
    required this.missingRecommendedAttachments,
    required this.warnings,
    required this.nextBestAction,
  });

  final int score;
  final RequestReadinessLevel level;
  final List<String> missingRequiredFields;
  final List<String> missingRecommendedAttachments;
  final List<String> warnings;
  final String nextBestAction;
}
