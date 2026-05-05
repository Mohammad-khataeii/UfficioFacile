import '../domain/admin_procedure.dart';
import '../domain/attachment_item.dart';
import '../domain/procedure_field.dart';
import 'generators/shared_generator_helpers.dart';

class ItalyAdminProcedureDefinitions {
  static List<AdminProcedure> all() => _procedures;

  static AdminProcedure? byId(String id) {
    for (final procedure in _procedures) {
      if (procedure.id == id) return procedure;
    }
    return null;
  }

  static final List<AdminProcedure> _procedures = [
    _health(
      'CHANGE_DOCTOR',
      'Change Doctor / Medico di Base Request',
      'Change doctor',
      _changeDoctorFields(),
      _healthAttachments(),
    ),
    _health(
      'TESSERA_SANITARIA_RENEWAL',
      'Tessera Sanitaria Renewal / Health Card Problem',
      'Health card',
      _tesseraFields(),
      _tesseraAttachments(),
    ),
    _health(
      'ASL_REJECTED_REQUEST_REPLY',
      'ASL Rejected Request Reply',
      'Rejected ASL request',
      _rejectedFields(),
      _rejectedAttachments(),
    ),
    _health(
      'ASL_APPOINTMENT_REQUEST',
      'ASL Appointment Request',
      'ASL appointment',
      _appointmentFields(),
      _genericAttachments(),
    ),
    _housing(
      'RENTAL_CONTRACT_CHANGE',
      'Rental Contract Add Tenant / Subentro / Cessione / Integrazione',
      'Contract change',
      _rentalFields(),
      _rentalAttachments(),
    ),
    _housing(
      'LANDLORD_MAINTENANCE_OR_CONTRACT',
      'Landlord Maintenance / Contract Problem Letter',
      'Maintenance & contract',
      _landlordFields(),
      _landlordAttachments(),
    ),
    _housing(
      'DEPOSIT_RETURN_REQUEST',
      'Deposit Return Request',
      'Deposit return',
      _depositFields(),
      _depositAttachments(),
    ),
    _housing(
      'RENT_CONTRACT_TERMINATION_NOTICE',
      'Rent Contract Termination Notice',
      'Contract termination',
      _terminationFields(),
      _rentalAttachments(),
    ),
    _utility(
      'ENERGY_BILL_ANALYZER_CHECKLIST',
      'Energy Bill Analyzer Checklist',
      'Bill understanding',
      _energyBillFields(),
      _billAttachments(),
    ),
    _utility(
      'ENERGY_SUPPLIER_COMPARISON',
      'Energy Supplier Comparison',
      'Offer comparison',
      _energyComparisonFields(),
      _billAttachments(),
    ),
    _utility(
      'ELECTRICITY_GAS_SWITCH_REQUEST',
      'Electricity / Gas Switch Request',
      'Provider switching',
      _utilitySwitchFields(),
      _utilityAttachments(),
    ),
    _utility(
      'VOLTURA_REQUEST',
      'Voltura Request',
      'Voltura',
      _utilitySwitchFields(),
      _utilityAttachments(),
    ),
    _utility(
      'SUBENTRO_REQUEST',
      'Subentro Request',
      'Subentro',
      _utilitySwitchFields(),
      _utilityAttachments(),
    ),
    _utility(
      'UTILITY_CANCELLATION_DISDETTA',
      'Utility Cancellation / Disdetta',
      'Disdetta',
      _utilityCancellationFields(),
      _utilityAttachments(),
    ),
    _utility(
      'HIGH_BILL_COMPLAINT',
      'High Bill Complaint',
      'High bill complaint',
      _highBillFields(),
      _billAttachments(),
    ),
    _utility(
      'METER_READING_CORRECTION',
      'Meter Reading Correction',
      'Reading correction',
      _meterCorrectionFields(),
      _billAttachments(),
    ),
    _utility(
      'PAYMENT_PLAN_REQUEST',
      'Payment Plan Request',
      'Payment plan',
      _paymentPlanFields(),
      _billAttachments(),
    ),
    _utility(
      'WRONG_CHARGE_REFUND_REQUEST',
      'Wrong Charge Refund Request',
      'Wrong charge refund',
      _wrongChargeFields(),
      _billAttachments(),
    ),
    _utility(
      'UNILATERAL_CONTRACT_CHANGE_COMPLAINT',
      'Unilateral Contract Change Complaint',
      'Contract change complaint',
      _contractChangeComplaintFields(),
      _billAttachments(),
    ),
    _canone(
      'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      'Canone RAI No-TV Declaration Checklist',
      'No-TV declaration',
      _canoneFields(),
      _canoneAttachments(),
    ),
    _canone(
      'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
      'Canone RAI Over-75 Exemption Checklist',
      'Over-75 exemption',
      _canoneFields(),
      _canoneAttachments(),
    ),
    _canone(
      'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      'Canone RAI Refund or Wrong Charge',
      'Refund / wrong charge',
      _canoneRefundFields(),
      _canoneAttachments(),
    ),
    _telecom(
      'INTERNET_PHONE_CANCELLATION',
      'Internet / Phone Cancellation',
      'Cancellation',
      _telecomCancellationFields(),
      _telecomAttachments(),
    ),
    _telecom(
      'TELECOM_WRONG_BILL_COMPLAINT',
      'Telecom Wrong Bill Complaint',
      'Wrong bill',
      _telecomComplaintFields(),
      _telecomAttachments(),
    ),
    _telecom(
      'SERVICE_NOT_WORKING_COMPLAINT',
      'Service Not Working Complaint',
      'Service issue',
      _telecomComplaintFields(),
      _telecomAttachments(),
    ),
    _telecom(
      'MODEM_RETURN_OR_CHARGE_DISPUTE',
      'Modem Return or Charge Dispute',
      'Modem dispute',
      _telecomComplaintFields(),
      _telecomAttachments(),
    ),
    _publicOffice(
      'COMUNE_RESIDENCE_REQUEST',
      'Comune / Residenza / Anagrafe Request',
      'Residence',
      _comuneFields(),
      _comuneAttachments(),
    ),
    _publicOffice(
      'ANAGRAFE_CERTIFICATE_REQUEST',
      'Anagrafe Certificate Request',
      'Certificate request',
      _anagrafeFields(),
      _comuneAttachments(),
    ),
    _work(
      'NASPI_PREPARATION',
      'NASpI Preparation',
      'NASpI',
      _naspiFields(),
      _naspiAttachments(),
    ),
    _work(
      'PATRONATO_APPOINTMENT_REQUEST',
      'Patronato Appointment Request',
      'Patronato appointment',
      _appointmentFields(),
      _genericAttachments(),
    ),
    _university(
      'UNIVERSITY_OFFICE_REQUEST',
      'University Office Request',
      'University office',
      _universityFields(),
      _universityAttachments(),
    ),
    _university(
      'PERMESSO_DOCUMENT_CHECKLIST',
      'Permesso Document Checklist',
      'Permesso support',
      _permessoFields(),
      _permessoAttachments(),
    ),
    _general(
      'REJECTED_REQUEST_REPLY',
      'Reply to Rejected Public Office Request',
      'Rejected request',
      _rejectedFields(),
      _rejectedAttachments(),
    ),
    _general(
      'REFUND_OR_COMPLAINT_REQUEST',
      'Refund or Complaint Request',
      'Refund / complaint',
      _refundFields(),
      _refundAttachments(),
    ),
    _general(
      'APPOINTMENT_REQUEST',
      'Formal Appointment Request',
      'Appointment',
      _appointmentFields(),
      _genericAttachments(),
    ),
    _general(
      'GENERIC_FORMAL_REQUEST',
      'Generic Formal Request',
      'Generic formal',
      _genericFields(),
      _genericAttachments(),
    ),
  ];
}

