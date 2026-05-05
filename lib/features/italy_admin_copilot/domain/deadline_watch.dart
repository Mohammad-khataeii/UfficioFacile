enum DeadlineDateType { fixed, relative, userDefined, recurring }

DeadlineDateType deadlineDateTypeFromJson(String? value) {
  return DeadlineDateType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => DeadlineDateType.userDefined,
  );
}

class DeadlineRule {
  const DeadlineRule({
    required this.id,
    required this.title,
    required this.category,
    required this.descriptionLocalized,
    required this.dateType,
    this.defaultDate,
    this.recurrence,
    required this.relatedProcedureIds,
    required this.warningLocalized,
    required this.officialVerificationRequired,
  });

  final String id;
  final String title;
  final String category;
  final Map<String, String> descriptionLocalized;
  final DeadlineDateType dateType;
  final DateTime? defaultDate;
  final String? recurrence;
  final List<String> relatedProcedureIds;
  final Map<String, String> warningLocalized;
  final bool officialVerificationRequired;
}

class UserDeadline {
  const UserDeadline({
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    this.relatedRequestId,
    this.relatedDocumentId,
    this.relatedContractId,
    required this.isDone,
  });

  final String id;
  final String title;
  final DateTime date;
  final String category;
  final String? relatedRequestId;
  final String? relatedDocumentId;
  final String? relatedContractId;
  final bool isDone;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'category': category,
    'relatedRequestId': relatedRequestId,
    'relatedDocumentId': relatedDocumentId,
    'relatedContractId': relatedContractId,
    'isDone': isDone,
  };

  factory UserDeadline.fromJson(Map<String, dynamic> json) => UserDeadline(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    category: json['category'] as String? ?? '',
    relatedRequestId: json['relatedRequestId'] as String?,
    relatedDocumentId: json['relatedDocumentId'] as String?,
    relatedContractId: json['relatedContractId'] as String?,
    isDone: json['isDone'] as bool? ?? false,
  );
}
