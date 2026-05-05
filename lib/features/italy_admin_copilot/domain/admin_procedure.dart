import 'attachment_item.dart';
import 'procedure_field.dart';

enum ProcedureCategory {
  health,
  housing,
  work,
  publicOffice,
  university,
  immigration,
  utilities,
  canoneRai,
  telecom,
  complaint,
  general,
}

enum ProcedureDifficulty { easy, medium, high }

ProcedureCategory procedureCategoryFromJson(String? value) {
  return ProcedureCategory.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ProcedureCategory.general,
  );
}

ProcedureDifficulty procedureDifficultyFromJson(String? value) {
  return ProcedureDifficulty.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ProcedureDifficulty.medium,
  );
}

extension ProcedureCategoryX on ProcedureCategory {
  String get label {
    switch (this) {
      case ProcedureCategory.health:
        return 'Health';
      case ProcedureCategory.housing:
        return 'Housing';
      case ProcedureCategory.work:
        return 'Work';
      case ProcedureCategory.publicOffice:
        return 'Public office';
      case ProcedureCategory.university:
        return 'University';
      case ProcedureCategory.immigration:
        return 'Immigration';
      case ProcedureCategory.utilities:
        return 'Utilities';
      case ProcedureCategory.canoneRai:
        return 'Canone RAI';
      case ProcedureCategory.telecom:
        return 'Telecom';
      case ProcedureCategory.complaint:
        return 'Complaint';
      case ProcedureCategory.general:
        return 'General';
    }
  }
}

extension ProcedureDifficultyX on ProcedureDifficulty {
  String get label {
    switch (this) {
      case ProcedureDifficulty.easy:
        return 'Easy';
      case ProcedureDifficulty.medium:
        return 'Medium';
      case ProcedureDifficulty.high:
        return 'High';
    }
  }
}

class AdminProcedure {
  const AdminProcedure({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.shortDescription,
    required this.longDescription,
    required this.authorityType,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.targetRecipientExamples,
    required this.fields,
    required this.attachmentSuggestions,
    required this.tags,
    required this.isPremium,
    required this.disclaimer,
  });

  final String id;
  final String title;
  final ProcedureCategory category;
  final String subcategory;
  final String shortDescription;
  final String longDescription;
  final String authorityType;
  final ProcedureDifficulty difficulty;
  final int estimatedMinutes;
  final List<String> targetRecipientExamples;
  final List<ProcedureField> fields;
  final List<AttachmentSuggestion> attachmentSuggestions;
  final List<String> tags;
  final bool isPremium;
  final String disclaimer;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'subcategory': subcategory,
    'shortDescription': shortDescription,
    'longDescription': longDescription,
    'authorityType': authorityType,
    'difficulty': difficulty.name,
    'estimatedMinutes': estimatedMinutes,
    'targetRecipientExamples': targetRecipientExamples,
    'fields': fields.map((item) => item.toJson()).toList(),
    'attachmentSuggestions': attachmentSuggestions
        .map((item) => item.toJson())
        .toList(),
    'tags': tags,
    'isPremium': isPremium,
    'disclaimer': disclaimer,
  };

  factory AdminProcedure.fromJson(Map<String, dynamic> json) => AdminProcedure(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: procedureCategoryFromJson(json['category'] as String?),
    subcategory: json['subcategory'] as String? ?? '',
    shortDescription: json['shortDescription'] as String? ?? '',
    longDescription: json['longDescription'] as String? ?? '',
    authorityType: json['authorityType'] as String? ?? '',
    difficulty: procedureDifficultyFromJson(json['difficulty'] as String?),
    estimatedMinutes: json['estimatedMinutes'] as int? ?? 10,
    targetRecipientExamples: ((json['targetRecipientExamples'] as List?) ?? [])
        .cast<String>(),
    fields: ((json['fields'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => ProcedureField.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    attachmentSuggestions: ((json['attachmentSuggestions'] as List?) ?? [])
        .whereType<Map>()
        .map(
          (item) =>
              AttachmentSuggestion.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(),
    tags: ((json['tags'] as List?) ?? []).cast<String>(),
    isPremium: json['isPremium'] as bool? ?? false,
    disclaimer: json['disclaimer'] as String? ?? '',
  );
}
