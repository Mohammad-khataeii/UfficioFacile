enum CommunityTemplateStatus { draft, local, submitted, approved, rejected }

CommunityTemplateStatus communityTemplateStatusFromJson(String? value) {
  return CommunityTemplateStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => CommunityTemplateStatus.local,
  );
}

class CommunityTemplate {
  const CommunityTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.language,
    required this.officialTextItalian,
    required this.explanationLocalized,
    required this.tags,
    required this.status,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String category;
  final String language;
  final String officialTextItalian;
  final Map<String, String> explanationLocalized;
  final List<String> tags;
  final CommunityTemplateStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'language': language,
    'officialTextItalian': officialTextItalian,
    'explanationLocalized': explanationLocalized,
    'tags': tags,
    'status': status.name,
    'createdBy': createdBy,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory CommunityTemplate.fromJson(
    Map<String, dynamic> json,
  ) => CommunityTemplate(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? '',
    language: json['language'] as String? ?? 'it',
    officialTextItalian: json['officialTextItalian'] as String? ?? '',
    explanationLocalized: Map<String, String>.from(
      (json['explanationLocalized'] as Map?) ?? <String, String>{},
    ),
    tags: ((json['tags'] as List?) ?? []).cast<String>(),
    status: communityTemplateStatusFromJson(json['status'] as String?),
    createdBy: json['createdBy'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
