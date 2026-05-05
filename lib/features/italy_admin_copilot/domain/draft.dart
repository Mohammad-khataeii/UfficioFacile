class DraftEntry {
  const DraftEntry({
    required this.id,
    required this.procedureId,
    required this.inputData,
    required this.updatedAt,
  });

  final String id;
  final String procedureId;
  final Map<String, dynamic> inputData;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'procedureId': procedureId,
    'inputData': inputData,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DraftEntry.fromJson(Map<String, dynamic> json) => DraftEntry(
    id: json['id'] as String? ?? '',
    procedureId: json['procedureId'] as String? ?? '',
    inputData: Map<String, dynamic>.from(
      (json['inputData'] as Map?) ?? <String, dynamic>{},
    ),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