AdminProcedure _build({
  required String id,
  required String title,
  required ProcedureCategory category,
  required String subcategory,
  required List<ProcedureField> fields,
  required List<AttachmentSuggestion> attachments,
  required List<String> tags,
  required String shortDescription,
}) {
  return AdminProcedure(
    id: id,
    title: title,
    category: category,
    subcategory: subcategory,
    shortDescription: shortDescription,
    longDescription:
        '$title helps the user organize the case, collect the right information, and generate a formal Italian request pack with follow-up and checklist support.',
    authorityType: category.label,
    difficulty: _difficultyFor(category),
    estimatedMinutes: _minutesFor(category),
    targetRecipientExamples: _recipientsFor(category),
    fields: fields,
    attachmentSuggestions: attachments,
    tags: tags,
    isPremium: false,
    disclaimer: '$kItalianDisclaimer\n\n$kEnglishDisclaimer',
  );
}

AdminProcedure _health(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.health,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['medico', 'ASL', 'tessera sanitaria', 'health'],
  shortDescription: 'Health and ASL support workflow.',
);

AdminProcedure _housing(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.housing,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['affitto', 'landlord', 'subentro', 'deposit', 'housing'],
  shortDescription: 'Housing and rent administration workflow.',
);

AdminProcedure _utility(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.utilities,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['bolletta', 'luce', 'gas', 'fornitore', 'voltura', 'disdetta'],
  shortDescription: 'Electricity and gas workflow or checklist.',
);

