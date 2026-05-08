import '../../italy_admin_copilot/data/canone_rai_guidance_definitions.dart';
import '../../italy_admin_copilot/data/general_guidance_definitions.dart';
import '../../italy_admin_copilot/data/health_asl_guidance_definitions.dart';
import '../../italy_admin_copilot/data/housing_rent_guidance_definitions.dart';
import '../../italy_admin_copilot/data/public_office_comune_guidance_definitions.dart';
import '../../italy_admin_copilot/data/telecom_guidance_definitions.dart';
import '../../italy_admin_copilot/data/university_student_guidance_definitions.dart';
import '../../italy_admin_copilot/data/utilities_electricity_gas_guidance_definitions.dart';
import '../../italy_admin_copilot/data/work_inps_patronato_guidance_definitions.dart';
import '../../italy_admin_copilot/domain/health_asl_guidance.dart';
import '../../italy_admin_copilot/domain/housing_rent_guidance.dart';
import '../../italy_admin_copilot/domain/rich_category_models.dart';

class BundledToCmsMapper {
  const BundledToCmsMapper();

  List<RichCategoryGuidance> allGuidance() => [
    healthAslToRichCategory(healthAslGetTesseraSanitariaTorino),
    housingToRichCategory(HousingRentGuidanceDefinitions.category),
    utilitiesElectricityGasTorino,
    canoneRaiTorino,
    telecomInternetMobileTorino,
    PublicOfficeComuneGuidanceDefinitions.category,
    WorkInpsPatronatoGuidanceDefinitions.category,
    UniversityStudentGuidanceDefinitions.category,
    GeneralGuidanceDefinitions.category,
  ];

  List<Map<String, dynamic>> exportCategories() {
    return allGuidance()
        .asMap()
        .entries
        .map(
          (entry) {
            final slug = entry.value.id;
            final localized = _categoryLocalizedContent(
              slug,
              defaultTitleEn: entry.value.title,
              defaultTitleIt: entry.value.titleIt,
              defaultQuestionEn: entry.value.mainUserQuestion,
              defaultQuestionIt: entry.value.mainUserQuestion,
              defaultDescriptionEn: entry.value.shortDescription,
              defaultDescriptionIt: entry.value.shortDescription,
            );
            return {
            'slug': entry.value.id,
            'id': entry.value.id,
            'title': _completeLocaleMap(
              en: localized.titleEn,
              it: localized.titleIt,
              fr: localized.titleFr,
              es: localized.titleEs,
              fa: localized.titleFa,
              ar: localized.titleAr,
            ),
            'subtitle': _completeLocaleMap(
              en: localized.questionEn,
              it: localized.questionIt,
              fr: localized.questionFr,
              es: localized.questionEs,
              fa: localized.questionFa,
              ar: localized.questionAr,
            ),
            'description': _completeLocaleMap(
              en: localized.descriptionEn,
              it: localized.descriptionIt,
              fr: localized.descriptionFr,
              es: localized.descriptionEs,
              fa: localized.descriptionFa,
              ar: localized.descriptionAr,
            ),
            'short_description': _completeLocaleMap(
              en: localized.descriptionEn,
              it: localized.descriptionIt,
              fr: localized.descriptionFr,
              es: localized.descriptionEs,
              fa: localized.descriptionFa,
              ar: localized.descriptionAr,
            ),
            'long_description': _completeLocaleMap(
              en: localized.questionEn,
              it: localized.questionIt,
              fr: localized.questionFr,
              es: localized.questionEs,
              fa: localized.questionFa,
              ar: localized.questionAr,
            ),
            'icon': null,
            'color': null,
            'sort_order': entry.key + 1,
            'is_active': true,
            'is_premium': _categoryIsPremium(entry.value.id),
            'visibility': 'public',
            'verification_status': 'bundledFallback',
            'monetization_type': _categoryIsPremium(entry.value.id)
                ? 'premium_money_value'
                : 'free',
            'allow_single_unlock': true,
            'single_unlock_currency': 'EUR',
            'premium_reason': _categoryIsPremium(entry.value.id)
                ? _completeLocaleMap(
                    en: 'This category can help save money, reduce bills, or access financial support.',
                    it: 'Questa categoria puo aiutare a risparmiare, ridurre costi o ottenere sostegni economici.',
                  )
                : <String, dynamic>{},
            'premium_teaser': _completeLocaleMap(
              en: localized.descriptionEn,
              it: localized.descriptionIt,
              fr: localized.descriptionFr,
              es: localized.descriptionEs,
              fa: localized.descriptionFa,
              ar: localized.descriptionAr,
            ),
            'metadata': <String, dynamic>{},
          };
          },
        )
        .toList();
  }

