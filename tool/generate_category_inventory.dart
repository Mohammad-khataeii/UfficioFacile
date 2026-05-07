import 'dart:convert';
import 'dart:io';

import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_authority_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_catalog_sources.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_city_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_official_contacts.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_official_links.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_procedure_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_provider_forms.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_region_guidance.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_service_terms.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_source_references.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/catalog/bundled_submission_channels.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/procedure_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/service_intelligence_definitions.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/data/service_terms_dictionary.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/admin_procedure.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/attachment_item.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/catalog_models.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/procedure_field.dart';
import 'package:ufficiofacile/features/italy_admin_copilot/domain/service_intelligence.dart';

const _docsDir = 'docs';
const _inventoryMdPath = 'docs/UFFICIOFACILE_FULL_CATEGORY_DATA_INVENTORY.md';
const _inventoryJsonPath = 'docs/ufficiofacile_category_data_inventory.json';
const _gapsMdPath = 'docs/UFFICIOFACILE_RESEARCH_GAPS.md';
const _tasksMdPath = 'docs/UFFICIOFACILE_RESEARCH_TASKS_BY_CATEGORY.md';

void main() {
  final procedures = ItalyAdminProcedureDefinitions.all();
  final serviceIntelligence = {
    for (final procedure in procedures)
      procedure.id: ServiceIntelligenceDefinitions.forProcedure(procedure),
  };
  final procedureGuidance = {
    for (final guidance in bundledProcedureGuidance)
      guidance.procedureId: guidance,
  };
  final officialLinksById = {
    for (final link in bundledOfficialLinks) link.id: link,
  };
  final officialContactsById = {
    for (final contact in bundledOfficialContacts) contact.id: contact,
  };
  final sourceReferencesById = {
    for (final reference in bundledSourceReferences) reference.id: reference,
  };
  final providersById = {
    for (final provider in bundledServiceProviders) provider.id: provider,
  };
  final formsByProviderId = <String, List<ProviderForm>>{};
  for (final form in bundledProviderForms) {
    formsByProviderId.putIfAbsent(form.providerId, () => []).add(form);
  }

  final categoryGroups = <ProcedureCategory, List<AdminProcedure>>{};
  for (final procedure in procedures) {
    categoryGroups.putIfAbsent(procedure.category, () => []).add(procedure);
  }

  final allStatusValues = <String>[
    ...bundledCatalogSources.map((item) => item.verificationStatus.name),
    ...bundledOfficialLinks.map((item) => item.verificationStatus.name),
    ...bundledOfficialContacts.map((item) => item.verificationStatus.name),
    ...bundledServiceProviders.map((item) => item.verificationStatus.name),
    ...bundledProviderForms.map((item) => item.verificationStatus.name),
    ...bundledRegionGuidance.map((item) => item.verificationStatus.name),
    ...bundledCityGuidance.map((item) => item.verificationStatus.name),
    ...bundledAuthorityGuidance.map((item) => item.verificationStatus.name),
    ...bundledProcedureGuidance.map((item) => item.verificationStatus.name),
    ...bundledSourceReferences.map((item) => item.verificationStatus.name),
    ...bundledServiceTerms.map((item) => item.verificationStatus.name),
    ...bundledSubmissionChannels.map((item) => item.verificationStatus.name),
    ...serviceIntelligence.values.map((item) => item.verificationStatus.name),
  ];
  final verifiedCount = allStatusValues
      .where((item) => item == 'verified')
      .length;
  final needsReviewCount = allStatusValues
      .where((item) => item == 'needsReview')
      .length;
  final unverifiedCount = allStatusValues
      .where((item) => item == 'unverified')
      .length;

  final categorySummary =
      categoryGroups.entries
          .map(
            (entry) => _buildCategorySummary(
              entry.key,
              entry.value,
              procedureGuidance,
            ),
          )
          .toList()
        ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

  final procedureObjects = procedures
      .map(
        (procedure) => _buildProcedureInventory(
          procedure,
          serviceIntelligence[procedure.id]!,
          procedureGuidance[procedure.id],
          officialLinksById,
          officialContactsById,
          sourceReferencesById,
          providersById,
          formsByProviderId,
        ),
      )
      .toList();

  final summary = {
    'categoryCount': categoryGroups.length,
    'subcategoryCount': procedures
        .map((item) => item.subcategory)
        .toSet()
        .length,
    'procedureCount': procedures.length,
    'providerCount': bundledServiceProviders.length,
    'officialLinkCount': bundledOfficialLinks.length,
    'officialContactCount': bundledOfficialContacts.length,
    'verifiedCount': verifiedCount,
    'needsReviewCount': needsReviewCount,
    'unverifiedCount': unverifiedCount,
  };

  final terms = _buildTermsInventory();
  final cities = bundledCityGuidance.map(_cityToJson).toList();
  final regions = bundledRegionGuidance.map(_regionToJson).toList();
  final providers = bundledServiceProviders
      .map(
        (provider) => _providerToJson(
          provider,
          formsByProviderId[provider.id] ?? const [],
        ),
      )
      .toList();
  final officialLinks = bundledOfficialLinks.map(_officialLinkToJson).toList();
  final officialContacts = bundledOfficialContacts
      .map(_officialContactToJson)
      .toList();
  final sourceReferences = bundledSourceReferences
      .map(_sourceReferenceToJson)
      .toList();

  final researchTasks = categoryGroups.entries
      .map((entry) => _buildResearchTask(entry.key, entry.value))
      .toList();

  final jsonOutput = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'summary': summary,
    'categories': categorySummary,
    'procedures': procedureObjects,
    'providers': providers,
    'cities': cities,
    'regions': regions,
    'terms': terms,
    'officialLinks': officialLinks,
    'officialContacts': officialContacts,
    'sourceReferences': sourceReferences,
    'researchTasks': researchTasks,
  };

  _writeFile(
    _inventoryJsonPath,
    const JsonEncoder.withIndent('  ').convert(jsonOutput),
  );
  _writeFile(
    _inventoryMdPath,
    _buildMarkdownReport(
      summary: summary,
      categorySummary: categorySummary,
      procedures: procedureObjects,
      providers: providers,
      cities: cities,
      regions: regions,
      terms: terms,
    ),
  );
  _writeFile(_gapsMdPath, _buildResearchGapsMarkdown(procedureObjects));
  _writeFile(_tasksMdPath, _buildResearchTasksMarkdown(categoryGroups));
}

