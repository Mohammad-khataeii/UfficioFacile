import 'dart:convert';
import 'dart:io';

import 'package:ufficiofacile/features/admin_cms/data/bundled_to_cms_mapper.dart';
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

const _outputPaths = [
  'docs/generated/cms_bundled_content_export.json',
  'apps/admin/data/cms_bundled_content_export.json',
];
const _bonusLoansSeedPath = 'apps/admin/data/seed/bonus_loans_categories.json';

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
    'cmsCategories': [
      ...const BundledToCmsMapper().exportCategories(),
      ..._seedCategoriesForCms(),
    ],
    'cmsProcedures': [
      ...const BundledToCmsMapper().exportProcedures(),
      ..._seedProceduresForCms(),
    ],
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

  final encoded = const JsonEncoder.withIndent('  ').convert(payload);
  for (final outputPath in _outputPaths) {
    final file = File(outputPath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(encoded);
    stdout.writeln('Wrote $outputPath');
  }
}

List<Map<String, dynamic>> _seedCategoriesForCms() {
  final seed = _loadSeedJson();
  final categories = (seed['categories'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
  return categories
      .map(
        (item) => {
          'id': item['slug'],
          'slug': item['slug'],
          'internal_label': item['slug'],
          'title': _completeLocaleMap(item['title']),
          'subtitle': _completeLocaleMap(item['subtitle']),
          'description': _completeLocaleMap(item['description']),
          'short_description': _completeLocaleMap(item['description']),
          'long_description': _completeLocaleMap(item['subtitle']),
          'icon': item['icon'],
          'color': item['color'],
          'sort_order': item['sort_order'] ?? 0,
          'is_active': item['is_active'] ?? true,
          'is_premium': item['is_premium'] ?? true,
          'visibility': 'public',
          'verification_status': item['verification_status'] ?? 'needsReview',
          'last_verified_at': item['last_verified_at'],
          'tags': item['tags'] ?? const <dynamic>[],
          'synonyms': item['synonyms'] ?? const <dynamic>[],
          'searchable_keywords':
              item['searchable_keywords'] ?? const <dynamic>[],
          'monetization_type':
              item['monetization_type'] ??
              (item['is_premium'] == true ? 'premium_money_value' : 'free'),
          'allow_single_unlock': item['allow_single_unlock'] ?? true,
          'single_unlock_price_cents': item['single_unlock_price_cents'],
          'single_unlock_currency': item['single_unlock_currency'] ?? 'EUR',
          'premium_reason': item['premium_reason'] ?? const <String, dynamic>{},
          'premium_teaser': _completeLocaleMap(
            item['premium_teaser'] ?? item['subtitle'],
          ),
          'metadata': item['metadata'] ?? const <String, dynamic>{},
          'public_snapshot': item,
        },
      )
      .toList();
}

List<Map<String, dynamic>> _seedProceduresForCms() {
  final seed = _loadSeedJson();
  final categories = (seed['categories'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
  final procedures = <Map<String, dynamic>>[];
  for (final category in categories) {
    final categorySlug = category['slug']?.toString() ?? '';
    final entries = (category['procedures'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item));
    for (final procedure in entries) {
      final normalizedBlocks = _normalizedBlocks(
        categorySlug,
        Map<String, dynamic>.from(procedure),
      );
      procedures.add({
        'id': procedure['slug'],
        'slug': procedure['slug'],
        'category_slug': procedure['category_slug'] ?? categorySlug,
        'title': _completeLocaleMap(procedure['title']),
        'subtitle': _completeLocaleMap(procedure['subtitle']),
        'summary': _completeLocaleMap(procedure['summary']),
        'what_is_it': _completeLocaleMap(
          procedure['what_is_it'] ?? procedure['summary'],
        ),
        'why_you_may_need_it':
            procedure['why_you_may_need_it'] ?? const <dynamic>[],
        'how_to_do_it': procedure['how_to_do_it'] ?? const <dynamic>[],
        'required_documents':
            procedure['required_documents'] ?? const <dynamic>[],
        'optional_documents':
            procedure['optional_documents'] ?? const <dynamic>[],
        'warnings': _collectBlockBodies(procedure, ['warning']),
        'common_mistakes': _collectBlockBodies(procedure, ['common_mistakes']),
        'proof_to_keep': const <dynamic>[],
        'faq': _collectBlockBodies(procedure, ['faq']),
        'official_links': _sourceUrls(procedure),
        'status': procedure['status'] ?? 'published',
        'sort_order': procedure['sort_order'] ?? 0,
        'is_active': procedure['is_active'] ?? true,
        'is_premium': procedure['is_premium'] ?? true,
        'visibility': 'public',
        'verification_status':
            procedure['verification_status'] ?? 'needsReview',
        'last_verified_at': procedure['last_verified_at'],
        'tags': procedure['tags'] ?? const <dynamic>[],
        'synonyms': procedure['synonyms'] ?? const <dynamic>[],
        'searchable_keywords':
            procedure['searchable_keywords'] ?? const <dynamic>[],
        'monetization_type':
            procedure['monetization_type'] ??
            (procedure['is_premium'] == true ? 'premium_money_value' : 'free'),
        'allow_single_unlock': procedure['allow_single_unlock'] ?? true,
        'single_unlock_price_cents':
            procedure['single_unlock_price_cents'] ??
            ((procedure['is_premium'] ?? false) ? 399 : null),
        'single_unlock_currency': procedure['single_unlock_currency'] ?? 'EUR',
        'premium_reason': _completeLocaleMap(procedure['premium_reason']),
        'premium_teaser': _completeLocaleMap(
          procedure['premium_teaser'] ??
              procedure['subtitle'] ??
              procedure['summary'],
        ),
        'metadata': {
          ...(procedure['metadata'] as Map? ?? const {}),
          'blocks': normalizedBlocks,
          'sources': procedure['sources'] ?? const <dynamic>[],
          'allow_single_unlock': procedure['allow_single_unlock'] ?? true,
          'single_unlock_price_cents':
              procedure['single_unlock_price_cents'] ??
              ((procedure['is_premium'] ?? false) ? 399 : null),
        },
        'public_snapshot': {...procedure, 'blocks': normalizedBlocks},
      });
    }
  }
  return procedures;
}

Map<String, dynamic> _loadSeedJson() {
  final raw = File(_bonusLoansSeedPath).readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

List<String> _collectBlockBodies(
  Map<String, dynamic> procedure,
  List<String> blockTypes,
) {
  final blocks = (procedure['blocks'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .where((item) => blockTypes.contains(item['block_type']))
      .toList();
  return blocks
      .map((item) => ((item['body'] as Map?)?['en'] ?? '').toString())
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

List<String> _sourceUrls(Map<String, dynamic> procedure) {
  final sources = (procedure['sources'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
  return sources
      .map((item) => (item['url'] ?? '').toString())
      .where((item) => item.trim().isNotEmpty)
      .toList();
}

List<Map<String, dynamic>> _normalizedBlocks(
  String categorySlug,
  Map<String, dynamic> procedure,
) {
  final blocks = (procedure['blocks'] as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
  final text = jsonEncode(blocks).toLowerCase();
  if (categorySlug == 'loans-credit' &&
      !text.contains('credit') &&
      !text.contains('taeg')) {
    blocks.add(_loanWarningBlock());
  }
  if (categorySlug == 'bonuses-benefits' &&
      !text.contains('verify') &&
      !text.contains('application window') &&
      !text.contains('warning')) {
    blocks.add(_bonusWarningBlock());
  }
  return blocks;
}

Map<String, dynamic> _loanWarningBlock() {
  return {
    'block_type': 'warning',
    'title': _completeLocaleMap({
      'en': 'Credit warning',
      'it': 'Avvertenza sul credito',
      'fr': 'Avertissement sur le crédit',
      'es': 'Advertencia sobre el crédito',
      'fa': 'هشدار درباره اعتبار',
      'ar': 'تحذير بخصوص الائتمان',
    }),
    'body': _completeLocaleMap({
      'en':
          'This is credit, not free money. Compare TAEG, total cost, repayment duration, guarantees and late-payment consequences before signing.',
      'it':
          'Questo e credito, non denaro gratuito. Confronta TAEG, costo totale, durata del rimborso, garanzie e conseguenze dei ritardi prima di firmare.',
      'fr':
          'Il s’agit de crédit, pas d’argent gratuit. Comparez le TAEG, le coût total, la durée de remboursement, les garanties et les conséquences des retards avant de signer.',
      'es':
          'Esto es crédito, no dinero gratis. Compara TAEG, coste total, duración del reembolso, garantías y consecuencias por retrasos antes de firmar.',
      'fa':
          'این اعتبار است، نه پول رایگان. قبل از امضا TAEG، هزینه کل، مدت بازپرداخت، ضمانت‌ها و پیامدهای تأخیر را مقایسه کن.',
      'ar':
          'هذا ائتمان وليس مالاً مجانياً. قارن TAEG والتكلفة الإجمالية ومدة السداد والضمانات وعواقب التأخر قبل التوقيع.',
    }),
    'items': [
      'TAEG',
      'Total cost',
      'Repayment duration',
      'Guarantees',
      'Late-payment consequences',
    ],
    'sort_order': 999,
    'is_active': true,
    'warning_level': 'important',
  };
}

Map<String, dynamic> _bonusWarningBlock() {
  return {
    'block_type': 'warning',
    'title': _completeLocaleMap({
      'en': 'Verify before applying',
      'it': 'Verifica prima di fare domanda',
      'fr': 'Vérifiez avant de demander',
      'es': 'Verifica antes de solicitar',
      'fa': 'قبل از درخواست بررسی کن',
      'ar': 'تحقق قبل التقديم',
    }),
    'body': _completeLocaleMap({
      'en':
          'Eligibility depends on current rules, ISEE, residence, family status and application windows. Always verify the official page before applying.',
      'it':
          'L’idoneita dipende dalle regole attuali, dall’ISEE, dalla residenza, dalla situazione familiare e dalle finestre di domanda. Verifica sempre la pagina ufficiale prima di fare domanda.',
      'fr':
          'L’éligibilité dépend des règles en vigueur, de l’ISEE, de la résidence, de la situation familiale et des périodes de candidature. Vérifiez toujours la page officielle avant de demander.',
      'es':
          'La elegibilidad depende de las reglas vigentes, el ISEE, la residencia, la situación familiar y las ventanas de solicitud. Verifica siempre la página oficial antes de solicitar.',
      'fa':
          'واجد شرایط بودن به قوانین فعلی، ISEE، محل اقامت، وضعیت خانوادگی و بازه درخواست بستگی دارد. همیشه قبل از درخواست صفحه رسمی را بررسی کن.',
      'ar':
          'تعتمد الأهلية على القواعد الحالية وISEE والإقامة والوضع العائلي وفترات التقديم. تحقق دائماً من الصفحة الرسمية قبل التقديم.',
    }),
    'items': [],
    'sort_order': 999,
    'is_active': true,
    'warning_level': 'important',
  };
}

Map<String, dynamic> _completeLocaleMap(dynamic value) {
  final source = value is Map
      ? Map<String, dynamic>.from(value)
      : <String, dynamic>{};
  final en = (source['en'] ?? source['it'] ?? '').toString().trim();
  final it = (source['it'] ?? en).toString().trim();
  final fr = (source['fr'] ?? en).toString().trim();
  final es = (source['es'] ?? en).toString().trim();
  final fa = (source['fa'] ?? it).toString().trim();
  final ar = (source['ar'] ?? en).toString().trim();
  return {'en': en, 'it': it, 'fr': fr, 'es': es, 'fa': fa, 'ar': ar};
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
    return value.map(_sanitizeDynamic).where((item) => item != null).toList();
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
          phone:
              entry.value.phone ??
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