AdminProcedure _canone(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.canoneRai,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['canone rai', 'tv', 'refund', 'exemption'],
  shortDescription: 'Canone RAI checklist and support workflow.',
);

AdminProcedure _telecom(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.telecom,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['internet', 'telefono', 'modem', 'disdetta', 'telecom'],
  shortDescription: 'Internet and phone complaint workflow.',
);

AdminProcedure _publicOffice(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.publicOffice,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['residenza', 'comune', 'anagrafe', 'documents'],
  shortDescription: 'Comune and document support workflow.',
);

AdminProcedure _work(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.work,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['NASpI', 'patronato', 'INPS', 'lavoro'],
  shortDescription: 'Work and patronato support workflow.',
);

AdminProcedure _university(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.university,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['università', 'ISEE', 'borsa', 'tuition'],
  shortDescription: 'University administration support workflow.',
);

AdminProcedure _general(
  String id,
  String title,
  String subcategory,
  List<ProcedureField> fields,
  List<AttachmentSuggestion> attachments,
) => _build(
  id: id,
  title: title,
  category: ProcedureCategory.general,
  subcategory: subcategory,
  fields: fields,
  attachments: attachments,
  tags: const ['generic', 'formal', 'appointment', 'refund', 'complaint'],
  shortDescription: 'General formal support workflow.',
);

ProcedureDifficulty _difficultyFor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.health:
    case ProcedureCategory.publicOffice:
    case ProcedureCategory.work:
      return ProcedureDifficulty.medium;
    case ProcedureCategory.housing:
    case ProcedureCategory.utilities:
    case ProcedureCategory.canoneRai:
      return ProcedureDifficulty.high;
    case ProcedureCategory.telecom:
    case ProcedureCategory.university:
    case ProcedureCategory.general:
    case ProcedureCategory.immigration:
    case ProcedureCategory.complaint:
      return ProcedureDifficulty.medium;
  }
}

int _minutesFor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.utilities:
      return 10;
    case ProcedureCategory.canoneRai:
      return 8;
    case ProcedureCategory.housing:
      return 9;
    default:
      return 7;
  }
}

List<String> _recipientsFor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.health:
      return const ['ASL', 'Health office'];
    case ProcedureCategory.housing:
      return const ['Landlord', 'Agency', 'Agenzia Entrate'];
    case ProcedureCategory.utilities:
      return const ['Energy provider', 'Customer support'];
    case ProcedureCategory.canoneRai:
      return const ['Agenzia Entrate', 'Energy provider'];
    case ProcedureCategory.telecom:
      return const ['Telecom provider'];
    case ProcedureCategory.publicOffice:
      return const ['Comune', 'Anagrafe'];
    case ProcedureCategory.work:
      return const ['Patronato', 'CAF', 'Employer'];
    case ProcedureCategory.university:
      return const ['University office'];
    case ProcedureCategory.complaint:
      return const ['Company', 'Support office'];
    case ProcedureCategory.general:
    case ProcedureCategory.immigration:
      return const ['Office', 'Company'];
  }
}

