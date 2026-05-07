import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/app_config.dart';
import '../../../app/supabase_bootstrap.dart';
import '../domain/health_asl_guidance.dart';
import '../domain/housing_rent_guidance.dart';
import '../domain/premium_config.dart';
import '../domain/rich_category_models.dart';
import 'canone_rai_guidance_definitions.dart';
import 'general_guidance_definitions.dart';
import 'health_asl_guidance_definitions.dart';
import 'housing_rent_guidance_definitions.dart';
import 'local_storage_list_repository.dart';
import 'premium_service.dart';
import 'public_office_comune_guidance_definitions.dart';
import 'telecom_guidance_definitions.dart';
import 'university_student_guidance_definitions.dart';
import 'ufficcio_supabase_readiness.dart';
import 'utilities_electricity_gas_guidance_definitions.dart';
import 'work_inps_patronato_guidance_definitions.dart';

enum ProblemRequestStatus { newRequest, reviewing, planned, added, rejected }

ProblemRequestStatus problemRequestStatusFromJson(String? value) {
  return ProblemRequestStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ProblemRequestStatus.newRequest,
  );
}

class ProblemRequestRecord {
  const ProblemRequestRecord({
    required this.id,
    this.userId,
    this.userEmail,
    this.categoryId,
    this.subcategoryId,
    required this.title,
    required this.description,
    required this.city,
    required this.region,
    required this.urgency,
    required this.language,
    this.attachmentPlaceholder,
    required this.status,
    required this.isPremiumUser,
    required this.sourcePage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? userEmail;
  final String? categoryId;
  final String? subcategoryId;
  final String title;
  final String description;
  final String city;
  final String region;
  final String urgency;
  final String language;
  final String? attachmentPlaceholder;
  final ProblemRequestStatus status;
  final bool isPremiumUser;
  final String sourcePage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProblemRequestRecord copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? categoryId,
    String? subcategoryId,
    String? title,
    String? description,
    String? city,
    String? region,
    String? urgency,
    String? language,
    String? attachmentPlaceholder,
    ProblemRequestStatus? status,
    bool? isPremiumUser,
    String? sourcePage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProblemRequestRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      region: region ?? this.region,
      urgency: urgency ?? this.urgency,
      language: language ?? this.language,
      attachmentPlaceholder:
          attachmentPlaceholder ?? this.attachmentPlaceholder,
      status: status ?? this.status,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      sourcePage: sourcePage ?? this.sourcePage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userEmail': userEmail,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'title': title,
    'description': description,
    'city': city,
    'region': region,
    'urgency': urgency,
    'language': language,
    'attachmentPlaceholder': attachmentPlaceholder,
    'status': status.name,
    'isPremiumUser': isPremiumUser,
    'sourcePage': sourcePage,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ProblemRequestRecord.fromJson(Map<String, dynamic> json) =>
      ProblemRequestRecord(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String?,
        userEmail: json['userEmail'] as String?,
        categoryId: json['categoryId'] as String?,
        subcategoryId: json['subcategoryId'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        city: json['city'] as String? ?? 'Torino',
        region: json['region'] as String? ?? 'Piemonte',
        urgency: json['urgency'] as String? ?? 'normal',
        language: json['language'] as String? ?? 'English',
        attachmentPlaceholder: json['attachmentPlaceholder'] as String?,
        status: problemRequestStatusFromJson(json['status'] as String?),
        isPremiumUser: json['isPremiumUser'] as bool? ?? false,
        sourcePage: json['sourcePage'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

enum ConsultancyPaymentStatus {
  freeForPremium,
  paymentRequired,
  waitingPayment,
  paid,
  failed,
  notAvailable,
}

ConsultancyPaymentStatus consultancyPaymentStatusFromJson(String? value) {
  return ConsultancyPaymentStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ConsultancyPaymentStatus.notAvailable,
  );
}

enum ConsultancyRequestStatus {
  newRequest,
  waitingPayment,
  reviewing,
  replied,
  closed,
}

ConsultancyRequestStatus consultancyRequestStatusFromJson(String? value) {
  return ConsultancyRequestStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => ConsultancyRequestStatus.newRequest,
  );
}

class ConsultancyRequestRecord {
  const ConsultancyRequestRecord({
    required this.id,
    this.userId,
    this.userEmail,
    required this.fullName,
    this.categoryId,
    this.subcategoryId,
    required this.problemType,
    required this.description,
    required this.desiredResult,
    required this.city,
    required this.region,
    required this.documentsAvailable,
    this.attachmentUrls = const <String>[],
    required this.userPlan,
    required this.paymentStatus,
    required this.status,
    required this.sourcePage,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? userEmail;
  final String fullName;
  final String? categoryId;
  final String? subcategoryId;
  final String problemType;
  final String description;
  final String desiredResult;
  final String city;
  final String region;
  final String documentsAvailable;
  final List<String> attachmentUrls;
  final String userPlan;
  final ConsultancyPaymentStatus paymentStatus;
  final ConsultancyRequestStatus status;
  final String sourcePage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userEmail': userEmail,
    'fullName': fullName,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'problemType': problemType,
    'description': description,
    'desiredResult': desiredResult,
    'city': city,
    'region': region,
    'documentsAvailable': documentsAvailable,
    'attachmentUrls': attachmentUrls,
    'userPlan': userPlan,
    'paymentStatus': paymentStatus.name,
    'status': status.name,
    'sourcePage': sourcePage,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ConsultancyRequestRecord.fromJson(Map<String, dynamic> json) =>
      ConsultancyRequestRecord(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String?,
        userEmail: json['userEmail'] as String?,
        fullName: json['fullName'] as String? ?? '',
        categoryId: json['categoryId'] as String?,
        subcategoryId: json['subcategoryId'] as String?,
        problemType: json['problemType'] as String? ?? '',
        description: json['description'] as String? ?? '',
        desiredResult: json['desiredResult'] as String? ?? '',
        city: json['city'] as String? ?? 'Torino',
        region: json['region'] as String? ?? 'Piemonte',
        documentsAvailable: json['documentsAvailable'] as String? ?? '',
        attachmentUrls: ((json['attachmentUrls'] as List?) ?? []).cast<String>(),
        userPlan: json['userPlan'] as String? ?? UfficioPlan.free.name,
        paymentStatus: consultancyPaymentStatusFromJson(
          json['paymentStatus'] as String?,
        ),
        status: consultancyRequestStatusFromJson(json['status'] as String?),
        sourcePage: json['sourcePage'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

enum UfficioCostItemType { expense, refund, deposit, installment, estimate }

UfficioCostItemType ufficioCostItemTypeFromJson(String? value) {
  return UfficioCostItemType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioCostItemType.expense,
  );
}

enum UfficioCostItemStatus {
  estimated,
  planned,
  paid,
  refunded,
  disputed,
  cancelled,
}

UfficioCostItemStatus ufficioCostItemStatusFromJson(String? value) {
  return UfficioCostItemStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioCostItemStatus.estimated,
  );
}

enum UfficioCostItemSource {
  manual,
  generatedFromCategory,
  imported,
}

UfficioCostItemSource ufficioCostItemSourceFromJson(String? value) {
  return UfficioCostItemSource.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioCostItemSource.manual,
  );
}

class UfficioCostItem {
  const UfficioCostItem({
    required this.id,
    this.userId,
    this.categoryId,
    this.subcategoryId,
    required this.title,
    this.description,
    required this.amount,
    this.currency = 'EUR',
    required this.type,
    required this.status,
    this.dueDate,
    this.paidDate,
    this.relatedContactId,
    this.relatedDocumentId,
    required this.source,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? categoryId;
  final String? subcategoryId;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final UfficioCostItemType type;
  final UfficioCostItemStatus status;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? relatedContactId;
  final String? relatedDocumentId;
  final UfficioCostItemSource source;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UfficioCostItem copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? subcategoryId,
    String? title,
    String? description,
    double? amount,
    String? currency,
    UfficioCostItemType? type,
    UfficioCostItemStatus? status,
    DateTime? dueDate,
    DateTime? paidDate,
    String? relatedContactId,
    String? relatedDocumentId,
    UfficioCostItemSource? source,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UfficioCostItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      relatedContactId: relatedContactId ?? this.relatedContactId,
      relatedDocumentId: relatedDocumentId ?? this.relatedDocumentId,
      source: source ?? this.source,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'title': title,
    'description': description,
    'amount': amount,
    'currency': currency,
    'type': type.name,
    'status': status.name,
    'dueDate': dueDate?.toIso8601String(),
    'paidDate': paidDate?.toIso8601String(),
    'relatedContactId': relatedContactId,
    'relatedDocumentId': relatedDocumentId,
    'source': source.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UfficioCostItem.fromJson(Map<String, dynamic> json) =>
      UfficioCostItem(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String?,
        categoryId: json['categoryId'] as String?,
        subcategoryId: json['subcategoryId'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'EUR',
        type: ufficioCostItemTypeFromJson(json['type'] as String?),
        status: ufficioCostItemStatusFromJson(json['status'] as String?),
        dueDate: DateTime.tryParse(json['dueDate'] as String? ?? ''),
        paidDate: DateTime.tryParse(json['paidDate'] as String? ?? ''),
        relatedContactId: json['relatedContactId'] as String?,
        relatedDocumentId: json['relatedDocumentId'] as String?,
        source: ufficioCostItemSourceFromJson(json['source'] as String?),
        notes: json['notes'] as String?,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

enum UfficioContactSource { official, userSaved, categoryGenerated }

UfficioContactSource ufficioContactSourceFromJson(String? value) {
  return UfficioContactSource.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioContactSource.userSaved,
  );
}

enum UfficioContactType {
  publicOffice,
  authority,
  unionSupport,
  support,
  operator,
  personal,
  patronato,
  caf,
  healthcare,
  housing,
  other,
}

UfficioContactType ufficioContactTypeFromJson(String? value) {
  return UfficioContactType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioContactType.other,
  );
}

class UfficioContactEntry {
  const UfficioContactEntry({
    required this.id,
    this.userId,
    required this.source,
    this.categoryId,
    this.subcategoryId,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.pec,
    this.website,
    this.openingHours,
    this.useFor = const <String>[],
    this.warning,
    this.city,
    this.region,
    this.tags = const <String>[],
    required this.contactType,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final UfficioContactSource source;
  final String? categoryId;
  final String? subcategoryId;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? pec;
  final String? website;
  final String? openingHours;
  final List<String> useFor;
  final String? warning;
  final String? city;
  final String? region;
  final List<String> tags;
  final UfficioContactType contactType;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isOfficial => source != UfficioContactSource.userSaved;

  UfficioContactEntry copyWith({
    String? id,
    String? userId,
    UfficioContactSource? source,
    String? categoryId,
    String? subcategoryId,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? pec,
    String? website,
    String? openingHours,
    List<String>? useFor,
    String? warning,
    String? city,
    String? region,
    List<String>? tags,
    UfficioContactType? contactType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UfficioContactEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      pec: pec ?? this.pec,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      useFor: useFor ?? this.useFor,
      warning: warning ?? this.warning,
      city: city ?? this.city,
      region: region ?? this.region,
      tags: tags ?? this.tags,
      contactType: contactType ?? this.contactType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'source': source.name,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'name': name,
    'description': description,
    'address': address,
    'phone': phone,
    'email': email,
    'pec': pec,
    'website': website,
    'openingHours': openingHours,
    'useFor': useFor,
    'warning': warning,
    'city': city,
    'region': region,
    'tags': tags,
    'contactType': contactType.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UfficioContactEntry.fromJson(Map<String, dynamic> json) =>
      UfficioContactEntry(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String?,
        source: ufficioContactSourceFromJson(json['source'] as String?),
        categoryId: json['categoryId'] as String?,
        subcategoryId: json['subcategoryId'] as String?,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        pec: json['pec'] as String?,
        website: json['website'] as String?,
        openingHours: json['openingHours'] as String?,
        useFor: ((json['useFor'] as List?) ?? []).cast<String>(),
        warning: json['warning'] as String?,
        city: json['city'] as String?,
        region: json['region'] as String?,
        tags: ((json['tags'] as List?) ?? []).cast<String>(),
        contactType: ufficioContactTypeFromJson(json['contactType'] as String?),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

enum UfficioDocumentType {
  identity,
  codiceFiscale,
  bill,
  contract,
  receipt,
  form,
  certificate,
  paymentProof,
  photo,
  other,
}

UfficioDocumentType ufficioDocumentTypeFromJson(String? value) {
  return UfficioDocumentType.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioDocumentType.other,
  );
}

enum UfficioDocumentStatus {
  needed,
  collected,
  uploaded,
  sent,
  expired,
  rejected,
  notApplicable,
}

UfficioDocumentStatus ufficioDocumentStatusFromJson(String? value) {
  return UfficioDocumentStatus.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioDocumentStatus.needed,
  );
}

enum UfficioDocumentSource {
  manual,
  generatedFromSubcategory,
  uploaded,
  officialForm,
}

UfficioDocumentSource ufficioDocumentSourceFromJson(String? value) {
  return UfficioDocumentSource.values.firstWhere(
    (item) => item.name == value,
    orElse: () => UfficioDocumentSource.manual,
  );
}

class UfficioDocumentEntry {
  const UfficioDocumentEntry({
    required this.id,
    this.userId,
    this.categoryId,
    this.subcategoryId,
    required this.title,
    this.description,
    required this.documentType,
    required this.status,
    required this.source,
    this.fileUrl,
    this.fileName,
    this.expiryDate,
    this.relatedRequestId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final String? categoryId;
  final String? subcategoryId;
  final String title;
  final String? description;
  final UfficioDocumentType documentType;
  final UfficioDocumentStatus status;
  final UfficioDocumentSource source;
  final String? fileUrl;
  final String? fileName;
  final DateTime? expiryDate;
  final String? relatedRequestId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  UfficioDocumentEntry copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? subcategoryId,
    String? title,
    String? description,
    UfficioDocumentType? documentType,
    UfficioDocumentStatus? status,
    UfficioDocumentSource? source,
    String? fileUrl,
    String? fileName,
    DateTime? expiryDate,
    String? relatedRequestId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UfficioDocumentEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      source: source ?? this.source,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      expiryDate: expiryDate ?? this.expiryDate,
      relatedRequestId: relatedRequestId ?? this.relatedRequestId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'title': title,
    'description': description,
    'documentType': documentType.name,
    'status': status.name,
    'source': source.name,
    'fileUrl': fileUrl,
    'fileName': fileName,
    'expiryDate': expiryDate?.toIso8601String(),
    'relatedRequestId': relatedRequestId,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UfficioDocumentEntry.fromJson(Map<String, dynamic> json) =>
      UfficioDocumentEntry(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String?,
        categoryId: json['categoryId'] as String?,
        subcategoryId: json['subcategoryId'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        documentType: ufficioDocumentTypeFromJson(
          json['documentType'] as String?,
        ),
        status: ufficioDocumentStatusFromJson(json['status'] as String?),
        source: ufficioDocumentSourceFromJson(json['source'] as String?),
        fileUrl: json['fileUrl'] as String?,
        fileName: json['fileName'] as String?,
        expiryDate: DateTime.tryParse(json['expiryDate'] as String? ?? ''),
        relatedRequestId: json['relatedRequestId'] as String?,
        notes: json['notes'] as String?,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class CostSummary {
  const CostSummary({
    required this.totalEstimatedExpenses,
    required this.totalPaid,
    required this.totalExpectedRefunds,
    required this.totalDisputed,
    required this.upcomingDuePayments,
  });

  final double totalEstimatedExpenses;
  final double totalPaid;
  final double totalExpectedRefunds;
  final double totalDisputed;
  final int upcomingDuePayments;
}

class DocumentSummary {
  const DocumentSummary({
    required this.needed,
    required this.collected,
    required this.uploaded,
    required this.sent,
    required this.rejectedOrExpired,
  });

  final int needed;
  final int collected;
  final int uploaded;
  final int sent;
  final int rejectedOrExpired;
}

class PaymentPlaceholderResult {
  const PaymentPlaceholderResult({
    required this.available,
    required this.message,
  });

  final bool available;
  final String message;
}

class UfficioUserEntitlements {
  const UfficioUserEntitlements({
    required this.isPremium,
    required this.canRequestProblem,
    required this.canUsePrivateConsultancyForFree,
    required this.canUseCostDashboard,
    required this.canUseDocuments,
    required this.canUseContactsDirectory,
  });

  final bool isPremium;
  final bool canRequestProblem;
  final bool canUsePrivateConsultancyForFree;
  final bool canUseCostDashboard;
  final bool canUseDocuments;
  final bool canUseContactsDirectory;
}

class RequirePremiumOrPaymentResult {
  const RequirePremiumOrPaymentResult({
    required this.allowed,
    required this.paymentAvailable,
    required this.message,
    this.decision,
  });

  final bool allowed;
  final bool paymentAvailable;
  final String message;
  final EntitlementDecision? decision;
}

class LocalProblemRequestsRepository {
  const LocalProblemRequestsRepository(this._repo);

  factory LocalProblemRequestsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalProblemRequestsRepository(
        LocalStorageListRepository<ProblemRequestRecord>(
          prefs: prefs,
          storageKey: 'ufficio_problem_requests_v1',
          fromJson: ProblemRequestRecord.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );

  final LocalStorageListRepository<ProblemRequestRecord> _repo;

  Future<List<ProblemRequestRecord>> list() async => _repo.readAll();

  Future<void> save(ProblemRequestRecord item) async {
    final items = _repo.readAll()
      ..removeWhere((entry) => entry.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

abstract class ProblemRequestsRepository {
  Future<List<ProblemRequestRecord>> listUserProblemRequests();
  Future<List<ProblemRequestRecord>> listAdminProblemRequests();
  Future<ProblemRequestRecord> save(ProblemRequestRecord item);
}

class SupabaseProblemRequestsRepository implements ProblemRequestsRepository {
  const SupabaseProblemRequestsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ProblemRequestRecord>> listUserProblemRequests() async {
    final rows = await _client
        .from('ufficio_problem_requests')
        .select()
        .order('created_at', ascending: false);
    return rows
        .map((item) => _problemRequestFromDb(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<ProblemRequestRecord>> listAdminProblemRequests() async {
    final rows = await _client
        .from('ufficio_problem_requests')
        .select()
        .order('created_at', ascending: false);
    return rows
        .map((item) => _problemRequestFromDb(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<ProblemRequestRecord> save(ProblemRequestRecord item) async {
    final row = await _client
        .from('ufficio_problem_requests')
        .upsert(_problemRequestToDb(item))
        .select()
        .single();
    return _problemRequestFromDb(Map<String, dynamic>.from(row));
  }
}

class HybridProblemRequestsRepository implements ProblemRequestsRepository {
  HybridProblemRequestsRepository({
    required this.local,
    required this.config,
    required this.authFacade,
  });

  final LocalProblemRequestsRepository local;
  final UfficcioFacileConfig config;
  final UfficcioAuthFacade authFacade;

  SupabaseProblemRequestsRepository? get _remote {
    final client = SupabaseBootstrap.client;
    if (!config.isSupabaseEnabled ||
        !authFacade.state.isAuthenticated ||
        client == null) {
      return null;
    }
    return SupabaseProblemRequestsRepository(client);
  }

  @override
  Future<List<ProblemRequestRecord>> listAdminProblemRequests() async {
    final remote = _remote;
    if (remote == null) return local.list();
    try {
      return await remote.listAdminProblemRequests();
    } catch (_) {
      return local.list();
    }
  }

  @override
  Future<List<ProblemRequestRecord>> listUserProblemRequests() async {
    final remote = _remote;
    if (remote == null) return local.list();
    try {
      return await remote.listUserProblemRequests();
    } catch (_) {
      return local.list();
    }
  }

  @override
  Future<ProblemRequestRecord> save(ProblemRequestRecord item) async {
    await local.save(item);
    final remote = _remote;
    if (remote == null) return item;
    try {
      return await remote.save(item);
    } catch (_) {
      return item;
    }
  }
}

class LocalConsultancyRequestsRepository {
  const LocalConsultancyRequestsRepository(this._repo);

  factory LocalConsultancyRequestsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalConsultancyRequestsRepository(
        LocalStorageListRepository<ConsultancyRequestRecord>(
          prefs: prefs,
          storageKey: 'ufficio_consultancy_requests_v1',
          fromJson: ConsultancyRequestRecord.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );

  final LocalStorageListRepository<ConsultancyRequestRecord> _repo;

  Future<List<ConsultancyRequestRecord>> list() async => _repo.readAll();

  Future<void> save(ConsultancyRequestRecord item) async {
    final items = _repo.readAll()
      ..removeWhere((entry) => entry.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }
}

abstract class ConsultancyRequestsRepository {
  Future<List<ConsultancyRequestRecord>> listUserConsultancyRequests();
  Future<List<ConsultancyRequestRecord>> listAdminConsultancyRequests();
  Future<ConsultancyRequestRecord> save(ConsultancyRequestRecord item);
}

class SupabaseConsultancyRequestsRepository
    implements ConsultancyRequestsRepository {
  const SupabaseConsultancyRequestsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ConsultancyRequestRecord>> listAdminConsultancyRequests() async {
    final rows = await _client
        .from('ufficio_consultancy_requests')
        .select()
        .order('created_at', ascending: false);
    return rows
        .map((item) => _consultancyRequestFromDb(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<ConsultancyRequestRecord>> listUserConsultancyRequests() async {
    final rows = await _client
        .from('ufficio_consultancy_requests')
        .select()
        .order('created_at', ascending: false);
    return rows
        .map((item) => _consultancyRequestFromDb(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<ConsultancyRequestRecord> save(ConsultancyRequestRecord item) async {
    final row = await _client
        .from('ufficio_consultancy_requests')
        .upsert(_consultancyRequestToDb(item))
        .select()
        .single();
    return _consultancyRequestFromDb(Map<String, dynamic>.from(row));
  }
}

class HybridConsultancyRequestsRepository
    implements ConsultancyRequestsRepository {
  HybridConsultancyRequestsRepository({
    required this.local,
    required this.config,
    required this.authFacade,
  });

  final LocalConsultancyRequestsRepository local;
  final UfficcioFacileConfig config;
  final UfficcioAuthFacade authFacade;

  SupabaseConsultancyRequestsRepository? get _remote {
    final client = SupabaseBootstrap.client;
    if (!config.isSupabaseEnabled ||
        !authFacade.state.isAuthenticated ||
        client == null) {
      return null;
    }
    return SupabaseConsultancyRequestsRepository(client);
  }

  @override
  Future<List<ConsultancyRequestRecord>> listAdminConsultancyRequests() async {
    final remote = _remote;
    if (remote == null) return local.list();
    try {
      return await remote.listAdminConsultancyRequests();
    } catch (_) {
      return local.list();
    }
  }

  @override
  Future<List<ConsultancyRequestRecord>> listUserConsultancyRequests() async {
    final remote = _remote;
    if (remote == null) return local.list();
    try {
      return await remote.listUserConsultancyRequests();
    } catch (_) {
      return local.list();
    }
  }

  @override
  Future<ConsultancyRequestRecord> save(ConsultancyRequestRecord item) async {
    await local.save(item);
    final remote = _remote;
    if (remote == null) return item;
    try {
      return await remote.save(item);
    } catch (_) {
      return item;
    }
  }
}

class LocalCostItemsRepository {
  const LocalCostItemsRepository(this._repo);

  factory LocalCostItemsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalCostItemsRepository(
        LocalStorageListRepository<UfficioCostItem>(
          prefs: prefs,
          storageKey: 'ufficio_cost_items_v1',
          fromJson: UfficioCostItem.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );

  final LocalStorageListRepository<UfficioCostItem> _repo;

  Future<List<UfficioCostItem>> list() async => _repo.readAll();

  Future<void> save(UfficioCostItem item) async {
    final items = _repo.readAll()
      ..removeWhere((entry) => entry.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }

  Future<void> delete(String id) async {
    final items = _repo.readAll()..removeWhere((entry) => entry.id == id);
    await _repo.writeAll(items);
  }
}

class LocalDirectoryContactsRepository {
  const LocalDirectoryContactsRepository(this._repo);

  factory LocalDirectoryContactsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalDirectoryContactsRepository(
        LocalStorageListRepository<UfficioContactEntry>(
          prefs: prefs,
          storageKey: 'ufficio_directory_contacts_v1',
          fromJson: UfficioContactEntry.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );

  final LocalStorageListRepository<UfficioContactEntry> _repo;

  Future<List<UfficioContactEntry>> list() async => _repo.readAll();

  Future<void> save(UfficioContactEntry item) async {
    final items = _repo.readAll()
      ..removeWhere((entry) => entry.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }

  Future<void> delete(String id) async {
    final items = _repo.readAll()..removeWhere((entry) => entry.id == id);
    await _repo.writeAll(items);
  }
}

class LocalDirectoryDocumentsRepository {
  const LocalDirectoryDocumentsRepository(this._repo);

  factory LocalDirectoryDocumentsRepository.fromPrefs(SharedPreferences prefs) =>
      LocalDirectoryDocumentsRepository(
        LocalStorageListRepository<UfficioDocumentEntry>(
          prefs: prefs,
          storageKey: 'ufficio_documents_v2',
          fromJson: UfficioDocumentEntry.fromJson,
          toJson: (item) => item.toJson(),
        ),
      );

  final LocalStorageListRepository<UfficioDocumentEntry> _repo;

  Future<List<UfficioDocumentEntry>> list() async => _repo.readAll();

  Future<void> save(UfficioDocumentEntry item) async {
    final items = _repo.readAll()
      ..removeWhere((entry) => entry.id == item.id)
      ..add(item);
    await _repo.writeAll(items);
  }

  Future<void> delete(String id) async {
    final items = _repo.readAll()..removeWhere((entry) => entry.id == id);
    await _repo.writeAll(items);
  }
}

class ProblemRequestsService {
  const ProblemRequestsService(this._repository);

  final ProblemRequestsRepository _repository;

  Future<ProblemRequestRecord> submitProblemRequest(
    ProblemRequestRecord request,
  ) async {
    final saved = request.copyWith(updatedAt: DateTime.now());
    await _repository.save(saved);
    return saved;
  }

  Future<List<ProblemRequestRecord>> listUserProblemRequests() =>
      _repository.listUserProblemRequests();

  Future<List<ProblemRequestRecord>> listAdminProblemRequests() =>
      _repository.listAdminProblemRequests();
}

class ConsultancyService {
  const ConsultancyService(this._repository);

  final ConsultancyRequestsRepository _repository;

  Future<ConsultancyRequestRecord> submitConsultancyRequest(
    ConsultancyRequestRecord request,
  ) async {
    await _repository.save(request);
    return request;
  }

  Future<PaymentPlaceholderResult> createConsultancyPayment({
    required ConsultancyRequestRecord request,
  }) async {
    return const PaymentPlaceholderResult(
      available: false,
      message: 'Payment is not configured yet.',
    );
  }

  Future<PaymentPlaceholderResult> notifyConsultancyRequestCreated(
    ConsultancyRequestRecord request,
  ) async {
    return const PaymentPlaceholderResult(
      available: false,
      message: 'Notification email is not configured yet.',
    );
  }

  Future<List<ConsultancyRequestRecord>> listUserConsultancyRequests() =>
      _repository.listUserConsultancyRequests();

  Future<List<ConsultancyRequestRecord>> listAdminConsultancyRequests() =>
      _repository.listAdminConsultancyRequests();
}

Map<String, dynamic> _problemRequestToDb(ProblemRequestRecord item) => {
  'id': item.id,
  'user_id': item.userId,
  'user_email': item.userEmail,
  'category_id': item.categoryId,
  'subcategory_id': item.subcategoryId,
  'title': item.title,
  'description': item.description,
  'city': item.city,
  'region': item.region,
  'urgency': item.urgency,
  'language': item.language,
  'attachment_placeholder': item.attachmentPlaceholder,
  'status': switch (item.status) {
    ProblemRequestStatus.newRequest => 'new',
    ProblemRequestStatus.reviewing => 'reviewing',
    ProblemRequestStatus.planned => 'planned',
    ProblemRequestStatus.added => 'added',
    ProblemRequestStatus.rejected => 'rejected',
  },
  'is_premium_user': item.isPremiumUser,
  'source_page': item.sourcePage,
  'created_at': item.createdAt.toIso8601String(),
  'updated_at': item.updatedAt.toIso8601String(),
};

ProblemRequestRecord _problemRequestFromDb(Map<String, dynamic> row) =>
    ProblemRequestRecord(
      id: row['id'] as String? ?? '',
      userId: row['user_id'] as String?,
      userEmail: row['user_email'] as String?,
      categoryId: row['category_id'] as String?,
      subcategoryId: row['subcategory_id'] as String?,
      title: row['title'] as String? ?? '',
      description: row['description'] as String? ?? '',
      city: row['city'] as String? ?? 'Torino',
      region: row['region'] as String? ?? 'Piemonte',
      urgency: row['urgency'] as String? ?? 'normal',
      language: row['language'] as String? ?? 'English',
      attachmentPlaceholder: row['attachment_placeholder'] as String?,
      status: switch (row['status']) {
        'reviewing' => ProblemRequestStatus.reviewing,
        'planned' => ProblemRequestStatus.planned,
        'added' => ProblemRequestStatus.added,
        'rejected' => ProblemRequestStatus.rejected,
        _ => ProblemRequestStatus.newRequest,
      },
      isPremiumUser: row['is_premium_user'] as bool? ?? false,
      sourcePage: row['source_page'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );

Map<String, dynamic> _consultancyRequestToDb(ConsultancyRequestRecord item) => {
  'id': item.id,
  'user_id': item.userId,
  'user_email': item.userEmail,
  'full_name': item.fullName,
  'category_id': item.categoryId,
  'subcategory_id': item.subcategoryId,
  'problem_type': item.problemType,
  'description': item.description,
  'desired_result': item.desiredResult,
  'city': item.city,
  'region': item.region,
  'documents_available': item.documentsAvailable,
  'attachment_urls': item.attachmentUrls,
  'user_plan': item.userPlan,
  'payment_status': item.paymentStatus.name,
  'status': item.status.name,
  'source_page': item.sourcePage,
  'created_at': item.createdAt.toIso8601String(),
  'updated_at': item.updatedAt.toIso8601String(),
};

ConsultancyRequestRecord _consultancyRequestFromDb(Map<String, dynamic> row) =>
    ConsultancyRequestRecord(
      id: row['id'] as String? ?? '',
      userId: row['user_id'] as String?,
      userEmail: row['user_email'] as String?,
      fullName: row['full_name'] as String? ?? '',
      categoryId: row['category_id'] as String?,
      subcategoryId: row['subcategory_id'] as String?,
      problemType: row['problem_type'] as String? ?? '',
      description: row['description'] as String? ?? '',
      desiredResult: row['desired_result'] as String? ?? '',
      city: row['city'] as String? ?? 'Torino',
      region: row['region'] as String? ?? 'Piemonte',
      documentsAvailable: row['documents_available'] as String? ?? '',
      attachmentUrls: ((row['attachment_urls'] as List?) ?? const []).cast<String>(),
      userPlan: row['user_plan'] as String? ?? UfficioPlan.free.name,
      paymentStatus: consultancyPaymentStatusFromJson(
        row['payment_status'] as String?,
      ),
      status: consultancyRequestStatusFromJson(row['status'] as String?),
      sourcePage: row['source_page'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );

class CostDashboardService {
  const CostDashboardService(this._repository);

  final LocalCostItemsRepository _repository;

  Future<List<UfficioCostItem>> listCostItems() => _repository.list();

  Future<UfficioCostItem> createCostItem(UfficioCostItem item) async {
    await _repository.save(item);
    return item;
  }

  Future<UfficioCostItem> updateCostItem(UfficioCostItem item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _repository.save(updated);
    return updated;
  }

  Future<void> deleteCostItem(String id) => _repository.delete(id);

  Future<UfficioCostItem> markCostItemPaid(UfficioCostItem item) async {
    final nextStatus = item.type == UfficioCostItemType.refund
        ? UfficioCostItemStatus.refunded
        : UfficioCostItemStatus.paid;
    final updated = item.copyWith(
      status: nextStatus,
      paidDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.save(updated);
    return updated;
  }

  CostSummary calculateCostSummary(List<UfficioCostItem> items) {
    double estimatedExpenses = 0;
    double totalPaid = 0;
    double refunds = 0;
    double disputed = 0;
    var upcomingDuePayments = 0;
    final now = DateTime.now();
    for (final item in items) {
      if (item.type != UfficioCostItemType.refund &&
          item.status != UfficioCostItemStatus.cancelled) {
        estimatedExpenses += item.amount;
      }
      if (item.status == UfficioCostItemStatus.paid) {
        totalPaid += item.amount;
      }
      if (item.type == UfficioCostItemType.refund &&
          item.status != UfficioCostItemStatus.cancelled) {
        refunds += item.amount;
      }
      if (item.status == UfficioCostItemStatus.disputed) {
        disputed += item.amount;
      }
      if (item.dueDate != null &&
          item.dueDate!.isAfter(now) &&
          item.status != UfficioCostItemStatus.paid &&
          item.status != UfficioCostItemStatus.refunded &&
          item.status != UfficioCostItemStatus.cancelled) {
        upcomingDuePayments += 1;
      }
    }
    return CostSummary(
      totalEstimatedExpenses: estimatedExpenses,
      totalPaid: totalPaid,
      totalExpectedRefunds: refunds,
      totalDisputed: disputed,
      upcomingDuePayments: upcomingDuePayments,
    );
  }
}

class ContactsDirectoryService {
  const ContactsDirectoryService(this._repository);

  final LocalDirectoryContactsRepository _repository;

  List<UfficioContactEntry> extractOfficialContactsFromCategories() {
    final official = <UfficioContactEntry>[
      ..._mapHealthContacts(healthAslGetTesseraSanitariaTorino),
      ..._mapHousingContacts(HousingRentGuidanceDefinitions.category),
      ..._mapRichContacts(UtilitiesElectricityGasGuidanceDefinitions.category),
      ..._mapRichContacts(CanoneRaiGuidanceDefinitions.category),
      ..._mapRichContacts(TelecomGuidanceDefinitions.category),
      ..._mapRichContacts(PublicOfficeComuneGuidanceDefinitions.category),
      ..._mapRichContacts(WorkInpsPatronatoGuidanceDefinitions.category),
      ..._mapRichContacts(UniversityStudentGuidanceDefinitions.category),
      ..._mapRichContacts(GeneralGuidanceDefinitions.category),
    ];
    return dedupeContacts(official);
  }

  Future<List<UfficioContactEntry>> listContacts() async {
    final custom = await _repository.list();
    final merged = [...extractOfficialContactsFromCategories(), ...custom];
    return dedupeContacts(merged)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<UfficioContactEntry> createCustomContact(UfficioContactEntry item) async {
    await _repository.save(
      item.copyWith(source: UfficioContactSource.userSaved),
    );
    return item;
  }

  Future<UfficioContactEntry> updateCustomContact(UfficioContactEntry item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _repository.save(updated);
    return updated;
  }

  Future<void> deleteCustomContact(String id) => _repository.delete(id);

  List<UfficioContactEntry> dedupeContacts(List<UfficioContactEntry> items) {
    final seen = <String>{};
    final deduped = <UfficioContactEntry>[];
    for (final item in items) {
      final key = item.id.isNotEmpty
          ? 'id:${item.id}'
          : [
              item.name.trim().toLowerCase(),
              (item.email ?? '').trim().toLowerCase(),
              (item.pec ?? '').trim().toLowerCase(),
              (item.phone ?? '').trim().toLowerCase(),
            ].join('|');
      if (seen.add(key)) {
        deduped.add(item);
      }
    }
    return deduped;
  }
}

class DocumentsService {
  const DocumentsService(this._repository);

  final LocalDirectoryDocumentsRepository _repository;

  Future<List<UfficioDocumentEntry>> listDocuments() => _repository.list();

  Future<UfficioDocumentEntry> createDocument(UfficioDocumentEntry item) async {
    await _repository.save(item);
    return item;
  }

  Future<List<UfficioDocumentEntry>> createDocumentsFromSubcategory({
    required String userId,
    required RichCategoryGuidance categoryGuidance,
    required RichCategorySubcategory subcategory,
  }) async {
    final existing = await _repository.list();
    final commonDocuments = {
      for (final item in categoryGuidance.commonDocuments) item.id: item,
    };
    final entries = <UfficioDocumentEntry>[];
    for (final id in subcategory.documents) {
      final title = commonDocuments[id]?.label ?? id;
      final duplicate = existing.any(
        (item) =>
            item.userId == userId &&
            item.categoryId == categoryGuidance.id &&
            item.subcategoryId == subcategory.id &&
            item.title.trim().toLowerCase() == title.trim().toLowerCase(),
      );
      if (duplicate) {
        continue;
      }
      entries.add(
        UfficioDocumentEntry(
          id:
              '${categoryGuidance.id}_${subcategory.id}_${title.toLowerCase().replaceAll(' ', '_')}',
          userId: userId,
          categoryId: categoryGuidance.id,
          subcategoryId: subcategory.id,
          title: title,
          description: subcategory.title,
          documentType: _guessDocumentType(title),
          status: UfficioDocumentStatus.needed,
          source: UfficioDocumentSource.generatedFromSubcategory,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    for (final title in subcategory.extraDocuments) {
      final duplicate = existing.any(
        (item) =>
            item.userId == userId &&
            item.categoryId == categoryGuidance.id &&
            item.subcategoryId == subcategory.id &&
            item.title.trim().toLowerCase() == title.trim().toLowerCase(),
      );
      if (duplicate) {
        continue;
      }
      entries.add(
        UfficioDocumentEntry(
          id:
              '${categoryGuidance.id}_${subcategory.id}_${title.toLowerCase().replaceAll(' ', '_')}',
          userId: userId,
          categoryId: categoryGuidance.id,
          subcategoryId: subcategory.id,
          title: title,
          description: subcategory.title,
          documentType: _guessDocumentType(title),
          status: UfficioDocumentStatus.needed,
          source: UfficioDocumentSource.generatedFromSubcategory,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    for (final item in entries) {
      await _repository.save(item);
    }
    return entries;
  }

  Future<UfficioDocumentEntry> updateDocument(UfficioDocumentEntry item) async {
    final updated = item.copyWith(updatedAt: DateTime.now());
    await _repository.save(updated);
    return updated;
  }

  Future<void> deleteDocument(String id) => _repository.delete(id);

  Future<UfficioDocumentEntry> markCollected(UfficioDocumentEntry item) async {
    final updated = item.copyWith(
      status: UfficioDocumentStatus.collected,
      updatedAt: DateTime.now(),
    );
    await _repository.save(updated);
    return updated;
  }

  Future<UfficioDocumentEntry> markSent(UfficioDocumentEntry item) async {
    final updated = item.copyWith(
      status: UfficioDocumentStatus.sent,
      updatedAt: DateTime.now(),
    );
    await _repository.save(updated);
    return updated;
  }

  DocumentSummary calculateDocumentSummary(List<UfficioDocumentEntry> items) {
    var needed = 0;
    var collected = 0;
    var uploaded = 0;
    var sent = 0;
    var rejectedOrExpired = 0;
    for (final item in items) {
      switch (item.status) {
        case UfficioDocumentStatus.needed:
          needed += 1;
        case UfficioDocumentStatus.collected:
          collected += 1;
        case UfficioDocumentStatus.uploaded:
          uploaded += 1;
        case UfficioDocumentStatus.sent:
          sent += 1;
        case UfficioDocumentStatus.expired:
        case UfficioDocumentStatus.rejected:
          rejectedOrExpired += 1;
        case UfficioDocumentStatus.notApplicable:
          break;
      }
    }
    return DocumentSummary(
      needed: needed,
      collected: collected,
      uploaded: uploaded,
      sent: sent,
      rejectedOrExpired: rejectedOrExpired,
    );
  }
}

class EntitlementsService {
  const EntitlementsService(this._premiumService);

  final UfficioPremiumEntitlementService _premiumService;

  Future<UfficioUserEntitlements> getUserEntitlements() async {
    final entitlement = await _premiumService.getCurrentEntitlement();
    final isPremium = entitlement.isProLike;
    return UfficioUserEntitlements(
      isPremium: isPremium,
      canRequestProblem: isPremium || entitlement.betaModeEnabled,
      canUsePrivateConsultancyForFree: isPremium || entitlement.betaModeEnabled,
      canUseCostDashboard: true,
      canUseDocuments: true,
      canUseContactsDirectory: true,
    );
  }

  Future<RequirePremiumOrPaymentResult> requirePremiumOrPayment({
    required String purpose,
  }) async {
    final decision = await _premiumService.canUseFeature(
      purpose == 'consultancy'
          ? FeatureKey.consultantMode
          : FeatureKey.serviceIntelligenceAdvanced,
    );
    if (decision.allowed) {
      return RequirePremiumOrPaymentResult(
        allowed: true,
        paymentAvailable: false,
        message: decision.reason,
        decision: decision,
      );
    }
    return RequirePremiumOrPaymentResult(
      allowed: false,
      paymentAvailable: false,
      message: 'Payment is not configured yet.',
      decision: decision,
    );
  }
}

UfficioDocumentType _guessDocumentType(String label) {
  final value = label.toLowerCase();
  if (value.contains('identity') || value.contains('documento')) {
    return UfficioDocumentType.identity;
  }
  if (value.contains('codice fiscale')) {
    return UfficioDocumentType.codiceFiscale;
  }
  if (value.contains('bill') || value.contains('bolletta')) {
    return UfficioDocumentType.bill;
  }
  if (value.contains('contract') || value.contains('contratto')) {
    return UfficioDocumentType.contract;
  }
  if (value.contains('receipt') || value.contains('ricevuta')) {
    return UfficioDocumentType.receipt;
  }
  if (value.contains('form') || value.contains('modulo')) {
    return UfficioDocumentType.form;
  }
  if (value.contains('certificate') || value.contains('certificato')) {
    return UfficioDocumentType.certificate;
  }
  if (value.contains('payment')) {
    return UfficioDocumentType.paymentProof;
  }
  if (value.contains('photo') || value.contains('foto')) {
    return UfficioDocumentType.photo;
  }
  return UfficioDocumentType.other;
}

List<UfficioContactEntry> _mapRichContacts(RichCategoryGuidance guidance) {
  return guidance.contacts.values.map((contact) {
    final type = _guessContactType(
      categoryId: guidance.id,
      contact: contact,
      useFor: contact.useFor,
    );
    return UfficioContactEntry(
      id: contact.id.isEmpty ? '${guidance.id}_${contact.name}' : contact.id,
      source: UfficioContactSource.official,
      categoryId: guidance.id,
      name: contact.name,
      description: contact.authority,
      address:
          contact.address ??
          contact.postalAddress ??
          contact.physicalOfficeAddress,
      phone:
          contact.phone ??
          contact.phoneFixedLine ??
          contact.phoneMobileOrAbroad ??
          contact.consumerPhone ??
          contact.conciliationFreeNumber,
      email: contact.email,
      pec: contact.pec,
      website: contact.url,
      openingHours:
          contact.openingHours ?? contact.conciliationFreeNumberHours,
      useFor: contact.useFor,
      warning: contact.warning,
      city: guidance.city,
      region: guidance.region,
      tags: [guidance.id, ...contact.useFor],
      contactType: type,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }).toList();
}

List<UfficioContactEntry> _mapHealthContacts(HealthAslGuidance guidance) {
  return guidance.contacts.values.map((contact) {
    return UfficioContactEntry(
      id: '${guidance.id}_${contact.name}',
      source: UfficioContactSource.official,
      categoryId: guidance.id,
      name: contact.name,
      description: contact.fullName ?? contact.accessMode,
      address: contact.address,
      phone: contact.phone,
      email: contact.email,
      pec: contact.pec,
      website: null,
      openingHours: contact.openingHours,
      useFor: contact.useFor,
      warning: contact.warning,
      city: guidance.city,
      region: guidance.region,
      tags: [guidance.id, ...contact.useFor],
      contactType: UfficioContactType.healthcare,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }).toList();
}

List<UfficioContactEntry> _mapHousingContacts(HousingRentGuidance guidance) {
  return guidance.contacts.values.map((contact) {
    return UfficioContactEntry(
      id: '${guidance.id}_${contact.name}',
      source: UfficioContactSource.official,
      categoryId: guidance.id,
      name: contact.name,
      description: contact.officeCode,
      address: contact.address,
      phone: contact.phone,
      email: contact.email,
      pec: contact.pec,
      website: null,
      openingHours: contact.openingHours,
      useFor: contact.useFor,
      warning: contact.warning,
      city: guidance.city,
      region: guidance.region,
      tags: [guidance.id, ...contact.useFor],
      contactType: UfficioContactType.housing,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }).toList();
}

UfficioContactType _guessContactType({
  required String categoryId,
  required RichCategoryContact contact,
  required List<String> useFor,
}) {
  final haystack = '${contact.name} ${contact.authority ?? ''} ${useFor.join(' ')}'
      .toLowerCase();
  if (categoryId.contains('public_office') ||
      haystack.contains('comune') ||
      haystack.contains('anagrafe')) {
    return UfficioContactType.publicOffice;
  }
  if (categoryId.contains('work') || haystack.contains('patronato')) {
    return UfficioContactType.patronato;
  }
  if (haystack.contains('caf')) {
    return UfficioContactType.caf;
  }
  if (haystack.contains('union') ||
      haystack.contains('cgil') ||
      haystack.contains('sindacato')) {
    return UfficioContactType.unionSupport;
  }
  if (haystack.contains('operator') ||
      haystack.contains('provider') ||
      haystack.contains('agcom') ||
      haystack.contains('arera')) {
    return UfficioContactType.operator;
  }
  if (haystack.contains('authority') || haystack.contains('agenzia')) {
    return UfficioContactType.authority;
  }
  return UfficioContactType.support;
}