Map<String, dynamic> _buildCategorySummary(
  ProcedureCategory category,
  List<AdminProcedure> procedures,
  Map<String, ProcedureGuidance> guidanceByProcedureId,
) {
  final maturity = procedures
      .map(
        (procedure) => _maturityForProcedure(
          procedure,
          guidanceByProcedureId[procedure.id],
        ),
      )
      .toSet()
      .toList();
  final missing = <String>{
    if (category == ProcedureCategory.health)
      'Exact ASL email/PEC/office finder coverage is still sparse.'
    else if (category == ProcedureCategory.housing)
      'No exact landlord/agency PEC, address, or raccomandata targets are stored.'
    else if (category == ProcedureCategory.utilities)
      'Provider-specific forms, PEC, and complaint channels are mostly missing.'
    else if (category == ProcedureCategory.telecom)
      'Provider cancellation and complaint contacts remain mostly unverified placeholders.'
    else if (category == ProcedureCategory.publicOffice)
      'Comune appointment links, PEC, and office-finder coverage are incomplete.'
    else if (category == ProcedureCategory.work)
      'INPS/Patronato office-level contacts and forms are limited.'
    else if (category == ProcedureCategory.university)
      'University-specific office links and helpdesk contacts are largely absent.'
    else if (category == ProcedureCategory.canoneRai)
      'Official forms and deadline-specific submission data remain incomplete.'
    else
      'Operational contact and form details are still generic in several flows.',
  };
  return {
    'id': category.name,
    'name': category.label,
    'localizedNames': <String, String>{},
    'subcategories': procedures
        .map((item) => item.subcategory)
        .toSet()
        .toList(),
    'procedureIds': procedures.map((item) => item.id).toList(),
    'maturity': maturity.contains('Missing real data')
        ? 'Missing real data'
        : maturity.contains('Generic')
        ? 'Generic'
        : 'Partial',
    'missingDataSummary': missing.toList(),
  };
}

Map<String, dynamic> _buildProcedureInventory(
  AdminProcedure procedure,
  ServiceIntelligence intelligence,
  ProcedureGuidance? guidance,
  Map<String, OfficialLink> officialLinksById,
  Map<String, OfficialContact> officialContactsById,
  Map<String, SourceReference> sourceReferencesById,
  Map<String, ServiceProvider> providersById,
  Map<String, List<ProviderForm>> formsByProviderId,
) {
  final guidanceLinks = (guidance?.officialLinkIds ?? const <String>[])
      .map((id) => officialLinksById[id])
      .whereType<OfficialLink>()
      .toList();
  final guidanceContacts = (guidance?.officialContactIds ?? const <String>[])
      .map((id) => officialContactsById[id])
      .whereType<OfficialContact>()
      .toList();
  final sourceReferences = (guidance?.sourceReferenceIds ?? const <String>[])
      .map((id) => sourceReferencesById[id])
      .whereType<SourceReference>()
      .toList();
  final providers = (guidance?.providerIds ?? const <String>[])
      .map((id) => providersById[id])
      .whereType<ServiceProvider>()
      .toList();
  final providerForms = providers
      .expand(
        (provider) => formsByProviderId[provider.id] ?? const <ProviderForm>[],
      )
      .toList();
  final fieldRows = procedure.fields.map(_fieldToJson).toList();
  final attachmentRows = procedure.attachmentSuggestions
      .map(_attachmentToJson)
      .toList();
  final generatedOutputs = _generatedOutputsFor(
    procedure,
    guidance,
    intelligence,
  );
  final missingData = _missingDataForProcedure(
    procedure: procedure,
    guidance: guidance,
    contacts: guidanceContacts,
    links: guidanceLinks,
    references: sourceReferences,
    providers: providers,
  );
  return {
    'id': procedure.id,
    'title': procedure.title,
    'category': procedure.category.label,
    'subcategory': procedure.subcategory,
    'difficulty': procedure.difficulty.label,
    'estimatedTime': procedure.estimatedMinutes,
    'isPremium': procedure.isPremium,
    'tags': procedure.tags,
    'sourceFile':
        'lib/features/italy_admin_copilot/data/procedure_definitions.dart',
    'shortDescription': procedure.shortDescription,
    'longDescription': procedure.longDescription,
    'authorityType': procedure.authorityType,
    'targetRecipientExamples': procedure.targetRecipientExamples,
    'fields': fieldRows,
    'attachments': attachmentRows,
    'generatedOutputs': generatedOutputs,
    'serviceIntelligence': {
      'exists': true,
      'destinationGuidance': intelligence.destinationGuidance,
      'responsibleAuthority': intelligence.responsibleAuthorityType,
      'submissionChannels': guidance?.submissionChannelIds ?? <String>[],
      'onlineOptions': intelligence.onlineOptions
          .map(
            (item) => {
              'title': item.title,
              'description': item.description,
              'url': item.url,
              'requiresSpid': item.requiresSpid,
              'requiresCie': item.requiresCie,
              'requiresPec': item.requiresPec,
              'verificationStatus': item.verificationStatus.name,
            },
          )
          .toList(),
      'inPersonOptions': intelligence.inPersonOptions
          .map(
            (item) => {
              'title': item.title,
              'description': item.description,
              'address': item.address,
              'officeFinderLink': item.officeFinderLink,
              'documentsToBring': item.documentsToBring,
              'verificationStatus': item.verificationStatus.name,
            },
          )
          .toList(),
      'documentsDetailed': {
        'required': intelligence.requiredDocumentsDetailed
            .map(_documentReqToJson)
            .toList(),
        'recommended': intelligence.recommendedDocumentsDetailed
            .map(_documentReqToJson)
            .toList(),
        'conditional': intelligence.situationSpecificDocuments
            .map(_documentReqToJson)
            .toList(),
      },
      'beforeSendingChecklist': [
        ...intelligence.beforeSendingChecklist,
        ...?guidance?.beforeSendingChecklist,
      ],
      'followUpGuidance': intelligence.followUpGuidance,
      'rejectionGuidance': intelligence.rejectionGuidance,
      'escalationGuidance': intelligence.escalationGuidance,
      'cityRegionNotes': [
        ...intelligence.citySpecificNotes,
        ...intelligence.regionSpecificNotes,
      ],
      'providerNotes': intelligence.providerSpecificNotes,
      'verificationStatus': intelligence.verificationStatus.name,
      'sourceFile':
          'lib/features/italy_admin_copilot/data/service_intelligence_definitions.dart',
      'bundledProcedureGuidanceSource': guidance == null
          ? null
          : 'lib/features/italy_admin_copilot/data/catalog/bundled_procedure_guidance.dart',
    },
    'officialLinks': guidanceLinks.map(_officialLinkToJson).toList(),
    'officialContacts': guidanceContacts.map(_officialContactToJson).toList(),
    'sourceReferences': sourceReferences.map(_sourceReferenceToJson).toList(),
    'providers': providers
        .map(
          (provider) => {
            'id': provider.id,
            'name': provider.name,
            'verificationStatus': provider.verificationStatus.name,
            'websiteUrl': provider.websiteUrl,
            'customerAreaUrl': provider.customerAreaUrl,
          },
        )
        .toList(),
    'providerForms': providerForms
        .map(
          (form) => {
            'id': form.id,
            'providerId': form.providerId,
            'title': form.title,
            'url': form.url,
            'verificationStatus': form.verificationStatus.name,
            'submissionChannels': form.submissionChannels,
          },
        )
        .toList(),
    'cityRegionDependencies': {
      'requiresCityOrRegion': _requiresCityOrRegion(procedure),
      'coveredCities': _coveredCitiesForProcedure(procedure.id),
      'coveredRegions': _coveredRegionsForProcedure(procedure.id),
    },
    'maturity': _maturityForProcedure(procedure, guidance),
    'missingData': missingData,
    'researchPriority': _researchPriority(
      procedure,
      guidance,
      guidanceContacts,
      guidanceLinks,
    ),
    'researchQueries': _researchQueriesForProcedure(procedure),
  };
}