ProcedureField _field(
  String id,
  String label,
  ProcedureFieldType type, {
  bool required = true,
  String? section,
  List<FieldOption> options = const [],
  FieldCondition? showWhen,
  FieldValidation? validation,
}) {
  return ProcedureField(
    id: id,
    label: label,
    type: type,
    required: required,
    section: section,
    options: options,
    showWhen: showWhen,
    validation: validation,
  );
}

AttachmentSuggestion _attachment(
  String id,
  String name,
  AttachmentCategory category, {
  bool required = false,
}) {
  return AttachmentSuggestion(
    id: id,
    name: name,
    description: name,
    required: required,
    category: category,
  );
}

List<ProcedureField> _identityFields() => [
  _field('fullName', 'Full name', ProcedureFieldType.text, section: 'Personal'),
  _field(
    'codiceFiscale',
    'Codice fiscale',
    ProcedureFieldType.text,
    required: false,
    section: 'Personal',
  ),
  _field(
    'phone',
    'Phone',
    ProcedureFieldType.phone,
    required: false,
    section: 'Personal',
  ),
  _field(
    'email',
    'Email',
    ProcedureFieldType.email,
    required: false,
    section: 'Personal',
  ),
  _field(
    'city',
    'City',
    ProcedureFieldType.text,
    required: false,
    section: 'Personal',
  ),
];

List<ProcedureField> _changeDoctorFields() => [
  ..._identityFields(),
  _field(
    'addressOrDomicile',
    'Address',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'aslOrOfficeName',
    'ASL or office',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'requestedDoctor',
    'Requested doctor',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'reason',
    'Reason',
    ProcedureFieldType.textarea,
    section: 'Case',
    validation: const FieldValidation(minLength: 12),
  ),
  _field(
    'cannotGoInPerson',
    'Cannot go in person',
    ProcedureFieldType.boolean,
    section: 'Case',
  ),
];

