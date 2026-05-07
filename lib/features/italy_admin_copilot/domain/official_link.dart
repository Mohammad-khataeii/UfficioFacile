enum OfficialLinkVerificationStatus { unverified, needsReview, verified }

OfficialLinkVerificationStatus officialLinkVerificationStatusFromJson(
  String? value,
) {
  return OfficialLinkVerificationStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => OfficialLinkVerificationStatus.unverified,
  );
}

class OfficialLink {
  const OfficialLink({
    required this.id,
    required this.title,
    required this.category,
    required this.descriptionLocalized,
    required this.url,
    required this.country,
    this.region,
    this.city,
    required this.relatedProcedureIds,
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    required this.verificationStatus,
    required this.warningLocalized,
    this.notes = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String category;
  final Map<String, String> descriptionLocalized;
  final String url;
  final String country;
  final String? region;
  final String? city;
  final List<String> relatedProcedureIds;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final OfficialLinkVerificationStatus verificationStatus;
  final Map<String, String> warningLocalized;
  final Map<String, dynamic> notes;

  bool get isVerified =>
      verificationStatus == OfficialLinkVerificationStatus.verified;

  String localizedWarning(String languageCode) =>
      warningLocalized[languageCode] ??
      warningLocalized['en'] ??
      'Verify that this is the correct official page before submitting personal data.';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'descriptionLocalized': descriptionLocalized,
    'url': url,
    'country': country,
    'region': region,
    'city': city,
    'relatedProcedureIds': relatedProcedureIds,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'verificationStatus': verificationStatus.name,
    'warningLocalized': warningLocalized,
    'notes': notes,
  };

  factory OfficialLink.fromJson(Map<String, dynamic> json) => OfficialLink(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? '',
    descriptionLocalized: Map<String, String>.from(
      (json['descriptionLocalized'] as Map?) ?? <String, String>{},
    ),
    url: json['url'] as String? ?? '',
    country: json['country'] as String? ?? 'Italy',
    region: json['region'] as String?,
    city: json['city'] as String?,
    relatedProcedureIds: ((json['relatedProcedureIds'] as List?) ?? [])
        .cast<String>(),
    sourceUrl: json['sourceUrl'] as String?,
    sourceLabel: json['sourceLabel'] as String?,
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    verificationStatus: officialLinkVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    warningLocalized: Map<String, String>.from(
      (json['warningLocalized'] as Map?) ?? <String, String>{},
    ),
    notes: Map<String, dynamic>.from(
      (json['notes'] as Map?) ?? const <String, dynamic>{},
    ),
  );

  factory OfficialLink.fromSupabaseJson(Map<String, dynamic> json) =>
      OfficialLink(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? '',
        descriptionLocalized: Map<String, String>.from(
          (json['description'] as Map?) ?? <String, String>{},
        ),
        url: json['url'] as String? ?? '',
        country: json['country'] as String? ?? 'Italy',
        region: json['region'] as String?,
        city: json['city'] as String?,
        relatedProcedureIds: ((json['procedure_ids'] as List?) ?? [])
            .map((item) => item.toString())
            .toList(),
        sourceUrl: json['source_url'] as String?,
        sourceLabel: json['source_label'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['last_verified_at'] as String? ?? '',
        ),
        verificationStatus: officialLinkVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        warningLocalized: Map<String, String>.from(
          (json['warning'] as Map?) ?? <String, String>{},
        ),
        notes: Map<String, dynamic>.from(
          (json['notes'] as Map?) ?? const <String, dynamic>{},
        ),
      );
}
