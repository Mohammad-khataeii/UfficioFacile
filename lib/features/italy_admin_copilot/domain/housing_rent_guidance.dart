class HousingRentGuidance {
  const HousingRentGuidance({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.region,
    required this.city,
    required this.shortDescription,
    required this.mainUserQuestion,
    required this.routingLogicSummary,
    required this.contacts,
    required this.channelRules,
    required this.commonDocuments,
    required this.subcategories,
    required this.outputGenerators,
    required this.implementationNotesForCodex,
  });

  final String id;
  final String title;
  final String titleIt;
  final String region;
  final String city;
  final String shortDescription;
  final String mainUserQuestion;
  final String routingLogicSummary;
  final Map<String, HousingRentContact> contacts;
  final List<HousingRentChannelRule> channelRules;
  final List<HousingRentDocument> commonDocuments;
  final List<HousingRentSubcategory> subcategories;
  final List<HousingRentOutputGenerator> outputGenerators;
  final List<String> implementationNotesForCodex;
}

class HousingRentContact {
  const HousingRentContact({
    required this.id,
    required this.name,
    this.officeCode,
    this.address,
    this.phone,
    this.email,
    this.pec,
    this.openingHours,
    this.useFor = const <String>[],
    this.warning,
  });

  final String id;
  final String name;
  final String? officeCode;
  final String? address;
  final String? phone;
  final String? email;
  final String? pec;
  final String? openingHours;
  final List<String> useFor;
  final String? warning;
}

class HousingRentChannelRule {
  const HousingRentChannelRule({
    required this.id,
    required this.label,
    required this.labelIt,
    required this.priority,
    required this.useWhen,
    this.warning,
  });

  final String id;
  final String label;
  final String labelIt;
  final String priority;
  final List<String> useWhen;
  final String? warning;
}

class HousingRentDocument {
  const HousingRentDocument({
    required this.id,
    required this.label,
    required this.labelIt,
  });

  final String id;
  final String label;
  final String labelIt;
}

class HousingRentSubcategory {
  const HousingRentSubcategory({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.priority,
    required this.whatIsIt,
    required this.whyDoYouNeedIt,
    required this.recommendedChannels,
    required this.recommendedContacts,
    required this.documents,
    this.extraDocuments = const <String>[],
    this.userQuestions = const <String>[],
    this.warnings = const <String>[],
    this.outputs = const <String>[],
    this.emergencyWarning,
  });

  final String id;
  final String title;
  final String titleIt;
  final String priority;
  final String whatIsIt;
  final List<String> whyDoYouNeedIt;
  final List<String> recommendedChannels;
  final List<String> recommendedContacts;
  final List<String> documents;
  final List<String> extraDocuments;
  final List<String> userQuestions;
  final List<String> warnings;
  final List<String> outputs;
  final String? emergencyWarning;
}

class HousingRentOutputGenerator {
  const HousingRentOutputGenerator({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.outputType,
    this.recipient,
    this.sendTo,
    this.sendToOptions = const <String>[],
    this.templateIt,
  });

  final String id;
  final String title;
  final String titleIt;
  final String outputType;
  final String? recipient;
  final String? sendTo;
  final List<String> sendToOptions;
  final String? templateIt;
}
