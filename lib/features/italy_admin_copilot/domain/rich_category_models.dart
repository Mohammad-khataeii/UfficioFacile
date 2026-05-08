class RichCategoryGuidance {
  const RichCategoryGuidance({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.region,
    required this.city,
    required this.shortDescription,
    required this.mainUserQuestion,
    required this.routingLogicSummary,
    this.topWarning,
    this.officialReferences = const <String, RichCategoryReference>{},
    this.contacts = const <String, RichCategoryContact>{},
    this.channelRules = const <RichCategoryChannelRule>[],
    this.commonDocuments = const <RichCategoryDocument>[],
    this.firstScreenQuestions = const <RichCategoryQuestion>[],
    this.subcategories = const <RichCategorySubcategory>[],
    this.outputGenerators = const <RichCategoryOutputGenerator>[],
    this.routingRules = const <RichCategoryRoutingRule>[],
    this.implementationNotesForCodex = const <String>[],
  });

  factory RichCategoryGuidance.fromMap(Map<String, dynamic> map) {
    return RichCategoryGuidance(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      titleIt: map['titleIt'] as String? ?? '',
      region: map['region'] as String? ?? '',
      city: map['city'] as String? ?? '',
      shortDescription: map['shortDescription'] as String? ?? '',
      mainUserQuestion: map['mainUserQuestion'] as String? ?? '',
      routingLogicSummary: map['routingLogicSummary'] as String? ?? '',
      topWarning: map['topWarning'] as String?,
      officialReferences: _mapValues(
        map['officialReferences'],
        (value) => RichCategoryReference.fromMap(value),
      ),
      contacts: _mapValues(
        map['contacts'],
        (value) => RichCategoryContact.fromMap(value),
      ),
      channelRules: _listValues(
        map['channelRules'],
        (value) => RichCategoryChannelRule.fromMap(value),
      ),
      commonDocuments: _listValues(
        map['commonDocuments'],
        (value) => RichCategoryDocument.fromMap(value),
      ),
      firstScreenQuestions: _listValues(
        map['firstScreenQuestions'],
        (value) => RichCategoryQuestion.fromMap(value),
      ),
      subcategories: _listValues(
        map['subcategories'],
        (value) => RichCategorySubcategory.fromMap(value),
      ),
      outputGenerators: _listValues(
        map['outputGenerators'],
        (value) => RichCategoryOutputGenerator.fromMap(value),
      ),
      routingRules: _listValues(
        map['routingRules'],
        (value) => RichCategoryRoutingRule.fromMap(value),
      ),
      implementationNotesForCodex:
          (map['implementationNotesForCodex'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
    );
  }

  final String id;
  final String title;
  final String titleIt;
  final String region;
  final String city;
  final String shortDescription;
  final String mainUserQuestion;
  final String routingLogicSummary;
  final String? topWarning;
  final Map<String, RichCategoryReference> officialReferences;
  final Map<String, RichCategoryContact> contacts;
  final List<RichCategoryChannelRule> channelRules;
  final List<RichCategoryDocument> commonDocuments;
  final List<RichCategoryQuestion> firstScreenQuestions;
  final List<RichCategorySubcategory> subcategories;
  final List<RichCategoryOutputGenerator> outputGenerators;
  final List<RichCategoryRoutingRule> routingRules;
  final List<String> implementationNotesForCodex;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'titleIt': titleIt,
    'region': region,
    'city': city,
    'shortDescription': shortDescription,
    'mainUserQuestion': mainUserQuestion,
    'routingLogicSummary': routingLogicSummary,
    if (topWarning != null) 'topWarning': topWarning,
    'officialReferences': officialReferences.map(
      (key, value) => MapEntry(key, value.toMap()),
    ),
    'contacts': contacts.map((key, value) => MapEntry(key, value.toMap())),
    'channelRules': channelRules.map((item) => item.toMap()).toList(),
    'commonDocuments': commonDocuments.map((item) => item.toMap()).toList(),
    'firstScreenQuestions': firstScreenQuestions
        .map((item) => item.toMap())
        .toList(),
    'subcategories': subcategories.map((item) => item.toMap()).toList(),
    'outputGenerators': outputGenerators.map((item) => item.toMap()).toList(),
    'routingRules': routingRules.map((item) => item.toMap()).toList(),
    'implementationNotesForCodex': implementationNotesForCodex,
  };
}

class RichCategoryReference {
  const RichCategoryReference({required this.label, this.url});

  factory RichCategoryReference.fromMap(Map<String, dynamic> map) {
    return RichCategoryReference(
      label: map['label'] as String? ?? '',
      url: map['url'] as String?,
    );
  }

  final String label;
  final String? url;

  Map<String, dynamic> toMap() => {'label': label, if (url != null) 'url': url};
}

class RichCategoryContact {
  const RichCategoryContact({
    required this.id,
    required this.name,
    this.nameIt,
    this.categoryId,
    this.authority,
    this.officeCode,
    this.address,
    this.postalAddress,
    this.physicalOfficeAddress,
    this.phone,
    this.phoneHours,
    this.phoneSupportLegacy,
    this.phoneFixedLine,
    this.phoneMobileOrAbroad,
    this.conciliationFreeNumber,
    this.conciliationFreeNumberHours,
    this.consumerPhone,
    this.email,
    this.pec,
    this.permessoSupportPec,
    this.url,
    this.access,
    this.howToFind,
    this.requiredBeforeUse,
    this.openingHours,
    this.publicHours,
    this.warning,
    this.useFor = const <String>[],
  });

  factory RichCategoryContact.fromMap(Map<String, dynamic> map) {
    return RichCategoryContact(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      nameIt: map['nameIt'] as String?,
      categoryId: map['categoryId'] as String?,
      authority: map['authority'] as String?,
      officeCode: map['officeCode'] as String?,
      address: map['address'] as String?,
      postalAddress: map['postalAddress'] as String?,
      physicalOfficeAddress: map['physicalOfficeAddress'] as String?,
      phone: map['phone'] as String?,
      phoneHours: map['phoneHours'] as String?,
      phoneSupportLegacy: map['phoneSupportLegacy'] as String?,
      phoneFixedLine: map['phoneFixedLine'] as String?,
      phoneMobileOrAbroad: map['phoneMobileOrAbroad'] as String?,
      conciliationFreeNumber: map['conciliationFreeNumber'] as String?,
      conciliationFreeNumberHours:
          map['conciliationFreeNumberHours'] as String?,
      consumerPhone: map['consumerPhone'] as String?,
      email: map['email'] as String?,
      pec: map['pec'] as String?,
      permessoSupportPec: map['permessoSupportPec'] as String?,
      url: map['url'] as String?,
      access: map['access'] as String?,
      howToFind: map['howToFind'] as String?,
      requiredBeforeUse: map['requiredBeforeUse'] as String?,
      openingHours: map['openingHours'] as String?,
      publicHours: map['publicHours'] as String?,
      warning: map['warning'] as String?,
      useFor: (map['useFor'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  final String id;
  final String name;
  final String? nameIt;
  final String? categoryId;
  final String? authority;
  final String? officeCode;
  final String? address;
  final String? postalAddress;
  final String? physicalOfficeAddress;
  final String? phone;
  final String? phoneHours;
  final String? phoneSupportLegacy;
  final String? phoneFixedLine;
  final String? phoneMobileOrAbroad;
  final String? conciliationFreeNumber;
  final String? conciliationFreeNumberHours;
  final String? consumerPhone;
  final String? email;
  final String? pec;
  final String? permessoSupportPec;
  final String? url;
  final String? access;
  final String? howToFind;
  final String? requiredBeforeUse;
  final String? openingHours;
  final String? publicHours;
  final String? warning;
  final List<String> useFor;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    if (nameIt != null) 'nameIt': nameIt,
    if (categoryId != null) 'categoryId': categoryId,
    if (authority != null) 'authority': authority,
    if (officeCode != null) 'officeCode': officeCode,
    if (address != null) 'address': address,
    if (postalAddress != null) 'postalAddress': postalAddress,
    if (physicalOfficeAddress != null)
      'physicalOfficeAddress': physicalOfficeAddress,
    if (phone != null) 'phone': phone,
    if (phoneHours != null) 'phoneHours': phoneHours,
    if (phoneSupportLegacy != null) 'phoneSupportLegacy': phoneSupportLegacy,
    if (phoneFixedLine != null) 'phoneFixedLine': phoneFixedLine,
    if (phoneMobileOrAbroad != null) 'phoneMobileOrAbroad': phoneMobileOrAbroad,
    if (conciliationFreeNumber != null)
      'conciliationFreeNumber': conciliationFreeNumber,
    if (conciliationFreeNumberHours != null)
      'conciliationFreeNumberHours': conciliationFreeNumberHours,
    if (consumerPhone != null) 'consumerPhone': consumerPhone,
    if (email != null) 'email': email,
    if (pec != null) 'pec': pec,
    if (permessoSupportPec != null) 'permessoSupportPec': permessoSupportPec,
    if (url != null) 'url': url,
    if (access != null) 'access': access,
    if (howToFind != null) 'howToFind': howToFind,
    if (requiredBeforeUse != null) 'requiredBeforeUse': requiredBeforeUse,
    if (openingHours != null) 'openingHours': openingHours,
    if (publicHours != null) 'publicHours': publicHours,
    if (warning != null) 'warning': warning,
    if (useFor.isNotEmpty) 'useFor': useFor,
  };
}

class RichCategoryChannelRule {
  const RichCategoryChannelRule({
    required this.id,
    required this.label,
    required this.labelIt,
    required this.priority,
    required this.useWhen,
    this.address,
    this.pec,
    this.warning,
  });

  factory RichCategoryChannelRule.fromMap(Map<String, dynamic> map) {
    return RichCategoryChannelRule(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      labelIt: map['labelIt'] as String? ?? '',
      priority: map['priority'] as String? ?? '',
      useWhen: (map['useWhen'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      address: map['address'] as String?,
      pec: map['pec'] as String?,
      warning: map['warning'] as String?,
    );
  }

  final String id;
  final String label;
  final String labelIt;
  final String priority;
  final List<String> useWhen;
  final String? address;
  final String? pec;
  final String? warning;

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'labelIt': labelIt,
    'priority': priority,
    'useWhen': useWhen,
    if (address != null) 'address': address,
    if (pec != null) 'pec': pec,
    if (warning != null) 'warning': warning,
  };
}

class RichCategoryDocument {
  const RichCategoryDocument({
    required this.id,
    required this.label,
    required this.labelIt,
  });

  factory RichCategoryDocument.fromMap(Map<String, dynamic> map) {
    return RichCategoryDocument(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      labelIt: map['labelIt'] as String? ?? '',
    );
  }

  final String id;
  final String label;
  final String labelIt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'labelIt': labelIt,
  };
}

class RichCategoryQuestion {
  const RichCategoryQuestion({
    required this.id,
    required this.question,
    required this.questionIt,
    required this.type,
    this.placeholder,
    this.options = const <RichCategoryQuestionOption>[],
    this.showWhen = const <String, String>{},
  });

  factory RichCategoryQuestion.fromMap(Map<String, dynamic> map) {
    return RichCategoryQuestion(
      id: map['id'] as String? ?? '',
      question: map['question'] as String? ?? '',
      questionIt: map['questionIt'] as String? ?? '',
      type: map['type'] as String? ?? 'single_choice',
      placeholder: map['placeholder'] as String?,
      options: _listValues(
        map['options'],
        (value) => RichCategoryQuestionOption.fromMap(value),
      ),
      showWhen: Map<String, String>.from(
        (map['showWhen'] as Map?) ?? const <String, String>{},
      ),
    );
  }

  final String id;
  final String question;
  final String questionIt;
  final String type;
  final String? placeholder;
  final List<RichCategoryQuestionOption> options;
  final Map<String, String> showWhen;

  Map<String, dynamic> toMap() => {
    'id': id,
    'question': question,
    'questionIt': questionIt,
    'type': type,
    if (placeholder != null) 'placeholder': placeholder,
    if (options.isNotEmpty)
      'options': options.map((item) => item.toMap()).toList(),
    if (showWhen.isNotEmpty) 'showWhen': showWhen,
  };
}

class RichCategoryQuestionOption {
  const RichCategoryQuestionOption({required this.id, required this.label});

  factory RichCategoryQuestionOption.fromMap(Map<String, dynamic> map) {
    return RichCategoryQuestionOption(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
    );
  }

  final String id;
  final String label;

  Map<String, dynamic> toMap() => {'id': id, 'label': label};
}

class RichCategoryDeadline {
  const RichCategoryDeadline({
    required this.id,
    required this.label,
    required this.rule,
  });

  factory RichCategoryDeadline.fromMap(Map<String, dynamic> map) {
    return RichCategoryDeadline(
      id: map['id'] as String? ?? '',
      label: map['label'] as String? ?? '',
      rule: map['rule'] as String? ?? '',
    );
  }

  final String id;
  final String label;
  final String rule;

  Map<String, dynamic> toMap() => {'id': id, 'label': label, 'rule': rule};
}

class RichCategoryConfigurableRule {
  const RichCategoryConfigurableRule({
    required this.label,
    required this.value,
    this.warning,
  });

  factory RichCategoryConfigurableRule.fromMap(Map<String, dynamic> map) {
    return RichCategoryConfigurableRule(
      label: map['label'] as String? ?? '',
      value: map['value'] as String? ?? '',
      warning: map['warning'] as String?,
    );
  }

  final String label;
  final String value;
  final String? warning;

  Map<String, dynamic> toMap() => {
    'label': label,
    'value': value,
    if (warning != null) 'warning': warning,
  };
}

class RichCategorySubcategory {
  const RichCategorySubcategory({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.priority,
    required this.whatIsIt,
    this.whyDoYouNeedIt = const <String>[],
    this.recommendedChannels = const <String>[],
    this.recommendedContacts = const <String>[],
    this.documents = const <String>[],
    this.extraDocuments = const <String>[],
    this.warnings = const <String>[],
    this.outputs = const <String>[],
    this.userQuestions = const <String>[],
    this.fieldsToExtractFromBill = const <String>[],
    this.deadlines = const <RichCategoryDeadline>[],
    this.configurableRules = const <String, RichCategoryConfigurableRule>{},
    this.urgentWarning,
  });

  factory RichCategorySubcategory.fromMap(Map<String, dynamic> map) {
    return RichCategorySubcategory(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      titleIt: map['titleIt'] as String? ?? '',
      priority: map['priority'] as String? ?? '',
      whatIsIt: map['whatIsIt'] as String? ?? '',
      whyDoYouNeedIt: (map['whyDoYouNeedIt'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      recommendedChannels:
          (map['recommendedChannels'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
      recommendedContacts:
          (map['recommendedContacts'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
      documents: (map['documents'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      extraDocuments: (map['extraDocuments'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      warnings: (map['warnings'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      outputs: (map['outputs'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      userQuestions: (map['userQuestions'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      fieldsToExtractFromBill:
          (map['fieldsToExtractFromBill'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
      deadlines: _listValues(
        map['deadlines'],
        (value) => RichCategoryDeadline.fromMap(value),
      ),
      configurableRules: _mapValues(
        map['configurableRules'],
        (value) => RichCategoryConfigurableRule.fromMap(value),
      ),
      urgentWarning: map['urgentWarning'] as String?,
    );
  }

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
  final List<String> warnings;
  final List<String> outputs;
  final List<String> userQuestions;
  final List<String> fieldsToExtractFromBill;
  final List<RichCategoryDeadline> deadlines;
  final Map<String, RichCategoryConfigurableRule> configurableRules;
  final String? urgentWarning;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'titleIt': titleIt,
    'priority': priority,
    'whatIsIt': whatIsIt,
    if (whyDoYouNeedIt.isNotEmpty) 'whyDoYouNeedIt': whyDoYouNeedIt,
    if (recommendedChannels.isNotEmpty)
      'recommendedChannels': recommendedChannels,
    if (recommendedContacts.isNotEmpty)
      'recommendedContacts': recommendedContacts,
    if (documents.isNotEmpty) 'documents': documents,
    if (extraDocuments.isNotEmpty) 'extraDocuments': extraDocuments,
    if (warnings.isNotEmpty) 'warnings': warnings,
    if (outputs.isNotEmpty) 'outputs': outputs,
    if (userQuestions.isNotEmpty) 'userQuestions': userQuestions,
    if (fieldsToExtractFromBill.isNotEmpty)
      'fieldsToExtractFromBill': fieldsToExtractFromBill,
    if (deadlines.isNotEmpty)
      'deadlines': deadlines.map((item) => item.toMap()).toList(),
    if (configurableRules.isNotEmpty)
      'configurableRules': configurableRules.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    if (urgentWarning != null) 'urgentWarning': urgentWarning,
  };
}

class RichCategoryOutputGenerator {
  const RichCategoryOutputGenerator({
    required this.id,
    required this.title,
    required this.titleIt,
    required this.outputType,
    this.recipient,
    this.sendTo,
    this.address,
    this.contentIt,
    this.templateIt,
    this.templateBehavior,
    this.behavior,
    this.warning,
    this.items = const <String>[],
    this.sendToOptions = const <String>[],
  });

  factory RichCategoryOutputGenerator.fromMap(Map<String, dynamic> map) {
    return RichCategoryOutputGenerator(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      titleIt: map['titleIt'] as String? ?? '',
      outputType: map['outputType'] as String? ?? '',
      recipient: map['recipient'] as String?,
      sendTo: map['sendTo'] as String?,
      address: map['address'] as String?,
      contentIt: map['contentIt'] as String?,
      templateIt: map['templateIt'] as String?,
      templateBehavior: map['templateBehavior'] as String?,
      behavior: map['behavior'] as String?,
      warning: map['warning'] as String?,
      items: (map['items'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      sendToOptions: (map['sendToOptions'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  final String id;
  final String title;
  final String titleIt;
  final String outputType;
  final String? recipient;
  final String? sendTo;
  final String? address;
  final String? contentIt;
  final String? templateIt;
  final String? templateBehavior;
  final String? behavior;
  final String? warning;
  final List<String> items;
  final List<String> sendToOptions;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'titleIt': titleIt,
    'outputType': outputType,
    if (recipient != null) 'recipient': recipient,
    if (sendTo != null) 'sendTo': sendTo,
    if (address != null) 'address': address,
    if (contentIt != null) 'contentIt': contentIt,
    if (templateIt != null) 'templateIt': templateIt,
    if (templateBehavior != null) 'templateBehavior': templateBehavior,
    if (behavior != null) 'behavior': behavior,
    if (warning != null) 'warning': warning,
    if (items.isNotEmpty) 'items': items,
    if (sendToOptions.isNotEmpty) 'sendToOptions': sendToOptions,
  };
}

class RichCategoryRoutingRule {
  const RichCategoryRoutingRule({
    required this.conditions,
    required this.routeTo,
    this.priority,
    this.note,
  });

  factory RichCategoryRoutingRule.fromMap(Map<String, dynamic> map) {
    return RichCategoryRoutingRule(
      conditions: (map['if'] as Map<dynamic, dynamic>? ?? const {}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      routeTo: map['routeTo'] as String? ?? '',
      priority: map['priority'] as String?,
      note: map['note'] as String?,
    );
  }

  final Map<String, String> conditions;
  final String routeTo;
  final String? priority;
  final String? note;

  Map<String, dynamic> toMap() => {
    'if': conditions,
    'routeTo': routeTo,
    if (priority != null) 'priority': priority,
    if (note != null) 'note': note,
  };
}

Map<String, T> _mapValues<T>(
  dynamic source,
  T Function(Map<String, dynamic>) builder,
) {
  final map = source as Map<dynamic, dynamic>? ?? const {};
  return map.map(
    (key, value) => MapEntry(
      key.toString(),
      builder(Map<String, dynamic>.from(value as Map)),
    ),
  );
}

List<T> _listValues<T>(
  dynamic source,
  T Function(Map<String, dynamic>) builder,
) {
  final list = source as List<dynamic>? ?? const [];
  return list
      .whereType<Map>()
      .map((value) => builder(Map<String, dynamic>.from(value)))
      .toList();
}