Map<String, dynamic> _fieldToJson(ProcedureField field) => {
  'id': field.id,
  'label': field.label,
  'type': field.type.name,
  'required': field.required,
  'options': field.options
      .map(
        (option) => {
          'value': option.value,
          'label': option.label,
          'description': option.description,
        },
      )
      .toList(),
  'helpText': field.helpText,
  'conditional': field.showWhen?.toJson(),
  'section': field.section,
};

Map<String, dynamic> _attachmentToJson(AttachmentSuggestion item) => {
  'id': item.id,
  'name': item.name,
  'requiredLevel': item.required ? 'Required' : 'Recommended',
  'description': item.description,
  'category': item.category.name,
};

Map<String, dynamic> _documentReqToJson(DocumentRequirementDetailed item) => {
  'id': item.id,
  'name': item.name,
  'requiredLevel': item.requiredLevel.name,
  'description': item.description,
  'whenNeeded': item.whenNeeded,
  'examples': item.examples,
  'relatedDocumentType': item.relatedDocumentType,
  'canUseCopy': item.canUseCopy,
  'warning': item.warning,
};

Map<String, dynamic> _officialLinkToJson(OfficialLink item) => {
  'id': item.id,
  'title': item.title,
  'url': item.url,
  'sourceUrl': item.sourceUrl,
  'sourceLabel': item.sourceLabel,
  'verificationStatus': item.verificationStatus.name,
  'lastVerifiedAt': item.lastVerifiedAt?.toIso8601String(),
  'notes': item.notes,
};

Map<String, dynamic> _officialContactToJson(OfficialContact item) => {
  'id': item.id,
  'label': item.label,
  'type': item.contactType,
  'value': item.value,
  'displayValue': item.displayValue,
  'jurisdiction': item.jurisdiction,
  'region': item.region,
  'city': item.city,
  'provider': item.providerName,
  'sourceUrl': item.sourceUrl,
  'sourceLabel': item.sourceLabel,
  'verificationStatus': item.verificationStatus.name,
  'lastVerifiedAt': item.lastVerifiedAt?.toIso8601String(),
};

Map<String, dynamic> _sourceReferenceToJson(SourceReference item) => {
  'id': item.id,
  'title': item.title,
  'type': item.sourceType,
  'url': item.url,
  'verificationStatus': item.verificationStatus.name,
  'referenceLabel': item.referenceLabel,
  'relevance': item.relevance,
  'notes': item.warning,
};

Map<String, dynamic> _providerToJson(
  ServiceProvider provider,
  List<ProviderForm> forms,
) {
  return {
    'id': provider.id,
    'name': provider.name,
    'category': provider.category,
    'normalizedName': provider.id,
    'website': provider.websiteUrl,
    'customerArea': provider.customerAreaUrl,
    'verificationStatus': provider.verificationStatus.name,
    'lastVerifiedAt': provider.lastVerifiedAt?.toIso8601String(),
    'sourceReferences': provider.sourceReferences,
    'contactOptions': provider.contactOptions
        .map(
          (item) => {
            'type': item.contactType,
            'label': item.label,
            'value': item.value,
            'url': item.url,
            'sourceUrl': item.sourceUrl,
            'verificationStatus': item.verificationStatus.name,
          },
        )
        .toList(),
    'forms': forms
        .map(
          (item) => {
            'type': item.formType,
            'title': item.title,
            'url': item.url,
            'submissionChannels': item.submissionChannels,
            'verificationStatus': item.verificationStatus.name,
          },
        )
        .toList(),
    'guidance': {
      'cancellation': provider.cancellationGuidance,
      'complaint': provider.complaintGuidance,
      'paymentPlan': provider.paymentPlanGuidance,
      'modemReturn': provider.modemReturnGuidance,
    },
  };
}

Map<String, dynamic> _cityToJson(CityGuidance item) => {
  'id': item.id,
  'city': item.city,
  'region': item.region,
  'category': item.category,
  'title': item.title,
  'sourceUrl': item.sourceUrl,
  'verificationStatus': item.verificationStatus.name,
  'officeLinks': item.officeLinks.map(_officialLinkToJson).toList(),
};

Map<String, dynamic> _regionToJson(RegionGuidance item) => {
  'id': item.id,
  'region': item.region,
  'category': item.category,
  'title': item.title,
  'sourceUrl': item.sourceUrl,
  'verificationStatus': item.verificationStatus.name,
  'portalLinks': item.portalLinks.map(_officialLinkToJson).toList(),
};

List<Map<String, dynamic>> _buildTermsInventory() {
  final bundledById = {for (final term in bundledServiceTerms) term.id: term};
  return ServiceTermsDictionary.all().map((item) {
    final bundled = bundledById[item.id];
    return {
      'id': item.id,
      'term': item.term,
      'shortDefinition': item.shortDefinition,
      'longExplanation': item.longExplanation,
      'relatedLinks': item.relatedLinks,
      'providers': item.providers,
      'warnings': item.warnings,
      'catalogTerm': bundled == null
          ? null
          : {
              'verificationStatus': bundled.verificationStatus.name,
              'relatedLinks': bundled.relatedLinks,
              'providerExamples': bundled.providerExamples,
            },
      'localizationStatus': bundled == null
          ? 'Dictionary only, mostly English strings.'
          : 'Dictionary text is English-only; bundled catalog fallback currently localizes mainly en/it.',
    };
  }).toList();
}

