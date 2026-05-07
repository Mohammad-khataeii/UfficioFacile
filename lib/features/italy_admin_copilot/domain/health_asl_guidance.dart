class HealthAslGuidance {
  const HealthAslGuidance({
    required this.id,
    required this.categoryId,
    required this.region,
    required this.city,
    required this.asl,
    required this.title,
    required this.titleIt,
    required this.shortDescription,
    required this.whatIsIt,
    required this.mainUserQuestion,
    required this.topAnswer,
    required this.sourceNotes,
    required this.contacts,
    required this.channelRules,
    required this.aslAdministrativeOffices,
    required this.commonDocuments,
    required this.userSituationQuestions,
    required this.userFlows,
    required this.outputGenerators,
    required this.routingRules,
    required this.implementationNotesForCodex,
  });

  final String id;
  final String categoryId;
  final String region;
  final String city;
  final String asl;
  final String title;
  final String titleIt;
  final String shortDescription;
  final String whatIsIt;
  final String mainUserQuestion;
  final HealthAslTopAnswer topAnswer;
  final List<HealthAslSourceNote> sourceNotes;
  final Map<String, HealthAslContact> contacts;
  final List<HealthAslChannelRule> channelRules;
  final HealthAslAdministrativeOffices aslAdministrativeOffices;
  final List<HealthAslCommonDocument> commonDocuments;
  final List<HealthAslSituationQuestion> userSituationQuestions;
  final List<HealthAslUserFlow> userFlows;
  final List<HealthAslOutputGenerator> outputGenerators;
  final List<HealthAslRoutingRule> routingRules;
  final List<String> implementationNotesForCodex;
}

class HealthAslTopAnswer {
  const HealthAslTopAnswer({
    required this.title,
    required this.body,
    required this.defaultRecommendedChannel,
  });

  final String title;
  final String body;
  final String defaultRecommendedChannel;
}

class HealthAslSourceNote {
  const HealthAslSourceNote({required this.label, required this.note});

  final String label;
  final String note;
}

class HealthAslContact {
  const HealthAslContact({
    required this.name,
    this.fullName,
    this.address,
    this.pec,
    this.email,
    this.phones = const <String>[],
    this.cupRegionale,
    this.phone,
    this.openingHours,
    this.accessMode,
    this.useFor = const <String>[],
    this.warning,
  });

  final String name;
  final String? fullName;
  final String? address;
  final String? pec;
  final String? email;
  final List<String> phones;
  final String? cupRegionale;
  final String? phone;
  final String? openingHours;
  final String? accessMode;
  final List<String> useFor;
  final String? warning;
}

class HealthAslChannelRule {
  const HealthAslChannelRule({
    required this.id,
    required this.label,
    required this.labelIt,
    required this.priority,
    required this.useWhen,
    this.address,
    this.userFacingText,
    this.warning,
  });

  final String id;
  final String label;
  final String labelIt;
  final String priority;
  final String? address;
  final List<String> useWhen;
  final String? userFacingText;
  final String? warning;
}

class HealthAslAdministrativeOffices {
  const HealthAslAdministrativeOffices({
    required this.generalOpeningHours,
    required this.verifyBeforeGoing,
    required this.offices,
  });

  final String generalOpeningHours;
  final bool verifyBeforeGoing;
  final List<HealthAslOffice> offices;
}

class HealthAslOffice {
  const HealthAslOffice({
    required this.id,
    required this.district,
    required this.circoscrizione,
    required this.areas,
    required this.address,
    this.notes,
  });

  final String id;
  final String district;
  final String circoscrizione;
  final List<String> areas;
  final String address;
  final String? notes;
}

class HealthAslCommonDocument {
  const HealthAslCommonDocument({
    required this.id,
    required this.label,
    required this.labelIt,
    this.examples = const <String>[],
  });

  final String id;
  final String label;
  final String labelIt;
  final List<String> examples;
}

class HealthAslSituationQuestion {
  const HealthAslSituationQuestion({
    required this.id,
    required this.question,
    required this.questionIt,
    required this.type,
    required this.options,
    this.showWhen = const <String, String>{},
  });

  final String id;
  final String question;
  final String questionIt;
  final String type;
  final List<HealthAslQuestionOption> options;
  final Map<String, String> showWhen;
}

class HealthAslQuestionOption {
  const HealthAslQuestionOption({required this.id, required this.label});

  final String id;
  final String label;
}

class HealthAslUserFlow {
  const HealthAslUserFlow({
    required this.id,
    required this.label,
    required this.labelIt,
    required this.summary,
    required this.recommendedChannel,
    required this.channelExplanation,
    required this.whereToGo,
    required this.documents,
    this.extraDocuments = const <String>[],
    this.warnings = const <String>[],
    this.usefulContacts = const <String>[],
    this.outputs = const <String>[],
  });

  final String id;
  final String label;
  final String labelIt;
  final String summary;
  final String recommendedChannel;
  final String channelExplanation;
  final String whereToGo;
  final List<String> documents;
  final List<String> extraDocuments;
  final List<String> warnings;
  final List<String> usefulContacts;
  final List<String> outputs;
}

class HealthAslOutputGenerator {
  const HealthAslOutputGenerator({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.outputType,
    this.sendTo,
    this.tone,
    this.templateIt,
    this.fieldsNeeded = const <String>[],
    this.templateBehavior,
    this.appliesTo = const <String>[],
    this.items = const <String>[],
    this.warning,
  });

  final String id;
  final String title;
  final String titleIt;
  final String outputType;
  final String? sendTo;
  final String? tone;
  final String? templateIt;
  final List<String> fieldsNeeded;
  final String? templateBehavior;
  final List<String> appliesTo;
  final List<String> items;
  final String? warning;
}

class HealthAslRoutingRule {
  const HealthAslRoutingRule({
    required this.conditions,
    required this.routeTo,
    this.note,
    this.recommendedChannel,
    this.recommendedOutput,
  });

  final Map<String, String> conditions;
  final String routeTo;
  final String? note;
  final String? recommendedChannel;
  final String? recommendedOutput;
}
