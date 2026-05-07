import 'dart:convert';
import 'dart:io';

import 'package:ufficiofacile/features/italy_admin_copilot/data/canone_rai_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/general_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/public_office_comune_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/telecom_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/university_student_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/utilities_electricity_gas_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/work_inps_patronato_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/health_asl_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/housing_rent_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/rich_category_models.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/health_asl_guidance_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/housing_rent_guidance_definitions.dart';

const _outputPath = 'docs/generated/cms_bundled_content_export.json';

final _forbiddenPatterns = <RegExp>[
  RegExp(r'do not show', caseSensitive: false),
  RegExp(r'internal note', caseSensitive: false),
  RegExp(r'for codex', caseSensitive: false),
];

void main() {
  final richCategories = <RichCategoryGuidance>[
    UtilitiesElectricityGasGuidanceDefinitions.category,
    CanoneRaiGuidanceDefinitions.category,
    TelecomGuidanceDefinitions.category,
    PublicOfficeComuneGuidanceDefinitions.category,
    WorkInpsPatronatoGuidanceDefinitions.category,
    UniversityStudentGuidanceDefinitions.category,
    GeneralGuidanceDefinitions.category,
  ];

  final payload = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'richCategories': richCategories
        .map((category) => _sanitizeDynamic(category.toMap()))
        .toList(),
    'healthCategory': _sanitizeDynamic(
      healthAslToRichCategory(healthAslGetTesseraSanitariaTorino).toMap(),
    ),
    'housingCategory': _sanitizeDynamic(
      housingToRichCategory(HousingRentGuidanceDefinitions.category).toMap(),
    ),
  };

  final file = File(_outputPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  stdout.writeln('Wrote $_outputPath');
}

dynamic _sanitizeDynamic(dynamic value) {
  if (value is Map) {
    final cleaned = <String, dynamic>{};
    for (final entry in value.entries) {
      final sanitizedValue = _sanitizeDynamic(entry.value);
      if (sanitizedValue == null) continue;
      if (sanitizedValue is String && sanitizedValue.trim().isEmpty) continue;
      if (sanitizedValue is List && sanitizedValue.isEmpty) continue;
      if (sanitizedValue is Map && sanitizedValue.isEmpty) continue;
      cleaned[entry.key.toString()] = sanitizedValue;
    }
    if (_looksInternalWarning(cleaned)) {
      cleaned.remove('topWarning');
    }
    cleaned.remove('implementationNotesForCodex');
    return cleaned;
  }
  if (value is List) {
    return value
        .map(_sanitizeDynamic)
        .where((item) => item != null)
        .toList();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (_forbiddenPatterns.any((pattern) => pattern.hasMatch(trimmed))) {
      return null;
    }
    return _humanize(trimmed);
  }
  return value;
}

bool _looksInternalWarning(Map<String, dynamic> map) {
  final warning = map['topWarning'];
  return warning is String &&
      _forbiddenPatterns.any((pattern) => pattern.hasMatch(warning));
}

String _humanize(String value) {
  final replacements = <Pattern, String>{
    RegExp(r'^This page helps the user ', caseSensitive: false): '',
    RegExp(r'^This page helps users ', caseSensitive: false): '',
    RegExp(r'^This page helps the student ', caseSensitive: false): '',
    RegExp(r'^This page helps students ', caseSensitive: false): '',
    RegExp(r'^This page helps ', caseSensitive: false): '',
    RegExp(r'\bthe user should\b', caseSensitive: false): 'you should',
  };

  var updated = value;
  replacements.forEach((pattern, replacement) {
    updated = updated.replaceFirst(pattern, replacement);
  });

  if (updated != value && updated.isNotEmpty) {
    final first = updated[0].toUpperCase();
    updated = '$first${updated.substring(1)}';
  }
  return updated;
}