Map<String, dynamic> _generatedOutputsFor(
  AdminProcedure procedure,
  ProcedureGuidance? guidance,
  ServiceIntelligence intelligence,
) {
  final specificIds = <String>{
    'CHANGE_DOCTOR',
    'TESSERA_SANITARIA_RENEWAL',
    'ASL_REJECTED_REQUEST_REPLY',
    'ASL_APPOINTMENT_REQUEST',
    'RENTAL_CONTRACT_CHANGE',
    'DEPOSIT_RETURN_REQUEST',
    'RENT_CONTRACT_TERMINATION_NOTICE',
    'NASPI_PREPARATION',
    'PATRONATO_APPOINTMENT_REQUEST',
    'REJECTED_REQUEST_REPLY',
    'UNIVERSITY_OFFICE_REQUEST',
    'LANDLORD_MAINTENANCE_OR_CONTRACT',
    'GENERIC_FORMAL_REQUEST',
    'COMUNE_RESIDENCE_REQUEST',
    'ANAGRAFE_CERTIFICATE_REQUEST',
    'PERMESSO_DOCUMENT_CHECKLIST',
    'REFUND_OR_COMPLAINT_REQUEST',
    'APPOINTMENT_REQUEST',
  };
  final specificity = specificIds.contains(procedure.id)
      ? 'specific'
      : 'generic';
  return {
    'normalEmail': specificity,
    'pecVersion': specificity,
    'whatsAppMessage': specificity,
    'raccomandataVersion': 'no',
    'followUp': specificity,
    'strongFollowUp': specificity,
    'inPersonChecklist':
        intelligence.inPersonOptions.isNotEmpty ||
            intelligence.inPersonChecklist.isNotEmpty
        ? 'yes'
        : 'no',
    'onlinePortalChecklist': intelligence.onlineOptions.isNotEmpty
        ? 'yes'
        : 'no',
    'proofChecklist': (guidance?.proofItems.isNotEmpty ?? false) ? 'yes' : 'no',
    'providerSpecificInstructions': (guidance?.providerIds.isNotEmpty ?? false)
        ? 'yes'
        : 'no',
    'cityRegionSpecificInstructions': _requiresCityOrRegion(procedure)
        ? 'yes'
        : 'no',
  };
}

Map<String, dynamic> _missingDataForProcedure({
  required AdminProcedure procedure,
  required ProcedureGuidance? guidance,
  required List<OfficialContact> contacts,
  required List<OfficialLink> links,
  required List<SourceReference> references,
  required List<ServiceProvider> providers,
}) {
  final contactTypes = contacts.map((item) => item.contactType).toSet();
  final hasExactEmail = contacts.any(
    (item) => item.contactType == 'email' && (item.value ?? '').isNotEmpty,
  );
  final hasExactPec = contacts.any(
    (item) => item.contactType == 'pec' && (item.value ?? '').isNotEmpty,
  );
  final hasExactAddress = contacts.any(
    (item) => item.contactType == 'address' && (item.value ?? '').isNotEmpty,
  );
  final hasPhone = contacts.any(
    (item) => item.contactType == 'phone' && (item.value ?? '').isNotEmpty,
  );
  final hasOfficeFinder = contactTypes.contains('officeFinder');
  final hasFormLink = links.any(
    (item) => item.category.toLowerCase().contains('form'),
  );
  final missing = <String, dynamic>{
    'emails': hasExactEmail
        ? <String>[]
        : <String>['Exact official email not currently stored.'],
    'pecs': hasExactPec
        ? <String>[]
        : <String>['Exact official PEC not currently stored.'],
    'addresses': hasExactAddress
        ? <String>[]
        : <String>[
            'Exact physical office or postal address not currently stored.',
          ],
    'phoneNumbers': hasPhone
        ? <String>[]
        : <String>['Official phone number not currently stored.'],
    'forms': hasFormLink
        ? <String>[]
        : <String>[
            'Official form link not currently stored or not mapped to this procedure.',
          ],
    'officeFinders': hasOfficeFinder
        ? <String>[]
        : <String>['Office finder or local desk selector missing.'],
    'officialLinks': links.isNotEmpty
        ? <String>[]
        : <String>[
            'No concrete official link is currently attached to this procedure.',
          ],
    'legalReferences': references.isNotEmpty
        ? <String>[]
        : <String>['No concrete source/legal reference is currently attached.'],
    'providerSpecific':
        providers.isNotEmpty ||
            procedure.category != ProcedureCategory.telecom &&
                procedure.category != ProcedureCategory.utilities
        ? <String>[]
        : <String>[
            'Provider-specific channel, form, and contact data are missing.',
          ],
    'translations': <String>[
      'Localized guidance coverage is incomplete in several production screens.',
    ],
  };
  if (guidance == null) {
    (missing['officialLinks'] as List<String>).add(
      'Only fallback generic guidance is available.',
    );
  }
  return missing;
}

String _maturityForProcedure(
  AdminProcedure procedure,
  ProcedureGuidance? guidance,
) {
  final hasSpecificGuidance = guidance != null;
  final hasRealLinks = (guidance?.officialLinkIds.isNotEmpty ?? false);
  final hasContacts = (guidance?.officialContactIds.isNotEmpty ?? false);
  final hasProviders = (guidance?.providerIds.isNotEmpty ?? false);
  if (hasSpecificGuidance && hasRealLinks && (hasContacts || hasProviders)) {
    return 'Partial';
  }
  if (hasSpecificGuidance && hasRealLinks) {
    return 'Generic';
  }
  if (procedure.category == ProcedureCategory.health ||
      procedure.category == ProcedureCategory.telecom ||
      procedure.category == ProcedureCategory.utilities ||
      procedure.category == ProcedureCategory.publicOffice) {
    return 'Missing real data';
  }
  return 'Generic';
}

String _researchPriority(
  AdminProcedure procedure,
  ProcedureGuidance? guidance,
  List<OfficialContact> contacts,
  List<OfficialLink> links,
) {
  if (guidance == null || links.isEmpty) return 'High';
  if (contacts.isEmpty &&
      (procedure.category == ProcedureCategory.health ||
          procedure.category == ProcedureCategory.publicOffice ||
          procedure.category == ProcedureCategory.telecom ||
          procedure.category == ProcedureCategory.utilities)) {
    return 'High';
  }
  if (procedure.category == ProcedureCategory.general) return 'Medium';
  return 'Medium';
}

