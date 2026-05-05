enum RequestStatus {
  draft,
  generated,
  sent,
  followUpNeeded,
  replied,
  rejected,
  completed,
  archived,
}

enum RequestPriority { low, normal, high, urgent }

enum ReminderType { followUp, deadline, appointment, renewal, custom }

RequestStatus requestStatusFromJson(String? value) {
  return RequestStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => RequestStatus.draft,
  );
}

RequestPriority requestPriorityFromJson(String? value) {
  return RequestPriority.values.firstWhere(
    (item) => item.name == value,
    orElse: () => RequestPriority.normal,
  );
}

ReminderType reminderTypeFromJson(String? value) {
  return ReminderType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ReminderType.followUp,
  );
}

class StatusEvent {
  const StatusEvent({
    required this.id,
    required this.requestId,
    this.oldStatus,
    required this.newStatus,
    this.note,
    required this.createdAt,
  });

  final String id;
  final String requestId;
  final RequestStatus? oldStatus;
  final RequestStatus newStatus;
  final String? note;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestId': requestId,
    'oldStatus': oldStatus?.name,
    'newStatus': newStatus.name,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StatusEvent.fromJson(Map<String, dynamic> json) => StatusEvent(
    id: json['id'] as String? ?? '',
    requestId: json['requestId'] as String? ?? '',
    oldStatus: json['oldStatus'] == null
        ? null
        : requestStatusFromJson(json['oldStatus'] as String?),
    newStatus: requestStatusFromJson(json['newStatus'] as String?),
    note: json['note'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}
