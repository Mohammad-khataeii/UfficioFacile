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
    this.lastVerifiedAt,
    required this.verificationStatus,
    required this.warningLocalized,
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
  final DateTime? lastVerifiedAt;
  final OfficialLinkVerificationStatus verificationStatus;
  final Map<String, String> warningLocalized;

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
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'verificationStatus': verificationStatus.name,
    'warningLocalized': warningLocalized,
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
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    verificationStatus: officialLinkVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    warningLocalized: Map<String, String>.from(
      (json['warningLocalized'] as Map?) ?? <String, String>{},
    ),
  );
}
