import 'admin_procedure.dart';

class ProcedureTemplateOverride {
  const ProcedureTemplateOverride({
    required this.procedureId,
    this.title,
    this.shortDescription,
    this.longDescription,
    this.tags,
    this.estimatedMinutes,
    this.difficulty,
    this.isActive,
    this.isPremium,
  });

  final String procedureId;
  final String? title;
  final String? shortDescription;
  final String? longDescription;
  final List<String>? tags;
  final int? estimatedMinutes;
  final ProcedureDifficulty? difficulty;
  final bool? isActive;
  final bool? isPremium;

  Map<String, dynamic> toJson() => {
    'procedureId': procedureId,
    'title': title,
    'shortDescription': shortDescription,
    'longDescription': longDescription,
    'tags': tags,
    'estimatedMinutes': estimatedMinutes,
    'difficulty': difficulty?.name,
    'isActive': isActive,
    'isPremium': isPremium,
  };

  factory ProcedureTemplateOverride.fromJson(Map<String, dynamic> json) =>
      ProcedureTemplateOverride(
        procedureId: json['procedureId'] as String? ?? '',
        title: json['title'] as String?,
        shortDescription: json['shortDescription'] as String?,
        longDescription: json['longDescription'] as String?,
        tags: (json['tags'] as List?)?.cast<String>(),
        estimatedMinutes: json['estimatedMinutes'] as int?,
        difficulty: json['difficulty'] == null
            ? null
            : procedureDifficultyFromJson(json['difficulty'] as String?),
        isActive: json['isActive'] as bool?,
        isPremium: json['isPremium'] as bool?,
      );
}