bool _requiresCityOrRegion(AdminProcedure procedure) =>
    procedure.category == ProcedureCategory.health ||
    procedure.category == ProcedureCategory.publicOffice;

List<String> _coveredCitiesForProcedure(String procedureId) {
  return bundledCityGuidance
      .where((item) => item.procedureIds.contains(procedureId))
      .map((item) => item.city)
      .toList();
}

List<String> _coveredRegionsForProcedure(String procedureId) {
  return bundledRegionGuidance
      .where((item) => item.procedureIds.contains(procedureId))
      .map((item) => item.region)
      .toList();
}

List<String> _researchQueriesForProcedure(AdminProcedure procedure) {
  switch (procedure.category) {
    case ProcedureCategory.health:
      return [
        '${procedure.subcategory} official ASL contact ${procedure.title}',
        '${procedure.subcategory} PEC ASL official site',
        '${procedure.subcategory} region portal official',
      ];
    case ProcedureCategory.housing:
      return [
        '${procedure.subcategory} raccomandata A/R Italy official guidance',
        '${procedure.subcategory} Agenzia Entrate contract official',
        '${procedure.subcategory} landlord PEC contract notice Italy',
      ];
    case ProcedureCategory.utilities:
      return [
        '${procedure.subcategory} provider official complaint form Italy',
        '${procedure.subcategory} ARERA Portale Offerte official',
        '${procedure.subcategory} provider PEC reclami official',
      ];
    case ProcedureCategory.canoneRai:
      return [
        '${procedure.subcategory} Agenzia Entrate official form',
        '${procedure.subcategory} Canone RAI official declaration official',
      ];
    case ProcedureCategory.telecom:
      return [
        '${procedure.subcategory} provider disdetta official site',
        '${procedure.subcategory} AGCOM ConciliaWeb official',
        '${procedure.subcategory} modem return official provider',
      ];
    case ProcedureCategory.publicOffice:
      return [
        '${procedure.subcategory} Comune official appointment',
        '${procedure.subcategory} anagrafe PEC official',
        '${procedure.subcategory} residenza office finder official',
      ];
    case ProcedureCategory.work:
      return [
        '${procedure.subcategory} INPS NASpI official',
        '${procedure.subcategory} patronato appointment official',
      ];
    case ProcedureCategory.university:
      return [
        '${procedure.subcategory} university student office official',
        '${procedure.subcategory} international office official',
      ];
    default:
      return [
        '${procedure.subcategory} official form Italy',
        '${procedure.subcategory} PEC official guidance Italy',
      ];
  }
}

Map<String, dynamic> _buildResearchTask(
  ProcedureCategory category,
  List<AdminProcedure> procedures,
) {
  return {
    'category': category.label,
    'procedureIds': procedures.map((item) => item.id).toList(),
    'searchTargets': procedures
        .expand(_researchQueriesForProcedure)
        .toSet()
        .toList(),
  };
}

