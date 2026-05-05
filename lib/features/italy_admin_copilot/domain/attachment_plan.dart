class AttachmentRequirement {
  const AttachmentRequirement({
    required this.title,
    required this.description,
    required this.required,
  });

  final String title;
  final String description;
  final bool required;
}

class AttachmentPlan {
  const AttachmentPlan({
    required this.requiredAttachments,
    required this.recommendedAttachments,
    required this.optionalAttachments,
    required this.proofItems,
    required this.missingCriticalItems,
    required this.readinessScore,
    required this.warnings,
    required this.nextSteps,
  });

  final List<AttachmentRequirement> requiredAttachments;
  final List<AttachmentRequirement> recommendedAttachments;
  final List<AttachmentRequirement> optionalAttachments;
  final List<String> proofItems;
  final List<String> missingCriticalItems;
  final int readinessScore;
  final List<String> warnings;
  final List<String> nextSteps;
}