  List<Map<String, dynamic>> exportProcedures() {
    final items = <Map<String, dynamic>>[];
    for (final guidance in allGuidance()) {
      for (final entry in guidance.subcategories.asMap().entries) {
        final subcategory = entry.value;
        items.add({
          'id': subcategory.id,
          'slug': subcategory.id,
          'category_slug': guidance.id,
          'subcategory_slug': subcategory.id,
          'title': _completeLocaleMap(
            en: subcategory.title,
            it: subcategory.titleIt,
          ),
          'subtitle': <String, dynamic>{},
          'summary': _completeLocaleMap(
            en: subcategory.whatIsIt,
            it: subcategory.whatIsIt,
          ),
          'what_is_it': _completeLocaleMap(
            en: subcategory.whatIsIt,
            it: subcategory.whatIsIt,
          ),
          'why_you_may_need_it': subcategory.whyDoYouNeedIt,
          'how_to_do_it': subcategory.recommendedChannels,
          'required_documents': subcategory.documents,
          'optional_documents': subcategory.extraDocuments,
          'documents_needed': _completeLocaleMap(
            en: subcategory.documents.join('\n'),
            it: subcategory.documents.join('\n'),
          ),
          'costs_and_timing': const {'en': '', 'it': ''},
          'common_mistakes': subcategory.warnings,
          'warnings': subcategory.warnings,
          'official_links': const [],
          'official_contacts': subcategory.recommendedContacts,
          'checklist': subcategory.documents,
          'faqs': const <dynamic>[],
          'faq': const <dynamic>[],
          'premium_notes': _completeLocaleMap(en: '', it: ''),
          'premium_only_guidance': const <dynamic>[],
          'cta_config': const <String, dynamic>{},
          'verification_status': 'needsReview',
          'sort_order': entry.key + 1,
          'is_active': true,
          'is_premium': _procedureIsPremium(guidance.id, subcategory.id),
          'visibility': 'public',
          'monetization_type': _procedureIsPremium(guidance.id, subcategory.id)
              ? 'premium_money_value'
              : 'free',
          'allow_single_unlock': true,
          'single_unlock_price_cents':
              _procedureIsPremium(guidance.id, subcategory.id) ? 399 : null,
          'single_unlock_currency': 'EUR',
          'premium_reason': _procedureIsPremium(guidance.id, subcategory.id)
              ? _completeLocaleMap(
                  en: 'This guide contains practical financial steps, savings strategy, or benefit access details.',
                  it: 'Questa guida contiene passaggi pratici per risparmiare, ottenere agevolazioni o gestire costi.',
                )
              : <String, dynamic>{},
          'premium_teaser': _completeLocaleMap(
            en: subcategory.whatIsIt,
            it: subcategory.whatIsIt,
          ),
          'metadata': <String, dynamic>{},
        });
      }
    }
    return items;
  }
}

class _CategoryLocalizedContent {
  const _CategoryLocalizedContent({
    required this.titleEn,
    required this.titleIt,
    required this.titleFr,
    required this.titleEs,
    required this.titleFa,
    required this.titleAr,
    required this.questionEn,
    required this.questionIt,
    required this.questionFr,
    required this.questionEs,
    required this.questionFa,
    required this.questionAr,
    required this.descriptionEn,
    required this.descriptionIt,
    required this.descriptionFr,
    required this.descriptionEs,
    required this.descriptionFa,
    required this.descriptionAr,
  });

  final String titleEn;
  final String titleIt;
  final String titleFr;
  final String titleEs;
  final String titleFa;
  final String titleAr;
  final String questionEn;
  final String questionIt;
  final String questionFr;
  final String questionEs;
  final String questionFa;
  final String questionAr;
  final String descriptionEn;
  final String descriptionIt;
  final String descriptionFr;
  final String descriptionEs;
  final String descriptionFa;
  final String descriptionAr;
}