List<ProcedureField> _tesseraFields() => [
  ..._identityFields(),
  _field(
    'cardExpiryDate',
    'Card expiry date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'cityOrAsl',
    'City or ASL',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('reason', 'Reason', ProcedureFieldType.textarea, section: 'Case'),
  _field(
    'canGoInPerson',
    'Can go in person',
    ProcedureFieldType.boolean,
    section: 'Case',
  ),
  _field(
    'urgencyReason',
    'Urgency reason',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _rejectedFields() => [
  _field(
    'officeName',
    'Office name',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'originalRequestTopic',
    'Original request topic',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'originalRequestDate',
    'Original request date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'rejectionDate',
    'Rejection date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'rejectionReason',
    'Rejection reason',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field(
    'missingDocumentNowAttached',
    'Missing document now attached',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
  _field(
    'desiredOutcome',
    'Desired outcome',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _appointmentFields() => [
  ..._identityFields(),
  _field(
    'recipient',
    'Recipient',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('reason', 'Reason', ProcedureFieldType.textarea, section: 'Case'),
  _field(
    'preferredDatesOrTimes',
    'Preferred dates or times',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
  _field(
    'urgency',
    'Urgency',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _rentalFields() => [
  _field(
    'tenantName',
    'Tenant name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'landlordOrAgencyName',
    'Landlord or agency',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'requestType',
    'Request type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'effectiveDate',
    'Effective date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'allPartiesAgree',
    'All parties agree',
    ProcedureFieldType.boolean,
    section: 'Case',
  ),
];

List<ProcedureField> _landlordFields() => [
  _field(
    'tenantName',
    'Tenant name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'landlordOrAgencyName',
    'Landlord or agency',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field('issueType', 'Issue type', ProcedureFieldType.text, section: 'Case'),
  _field(
    'description',
    'Description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field(
    'dateDiscovered',
    'Date discovered',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'desiredAction',
    'Desired action',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _depositFields() => [
  ..._landlordFields(),
  _field(
    'depositAmount',
    'Deposit amount',
    ProcedureFieldType.number,
    required: false,
    section: 'Case',
  ),
  _field(
    'moveOutDate',
    'Move-out date',
    ProcedureFieldType.date,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _terminationFields() => [
  _field(
    'tenantName',
    'Tenant name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'landlordOrAgencyName',
    'Landlord or agency',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'propertyAddress',
    'Property address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'terminationDate',
    'Termination date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'noticeReason',
    'Notice reason',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _energyBillFields() => [
  _field(
    'providerName',
    'Provider name',
    ProcedureFieldType.text,
    section: 'Bill',
  ),
  _field('billPeriod', 'Bill period', ProcedureFieldType.text, section: 'Bill'),
  _field('amount', 'Amount', ProcedureFieldType.number, section: 'Bill'),
  _field(
    'billType',
    'Bill type',
    ProcedureFieldType.select,
    section: 'Bill',
    options: const [
      FieldOption(value: 'electricity', label: 'Electricity'),
      FieldOption(value: 'gas', label: 'Gas'),
      FieldOption(value: 'water', label: 'Water'),
      FieldOption(value: 'internet', label: 'Internet'),
    ],
  ),
  _field(
    'readingType',
    'Reading type',
    ProcedureFieldType.text,
    required: false,
    section: 'Bill',
  ),
  _field(
    'consumption',
    'Consumption',
    ProcedureFieldType.number,
    required: false,
    section: 'Bill',
  ),
  _field(
    'hasConguaglio',
    'Conguaglio present',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Bill',
  ),
  _field(
    'hasCanoneRai',
    'Canone RAI present',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Bill',
  ),
  _field(
    'amountSeemsAbnormal',
    'Amount seems abnormal',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Bill',
  ),
  _field(
    'previousBillAmount',
    'Previous bill amount',
    ProcedureFieldType.number,
    required: false,
    section: 'Bill',
  ),
];

List<ProcedureField> _energyComparisonFields() => [
  _field(
    'currentProvider',
    'Current provider',
    ProcedureFieldType.text,
    section: 'Current contract',
  ),
  _field(
    'currentAnnualCost',
    'Current annual cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'currentMonthlyCost',
    'Current monthly cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'currentConsumptionKwh',
    'Current kWh consumption',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'currentGasSmc',
    'Current gas Smc',
    ProcedureFieldType.number,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'residentDomestic',
    'Resident domestic',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'hasCanoneRaiCharge',
    'Canone RAI charge',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Current contract',
  ),
  _field(
    'offerAProvider',
    'Offer A provider',
    ProcedureFieldType.text,
    section: 'Offer A',
  ),
  _field(
    'offerAName',
    'Offer A name',
    ProcedureFieldType.text,
    section: 'Offer A',
  ),
  _field(
    'offerAEstimatedAnnualCost',
    'Offer A estimated annual cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Offer A',
  ),
  _field(
    'offerBProvider',
    'Offer B provider',
    ProcedureFieldType.text,
    section: 'Offer B',
  ),
  _field(
    'offerBName',
    'Offer B name',
    ProcedureFieldType.text,
    section: 'Offer B',
  ),
  _field(
    'offerBEstimatedAnnualCost',
    'Offer B estimated annual cost',
    ProcedureFieldType.number,
    required: false,
    section: 'Offer B',
  ),
];

List<ProcedureField> _utilitySwitchFields() => [
  _field(
    'fullName',
    'Contract holder',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field('provider', 'Provider', ProcedureFieldType.text, section: 'Recipient'),
  _field(
    'supplyAddress',
    'Supply address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'podOrPdr',
    'POD / PDR',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field('reason', 'Reason', ProcedureFieldType.textarea, section: 'Case'),
];

List<ProcedureField> _utilityCancellationFields() => [
  ..._utilitySwitchFields(),
  _field(
    'contractNumber',
    'Contract number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'cancellationDate',
    'Cancellation date',
    ProcedureFieldType.date,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _highBillFields() => [
  ..._energyBillFields(),
  _field(
    'desiredSolution',
    'Desired solution',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _meterCorrectionFields() => [
  ..._utilitySwitchFields(),
  _field(
    'meterReadingValue',
    'Correct meter reading',
    ProcedureFieldType.number,
    required: false,
    section: 'Case',
  ),
  _field(
    'invoiceNumber',
    'Invoice number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _paymentPlanFields() => [
  ..._energyBillFields(),
  _field(
    'urgencyReason',
    'Reason for payment plan',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _wrongChargeFields() => [
  ..._energyBillFields(),
  _field(
    'wrongChargeDescription',
    'Wrong charge description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _contractChangeComplaintFields() => [
  ..._energyBillFields(),
  _field(
    'changeNoticeDate',
    'Change notice date',
    ProcedureFieldType.date,
    required: false,
    section: 'Case',
  ),
  _field(
    'issueDescription',
    'Issue description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _canoneFields() => [
  _field(
    'billHolderName',
    'Bill holder name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'codiceFiscale',
    'Codice fiscale',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'hasTV',
    'Has TV',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
  _field(
    'householdMemberAlreadyPaying',
    'Another household member already paying',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
  _field(
    'yearOfExemption',
    'Year or period',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'billProvider',
    'Bill provider',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _canoneRefundFields() => [
  ..._canoneFields(),
  _field(
    'chargeAlreadyPaid',
    'Charge already paid',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
  _field(
    'wantsRefund',
    'Wants refund',
    ProcedureFieldType.boolean,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _telecomCancellationFields() => [
  _field('provider', 'Provider', ProcedureFieldType.text, section: 'Recipient'),
  _field(
    'contractHolder',
    'Contract holder',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'customerCode',
    'Customer code',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'contractNumber',
    'Contract number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'serviceAddress',
    'Service address',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'desiredSolution',
    'Desired solution',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _telecomComplaintFields() => [
  ..._telecomCancellationFields(),
  _field('issueType', 'Issue type', ProcedureFieldType.text, section: 'Case'),
  _field(
    'invoiceNumber',
    'Invoice number',
    ProcedureFieldType.text,
    required: false,
    section: 'Case',
  ),
  _field(
    'amountDisputed',
    'Amount disputed',
    ProcedureFieldType.number,
    required: false,
    section: 'Case',
  ),
  _field(
    'previousContacts',
    'Previous contacts',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _comuneFields() => [
  ..._identityFields(),
  _field(
    'cityOrComune',
    'City or Comune',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('address', 'Address', ProcedureFieldType.text, section: 'Case'),
  _field(
    'requestType',
    'Request type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'issueDescription',
    'Issue description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _anagrafeFields() => [
  ..._identityFields(),
  _field(
    'cityOrComune',
    'City or Comune',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'certificateType',
    'Certificate type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'useReason',
    'Use reason',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _naspiFields() => [
  ..._identityFields(),
  _field(
    'contractType',
    'Contract type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field('employer', 'Employer', ProcedureFieldType.text, section: 'Case'),
  _field(
    'contractEndDate',
    'Contract end date',
    ProcedureFieldType.date,
    section: 'Case',
  ),
  _field(
    'terminationReason',
    'Termination reason',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _universityFields() => [
  _field(
    'universityName',
    'University name',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'officeName',
    'Office name',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'studentName',
    'Student name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'studentId',
    'Student ID',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field('topic', 'Topic', ProcedureFieldType.text, section: 'Case'),
  _field(
    'situation',
    'Situation',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field('request', 'Request', ProcedureFieldType.textarea, section: 'Case'),
];

List<ProcedureField> _permessoFields() => [
  ..._identityFields(),
  _field(
    'permessoType',
    'Permesso type',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field('expiryDate', 'Expiry date', ProcedureFieldType.date, section: 'Case'),
  _field(
    'officeOrRecipient',
    'Office or recipient',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'missingDocument',
    'Missing document',
    ProcedureFieldType.textarea,
    required: false,
    section: 'Case',
  ),
];

List<ProcedureField> _refundFields() => [
  ..._identityFields(),
  _field(
    'companyOrOffice',
    'Company or office',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field(
    'serviceOrProduct',
    'Service or product',
    ProcedureFieldType.text,
    section: 'Case',
  ),
  _field(
    'problemDescription',
    'Problem description',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field(
    'desiredSolution',
    'Desired solution',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
];

List<ProcedureField> _genericFields() => [
  _field(
    'senderName',
    'Sender name',
    ProcedureFieldType.text,
    section: 'Personal',
  ),
  _field(
    'recipientNameOrOffice',
    'Recipient',
    ProcedureFieldType.text,
    section: 'Recipient',
  ),
  _field('topic', 'Topic', ProcedureFieldType.text, section: 'Case'),
  _field(
    'situation',
    'Situation',
    ProcedureFieldType.textarea,
    section: 'Case',
  ),
  _field('request', 'Request', ProcedureFieldType.textarea, section: 'Case'),
];

List<AttachmentSuggestion> _healthAttachments() => [
  _attachment(
    'id_doc',
    'Documento d’identità',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment(
    'cf_doc',
    'Codice fiscale / tessera sanitaria',
    AttachmentCategory.health,
    required: true,
  ),
];

List<AttachmentSuggestion> _tesseraAttachments() => [
  _attachment(
    'id_doc',
    'Documento d’identità',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment('health_card', 'Tessera sanitaria', AttachmentCategory.health),
];

List<AttachmentSuggestion> _rejectedAttachments() => [
  _attachment(
    'notice',
    'Notice or rejection letter',
    AttachmentCategory.administrative,
    required: true,
  ),
  _attachment(
    'supporting_doc',
    'Supporting document',
    AttachmentCategory.administrative,
    required: true,
  ),
];

List<AttachmentSuggestion> _rentalAttachments() => [
  _attachment(
    'lease_copy',
    'Lease copy',
    AttachmentCategory.housing,
    required: true,
  ),
  _attachment(
    'id_docs',
    'ID documents',
    AttachmentCategory.identity,
    required: true,
  ),
];

List<AttachmentSuggestion> _landlordAttachments() => [
  _attachment(
    'photos',
    'Photos or evidence',
    AttachmentCategory.evidence,
    required: true,
  ),
  _attachment('lease_copy', 'Lease copy', AttachmentCategory.housing),
];

List<AttachmentSuggestion> _depositAttachments() => [
  _attachment(
    'lease_copy',
    'Lease copy',
    AttachmentCategory.housing,
    required: true,
  ),
  _attachment('moveout_proof', 'Move-out proof', AttachmentCategory.evidence),
];

List<AttachmentSuggestion> _billAttachments() => [
  _attachment(
    'bill_copy',
    'Bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment(
    'screenshots',
    'Screenshots or prior communication',
    AttachmentCategory.evidence,
  ),
];

List<AttachmentSuggestion> _utilityAttachments() => [
  _attachment(
    'contract_copy',
    'Contract or bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
];

List<AttachmentSuggestion> _canoneAttachments() => [
  _attachment(
    'bill_copy',
    'Electricity bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment(
    'support_docs',
    'Any supporting declaration or prior payment proof',
    AttachmentCategory.administrative,
  ),
];

List<AttachmentSuggestion> _telecomAttachments() => [
  _attachment(
    'invoice_copy',
    'Invoice or bill copy',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment(
    'contact_proof',
    'Previous contact proof',
    AttachmentCategory.evidence,
  ),
];

List<AttachmentSuggestion> _comuneAttachments() => [
  _attachment(
    'id_doc',
    'Identity document',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment(
    'support_docs',
    'Supporting documents',
    AttachmentCategory.administrative,
  ),
];

List<AttachmentSuggestion> _naspiAttachments() => [
  _attachment(
    'termination_docs',
    'Termination documents',
    AttachmentCategory.employment,
    required: true,
  ),
  _attachment('payslips', 'Recent payslips', AttachmentCategory.employment),
];

List<AttachmentSuggestion> _universityAttachments() => [
  _attachment(
    'student_id',
    'Student ID or card',
    AttachmentCategory.academic,
    required: true,
  ),
  _attachment(
    'support_docs',
    'Supporting documents',
    AttachmentCategory.academic,
  ),
];

List<AttachmentSuggestion> _permessoAttachments() => [
  _attachment(
    'passport',
    'Passport copy',
    AttachmentCategory.identity,
    required: true,
  ),
  _attachment(
    'permesso_copy',
    'Current permit copy',
    AttachmentCategory.administrative,
    required: true,
  ),
];

List<AttachmentSuggestion> _refundAttachments() => [
  _attachment(
    'receipt',
    'Receipt or invoice',
    AttachmentCategory.financial,
    required: true,
  ),
  _attachment('evidence', 'Supporting evidence', AttachmentCategory.evidence),
];

List<AttachmentSuggestion> _genericAttachments() => [
  _attachment(
    'supporting_docs',
    'Supporting documents',
    AttachmentCategory.other,
  ),
];
