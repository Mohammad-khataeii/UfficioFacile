enum PecRequiredLevel {
  notUsuallyNeeded,
  recommended,
  oftenRequired,
  requiredForPecSubmission,
  unknown,
}

enum SpidCieRequiredLevel {
  notNeeded,
  useful,
  oftenRequiredOnline,
  requiredOnline,
  unknown,
}

enum ServiceVerificationStatus { verified, needsReview, unverified }

enum OfficialContactType {
  email,
  pec,
  phone,
  address,
  portal,
  website,
  officeFinder,
}

enum DocumentRequiredLevel { required, recommended, conditional, optional }

class OfficialContactOption {
  const OfficialContactOption({
    required this.id,
    required this.label,
    required this.type,
    required this.value,
    required this.displayValue,
    required this.description,
    this.city,
    this.region,
    this.provider,
    this.sourceLabel,
    this.sourceUrl,
    required this.verificationStatus,
    this.lastVerifiedAt,
    required this.warning,
  });

  final String id;
  final String label;
  final OfficialContactType type;
  final String value;
  final String displayValue;
  final String description;
  final String? city;
  final String? region;
  final String? provider;
  final String? sourceLabel;
  final String? sourceUrl;
  final ServiceVerificationStatus verificationStatus;
  final DateTime? lastVerifiedAt;
  final String warning;
}

class InPersonOption {
  const InPersonOption({
    required this.id,
    required this.title,
    required this.description,
    this.address,
    this.city,
    this.region,
    this.openingHours,
    this.appointmentRequired,
    this.bookingLink,
    this.officeFinderLink,
    required this.documentsToBring,
    required this.verificationStatus,
    required this.warning,
  });

  final String id;
  final String title;
  final String description;
  final String? address;
  final String? city;
  final String? region;
  final String? openingHours;
  final bool? appointmentRequired;
  final String? bookingLink;
  final String? officeFinderLink;
  final List<String> documentsToBring;
  final ServiceVerificationStatus verificationStatus;
  final String warning;
}

class OnlineOption {
  const OnlineOption({
    required this.id,
    required this.title,
    required this.description,
    this.url,
    required this.requiresSpid,
    required this.requiresCie,
    required this.requiresPec,
    this.region,
    this.city,
    required this.verificationStatus,
    required this.warning,
  });

  final String id;
  final String title;
  final String description;
  final String? url;
  final bool requiresSpid;
  final bool requiresCie;
  final bool requiresPec;
  final String? region;
  final String? city;
  final ServiceVerificationStatus verificationStatus;
  final String warning;
}

class DocumentRequirementDetailed {
  const DocumentRequirementDetailed({
    required this.id,
    required this.name,
    required this.requiredLevel,
    required this.description,
    required this.whenNeeded,
    required this.examples,
    this.relatedDocumentType,
    required this.canUseCopy,
    this.warning,
  });

  final String id;
  final String name;
  final DocumentRequiredLevel requiredLevel;
  final String description;
  final String whenNeeded;
  final List<String> examples;
  final String? relatedDocumentType;
  final bool canUseCopy;
  final String? warning;
}

class ServiceTermExplanation {
  const ServiceTermExplanation({
    required this.id,
    required this.term,
    required this.shortDefinition,
    required this.longExplanation,
    required this.relatedLinks,
    required this.providers,
    required this.warnings,
    this.relatedProcedures = const [],
  });

  final String id;
  final String term;
  final String shortDefinition;
  final String longExplanation;
  final List<String> relatedLinks;
  final List<String> providers;
  final List<String> warnings;
  final List<String> relatedProcedures;
}

class ServiceIntelligence {
  const ServiceIntelligence({
    required this.procedureId,
    required this.title,
    required this.category,
    required this.responsibleAuthorityType,
    required this.destinationGuidance,
    required this.recipientRules,
    required this.officialContactOptions,
    required this.officialLinks,
    required this.inPersonOptions,
    required this.onlineOptions,
    required this.pecRequiredLevel,
    required this.spidCieRequiredLevel,
    required this.requiredDocumentsDetailed,
    required this.recommendedDocumentsDetailed,
    required this.situationSpecificDocuments,
    required this.beforeSendingChecklist,
    required this.inPersonChecklist,
    required this.followUpGuidance,
    required this.rejectionGuidance,
    required this.escalationGuidance,
    required this.citySpecificNotes,
    required this.regionSpecificNotes,
    required this.providerSpecificNotes,
    required this.warnings,
    required this.verificationStatus,
    this.lastReviewedAt,
    this.adminNotes,
  });

  final String procedureId;
  final String title;
  final String category;
  final String responsibleAuthorityType;
  final String destinationGuidance;
  final List<String> recipientRules;
  final List<OfficialContactOption> officialContactOptions;
  final List<String> officialLinks;
  final List<InPersonOption> inPersonOptions;
  final List<OnlineOption> onlineOptions;
  final PecRequiredLevel pecRequiredLevel;
  final SpidCieRequiredLevel spidCieRequiredLevel;
  final List<DocumentRequirementDetailed> requiredDocumentsDetailed;
  final List<DocumentRequirementDetailed> recommendedDocumentsDetailed;
  final List<DocumentRequirementDetailed> situationSpecificDocuments;
  final List<String> beforeSendingChecklist;
  final List<String> inPersonChecklist;
  final String followUpGuidance;
  final String rejectionGuidance;
  final String escalationGuidance;
  final List<String> citySpecificNotes;
  final List<String> regionSpecificNotes;
  final List<String> providerSpecificNotes;
  final List<String> warnings;
  final ServiceVerificationStatus verificationStatus;
  final DateTime? lastReviewedAt;
  final String? adminNotes;
}

class ServiceIntelligenceQualityResult {
  const ServiceIntelligenceQualityResult({
    required this.procedureId,
    required this.warnings,
  });

  final String procedureId;
  final List<String> warnings;

  bool get ok => warnings.isEmpty;
}
