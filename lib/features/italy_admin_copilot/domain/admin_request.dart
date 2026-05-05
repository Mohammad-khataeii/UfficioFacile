import 'generated_pack.dart';
import 'reminder.dart';
import 'request_status.dart';

class AdminCopilotRequest {
  const AdminCopilotRequest({
    required this.id,
    this.userId,
    this.anonymousSessionId,
    required this.procedureId,
    required this.procedureTitle,
    required this.category,
    required this.status,
    required this.priority,
    required this.inputData,
    required this.generatedPack,
    this.recipientName,
    this.recipientEmail,
    this.recipientPec,
    required this.subject,
    this.deadlineDate,
    this.sentAt,
    this.repliedAt,
    this.completedAt,
    this.lastCopiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.statusEvents = const [],
    this.reminders = const [],
  });

  final String id;
  final String? userId;
  final String? anonymousSessionId;
  final String procedureId;
  final String procedureTitle;
  final String category;
  final RequestStatus status;
  final RequestPriority priority;
  final Map<String, dynamic> inputData;
  final GeneratedPack generatedPack;
  final String? recipientName;
  final String? recipientEmail;
  final String? recipientPec;
  final String subject;
  final DateTime? deadlineDate;
  final DateTime? sentAt;
  final DateTime? repliedAt;
  final DateTime? completedAt;
  final DateTime? lastCopiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final List<StatusEvent> statusEvents;
  final List<Reminder> reminders;

  AdminCopilotRequest copyWith({
    String? id,
    String? userId,
    String? anonymousSessionId,
    String? procedureId,
    String? procedureTitle,
    String? category,
    RequestStatus? status,
    RequestPriority? priority,
    Map<String, dynamic>? inputData,
    GeneratedPack? generatedPack,
    String? recipientName,
    String? recipientEmail,
    String? recipientPec,
    String? subject,
    DateTime? deadlineDate,
    DateTime? sentAt,
    DateTime? repliedAt,
    DateTime? completedAt,
    DateTime? lastCopiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<StatusEvent>? statusEvents,
    List<Reminder>? reminders,
  }) {
    return AdminCopilotRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      anonymousSessionId: anonymousSessionId ?? this.anonymousSessionId,
      procedureId: procedureId ?? this.procedureId,
      procedureTitle: procedureTitle ?? this.procedureTitle,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      inputData: inputData ?? this.inputData,
      generatedPack: generatedPack ?? this.generatedPack,
      recipientName: recipientName ?? this.recipientName,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientPec: recipientPec ?? this.recipientPec,
      subject: subject ?? this.subject,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      sentAt: sentAt ?? this.sentAt,
      repliedAt: repliedAt ?? this.repliedAt,
      completedAt: completedAt ?? this.completedAt,
      lastCopiedAt: lastCopiedAt ?? this.lastCopiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      statusEvents: statusEvents ?? this.statusEvents,
      reminders: reminders ?? this.reminders,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'anonymousSessionId': anonymousSessionId,
    'procedureId': procedureId,
    'procedureTitle': procedureTitle,
    'category': category,
    'status': status.name,
    'priority': priority.name,
    'inputData': inputData,
    'generatedPack': generatedPack.toJson(),
    'recipientName': recipientName,
    'recipientEmail': recipientEmail,
    'recipientPec': recipientPec,
    'subject': subject,
    'deadlineDate': deadlineDate?.toIso8601String(),
    'sentAt': sentAt?.toIso8601String(),
    'repliedAt': repliedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'lastCopiedAt': lastCopiedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'notes': notes,
    'statusEvents': statusEvents.map((item) => item.toJson()).toList(),
    'reminders': reminders.map((item) => item.toJson()).toList(),
  };

  factory AdminCopilotRequest.fromJson(
    Map<String, dynamic> json,
  ) => AdminCopilotRequest(
    id: json['id'] as String? ?? '',
    userId: json['userId'] as String?,
    anonymousSessionId: json['anonymousSessionId'] as String?,
    procedureId: json['procedureId'] as String? ?? '',
    procedureTitle: json['procedureTitle'] as String? ?? '',
    category: json['category'] as String? ?? '',
    status: requestStatusFromJson(json['status'] as String?),
    priority: requestPriorityFromJson(json['priority'] as String?),
    inputData: Map<String, dynamic>.from(
      (json['inputData'] as Map?) ?? <String, dynamic>{},
    ),
    generatedPack: GeneratedPack.fromJson(
      Map<String, dynamic>.from(
        (json['generatedPack'] as Map?) ?? <String, dynamic>{},
      ),
    ),
    recipientName: json['recipientName'] as String?,
    recipientEmail: json['recipientEmail'] as String?,
    recipientPec: json['recipientPec'] as String?,
    subject: json['subject'] as String? ?? '',
    deadlineDate: DateTime.tryParse(json['deadlineDate'] as String? ?? ''),
    sentAt: DateTime.tryParse(json['sentAt'] as String? ?? ''),
    repliedAt: DateTime.tryParse(json['repliedAt'] as String? ?? ''),
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    lastCopiedAt: DateTime.tryParse(json['lastCopiedAt'] as String? ?? ''),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    notes: json['notes'] as String?,
    statusEvents: ((json['statusEvents'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => StatusEvent.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    reminders: ((json['reminders'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => Reminder.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
  );
}
