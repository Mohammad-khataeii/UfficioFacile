enum LifeChecklistStatus { notStarted, inProgress, done, notApplicable }

LifeChecklistStatus lifeChecklistStatusFromJson(String? value) {
  return LifeChecklistStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => LifeChecklistStatus.notStarted,
  );
}

class LifeChecklistItem {
  const LifeChecklistItem({
    required this.id,
    required this.category,
    required this.title,
    required this.descriptionLocalized,
    required this.status,
    required this.relatedProcedureIds,
    required this.relatedDocumentTypes,
    this.reminderDate,
    this.notes,
    required this.priority,
  });

  final String id;
  final String category;
  final String title;
  final Map<String, String> descriptionLocalized;
  final LifeChecklistStatus status;
  final List<String> relatedProcedureIds;
  final List<String> relatedDocumentTypes;
  final DateTime? reminderDate;
  final String? notes;
  final int priority;

  LifeChecklistItem copyWith({
    LifeChecklistStatus? status,
    DateTime? reminderDate,
    String? notes,
  }) {
    return LifeChecklistItem(
      id: id,
      category: category,
      title: title,
      descriptionLocalized: descriptionLocalized,
      status: status ?? this.status,
      relatedProcedureIds: relatedProcedureIds,
      relatedDocumentTypes: relatedDocumentTypes,
      reminderDate: reminderDate ?? this.reminderDate,
      notes: notes ?? this.notes,
      priority: priority,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'title': title,
    'descriptionLocalized': descriptionLocalized,
    'status': status.name,
    'relatedProcedureIds': relatedProcedureIds,
    'relatedDocumentTypes': relatedDocumentTypes,
    'reminderDate': reminderDate?.toIso8601String(),
    'notes': notes,
    'priority': priority,
  };

  factory LifeChecklistItem.fromJson(Map<String, dynamic> json) =>
      LifeChecklistItem(
        id: json['id'] as String? ?? '',
        category: json['category'] as String? ?? '',
        title: json['title'] as String? ?? '',
        descriptionLocalized: Map<String, String>.from(
          (json['descriptionLocalized'] as Map?) ?? <String, String>{},
        ),
        status: lifeChecklistStatusFromJson(json['status'] as String?),
        relatedProcedureIds: ((json['relatedProcedureIds'] as List?) ?? [])
            .cast<String>(),
        relatedDocumentTypes: ((json['relatedDocumentTypes'] as List?) ?? [])
            .cast<String>(),
        reminderDate: DateTime.tryParse(json['reminderDate'] as String? ?? ''),
        notes: json['notes'] as String?,
        priority: json['priority'] as int? ?? 1,
      );
}
