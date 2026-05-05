import 'request_status.dart';

class Reminder {
  const Reminder({
    required this.id,
    required this.requestId,
    required this.title,
    required this.reminderDate,
    required this.type,
    required this.isDone,
    required this.createdAt,
  });

  final String id;
  final String requestId;
  final String title;
  final DateTime reminderDate;
  final ReminderType type;
  final bool isDone;
  final DateTime createdAt;

  Reminder copyWith({
    String? id,
    String? requestId,
    String? title,
    DateTime? reminderDate,
    ReminderType? type,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      title: title ?? this.title,
      reminderDate: reminderDate ?? this.reminderDate,
      type: type ?? this.type,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestId': requestId,
    'title': title,
    'reminderDate': reminderDate.toIso8601String(),
    'type': type.name,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as String? ?? '',
    requestId: json['requestId'] as String? ?? '',
    title: json['title'] as String? ?? '',
    reminderDate:
        DateTime.tryParse(json['reminderDate'] as String? ?? '') ??
        DateTime.now(),
    type: reminderTypeFromJson(json['type'] as String?),
    isDone: json['isDone'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