RichCategoryGuidance healthAslToRichCategory(HealthAslGuidance guidance) {
  return RichCategoryGuidance(
    id: guidance.categoryId,
    title: guidance.title,
    titleIt: guidance.titleIt,
    region: guidance.region,
    city: guidance.city,
    shortDescription: guidance.shortDescription,
    mainUserQuestion: guidance.mainUserQuestion,
    routingLogicSummary:
        'Route the person to the correct ASL or support flow based on status, documents, and whether they need in-person help, information, or formal follow-up.',
    topWarning: guidance.topAnswer.body,
    contacts: {
      for (final entry in guidance.contacts.entries)
        entry.key: RichCategoryContact(
          id: entry.key,
          name: entry.value.name,
          address: entry.value.address,
          phone: entry.value.phone ??
              (entry.value.phones.isNotEmpty ? entry.value.phones.first : null),
          email: entry.value.email,
          pec: entry.value.pec,
          access: entry.value.accessMode,
          openingHours: entry.value.openingHours,
          warning: entry.value.warning,
          useFor: entry.value.useFor,
        ),
    },
    channelRules: guidance.channelRules
        .map(
          (item) => RichCategoryChannelRule(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
            priority: item.priority,
            useWhen: item.useWhen,
            address: item.address,
            warning: item.warning,
          ),
        )
        .toList(),
    commonDocuments: guidance.commonDocuments
        .map(
          (item) => RichCategoryDocument(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
          ),
        )
        .toList(),
    firstScreenQuestions: guidance.userSituationQuestions
        .map(
          (question) => RichCategoryQuestion(
            id: question.id,
            question: question.question,
            questionIt: question.questionIt,
            type: question.type,
            options: question.options
                .map(
                  (option) => RichCategoryQuestionOption(
                    id: option.id,
                    label: option.label,
                  ),
                )
                .toList(),
            showWhen: question.showWhen,
          ),
        )
        .toList(),
    subcategories: guidance.userFlows
        .map(
          (item) => RichCategorySubcategory(
            id: item.id,
            title: item.label,
            titleIt: item.labelIt,
            priority: 'high',
            whatIsIt: item.summary,
            whyDoYouNeedIt: [item.channelExplanation, item.whereToGo],
            recommendedChannels: [item.recommendedChannel],
            recommendedContacts: item.usefulContacts,
            documents: item.documents,
            extraDocuments: item.extraDocuments,
            warnings: item.warnings,
            outputs: item.outputs,
          ),
        )
        .toList(),
    outputGenerators: guidance.outputGenerators
        .map(
          (item) => RichCategoryOutputGenerator(
            id: item.id,
            title: item.title,
            titleIt: item.titleIt,
            outputType: item.outputType,
            sendTo: item.sendTo,
            templateIt: item.templateIt,
            templateBehavior: item.templateBehavior,
            warning: item.warning,
            items: item.items,
          ),
        )
        .toList(),
    routingRules: guidance.routingRules
        .map(
          (rule) => RichCategoryRoutingRule(
            conditions: rule.conditions,
            routeTo: rule.routeTo,
            note: rule.note,
          ),
        )
        .toList(),
  );
}

RichCategoryGuidance housingToRichCategory(HousingRentGuidance guidance) {
  return RichCategoryGuidance(
    id: guidance.id,
    title: guidance.title,
    titleIt: guidance.titleIt,
    region: guidance.region,
    city: guidance.city,
    shortDescription: guidance.shortDescription,
    mainUserQuestion: guidance.mainUserQuestion,
    routingLogicSummary: guidance.routingLogicSummary,
    contacts: {
      for (final entry in guidance.contacts.entries)
        entry.key: RichCategoryContact(
          id: entry.value.id,
          name: entry.value.name,
          officeCode: entry.value.officeCode,
          address: entry.value.address,
          phone: entry.value.phone,
          email: entry.value.email,
          pec: entry.value.pec,
          openingHours: entry.value.openingHours,
          warning: entry.value.warning,
          useFor: entry.value.useFor,
        ),
    },
    channelRules: guidance.channelRules
        .map(
          (item) => RichCategoryChannelRule(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
            priority: item.priority,
            useWhen: item.useWhen,
            warning: item.warning,
          ),
        )
        .toList(),
    commonDocuments: guidance.commonDocuments
        .map(
          (item) => RichCategoryDocument(
            id: item.id,
            label: item.label,
            labelIt: item.labelIt,
          ),
        )
        .toList(),
    subcategories: guidance.subcategories
        .map(
          (item) => RichCategorySubcategory(
            id: item.id,
            title: item.title,
            titleIt: item.titleIt,
            priority: item.priority,
            whatIsIt: item.whatIsIt,
            whyDoYouNeedIt: item.whyDoYouNeedIt,
            recommendedChannels: item.recommendedChannels,
            recommendedContacts: item.recommendedContacts,
            documents: item.documents,
            extraDocuments: item.extraDocuments,
            warnings: item.warnings,
            outputs: item.outputs,
          ),
        )
        .toList(),
    outputGenerators: guidance.outputGenerators
        .map(
          (item) => RichCategoryOutputGenerator(
            id: item.id,
            title: item.title,
            titleIt: item.titleIt,
            outputType: item.outputType,
            recipient: item.recipient,
            sendTo: item.sendTo,
            templateIt: item.templateIt,
          ),
        )
        .toList(),
  );
}
