class NextAction {
  const NextAction({
    required this.title,
    required this.description,
    required this.actionType,
    required this.relatedRoute,
    required this.priority,
  });

  final String title;
  final String description;
  final String actionType;
  final String relatedRoute;
  final int priority;
}
