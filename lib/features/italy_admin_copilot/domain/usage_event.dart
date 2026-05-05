class UsageEvent {
  const UsageEvent({
    required this.id,
    required this.eventName,
    required this.createdAt,
    this.procedureId,
    this.category,
    this.metadata = const {},
  });

  final String id;
  final String eventName;
  final DateTime createdAt;
  final String? procedureId;
  final String? category;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
    'id': id,
    'eventName': eventName,
    'createdAt': createdAt.toIso8601String(),
    'procedureId': procedureId,
    'category': category,
    'metadata': metadata,
  };

  factory UsageEvent.fromJson(Map<String, dynamic> json) => UsageEvent(
    id: json['id'] as String? ?? '',
    eventName: json['eventName'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    procedureId: json['procedureId'] as String?,
    category: json['category'] as String?,
    metadata: Map<String, dynamic>.from(
      (json['metadata'] as Map?) ?? <String, dynamic>{},
    ),
  );
}
