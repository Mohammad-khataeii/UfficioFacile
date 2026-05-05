class TelegramHandoffPayload {
  const TelegramHandoffPayload({
    required this.procedureId,
    required this.title,
    required this.summary,
    required this.language,
    required this.suggestedInput,
    required this.createdAt,
  });

  final String procedureId;
  final String title;
  final String summary;
  final String language;
  final String suggestedInput;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'procedureId': procedureId,
    'title': title,
    'summary': summary,
    'language': language,
    'suggestedInput': suggestedInput,
    'createdAt': createdAt.toIso8601String(),
  };

  factory TelegramHandoffPayload.fromJson(Map<String, dynamic> json) =>
      TelegramHandoffPayload(
        procedureId: json['procedureId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        language: json['language'] as String? ?? 'en',
        suggestedInput: json['suggestedInput'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