_CategoryLocalizedContent _categoryLocalizedContent(
  String slug, {
  required String defaultTitleEn,
  required String defaultTitleIt,
  required String defaultQuestionEn,
  required String defaultQuestionIt,
  required String defaultDescriptionEn,
  required String defaultDescriptionIt,
}) {
  switch (slug) {
    case 'general':
      return const _CategoryLocalizedContent(
        titleEn: 'General admin help',
        titleIt: 'Aiuto amministrativo generale',
        titleFr: 'Aide administrative générale',
        titleEs: 'Ayuda administrativa general',
        titleFa: 'راهنمای اداری عمومی',
        titleAr: 'مساعدة إدارية عامة',
        questionEn: 'What do you need help with?',
        questionIt: 'In cosa ti serve aiuto?',
        questionFr: 'De quoi avez-vous besoin ?',
        questionEs: '¿En qué necesitas ayuda?',
        questionFa: 'در چه کاری به کمک نیاز داری؟',
        questionAr: 'ما الذي تحتاج إلى مساعدة فيه؟',
        descriptionEn:
            'Not sure where your problem belongs? Start here. We help you choose the right office, reply to a rejected request, send missing documents, ask for a refund, make a complaint, or turn messy notes into formal Italian.',
        descriptionIt:
            'Non sai in quale categoria rientra il tuo problema? Parti da qui. Ti aiutiamo a capire quale ufficio contattare, rispondere a una richiesta respinta, inviare documenti mancanti, chiedere un rimborso, fare un reclamo o trasformare appunti confusi in un italiano formale.',
        descriptionFr:
            'Vous ne savez pas à quelle catégorie appartient votre problème ? Commencez ici. Nous vous aidons à choisir le bon bureau, répondre à un refus, envoyer des documents manquants, demander un remboursement, faire une réclamation ou transformer des notes confuses en italien formel.',
        descriptionEs:
            '¿No sabes en qué categoría encaja tu problema? Empieza aquí. Te ayudamos a elegir la oficina correcta, responder a un rechazo, enviar documentos faltantes, pedir un reembolso, presentar una reclamación o convertir notas confusas en italiano formal.',
        descriptionFa:
            'نمی‌دانی مشکلت به کدام بخش مربوط است؟ از اینجا شروع کن. به تو کمک می‌کنیم اداره درست را پیدا کنی، به رد شدن درخواست پاسخ بدهی، مدارک ناقص را بفرستی، درخواست بازپرداخت ثبت کنی، شکایت بنویسی یا یادداشت‌های به‌هم‌ریخته را به ایتالیایی رسمی تبدیل کنی.',
        descriptionAr:
            'إذا لم تكن متأكداً من القسم المناسب لمشكلتك، ابدأ من هنا. نساعدك على اختيار الجهة الصحيحة، الرد على طلب مرفوض، إرسال المستندات الناقصة، طلب استرداد، تقديم شكوى، أو تحويل الملاحظات غير المرتبة إلى إيطالية رسمية.',
      );
    case 'health_asl':
      return const _CategoryLocalizedContent(
        titleEn: 'Health / ASL',
        titleIt: 'Salute / ASL',
        titleFr: 'Santé / ASL',
        titleEs: 'Salud / ASL',
        titleFa: 'سلامت / ASL',
        titleAr: 'الصحة / ASL',
        questionEn:
            'Do you need help with the health card, SSN registration, your family doctor, or an ASL request?',
        questionIt:
            'Hai bisogno di aiuto con tessera sanitaria, iscrizione al SSN, medico di base o una pratica ASL?',
        questionFr:
            'Avez-vous besoin d’aide pour la carte sanitaire, l’inscription au SSN, le médecin traitant ou une démarche ASL ?',
        questionEs:
            '¿Necesitas ayuda con la tarjeta sanitaria, la inscripción al SSN, el médico de cabecera o un trámite ASL?',
        questionFa:
            'برای کارت سلامت، ثبت‌نام SSN، پزشک خانواده یا یک درخواست ASL به کمک نیاز داری؟',
        questionAr:
            'هل تحتاج إلى مساعدة بخصوص البطاقة الصحية أو التسجيل في SSN أو طبيب الأسرة أو إجراء لدى ASL؟',
        descriptionEn:
            'Use this area for public healthcare access in Italy: health card, SSN registration, doctor choice, ASL documents, and essential health administration.',
        descriptionIt:
            'Usa questa sezione per l’accesso alla sanità pubblica in Italia: tessera sanitaria, iscrizione SSN, scelta del medico, documenti ASL e pratiche sanitarie essenziali.',
        descriptionFr:
            'Utilisez cette section pour l’accès à la santé publique en Italie : carte sanitaire, inscription au SSN, choix du médecin, documents ASL et démarches sanitaires essentielles.',
        descriptionEs:
            'Usa esta sección para el acceso a la sanidad pública en Italia: tarjeta sanitaria, inscripción al SSN, elección de médico, documentos ASL y trámites sanitarios esenciales.',
        descriptionFa:
            'از این بخش برای دسترسی به خدمات درمانی عمومی در ایتالیا استفاده کن: کارت سلامت، ثبت‌نام SSN، انتخاب پزشک، مدارک ASL و کارهای ضروری درمانی.',
        descriptionAr:
            'استخدم هذا القسم للوصول إلى الرعاية الصحية العامة في إيطاليا: البطاقة الصحية، التسجيل في SSN، اختيار الطبيب، مستندات ASL والإجراءات الصحية الأساسية.',
      );
    case 'bonuses-benefits':
    case 'loans-credit':
      return _CategoryLocalizedContent(
        titleEn: defaultTitleEn,
        titleIt: defaultTitleIt,
        titleFr: defaultTitleEn,
        titleEs: defaultTitleEn,
        titleFa: defaultTitleIt,
        titleAr: defaultTitleEn,
        questionEn: defaultQuestionEn,
        questionIt: defaultQuestionIt,
        questionFr: defaultQuestionEn,
        questionEs: defaultQuestionEn,
        questionFa: defaultQuestionIt,
        questionAr: defaultQuestionEn,
        descriptionEn: defaultDescriptionEn,
        descriptionIt: defaultDescriptionIt,
        descriptionFr: defaultDescriptionEn,
        descriptionEs: defaultDescriptionEn,
        descriptionFa: defaultDescriptionIt,
        descriptionAr: defaultDescriptionEn,
      );
    default:
      return _CategoryLocalizedContent(
        titleEn: defaultTitleEn,
        titleIt: defaultTitleIt,
        titleFr: defaultTitleEn,
        titleEs: defaultTitleEn,
        titleFa: defaultTitleIt,
        titleAr: defaultTitleEn,
        questionEn: defaultQuestionEn,
        questionIt: defaultQuestionIt,
        questionFr: defaultQuestionEn,
        questionEs: defaultQuestionEn,
        questionFa: defaultQuestionIt,
        questionAr: defaultQuestionEn,
        descriptionEn: defaultDescriptionEn,
        descriptionIt: defaultDescriptionIt,
        descriptionFr: defaultDescriptionEn,
        descriptionEs: defaultDescriptionEn,
        descriptionFa: defaultDescriptionIt,
        descriptionAr: defaultDescriptionEn,
      );
  }
}

