import '../../../app/localized_text.dart';
import 'official_link.dart';

export 'official_link.dart';

typedef LocalizedText = Map<String, String>;

String localizedValue(
  LocalizedText values,
  String languageCode, {
  String fallback = '',
}) => resolveLocalizedText(values, languageCode, fallback: fallback);

enum CatalogVerificationStatus { verified, needsReview, unverified }

CatalogVerificationStatus catalogVerificationStatusFromJson(String? value) {
  return CatalogVerificationStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => CatalogVerificationStatus.unverified,
  );
}

class CatalogSource {
  const CatalogSource({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.sourceUrl,
    required this.sourceLabel,
    required this.jurisdiction,
    required this.verificationStatus,
    this.authorityName,
    this.region,
    this.city,
    this.provider,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
    this.notes = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String sourceType;
  final String sourceUrl;
  final String sourceLabel;
  final String jurisdiction;
  final CatalogVerificationStatus verificationStatus;
  final String? authorityName;
  final String? region;
  final String? city;
  final String? provider;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;
  final Map<String, dynamic> notes;

  factory CatalogSource.fromJson(Map<String, dynamic> json) => CatalogSource(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    sourceType: json['sourceType'] as String? ?? '',
    sourceUrl: json['sourceUrl'] as String? ?? '',
    sourceLabel: json['sourceLabel'] as String? ?? '',
    jurisdiction: json['jurisdiction'] as String? ?? 'national',
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    authorityName: json['authorityName'] as String?,
    region: json['region'] as String?,
    city: json['city'] as String?,
    provider: json['provider'] as String?,
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    warning: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
    notes: Map<String, dynamic>.from(
      (json['notes'] as Map?) ?? const <String, dynamic>{},
    ),
  );

  factory CatalogSource.fromSupabaseJson(Map<String, dynamic> json) =>
      CatalogSource(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        sourceType: json['source_type'] as String? ?? '',
        sourceUrl: json['source_url'] as String? ?? '',
        sourceLabel:
            json['source_label'] as String? ??
            json['authority_name'] as String? ??
            '',
        jurisdiction: json['jurisdiction'] as String? ?? 'national',
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        authorityName: json['authority_name'] as String?,
        region: json['region'] as String?,
        city: json['city'] as String?,
        provider: json['provider'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['last_verified_at'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        notes: Map<String, dynamic>.from(
          (json['notes'] as Map?) ?? const <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sourceType': sourceType,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'jurisdiction': jurisdiction,
    'verificationStatus': verificationStatus.name,
    'authorityName': authorityName,
    'region': region,
    'city': city,
    'provider': provider,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
    'notes': notes,
  };
}

class OfficialContact {
  const OfficialContact({
    required this.id,
    required this.label,
    required this.contactType,
    required this.category,
    required this.displayValue,
    required this.verificationStatus,
    this.value,
    this.authorityType,
    this.procedureIds = const <String>[],
    this.jurisdiction = 'national',
    this.region,
    this.city,
    this.providerId,
    this.providerName,
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
    this.notes = const <String, dynamic>{},
  });

  final String id;
  final String label;
  final String contactType;
  final String category;
  final String displayValue;
  final CatalogVerificationStatus verificationStatus;
  final String? value;
  final String? authorityType;
  final List<String> procedureIds;
  final String jurisdiction;
  final String? region;
  final String? city;
  final String? providerId;
  final String? providerName;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;
  final Map<String, dynamic> notes;

  bool get isVerified =>
      verificationStatus == CatalogVerificationStatus.verified;

  factory OfficialContact.fromJson(Map<String, dynamic> json) =>
      OfficialContact(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        contactType: json['contactType'] as String? ?? '',
        category: json['category'] as String? ?? '',
        displayValue: json['displayValue'] as String? ?? '',
        verificationStatus: catalogVerificationStatusFromJson(
          json['verificationStatus'] as String?,
        ),
        value: json['value'] as String?,
        authorityType: json['authorityType'] as String?,
        procedureIds: ((json['procedureIds'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        jurisdiction: json['jurisdiction'] as String? ?? 'national',
        region: json['region'] as String?,
        city: json['city'] as String?,
        providerId: json['providerId'] as String?,
        providerName: json['providerName'] as String?,
        sourceUrl: json['sourceUrl'] as String?,
        sourceLabel: json['sourceLabel'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['lastVerifiedAt'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        notes: Map<String, dynamic>.from(
          (json['notes'] as Map?) ?? const <String, dynamic>{},
        ),
      );

  factory OfficialContact.fromSupabaseJson(Map<String, dynamic> json) =>
      OfficialContact(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        contactType: json['contact_type'] as String? ?? '',
        category: json['category'] as String? ?? '',
        displayValue:
            json['display_value'] as String? ?? json['value'] as String? ?? '',
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        value: json['value'] as String?,
        authorityType: json['authority_type'] as String?,
        procedureIds: ((json['procedure_ids'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        jurisdiction: json['jurisdiction'] as String? ?? 'national',
        region: json['region'] as String?,
        city: json['city'] as String?,
        providerId: json['provider_id'] as String?,
        providerName: json['provider_name'] as String?,
        sourceUrl: json['source_url'] as String?,
        sourceLabel: json['source_label'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['last_verified_at'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        notes: Map<String, dynamic>.from(
          (json['notes'] as Map?) ?? const <String, dynamic>{},
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'contactType': contactType,
    'category': category,
    'displayValue': displayValue,
    'verificationStatus': verificationStatus.name,
    'value': value,
    'authorityType': authorityType,
    'procedureIds': procedureIds,
    'jurisdiction': jurisdiction,
    'region': region,
    'city': city,
    'providerId': providerId,
    'providerName': providerName,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
    'notes': notes,
  };
}

class ProviderContactOption {
  const ProviderContactOption({
    required this.id,
    required this.contactType,
    required this.label,
    required this.description,
    required this.verificationStatus,
    this.value,
    this.url,
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
    this.procedureIds = const <String>[],
  });

  final String id;
  final String contactType;
  final String label;
  final LocalizedText description;
  final CatalogVerificationStatus verificationStatus;
  final String? value;
  final String? url;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;
  final List<String> procedureIds;

  factory ProviderContactOption.fromJson(Map<String, dynamic> json) =>
      ProviderContactOption(
        id: json['id'] as String? ?? '',
        contactType: json['contactType'] as String? ?? '',
        label: json['label'] as String? ?? '',
        description: Map<String, String>.from(
          (json['description'] as Map?) ?? const <String, String>{},
        ),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verificationStatus'] as String?,
        ),
        value: json['value'] as String?,
        url: json['url'] as String?,
        sourceUrl: json['sourceUrl'] as String?,
        sourceLabel: json['sourceLabel'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['lastVerifiedAt'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        procedureIds: ((json['procedureIds'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
      );

  factory ProviderContactOption.fromSupabaseJson(Map<String, dynamic> json) =>
      ProviderContactOption(
        id: json['id'] as String? ?? '',
        contactType: json['contact_type'] as String? ?? '',
        label: json['label'] as String? ?? '',
        description: Map<String, String>.from(
          (json['description'] as Map?) ?? const <String, String>{},
        ),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        value: json['value'] as String?,
        url: json['url'] as String?,
        sourceUrl: json['source_url'] as String?,
        sourceLabel: json['source_label'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['last_verified_at'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        procedureIds: ((json['procedure_ids'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'contactType': contactType,
    'label': label,
    'description': description,
    'verificationStatus': verificationStatus.name,
    'value': value,
    'url': url,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
    'procedureIds': procedureIds,
  };
}

class ProviderForm {
  const ProviderForm({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.formType,
    required this.title,
    required this.description,
    required this.verificationStatus,
    this.url,
    this.procedureIds = const <String>[],
    this.requiredFields = const <String>[],
    this.requiredDocuments = const <String>[],
    this.submissionChannels = const <String>[],
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
  });

  final String id;
  final String providerId;
  final String providerName;
  final String formType;
  final String title;
  final LocalizedText description;
  final CatalogVerificationStatus verificationStatus;
  final String? url;
  final List<String> procedureIds;
  final List<String> requiredFields;
  final List<String> requiredDocuments;
  final List<String> submissionChannels;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;

  factory ProviderForm.fromJson(Map<String, dynamic> json) => ProviderForm(
    id: json['id'] as String? ?? '',
    providerId: json['providerId'] as String? ?? '',
    providerName: json['providerName'] as String? ?? '',
    formType: json['formType'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: Map<String, String>.from(
      (json['description'] as Map?) ?? const <String, String>{},
    ),
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    url: json['url'] as String?,
    procedureIds: ((json['procedureIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    requiredFields: ((json['requiredFields'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    requiredDocuments: ((json['requiredDocuments'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    submissionChannels: ((json['submissionChannels'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    sourceUrl: json['sourceUrl'] as String?,
    sourceLabel: json['sourceLabel'] as String?,
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    warning: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
  );

  factory ProviderForm.fromSupabaseJson(Map<String, dynamic> json) =>
      ProviderForm(
        id: json['id'] as String? ?? '',
        providerId: json['provider_id'] as String? ?? '',
        providerName: json['provider_name'] as String? ?? '',
        formType: json['form_type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: Map<String, String>.from(
          (json['description'] as Map?) ?? const <String, String>{},
        ),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        url: json['url'] as String?,
        procedureIds: ((json['procedure_ids'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        requiredFields: ((json['required_fields'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        requiredDocuments: ((json['required_documents'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        submissionChannels: ((json['submission_channels'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        sourceUrl: json['source_url'] as String?,
        sourceLabel: json['source_label'] as String?,
        lastVerifiedAt: DateTime.tryParse(
          json['last_verified_at'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'providerId': providerId,
    'providerName': providerName,
    'formType': formType,
    'title': title,
    'description': description,
    'verificationStatus': verificationStatus.name,
    'url': url,
    'procedureIds': procedureIds,
    'requiredFields': requiredFields,
    'requiredDocuments': requiredDocuments,
    'submissionChannels': submissionChannels,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
  };
}

class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.verificationStatus,
    this.websiteUrl,
    this.customerAreaUrl,
    this.cancellationPageUrl,
    this.complaintPageUrl,
    this.forms = const <ProviderForm>[],
    this.contactOptions = const <ProviderContactOption>[],
    this.modemReturnGuidance = const <String, String>{},
    this.cancellationGuidance = const <String, String>{},
    this.complaintGuidance = const <String, String>{},
    this.paymentPlanGuidance = const <String, String>{},
    this.sourceReferences = const <String>[],
    this.lastVerifiedAt,
    this.warnings = const <String, String>{},
  });

  final String id;
  final String name;
  final String category;
  final CatalogVerificationStatus verificationStatus;
  final String? websiteUrl;
  final String? customerAreaUrl;
  final String? cancellationPageUrl;
  final String? complaintPageUrl;
  final List<ProviderForm> forms;
  final List<ProviderContactOption> contactOptions;
  final LocalizedText modemReturnGuidance;
  final LocalizedText cancellationGuidance;
  final LocalizedText complaintGuidance;
  final LocalizedText paymentPlanGuidance;
  final List<String> sourceReferences;
  final DateTime? lastVerifiedAt;
  final LocalizedText warnings;

  factory ServiceProvider.fromJson(
    Map<String, dynamic> json,
  ) => ServiceProvider(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? 'other',
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    websiteUrl: json['websiteUrl'] as String?,
    customerAreaUrl: json['customerAreaUrl'] as String?,
    cancellationPageUrl: json['cancellationPageUrl'] as String?,
    complaintPageUrl: json['complaintPageUrl'] as String?,
    forms: ((json['forms'] as List?) ?? const [])
        .map((item) => ProviderForm.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    contactOptions: ((json['contactOptions'] as List?) ?? const [])
        .map(
          (item) =>
              ProviderContactOption.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(),
    modemReturnGuidance: Map<String, String>.from(
      (json['modemReturnGuidance'] as Map?) ?? const <String, String>{},
    ),
    cancellationGuidance: Map<String, String>.from(
      (json['cancellationGuidance'] as Map?) ?? const <String, String>{},
    ),
    complaintGuidance: Map<String, String>.from(
      (json['complaintGuidance'] as Map?) ?? const <String, String>{},
    ),
    paymentPlanGuidance: Map<String, String>.from(
      (json['paymentPlanGuidance'] as Map?) ?? const <String, String>{},
    ),
    sourceReferences: ((json['sourceReferences'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    warnings: Map<String, String>.from(
      (json['warnings'] as Map?) ?? const <String, String>{},
    ),
  );

  factory ServiceProvider.fromSupabaseJson(
    Map<String, dynamic> json, {
    List<ProviderForm> forms = const <ProviderForm>[],
    List<ProviderContactOption> contactOptions =
        const <ProviderContactOption>[],
  }) => ServiceProvider(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? 'other',
    verificationStatus: catalogVerificationStatusFromJson(
      json['verification_status'] as String?,
    ),
    websiteUrl: json['website_url'] as String?,
    customerAreaUrl: json['customer_area_url'] as String?,
    cancellationPageUrl: json['cancellation_page_url'] as String?,
    complaintPageUrl: json['complaint_page_url'] as String?,
    forms: forms,
    contactOptions: contactOptions,
    modemReturnGuidance: Map<String, String>.from(
      (json['modem_return_guidance'] as Map?) ?? const <String, String>{},
    ),
    cancellationGuidance: Map<String, String>.from(
      (json['cancellation_guidance'] as Map?) ?? const <String, String>{},
    ),
    complaintGuidance: Map<String, String>.from(
      (json['complaint_guidance'] as Map?) ?? const <String, String>{},
    ),
    paymentPlanGuidance: Map<String, String>.from(
      (json['payment_plan_guidance'] as Map?) ?? const <String, String>{},
    ),
    sourceReferences: ((json['source_references'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    lastVerifiedAt: DateTime.tryParse(
      json['last_verified_at'] as String? ?? '',
    ),
    warnings: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'verificationStatus': verificationStatus.name,
    'websiteUrl': websiteUrl,
    'customerAreaUrl': customerAreaUrl,
    'cancellationPageUrl': cancellationPageUrl,
    'complaintPageUrl': complaintPageUrl,
    'forms': forms.map((item) => item.toJson()).toList(),
    'contactOptions': contactOptions.map((item) => item.toJson()).toList(),
    'modemReturnGuidance': modemReturnGuidance,
    'cancellationGuidance': cancellationGuidance,
    'complaintGuidance': complaintGuidance,
    'paymentPlanGuidance': paymentPlanGuidance,
    'sourceReferences': sourceReferences,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warnings': warnings,
  };
}

class RegionGuidance {
  const RegionGuidance({
    required this.id,
    required this.region,
    required this.category,
    required this.title,
    required this.description,
    required this.verificationStatus,
    this.procedureIds = const <String>[],
    this.portalLinks = const <OfficialLink>[],
    this.contactGuidance = const <String, String>{},
    this.inPersonGuidance = const <String, String>{},
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
  });

  final String id;
  final String region;
  final String category;
  final String title;
  final LocalizedText description;
  final CatalogVerificationStatus verificationStatus;
  final List<String> procedureIds;
  final List<OfficialLink> portalLinks;
  final LocalizedText contactGuidance;
  final LocalizedText inPersonGuidance;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;

  factory RegionGuidance.fromJson(Map<String, dynamic> json) => RegionGuidance(
    id: json['id'] as String? ?? '',
    region: json['region'] as String? ?? '',
    category: json['category'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: Map<String, String>.from(
      (json['description'] as Map?) ?? const <String, String>{},
    ),
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    procedureIds: ((json['procedureIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    portalLinks: ((json['portalLinks'] as List?) ?? const [])
        .map((item) => OfficialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    contactGuidance: Map<String, String>.from(
      (json['contactGuidance'] as Map?) ?? const <String, String>{},
    ),
    inPersonGuidance: Map<String, String>.from(
      (json['inPersonGuidance'] as Map?) ?? const <String, String>{},
    ),
    sourceUrl: json['sourceUrl'] as String?,
    sourceLabel: json['sourceLabel'] as String?,
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    warning: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'region': region,
    'category': category,
    'title': title,
    'description': description,
    'verificationStatus': verificationStatus.name,
    'procedureIds': procedureIds,
    'portalLinks': portalLinks.map((item) => item.toJson()).toList(),
    'contactGuidance': contactGuidance,
    'inPersonGuidance': inPersonGuidance,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
  };
}

class CityGuidance {
  const CityGuidance({
    required this.id,
    required this.city,
    required this.category,
    required this.title,
    required this.description,
    required this.verificationStatus,
    this.region,
    this.procedureIds = const <String>[],
    this.officeLinks = const <OfficialLink>[],
    this.contactGuidance = const <String, String>{},
    this.inPersonGuidance = const <String, String>{},
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
  });

  final String id;
  final String city;
  final String category;
  final String title;
  final LocalizedText description;
  final CatalogVerificationStatus verificationStatus;
  final String? region;
  final List<String> procedureIds;
  final List<OfficialLink> officeLinks;
  final LocalizedText contactGuidance;
  final LocalizedText inPersonGuidance;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;

  factory CityGuidance.fromJson(Map<String, dynamic> json) => CityGuidance(
    id: json['id'] as String? ?? '',
    city: json['city'] as String? ?? '',
    category: json['category'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: Map<String, String>.from(
      (json['description'] as Map?) ?? const <String, String>{},
    ),
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    region: json['region'] as String?,
    procedureIds: ((json['procedureIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    officeLinks: ((json['officeLinks'] as List?) ?? const [])
        .map((item) => OfficialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    contactGuidance: Map<String, String>.from(
      (json['contactGuidance'] as Map?) ?? const <String, String>{},
    ),
    inPersonGuidance: Map<String, String>.from(
      (json['inPersonGuidance'] as Map?) ?? const <String, String>{},
    ),
    sourceUrl: json['sourceUrl'] as String?,
    sourceLabel: json['sourceLabel'] as String?,
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    warning: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'city': city,
    'category': category,
    'title': title,
    'description': description,
    'verificationStatus': verificationStatus.name,
    'region': region,
    'procedureIds': procedureIds,
    'officeLinks': officeLinks.map((item) => item.toJson()).toList(),
    'contactGuidance': contactGuidance,
    'inPersonGuidance': inPersonGuidance,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
  };
}

class AuthorityGuidance {
  const AuthorityGuidance({
    required this.id,
    required this.authorityName,
    required this.authorityType,
    required this.category,
    required this.title,
    required this.description,
    required this.verificationStatus,
    this.procedureIds = const <String>[],
    this.officialLinks = const <OfficialLink>[],
    this.contactGuidance = const <String, String>{},
    this.sourceUrl,
    this.sourceLabel,
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
  });

  final String id;
  final String authorityName;
  final String authorityType;
  final String category;
  final String title;
  final LocalizedText description;
  final CatalogVerificationStatus verificationStatus;
  final List<String> procedureIds;
  final List<OfficialLink> officialLinks;
  final LocalizedText contactGuidance;
  final String? sourceUrl;
  final String? sourceLabel;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;

  factory AuthorityGuidance.fromJson(
    Map<String, dynamic> json,
  ) => AuthorityGuidance(
    id: json['id'] as String? ?? '',
    authorityName: json['authorityName'] as String? ?? '',
    authorityType: json['authorityType'] as String? ?? '',
    category: json['category'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: Map<String, String>.from(
      (json['description'] as Map?) ?? const <String, String>{},
    ),
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    procedureIds: ((json['procedureIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    officialLinks: ((json['officialLinks'] as List?) ?? const [])
        .map((item) => OfficialLink.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    contactGuidance: Map<String, String>.from(
      (json['contactGuidance'] as Map?) ?? const <String, String>{},
    ),
    sourceUrl: json['sourceUrl'] as String?,
    sourceLabel: json['sourceLabel'] as String?,
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    warning: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorityName': authorityName,
    'authorityType': authorityType,
    'category': category,
    'title': title,
    'description': description,
    'verificationStatus': verificationStatus.name,
    'procedureIds': procedureIds,
    'officialLinks': officialLinks.map((item) => item.toJson()).toList(),
    'contactGuidance': contactGuidance,
    'sourceUrl': sourceUrl,
    'sourceLabel': sourceLabel,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
  };
}

class SourceReference {
  const SourceReference({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.explanation,
    required this.relevance,
    required this.verificationStatus,
    this.referenceLabel,
    this.url,
    this.procedureIds = const <String>[],
    this.lastVerifiedAt,
    this.warning = const <String, String>{},
    this.notLegalAdvice = true,
  });

  final String id;
  final String title;
  final String sourceType;
  final LocalizedText explanation;
  final LocalizedText relevance;
  final CatalogVerificationStatus verificationStatus;
  final String? referenceLabel;
  final String? url;
  final List<String> procedureIds;
  final DateTime? lastVerifiedAt;
  final LocalizedText warning;
  final bool notLegalAdvice;

  factory SourceReference.fromJson(Map<String, dynamic> json) =>
      SourceReference(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        sourceType: json['sourceType'] as String? ?? '',
        explanation: Map<String, String>.from(
          (json['explanation'] as Map?) ?? const <String, String>{},
        ),
        relevance: Map<String, String>.from(
          (json['relevance'] as Map?) ?? const <String, String>{},
        ),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verificationStatus'] as String?,
        ),
        referenceLabel: json['referenceLabel'] as String?,
        url: json['url'] as String?,
        procedureIds: ((json['procedureIds'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        lastVerifiedAt: DateTime.tryParse(
          json['lastVerifiedAt'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        notLegalAdvice: json['notLegalAdvice'] as bool? ?? true,
      );

  factory SourceReference.fromSupabaseJson(Map<String, dynamic> json) =>
      SourceReference(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        sourceType: json['source_type'] as String? ?? '',
        explanation: Map<String, String>.from(
          (json['explanation'] as Map?) ?? const <String, String>{},
        ),
        relevance: Map<String, String>.from(
          (json['relevance'] as Map?) ?? const <String, String>{},
        ),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        referenceLabel: json['reference_label'] as String?,
        url: json['url'] as String?,
        procedureIds: ((json['procedure_ids'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        lastVerifiedAt: DateTime.tryParse(
          json['last_verified_at'] as String? ?? '',
        ),
        warning: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        notLegalAdvice: json['not_legal_advice'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sourceType': sourceType,
    'explanation': explanation,
    'relevance': relevance,
    'verificationStatus': verificationStatus.name,
    'referenceLabel': referenceLabel,
    'url': url,
    'procedureIds': procedureIds,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'warning': warning,
    'notLegalAdvice': notLegalAdvice,
  };
}

class ServiceTerm {
  const ServiceTerm({
    required this.id,
    required this.term,
    required this.shortDefinition,
    required this.longExplanation,
    required this.verificationStatus,
    this.relatedLinks = const <String>[],
    this.providerExamples = const <String>[],
    this.warnings = const <String, String>{},
    this.relatedProcedures = const <String>[],
  });

  final String id;
  final String term;
  final LocalizedText shortDefinition;
  final LocalizedText longExplanation;
  final CatalogVerificationStatus verificationStatus;
  final List<String> relatedLinks;
  final List<String> providerExamples;
  final LocalizedText warnings;
  final List<String> relatedProcedures;

  factory ServiceTerm.fromJson(Map<String, dynamic> json) => ServiceTerm(
    id: json['id'] as String? ?? '',
    term: json['term'] as String? ?? '',
    shortDefinition: Map<String, String>.from(
      (json['shortDefinition'] as Map?) ?? const <String, String>{},
    ),
    longExplanation: Map<String, String>.from(
      (json['longExplanation'] as Map?) ?? const <String, String>{},
    ),
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    relatedLinks: ((json['relatedLinks'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    providerExamples: ((json['providerExamples'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    warnings: Map<String, String>.from(
      (json['warnings'] as Map?) ?? const <String, String>{},
    ),
    relatedProcedures: ((json['relatedProcedures'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
  );

  factory ServiceTerm.fromSupabaseJson(Map<String, dynamic> json) =>
      ServiceTerm(
        id: json['id'] as String? ?? '',
        term: json['term'] as String? ?? '',
        shortDefinition: Map<String, String>.from(
          (json['short_definition'] as Map?) ?? const <String, String>{},
        ),
        longExplanation: Map<String, String>.from(
          (json['long_explanation'] as Map?) ?? const <String, String>{},
        ),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        relatedLinks: ((json['related_links'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        providerExamples: ((json['provider_examples'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        warnings: Map<String, String>.from(
          (json['warnings'] as Map?) ?? const <String, String>{},
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'term': term,
    'shortDefinition': shortDefinition,
    'longExplanation': longExplanation,
    'verificationStatus': verificationStatus.name,
    'relatedLinks': relatedLinks,
    'providerExamples': providerExamples,
    'warnings': warnings,
    'relatedProcedures': relatedProcedures,
  };
}

class SubmissionChannel {
  const SubmissionChannel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.whenToUse,
    required this.steps,
    required this.verificationStatus,
    this.pros = const <String, String>{},
    this.cons = const <String, String>{},
    this.requiredData = const <String>[],
    this.requiredDocuments = const <String>[],
    this.proofToKeep = const <String>[],
    this.costNotes = const <String, String>{},
    this.timeNotes = const <String, String>{},
    this.legalWeight = const <String, String>{},
    this.warnings = const <String, String>{},
    this.relatedTerms = const <String>[],
    this.officialLinks = const <String>[],
    this.isRecommendedForProcedure = false,
    this.priority = 0,
  });

  final String id;
  final String type;
  final LocalizedText title;
  final LocalizedText description;
  final LocalizedText whenToUse;
  final List<String> steps;
  final CatalogVerificationStatus verificationStatus;
  final LocalizedText pros;
  final LocalizedText cons;
  final List<String> requiredData;
  final List<String> requiredDocuments;
  final List<String> proofToKeep;
  final LocalizedText costNotes;
  final LocalizedText timeNotes;
  final LocalizedText legalWeight;
  final LocalizedText warnings;
  final List<String> relatedTerms;
  final List<String> officialLinks;
  final bool isRecommendedForProcedure;
  final int priority;

  factory SubmissionChannel.fromJson(Map<String, dynamic> json) =>
      SubmissionChannel(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        title: Map<String, String>.from(
          (json['title'] as Map?) ?? const <String, String>{},
        ),
        description: Map<String, String>.from(
          (json['description'] as Map?) ?? const <String, String>{},
        ),
        whenToUse: Map<String, String>.from(
          (json['whenToUse'] as Map?) ?? const <String, String>{},
        ),
        steps: ((json['steps'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verificationStatus'] as String?,
        ),
        pros: Map<String, String>.from(
          (json['pros'] as Map?) ?? const <String, String>{},
        ),
        cons: Map<String, String>.from(
          (json['cons'] as Map?) ?? const <String, String>{},
        ),
        requiredData: ((json['requiredData'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        requiredDocuments: ((json['requiredDocuments'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        proofToKeep: ((json['proofToKeep'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        costNotes: Map<String, String>.from(
          (json['costNotes'] as Map?) ?? const <String, String>{},
        ),
        timeNotes: Map<String, String>.from(
          (json['timeNotes'] as Map?) ?? const <String, String>{},
        ),
        legalWeight: Map<String, String>.from(
          (json['legalWeight'] as Map?) ?? const <String, String>{},
        ),
        warnings: Map<String, String>.from(
          (json['warnings'] as Map?) ?? const <String, String>{},
        ),
        relatedTerms: ((json['relatedTerms'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        officialLinks: ((json['officialLinks'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        isRecommendedForProcedure:
            json['isRecommendedForProcedure'] as bool? ?? false,
        priority: json['priority'] as int? ?? 0,
      );

  factory SubmissionChannel.fromSupabaseJson(Map<String, dynamic> json) =>
      SubmissionChannel(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        title: Map<String, String>.from(
          (json['title_localized'] as Map?) ?? const <String, String>{},
        ),
        description: Map<String, String>.from(
          (json['description_localized'] as Map?) ?? const <String, String>{},
        ),
        whenToUse: Map<String, String>.from(
          (json['when_to_use_localized'] as Map?) ?? const <String, String>{},
        ),
        steps: ((json['steps_localized'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        verificationStatus: catalogVerificationStatusFromJson(
          json['verification_status'] as String?,
        ),
        pros: Map<String, String>.from(
          (json['pros_localized'] as Map?) ?? const <String, String>{},
        ),
        cons: Map<String, String>.from(
          (json['cons_localized'] as Map?) ?? const <String, String>{},
        ),
        requiredData: ((json['required_data'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        requiredDocuments: ((json['required_documents'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        proofToKeep: ((json['proof_to_keep'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        costNotes: Map<String, String>.from(
          (json['cost_notes_localized'] as Map?) ?? const <String, String>{},
        ),
        timeNotes: Map<String, String>.from(
          (json['time_notes_localized'] as Map?) ?? const <String, String>{},
        ),
        legalWeight: Map<String, String>.from(
          (json['legal_weight_localized'] as Map?) ?? const <String, String>{},
        ),
        warnings: Map<String, String>.from(
          (json['warning'] as Map?) ?? const <String, String>{},
        ),
        relatedTerms: ((json['related_terms'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        officialLinks: ((json['official_links'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
        isRecommendedForProcedure:
            json['is_recommended_for_procedure'] as bool? ?? false,
        priority: json['priority'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'title': title,
    'description': description,
    'whenToUse': whenToUse,
    'steps': steps,
    'verificationStatus': verificationStatus.name,
    'pros': pros,
    'cons': cons,
    'requiredData': requiredData,
    'requiredDocuments': requiredDocuments,
    'proofToKeep': proofToKeep,
    'costNotes': costNotes,
    'timeNotes': timeNotes,
    'legalWeight': legalWeight,
    'warnings': warnings,
    'relatedTerms': relatedTerms,
    'officialLinks': officialLinks,
    'isRecommendedForProcedure': isRecommendedForProcedure,
    'priority': priority,
  };
}

class ProcedureGuidance {
  const ProcedureGuidance({
    required this.id,
    required this.procedureId,
    required this.category,
    required this.title,
    required this.verificationStatus,
    this.summary = const <String, String>{},
    this.destinationGuidance = const <String, String>{},
    this.contactRules = const <String, String>{},
    this.providerRules = const <String, dynamic>{},
    this.cityRegionRules = const <String, dynamic>{},
    this.submissionChannelIds = const <String>[],
    this.officialLinkIds = const <String>[],
    this.officialContactIds = const <String>[],
    this.requiredDocuments = const <String>[],
    this.recommendedDocuments = const <String>[],
    this.proofItems = const <String>[],
    this.beforeSendingChecklist = const <String>[],
    this.warnings = const <String, String>{},
    this.sourceReferenceIds = const <String>[],
    this.providerIds = const <String>[],
    this.regionIds = const <String>[],
    this.cityIds = const <String>[],
    this.lastVerifiedAt,
    this.notes = const <String, dynamic>{},
  });

  final String id;
  final String procedureId;
  final String category;
  final String title;
  final CatalogVerificationStatus verificationStatus;
  final LocalizedText summary;
  final LocalizedText destinationGuidance;
  final LocalizedText contactRules;
  final Map<String, dynamic> providerRules;
  final Map<String, dynamic> cityRegionRules;
  final List<String> submissionChannelIds;
  final List<String> officialLinkIds;
  final List<String> officialContactIds;
  final List<String> requiredDocuments;
  final List<String> recommendedDocuments;
  final List<String> proofItems;
  final List<String> beforeSendingChecklist;
  final LocalizedText warnings;
  final List<String> sourceReferenceIds;
  final List<String> providerIds;
  final List<String> regionIds;
  final List<String> cityIds;
  final DateTime? lastVerifiedAt;
  final Map<String, dynamic> notes;

  factory ProcedureGuidance.fromJson(
    Map<String, dynamic> json,
  ) => ProcedureGuidance(
    id: json['id'] as String? ?? '',
    procedureId: json['procedureId'] as String? ?? '',
    category: json['category'] as String? ?? '',
    title: json['title'] as String? ?? '',
    verificationStatus: catalogVerificationStatusFromJson(
      json['verificationStatus'] as String?,
    ),
    summary: Map<String, String>.from(
      (json['summary'] as Map?) ?? const <String, String>{},
    ),
    destinationGuidance: Map<String, String>.from(
      (json['destinationGuidance'] as Map?) ?? const <String, String>{},
    ),
    contactRules: Map<String, String>.from(
      (json['contactRules'] as Map?) ?? const <String, String>{},
    ),
    providerRules: Map<String, dynamic>.from(
      (json['providerRules'] as Map?) ?? const <String, dynamic>{},
    ),
    cityRegionRules: Map<String, dynamic>.from(
      (json['cityRegionRules'] as Map?) ?? const <String, dynamic>{},
    ),
    submissionChannelIds: ((json['submissionChannelIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    officialLinkIds: ((json['officialLinkIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    officialContactIds: ((json['officialContactIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    requiredDocuments: ((json['requiredDocuments'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    recommendedDocuments: ((json['recommendedDocuments'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    proofItems: ((json['proofItems'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    beforeSendingChecklist:
        ((json['beforeSendingChecklist'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
    warnings: Map<String, String>.from(
      (json['warnings'] as Map?) ?? const <String, String>{},
    ),
    sourceReferenceIds: ((json['sourceReferenceIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    providerIds: ((json['providerIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    regionIds: ((json['regionIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    cityIds: ((json['cityIds'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    notes: Map<String, dynamic>.from(
      (json['notes'] as Map?) ?? const <String, dynamic>{},
    ),
  );

  factory ProcedureGuidance.fromSupabaseJson(
    Map<String, dynamic> json,
  ) => ProcedureGuidance(
    id: json['id'] as String? ?? '',
    procedureId: json['procedure_id'] as String? ?? '',
    category: json['category'] as String? ?? '',
    title: json['title'] as String? ?? '',
    verificationStatus: catalogVerificationStatusFromJson(
      json['verification_status'] as String?,
    ),
    summary: Map<String, String>.from(
      (json['summary'] as Map?) ?? const <String, String>{},
    ),
    destinationGuidance: Map<String, String>.from(
      (json['destination_guidance'] as Map?) ?? const <String, String>{},
    ),
    contactRules: Map<String, String>.from(
      (json['contact_rules'] as Map?) ?? const <String, String>{},
    ),
    providerRules: Map<String, dynamic>.from(
      (json['provider_rules'] as Map?) ?? const <String, dynamic>{},
    ),
    cityRegionRules: Map<String, dynamic>.from(
      (json['city_region_rules'] as Map?) ?? const <String, dynamic>{},
    ),
    submissionChannelIds: ((json['submission_channels'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    officialLinkIds: ((json['official_links'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    officialContactIds: ((json['official_contacts'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    requiredDocuments: ((json['required_documents'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    recommendedDocuments: ((json['recommended_documents'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    proofItems: ((json['proof_items'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    beforeSendingChecklist:
        ((json['before_sending_checklist'] as List?) ?? const [])
            .map((item) => item.toString())
            .toList(),
    warnings: Map<String, String>.from(
      (json['warning'] as Map?) ?? const <String, String>{},
    ),
    sourceReferenceIds: ((json['source_references'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    providerIds: ((json['provider_ids'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    regionIds: ((json['region_ids'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    cityIds: ((json['city_ids'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList(),
    lastVerifiedAt: DateTime.tryParse(
      json['last_verified_at'] as String? ?? '',
    ),
    notes: Map<String, dynamic>.from(
      (json['notes'] as Map?) ?? const <String, dynamic>{},
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'procedureId': procedureId,
    'category': category,
    'title': title,
    'verificationStatus': verificationStatus.name,
    'summary': summary,
    'destinationGuidance': destinationGuidance,
    'contactRules': contactRules,
    'providerRules': providerRules,
    'cityRegionRules': cityRegionRules,
    'submissionChannelIds': submissionChannelIds,
    'officialLinkIds': officialLinkIds,
    'officialContactIds': officialContactIds,
    'requiredDocuments': requiredDocuments,
    'recommendedDocuments': recommendedDocuments,
    'proofItems': proofItems,
    'beforeSendingChecklist': beforeSendingChecklist,
    'warnings': warnings,
    'sourceReferenceIds': sourceReferenceIds,
    'providerIds': providerIds,
    'regionIds': regionIds,
    'cityIds': cityIds,
    'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    'notes': notes,
  };
}
