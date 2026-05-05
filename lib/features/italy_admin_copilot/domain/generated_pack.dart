import 'attachment_item.dart';
import 'request_status.dart';

class GeneratedPack {
  const GeneratedPack({
    required this.id,
    required this.procedureId,
    required this.procedureTitle,
    required this.category,
    required this.status,
    required this.priority,
    required this.inputData,
    required this.subject,
    required this.bodyItalian,
    required this.bodyPecItalian,
    required this.shortMessageItalian,
    required this.whatsappMessageItalian,
    required this.whatsappFollowUpItalian,
    required this.whatsappStrongFollowUpItalian,
    required this.ultraShortSummaryItalian,
    required this.followUpItalian,
    required this.strongFollowUpItalian,
    this.rejectedReplyItalian,
    required this.userExplanationEnglish,
    required this.localizedExplanations,
    required this.attachmentChecklist,
    required this.nextSteps,
    required this.warnings,
    required this.deadlineSuggestions,
    required this.fullText,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String procedureId;
  final String procedureTitle;
  final String category;
  final RequestStatus status;
  final RequestPriority priority;
  final Map<String, dynamic> inputData;
  final String subject;
  final String bodyItalian;
  final String bodyPecItalian;
  final String shortMessageItalian;
  final String whatsappMessageItalian;
  final String whatsappFollowUpItalian;
  final String whatsappStrongFollowUpItalian;
  final String ultraShortSummaryItalian;
  final String followUpItalian;
  final String strongFollowUpItalian;
  final String? rejectedReplyItalian;
  final String userExplanationEnglish;
  final Map<String, String> localizedExplanations;
  final List<AttachmentItem> attachmentChecklist;
  final List<String> nextSteps;
  final List<String> warnings;
  final List<String> deadlineSuggestions;
  final String fullText;
  final DateTime createdAt;
  final DateTime updatedAt;

  GeneratedPack copyWith({
    RequestStatus? status,
    RequestPriority? priority,
    List<AttachmentItem>? attachmentChecklist,
    String? fullText,
    DateTime? updatedAt,
    String? shortMessageItalian,
    String? whatsappMessageItalian,
    String? whatsappFollowUpItalian,
    String? whatsappStrongFollowUpItalian,
    String? ultraShortSummaryItalian,
    Map<String, String>? localizedExplanations,
  }) {
    return GeneratedPack(
      id: id,
      procedureId: procedureId,
      procedureTitle: procedureTitle,
      category: category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      inputData: inputData,
      subject: subject,
      bodyItalian: bodyItalian,
      bodyPecItalian: bodyPecItalian,
      shortMessageItalian: shortMessageItalian ?? this.shortMessageItalian,
      whatsappMessageItalian:
          whatsappMessageItalian ?? this.whatsappMessageItalian,
      whatsappFollowUpItalian:
          whatsappFollowUpItalian ?? this.whatsappFollowUpItalian,
      whatsappStrongFollowUpItalian:
          whatsappStrongFollowUpItalian ?? this.whatsappStrongFollowUpItalian,
      ultraShortSummaryItalian:
          ultraShortSummaryItalian ?? this.ultraShortSummaryItalian,
      followUpItalian: followUpItalian,
      strongFollowUpItalian: strongFollowUpItalian,
      rejectedReplyItalian: rejectedReplyItalian,
      userExplanationEnglish: userExplanationEnglish,
      localizedExplanations:
          localizedExplanations ?? this.localizedExplanations,
      attachmentChecklist: attachmentChecklist ?? this.attachmentChecklist,
      nextSteps: nextSteps,
      warnings: warnings,
      deadlineSuggestions: deadlineSuggestions,
      fullText: fullText ?? this.fullText,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'procedureId': procedureId,
    'procedureTitle': procedureTitle,
    'category': category,
    'status': status.name,
    'priority': priority.name,
    'inputData': inputData,
    'subject': subject,
    'bodyItalian': bodyItalian,
    'bodyPecItalian': bodyPecItalian,
    'shortMessageItalian': shortMessageItalian,
    'whatsappMessageItalian': whatsappMessageItalian,
    'whatsappFollowUpItalian': whatsappFollowUpItalian,
    'whatsappStrongFollowUpItalian': whatsappStrongFollowUpItalian,
    'ultraShortSummaryItalian': ultraShortSummaryItalian,
    'followUpItalian': followUpItalian,
    'strongFollowUpItalian': strongFollowUpItalian,
    'rejectedReplyItalian': rejectedReplyItalian,
    'userExplanationEnglish': userExplanationEnglish,
    'localizedExplanations': localizedExplanations,
    'attachmentChecklist': attachmentChecklist
        .map((item) => item.toJson())
        .toList(),
    'nextSteps': nextSteps,
    'warnings': warnings,
    'deadlineSuggestions': deadlineSuggestions,
    'fullText': fullText,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory GeneratedPack.fromJson(Map<String, dynamic> json) => GeneratedPack(
    id: json['id'] as String? ?? '',
    procedureId: json['procedureId'] as String? ?? '',
    procedureTitle: json['procedureTitle'] as String? ?? '',
    category: json['category'] as String? ?? '',
    status: requestStatusFromJson(json['status'] as String?),
    priority: requestPriorityFromJson(json['priority'] as String?),
    inputData: Map<String, dynamic>.from(
      (json['inputData'] as Map?) ?? <String, dynamic>{},
    ),
    subject: json['subject'] as String? ?? '',
    bodyItalian: json['bodyItalian'] as String? ?? '',
    bodyPecItalian: json['bodyPecItalian'] as String? ?? '',
    shortMessageItalian: json['shortMessageItalian'] as String? ?? '',
    whatsappMessageItalian: json['whatsappMessageItalian'] as String? ?? '',
    whatsappFollowUpItalian: json['whatsappFollowUpItalian'] as String? ?? '',
    whatsappStrongFollowUpItalian:
        json['whatsappStrongFollowUpItalian'] as String? ?? '',
    ultraShortSummaryItalian: json['ultraShortSummaryItalian'] as String? ?? '',
    followUpItalian: json['followUpItalian'] as String? ?? '',
    strongFollowUpItalian: json['strongFollowUpItalian'] as String? ?? '',
    rejectedReplyItalian: json['rejectedReplyItalian'] as String?,
    userExplanationEnglish: json['userExplanationEnglish'] as String? ?? '',
    localizedExplanations: Map<String, String>.from(
      (json['localizedExplanations'] as Map?) ?? <String, String>{},
    ),
    attachmentChecklist: ((json['attachmentChecklist'] as List?) ?? [])
        .whereType<Map>()
        .map((item) => AttachmentItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    nextSteps: ((json['nextSteps'] as List?) ?? []).cast<String>(),
    warnings: ((json['warnings'] as List?) ?? []).cast<String>(),
    deadlineSuggestions: ((json['deadlineSuggestions'] as List?) ?? [])
        .cast<String>(),
    fullText: json['fullText'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