Map<String, String> _completeLocaleMap({
  required String en,
  String? it,
  String? fr,
  String? es,
  String? fa,
  String? ar,
}) {
  final italian = (it == null || it.trim().isEmpty) ? en : it.trim();
  return {
    'en': en.trim(),
    'it': italian,
    'fr': (fr == null || fr.trim().isEmpty) ? en.trim() : fr.trim(),
    'es': (es == null || es.trim().isEmpty) ? en.trim() : es.trim(),
    'fa': (fa == null || fa.trim().isEmpty) ? italian : fa.trim(),
    'ar': (ar == null || ar.trim().isEmpty) ? en.trim() : ar.trim(),
  };
}

bool _categoryIsPremium(String slug) {
  return const {
    'utilities_electricity_gas',
    'canone_rai',
    'housing_rent',
    'work_inps_patronato',
    'university_student',
  }.contains(slug);
}

bool _procedureIsPremium(String categorySlug, String procedureSlug) {
  if (categorySlug == 'health_asl') {
    return procedureSlug.contains('insurance') ||
        procedureSlug.contains('refund') ||
        procedureSlug.contains('reimbursement');
  }
  if (categorySlug == 'general') {
    return procedureSlug.contains('tax') ||
        procedureSlug.contains('refund') ||
        procedureSlug.contains('detrazione');
  }
  return _categoryIsPremium(categorySlug);
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