String _buildMarkdownReport({
  required Map<String, dynamic> summary,
  required List<Map<String, dynamic>> categorySummary,
  required List<Map<String, dynamic>> procedures,
  required List<Map<String, dynamic>> providers,
  required List<Map<String, dynamic>> cities,
  required List<Map<String, dynamic>> regions,
  required List<Map<String, dynamic>> terms,
}) {
  final buffer = StringBuffer()
    ..writeln('# UfficioFacile Full Category Data Inventory')
    ..writeln()
    ..writeln('## 1. Executive Summary')
    ..writeln()
    ..writeln('- total number of categories found: ${summary['categoryCount']}')
    ..writeln(
      '- total number of subcategories found: ${summary['subcategoryCount']}',
    )
    ..writeln(
      '- total number of procedures found: ${summary['procedureCount']}',
    )
    ..writeln('- total number of providers found: ${summary['providerCount']}')
    ..writeln(
      '- total number of official links found: ${summary['officialLinkCount']}',
    )
    ..writeln(
      '- total number of official contacts found: ${summary['officialContactCount']}',
    )
    ..writeln('- total number of verified items: ${summary['verifiedCount']}')
    ..writeln(
      '- total number of needsReview items: ${summary['needsReviewCount']}',
    )
    ..writeln(
      '- total number of unverified items: ${summary['unverifiedCount']}',
    )
    ..writeln(
      '- biggest missing data areas: exact ASL contacts, provider complaint/disdetta forms, Comune appointment/office finders, university office links, official PEC/email/address/phone coverage.',
    )
    ..writeln()
    ..writeln('## 2. Category Map')
    ..writeln();

  for (final category in categorySummary) {
    buffer
      ..writeln('- ${category['name']}')
      ..writeln('  - category ID/name: ${category['id']} / ${category['name']}')
      ..writeln(
        '  - subcategories: ${(category['subcategories'] as List).join(', ')}',
      )
      ..writeln(
        '  - procedure IDs: ${(category['procedureIds'] as List).join(', ')}',
      )
      ..writeln('  - current maturity score: ${category['maturity']}')
      ..writeln(
        '  - notes: ${(category['missingDataSummary'] as List).join(' ')}',
      );
  }

  buffer
    ..writeln()
    ..writeln('## 3. Full Procedure Inventory')
    ..writeln();

  for (final procedure in procedures) {
    buffer
      ..writeln('### Procedure: ${procedure['id']}')
      ..writeln()
      ..writeln('Basic:')
      ..writeln('- Title: ${procedure['title']}')
      ..writeln('- Category: ${procedure['category']}')
      ..writeln('- Subcategory: ${procedure['subcategory']}')
      ..writeln('- Difficulty: ${procedure['difficulty']}')
      ..writeln('- Estimated time: ${procedure['estimatedTime']} minutes')
      ..writeln(
        '- Free/Pro: ${procedure['isPremium'] == true ? 'Pro' : 'Free'}',
      )
      ..writeln('- Tags: ${(procedure['tags'] as List).join(', ')}')
      ..writeln('- Source file: ${procedure['sourceFile']}')
      ..writeln()
      ..writeln('Current UI/help:')
      ..writeln('- Short description: ${procedure['shortDescription']}')
      ..writeln('- Long description: ${procedure['longDescription']}')
      ..writeln('- What this generates: ${procedure['generatedOutputs']}')
      ..writeln(
        '- Warnings: ${((procedure['serviceIntelligence'] as Map)['beforeSendingChecklist'] as List).join(' | ')}',
      )
      ..writeln(
        '- User-facing guidance currently shown: ${((procedure['serviceIntelligence'] as Map)['destinationGuidance'] as String)}',
      )
      ..writeln()
      ..writeln('Form fields:')
      ..writeln(
        '| Field ID | Label | Type | Required? | Options | Help Text | Conditional? |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
    for (final field in (procedure['fields'] as List)) {
      final options = ((field as Map)['options'] as List)
          .map((item) => (item as Map)['label'])
          .join(', ');
      buffer.writeln(
        '| ${field['id']} | ${field['label']} | ${field['type']} | ${field['required']} | $options | ${field['helpText'] ?? ''} | ${field['conditional'] ?? ''} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Attachments:')
      ..writeln(
        '| Name | Required/Recommended/Optional | Description | Current status |',
      )
      ..writeln('| --- | --- | --- | --- |');
    for (final attachment in (procedure['attachments'] as List)) {
      final item = attachment as Map;
      buffer.writeln(
        '| ${item['name']} | ${item['requiredLevel']} | ${item['description']} | suggested attachment |',
      );
    }
    final outputs = procedure['generatedOutputs'] as Map;
    buffer
      ..writeln()
      ..writeln('Generated outputs:')
      ..writeln('- Normal email: ${outputs['normalEmail']}')
      ..writeln('- PEC version: ${outputs['pecVersion']}')
      ..writeln('- WhatsApp message: ${outputs['whatsAppMessage']}')
      ..writeln('- Raccomandata version: ${outputs['raccomandataVersion']}')
      ..writeln('- Follow-up: ${outputs['followUp']}')
      ..writeln('- Strong follow-up: ${outputs['strongFollowUp']}')
      ..writeln('- In-person checklist: ${outputs['inPersonChecklist']}')
      ..writeln(
        '- Online portal checklist: ${outputs['onlinePortalChecklist']}',
      )
      ..writeln('- Proof checklist: ${outputs['proofChecklist']}')
      ..writeln(
        '- Provider-specific instructions: ${outputs['providerSpecificInstructions']}',
      )
      ..writeln(
        '- City/region-specific instructions: ${outputs['cityRegionSpecificInstructions']}',
      )
      ..writeln()
      ..writeln('Service intelligence:')
      ..writeln('- Exists? yes')
      ..writeln(
        '- Destination guidance: ${((procedure['serviceIntelligence'] as Map)['destinationGuidance'] as String)}',
      )
      ..writeln(
        '- Responsible authority: ${((procedure['serviceIntelligence'] as Map)['responsibleAuthority'] as String)}',
      )
      ..writeln(
        '- Submission channels: ${(((procedure['serviceIntelligence'] as Map)['submissionChannels']) as List).join(', ')}',
      )
      ..writeln(
        '- Online options: ${jsonEncode(((procedure['serviceIntelligence'] as Map)['onlineOptions']))}',
      )
      ..writeln(
        '- In-person options: ${jsonEncode(((procedure['serviceIntelligence'] as Map)['inPersonOptions']))}',
      )
      ..writeln(
        '- Documents detailed: ${jsonEncode(((procedure['serviceIntelligence'] as Map)['documentsDetailed']))}',
      )
      ..writeln(
        '- Before-sending checklist: ${(((procedure['serviceIntelligence'] as Map)['beforeSendingChecklist']) as List).join(' | ')}',
      )
      ..writeln(
        '- Follow-up guidance: ${((procedure['serviceIntelligence'] as Map)['followUpGuidance'] as String)}',
      )
      ..writeln(
        '- Rejection guidance: ${((procedure['serviceIntelligence'] as Map)['rejectionGuidance'] as String)}',
      )
      ..writeln(
        '- Escalation guidance: ${((procedure['serviceIntelligence'] as Map)['escalationGuidance'] as String)}',
      )
      ..writeln(
        '- City/region notes: ${(((procedure['serviceIntelligence'] as Map)['cityRegionNotes']) as List).join(' | ')}',
      )
      ..writeln(
        '- Provider notes: ${(((procedure['serviceIntelligence'] as Map)['providerNotes']) as List).join(' | ')}',
      )
      ..writeln(
        '- Verification status: ${((procedure['serviceIntelligence'] as Map)['verificationStatus'] as String)}',
      )
      ..writeln(
        '- Source file: ${((procedure['serviceIntelligence'] as Map)['sourceFile'] as String)}',
      )
      ..writeln()
      ..writeln('Official links currently stored:')
      ..writeln(
        '| Title | URL | Source URL | Verification Status | Last Verified | Notes |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final link in (procedure['officialLinks'] as List)) {
      final item = link as Map;
      buffer.writeln(
        '| ${item['title']} | ${item['url'] ?? ''} | ${item['sourceUrl'] ?? ''} | ${item['verificationStatus']} | ${item['lastVerifiedAt'] ?? ''} | ${item['notes'] ?? ''} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Official contacts currently stored:')
      ..writeln(
        '| Label | Type | Value | City/Region/Provider | Source URL | Verification Status | Last Verified | Notes |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final contact in (procedure['officialContacts'] as List)) {
      final item = contact as Map;
      final place = [item['city'], item['region'], item['provider']]
          .where((value) => value != null && value.toString().isNotEmpty)
          .join(' / ');
      buffer.writeln(
        '| ${item['label']} | ${item['type']} | ${item['displayValue'] ?? item['value'] ?? ''} | $place | ${item['sourceUrl'] ?? ''} | ${item['verificationStatus']} | ${item['lastVerifiedAt'] ?? ''} | ${item['sourceLabel'] ?? ''} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Source/legal/authority references:')
      ..writeln(
        '| Title | Type | URL | Verification Status | Relevance | Notes |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final ref in (procedure['sourceReferences'] as List)) {
      final item = ref as Map;
      buffer.writeln(
        '| ${item['title']} | ${item['type']} | ${item['url'] ?? ''} | ${item['verificationStatus']} | ${jsonEncode(item['relevance'])} | ${jsonEncode(item['notes'])} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Provider dependencies:')
      ..writeln(
        '- Requires provider selection? ${((procedure['providers'] as List).isNotEmpty || procedure['category'] == 'Telecom' || procedure['category'] == 'Utilities') ? 'yes' : 'no'}',
      )
      ..writeln(
        '- Providers currently listed: ${((procedure['providers'] as List).map((item) => (item as Map)['name']).join(', '))}',
      )
      ..writeln(
        '- Provider-specific forms currently stored: ${((procedure['providerForms'] as List).map((item) => (item as Map)['title']).join(', '))}',
      )
      ..writeln(
        '- Provider-specific contacts currently stored: ${((procedure['officialContacts'] as List).where((item) => (item as Map)['provider'] != null).length)}',
      )
      ..writeln()
      ..writeln('City/region dependencies:')
      ..writeln(
        '- Requires city/region? ${((procedure['cityRegionDependencies'] as Map)['requiresCityOrRegion'])}',
      )
      ..writeln(
        '- Current cities/regions covered: ${[((procedure['cityRegionDependencies'] as Map)['coveredCities'] as List).join(', '), ((procedure['cityRegionDependencies'] as Map)['coveredRegions'] as List).join(', ')].where((item) => item.isNotEmpty).join(' / ')}',
      )
      ..writeln(
        '- City-specific guidance found: ${((procedure['cityRegionDependencies'] as Map)['coveredCities'] as List).join(', ')}',
      )
      ..writeln(
        '- Region-specific guidance found: ${((procedure['cityRegionDependencies'] as Map)['coveredRegions'] as List).join(', ')}',
      )
      ..writeln()
      ..writeln('Missing real-world data:')
      ..writeln(
        '- Missing exact email: ${((procedure['missingData'] as Map)['emails'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing exact PEC: ${((procedure['missingData'] as Map)['pecs'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing exact address: ${((procedure['missingData'] as Map)['addresses'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing phone: ${((procedure['missingData'] as Map)['phoneNumbers'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing office finder: ${((procedure['missingData'] as Map)['officeFinders'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing official form: ${((procedure['missingData'] as Map)['forms'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing portal link: ${((procedure['missingData'] as Map)['officialLinks'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing legal/authority reference: ${((procedure['missingData'] as Map)['legalReferences'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing provider-specific instructions: ${((procedure['missingData'] as Map)['providerSpecific'] as List).join(' | ')}',
      )
      ..writeln(
        '- Missing in-person guidance: ${outputs['inPersonChecklist'] == 'no' ? 'Yes' : 'No'}',
      )
      ..writeln(
        '- Missing raccomandata guidance: ${outputs['raccomandataVersion'] == 'no' ? 'Yes' : 'No dedicated generated output'}',
      )
      ..writeln(
        '- Missing translation/localization: ${((procedure['missingData'] as Map)['translations'] as List).join(' | ')}',
      )
      ..writeln()
      ..writeln('Research priority:')
      ..writeln('- ${procedure['researchPriority']}')
      ..writeln()
      ..writeln('Research notes:')
      ..writeln(
        '- Exact things a researcher should search for: ${((procedure['researchQueries'] as List).join(' | '))}',
      )
      ..writeln();
  }

  buffer
    ..writeln('## Provider Inventory')
    ..writeln();
  for (final provider in providers) {
    final item = provider as Map;
    buffer
      ..writeln('### Provider: ${item['name']}')
      ..writeln()
      ..writeln('Basic:')
      ..writeln('- Category: ${item['category']}')
      ..writeln('- Normalized name: ${item['normalizedName']}')
      ..writeln('- Website: ${item['website'] ?? ''}')
      ..writeln('- Customer area: ${item['customerArea'] ?? ''}')
      ..writeln('- Verification status: ${item['verificationStatus']}')
      ..writeln('- Last verified: ${item['lastVerifiedAt'] ?? ''}')
      ..writeln(
        '- Source file: lib/features/italy_admin_copilot/data/catalog/bundled_service_providers.dart',
      )
      ..writeln()
      ..writeln('Contacts:')
      ..writeln('| Type | Value/URL | Source URL | Verification | Notes |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final contact in (item['contactOptions'] as List)) {
      final contactMap = contact as Map;
      buffer.writeln(
        '| ${contactMap['type']} | ${contactMap['url'] ?? contactMap['value'] ?? ''} | ${contactMap['sourceUrl'] ?? ''} | ${contactMap['verificationStatus']} | ${contactMap['label']} |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Forms:')
      ..writeln(
        '| Form Type | Title | URL | Submission Channels | Verification | Notes |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- |');
    for (final form in (item['forms'] as List)) {
      final formMap = form as Map;
      buffer.writeln(
        '| ${formMap['type']} | ${formMap['title']} | ${formMap['url'] ?? ''} | ${((formMap['submissionChannels'] as List).join(', '))} | ${formMap['verificationStatus']} | current bundled provider form shell |',
      );
    }
    buffer
      ..writeln()
      ..writeln('Guidance:')
      ..writeln(
        '- Cancellation: ${jsonEncode((item['guidance'] as Map)['cancellation'])}',
      )
      ..writeln(
        '- Complaint: ${jsonEncode((item['guidance'] as Map)['complaint'])}',
      )
      ..writeln(
        '- Modem return: ${jsonEncode((item['guidance'] as Map)['modemReturn'])}',
      )
      ..writeln('- Refund: no dedicated refund guidance object')
      ..writeln(
        '- Payment plan: ${jsonEncode((item['guidance'] as Map)['paymentPlan'])}',
      )
      ..writeln(
        '- Voltura/Subentro: no provider-specific voltura/subentro object',
      )
      ..writeln('- Disdetta: see cancellation guidance')
      ..writeln('- In-person: no dedicated in-person provider store guidance')
      ..writeln('- Raccomandata: no provider-specific postal target stored')
      ..writeln()
      ..writeln('Missing:')
      ..writeln('- Missing PEC: yes')
      ..writeln('- Missing email: yes')
      ..writeln('- Missing postal address: yes')
      ..writeln(
        '- Missing customer area: ${(item['customerArea'] == null || item['customerArea'].toString().isEmpty) ? 'yes' : 'no'}',
      )
      ..writeln(
        '- Missing forms: ${((item['forms'] as List).isEmpty) ? 'yes' : 'partial'}',
      )
      ..writeln(
        '- Missing modem return: ${(jsonEncode((item['guidance'] as Map)['modemReturn']) == '{}') ? 'yes' : 'partial'}',
      )
      ..writeln('- Missing complaint escalation: yes')
      ..writeln()
      ..writeln('Research queries:')
      ..writeln('- "${item['name']} disdetta official site"')
      ..writeln('- "${item['name']} reclami official site"')
      ..writeln('- "${item['name']} PEC reclami"')
      ..writeln('- "${item['name']} customer area official"')
      ..writeln();
  }

  buffer
    ..writeln('## City and Region Guidance Inventory')
    ..writeln();
  for (final region in regions) {
    final item = region as Map;
    buffer
      ..writeln('### Region: ${item['region']}')
      ..writeln(
        '- Current links: ${((item['portalLinks'] as List).map((link) => (link as Map)['title']).join(', '))}',
      )
      ..writeln('- Current contacts: no exact region-level contact rows stored')
      ..writeln('- Health/ASL guidance: ${item['title']}')
      ..writeln('- Comune guidance: none stored at region level')
      ..writeln(
        '- Portal links: ${((item['portalLinks'] as List).map((link) => (link as Map)['url']).join(', '))}',
      )
      ..writeln(
        '- Missing data: exact ASL emails, PECs, local desk finder pages, and phone numbers remain incomplete',
      )
      ..writeln(
        '- Research queries: "${item['region']} ASL contatti ufficiali", "${item['region']} scelta medico portale ufficiale"',
      )
      ..writeln();
  }
  for (final city in cities) {
    final item = city as Map;
    buffer
      ..writeln('### City: ${item['city']}')
      ..writeln('- Comune official link: ${item['sourceUrl'] ?? ''}')
      ..writeln('- Anagrafe/residenza link: no exact deep link stored')
      ..writeln('- Office address/finder: not stored')
      ..writeln('- PEC/email: not stored')
      ..writeln('- Appointment system: not stored')
      ..writeln('- University links: not stored in city guidance')
      ..writeln(
        '- Missing data: office finder, PEC, booking, deep links for anagrafe/residenza',
      )
      ..writeln(
        '- Research queries: "${item['city']} comune anagrafe residenza appuntamento", "${item['city']} PEC anagrafe ufficiale"',
      )
      ..writeln();
  }

  buffer
    ..writeln('## Terms / Guides Inventory')
    ..writeln();
  for (final term in terms) {
    final item = term as Map;
    buffer
      ..writeln('### Term: ${item['term']}')
      ..writeln('- current explanation: ${item['longExplanation']}')
      ..writeln(
        '- official source link if present: ${((item['relatedLinks'] as List).join(', '))}',
      )
      ..writeln(
        '- missing official source: ${((item['relatedLinks'] as List).isEmpty) ? 'yes' : 'partial'}',
      )
      ..writeln(
        '- missing provider/source references: ${(item['catalogTerm'] == null) ? 'yes' : 'partial'}',
      )
      ..writeln('- localization status: ${item['localizationStatus']}')
      ..writeln();
  }

  return buffer.toString();
}

String _buildResearchGapsMarkdown(List<Map<String, dynamic>> procedures) {
  final high = procedures
      .where((item) => item['researchPriority'] == 'High')
      .toList();
  final medium = procedures
      .where((item) => item['researchPriority'] == 'Medium')
      .toList();
  final buffer = StringBuffer()
    ..writeln('# UFFICIOFACILE Research Gaps')
    ..writeln()
    ..writeln('## High Priority Gaps')
    ..writeln();
  for (final procedure in high) {
    buffer
      ..writeln('### ${procedure['id']} — ${(procedure['title'] as String)}')
      ..writeln()
      ..writeln('Missing:')
      ..writeln(
        '- ${((procedure['missingData'] as Map)['emails'] as List).join(' | ')}',
      )
      ..writeln(
        '- ${((procedure['missingData'] as Map)['pecs'] as List).join(' | ')}',
      )
      ..writeln(
        '- ${((procedure['missingData'] as Map)['forms'] as List).join(' | ')}',
      )
      ..writeln()
      ..writeln('Why it matters:')
      ..writeln(
        '- Users need operational instructions, destination details, and a safe official path.',
      )
      ..writeln()
      ..writeln('Current fallback in app:')
      ..writeln(
        '- ${(procedure['serviceIntelligence'] as Map)['destinationGuidance']}',
      )
      ..writeln()
      ..writeln('Exact research needed:')
      ..writeln('- ${(procedure['researchQueries'] as List).join(' | ')}')
      ..writeln()
      ..writeln('Suggested search queries:')
      ..writeln(
        '- ${(procedure['researchQueries'] as List).map((item) => '"$item"').join('\n- ')}',
      )
      ..writeln()
      ..writeln('Expected official source type:')
      ..writeln(
        '- Government, regional health, Comune, university, AGCOM, ARERA, Agenzia Entrate, INPS, or provider domain depending on the procedure.',
      )
      ..writeln()
      ..writeln('Status:')
      ..writeln('- Needs external research.')
      ..writeln();
  }
  buffer
    ..writeln('## Medium Priority Gaps')
    ..writeln();
  for (final procedure in medium) {
    buffer
      ..writeln('### ${procedure['id']} — ${(procedure['title'] as String)}')
      ..writeln(
        '- Missing data types: ${((procedure['missingData'] as Map).entries.where((entry) => (entry.value as List).isNotEmpty).map((entry) => entry.key).join(', '))}',
      )
      ..writeln(
        '- Suggested research queries: ${(procedure['researchQueries'] as List).join(' | ')}',
      )
      ..writeln();
  }
  return buffer.toString();
}

String _buildResearchTasksMarkdown(
  Map<ProcedureCategory, List<AdminProcedure>> categoryGroups,
) {
  final buffer = StringBuffer();
  for (final entry in categoryGroups.entries) {
    buffer
      ..writeln('# Category: ${entry.key.label}')
      ..writeln();
    var index = 1;
    for (final procedure in entry.value) {
      final queries = _researchQueriesForProcedure(procedure);
      buffer
        ..writeln('## Task $index: Research ${procedure.title}')
        ..writeln('- Procedure IDs: ${procedure.id}')
        ..writeln(
          '- Needed data: official links, official contacts, forms, office finder, authority references, and channel rules.',
        )
        ..writeln('- Search queries: ${queries.join(' | ')}')
        ..writeln(
          '- Official source domains to prefer: .gov.it, official Comune/regional/ASL/university sites, AGCOM, ARERA, INPS, Agenzia Entrate, provider official domains.',
        )
        ..writeln('- Data fields to extract:')
        ..writeln('  - title')
        ..writeln('  - contact type')
        ..writeln('  - email/PEC/address/phone/link')
        ..writeln('  - source URL')
        ..writeln('  - last verified date')
        ..writeln('  - warning')
        ..writeln('- Where this should be implemented later:')
        ..writeln('  - official contacts catalog')
        ..writeln('  - procedure guidance')
        ..writeln('  - generated pack destination guidance')
        ..writeln();
      index += 1;
    }
  }
  return buffer.toString();
}

void _writeFile(String path, String contents) {
  Directory(_docsDir).createSync(recursive: true);
  File(path).writeAsStringSync(contents);
}
