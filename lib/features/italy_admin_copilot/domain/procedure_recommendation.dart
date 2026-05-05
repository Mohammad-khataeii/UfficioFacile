class ProcedureRecommendation {
  const ProcedureRecommendation({
    required this.procedureId,
    required this.confidence,
    required this.reason,
    required this.matchedKeywords,
    required this.category,
  });

  final String procedureId;
  final double confidence;
  final String reason;
  final List<String> matchedKeywords;
  final String category;
}
