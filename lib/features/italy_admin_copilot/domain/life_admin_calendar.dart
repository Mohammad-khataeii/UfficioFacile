enum LifeAdminCalendarType {
  reminder,
  documentExpiry,
  requestFollowUp,
  utilityRenewal,
  contractDeadline,
  canoneRai,
  appointment,
  custom,
}

enum CalendarPriority { low, normal, high, urgent }

LifeAdminCalendarType lifeAdminCalendarTypeFromJson(String? value) {
  return LifeAdminCalendarType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => LifeAdminCalendarType.custom,
  );
}

CalendarPriority calendarPriorityFromJson(String? value) {
  return CalendarPriority.values.firstWhere(
    (item) => item.name == value,
    orElse: () => CalendarPriority.normal,
  );
}

class LifeAdminCalendarItem {
  const LifeAdminCalendarItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.date,
    this.relatedRequestId,
    this.relatedDocumentId,
    required this.isDone,
    required this.priority,
  });

  final String id;
  final LifeAdminCalendarType type;
  final String title;
  final String description;
  final DateTime date;
  final String? relatedRequestId;
  final String? relatedDocumentId;
  final bool isDone;
  final CalendarPriority priority;
}
