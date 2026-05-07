import '../domain/admin_procedure.dart';
import '../domain/service_intelligence.dart';
import 'procedure_definitions.dart';

class ServiceIntelligenceDefinitions {
  static List<ServiceIntelligence> all() =>
      ItalyAdminProcedureDefinitions.all().map(forProcedure).toList();

  static ServiceIntelligence forProcedure(AdminProcedure procedure) {
    switch (procedure.id) {
      case 'TESSERA_SANITARIA_RENEWAL':
        return _health(
          procedure,
          destinationGuidance:
              'This request is usually handled by your local ASL or the regional health authority. The correct email, PEC, portal, or desk depends on your region and city.',
          officialLinks: const ['agenzia_entrate', 'generic_comune_search'],
          onlineOptions: [
            _portal(
              'regional_health_portal',
              'Regional health portal',
              'This request may be available through regional health portals such as Salute Piemonte, Fascicolo Sanitario, or ASL online services depending on region.',
              requiresSpid: true,
              requiresCie: true,
            ),
          ],
          requiredDocuments: _docs(
            required: [
              'ID or passport',
              'Codice fiscale',
              'Tessera sanitaria if available',
            ],
            recommended: [
              'Any previous ASL receipt',
              'Residence or domicile details',
            ],
            conditional: [
              'Permesso or stay documentation if requested locally',
            ],
          ),
          warnings: const [
            'Verify the exact ASL office, email, PEC, or portal before sending personal data.',
          ],
        );
      case 'CHANGE_DOCTOR':
      case 'ASL_REJECTED_REQUEST_REPLY':
      case 'ASL_APPOINTMENT_REQUEST':
        return _health(
          procedure,
          destinationGuidance:
              'This is usually handled by the ASL, distretto sanitario, or regional health service for your area.',
          officialLinks: const ['generic_comune_search'],
          onlineOptions: [
            _portal(
              'regional_health_services',
              'Regional health service portal',
              'Some regions allow online requests or appointment handling through regional portals.',
              requiresSpid: true,
              requiresCie: true,
            ),
          ],
          requiredDocuments: _docs(
            required: ['ID', 'Codice fiscale', 'Health card if available'],
            recommended: [
              'Previous correspondence',
              'Protocol or rejection notice if relevant',
            ],
            conditional: ['Work/study documents if the office requested them'],
          ),
          warnings: const ['Exact handling varies by region and city.'],
        );
      case 'RENTAL_CONTRACT_CHANGE':
      case 'REGISTER_OR_CHECK_RENTAL_CONTRACT':
      case 'ADD_OR_REMOVE_TENANT':
      case 'LANDLORD_MAINTENANCE_OR_CONTRACT':
      case 'DEPOSIT_RETURN_REQUEST':
      case 'RENT_CONTRACT_TERMINATION_NOTICE':
      case 'RENT_PAYMENT_DELAY_PAYMENT_PLAN':
      case 'WRONG_EXPENSES_SPESE_CONDOMINIALI':
      case 'UNREGISTERED_IRREGULAR_RENTAL_CONTRACT':
      case 'EVICTION_SFRATTO_SUPPORT':
      case 'EMERGENCY_HOUSING_COMUNE_SUPPORT':
      case 'STUDENT_RENT_HELP':
      case 'FORMAL_COMPLAINT_TO_LANDLORD':
      case 'TENANT_UNION_APPOINTMENT':
        return _housing(procedure);
      case 'ENERGY_BILL_ANALYZER_CHECKLIST':
      case 'ENERGY_SUPPLIER_COMPARISON':
      case 'ELECTRICITY_GAS_SWITCH_REQUEST':
      case 'VOLTURA_REQUEST':
      case 'SUBENTRO_REQUEST':
      case 'UTILITY_CANCELLATION_DISDETTA':
      case 'HIGH_BILL_COMPLAINT':
      case 'METER_READING_CORRECTION':
      case 'PAYMENT_PLAN_REQUEST':
      case 'WRONG_CHARGE_REFUND_REQUEST':
      case 'UNILATERAL_CONTRACT_CHANGE_COMPLAINT':
      case 'CHECK_SUPPLIER_VS_DISTRIBUTOR':
      case 'NEW_ACTIVATION_PRIMA_ATTIVAZIONE':
      case 'CONTRACT_NOT_REQUESTED_SCAM_ACTIVATION':
      case 'GAS_OR_ELECTRICITY_EMERGENCY_FAULT':
      case 'ARERA_COMPLAINT_AND_CONCILIATION':
        return _utility(procedure);
      case 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST':
      case 'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST':
      case 'CANONE_RAI_REFUND_OR_WRONG_CHARGE':
      case 'UNDERSTAND_IF_MUST_PAY_CANONE_RAI':
      case 'DIPLOMATIC_MILITARY_EXEMPTION':
      case 'WRONG_ELECTRICITY_BILL_CHARGE':
      case 'NEW_HOME_CHANGED_ELECTRICITY_CONTRACT':
      case 'HELP_FILLING_AGENZIA_ENTRATE_FORM':
        return _canoneRai(procedure);
      case 'INTERNET_PHONE_CANCELLATION':
      case 'TELECOM_WRONG_BILL_COMPLAINT':
      case 'SERVICE_NOT_WORKING_COMPLAINT':
      case 'MODEM_RETURN_OR_CHARGE_DISPUTE':
      case 'UNDERSTAND_TELECOM_PROBLEM':
      case 'MOBILE_SIM_CANCELLATION':
      case 'PROVIDER_SWITCHING_NUMBER_PORTABILITY':
      case 'INTERNET_SPEED_TOO_LOW':
      case 'ACTIVATION_DELAY_NO_LINE':
      case 'CONTRACT_NOT_REQUESTED_PHONE_SCAM':
      case 'REFUND_OR_COMPENSATION_REQUEST':
      case 'PAYMENT_PLAN_UNPAID_BILLS':
      case 'ROAMING_INTERNATIONAL_CHARGE_DISPUTE':
      case 'PEC_FORMAL_COMPLAINT_OPERATOR':
      case 'AGCOM_CORECOM_CONCILIAWEB_ESCALATION':
        return _telecom(procedure);
      case 'COMUNE_RESIDENCE_REQUEST':
      case 'UNDERSTAND_RESIDENZA_DOMICILIO_TEMPORARY':
      case 'CHANGE_RESIDENCE_FROM_ANOTHER_COMUNE_OR_ABROAD':
      case 'CHANGE_ADDRESS_INSIDE_TORINO':
      case 'TEMPORARY_RESIDENCE_POPOLAZIONE_TEMPORANEA':
      case 'DOORBELL_MAILBOX_ADDRESS_PROOF':
      case 'REJECTED_RESIDENZA_REQUEST_REPLY':
      case 'ANAGRAFE_CERTIFICATE_REQUEST':
      case 'FAMILY_STATUS_CERTIFICATE':
      case 'RESIDENCE_CERTIFICATE':
      case 'SELF_CERTIFICATION_AUTOCERTIFICAZIONE':
      case 'BOOK_ANAGRAFE_APPOINTMENT':
      case 'PEC_FORMAL_REQUEST_COMUNE':
      case 'ONLINE_COMUNE_SERVICE_PROBLEM':
      case 'GENERAL_COMUNE_INFORMATION_REQUEST':
        return _publicOffice(procedure);
      case 'UNDERSTAND_JOB_LOSS_BENEFIT_SITUATION':
      case 'NASPI_PREPARATION':
      case 'NASPI_APPLICATION_FOLLOWUP':
      case 'DID_AND_CENTRO_IMPIEGO':
      case 'PATRONATO_APPOINTMENT_REQUEST':
      case 'INPS_APPOINTMENT_CONTACT_REQUEST':
      case 'REPLY_REJECTED_INPS_REQUEST':
      case 'MISSING_DOCUMENTS_INTEGRATION':
      case 'EMPLOYER_TERMINATION_CONTRACT_END_DOCUMENTS':
      case 'PAYSLIP_TFR_FINAL_PAYMENT_PROBLEM':
      case 'SICK_LEAVE_MALATTIA_INPS_BASICS':
      case 'MATERNITY_FAMILY_BENEFIT_HELP':
      case 'ISEE_CAF_CONNECTION':
      case 'UNION_LEGAL_WORK_DISPUTE_SUPPORT':
      case 'GENERAL_INPS_FORMAL_REQUEST_PEC':
        return _work(procedure);
      case 'UNIVERSITY_OFFICE_REQUEST':
      case 'PERMESSO_DOCUMENT_CHECKLIST':
      case 'UNDERSTAND_STUDENT_ADMINISTRATIVE_PROBLEM':
      case 'EDISU_SCHOLARSHIP_APPLICATION':
      case 'EDISU_REJECTED_MISSING_DOCUMENTS':
      case 'STUDENT_HOUSING_EDISU_RESIDENCE':
      case 'ISEE_ISEE_PARIFICATO_STUDENTS':
      case 'TUITION_FEES_FEE_REDUCTION_DOCUMENTS':
      case 'PERMESSO_FIRST_REQUEST':
      case 'PERMESSO_RENEWAL':
      case 'PERMESSO_QUESTURA_FOLLOWUP':
      case 'STUDENT_HEALTHCARE_TESSERA_DOCTOR':
      case 'RESIDENZA_DOMICILE_STUDENTS':
      case 'RENTAL_CONTRACT_PROOF_STUDENTS':
      case 'UNIVERSITY_CERTIFICATE_REQUEST':
      case 'FORMAL_EMAIL_UNIVERSITY_EDISU_OFFICE':
        return _university(procedure);
      case 'REJECTED_REQUEST_REPLY':
      case 'REFUND_OR_COMPLAINT_REQUEST':
      case 'APPOINTMENT_REQUEST':
      case 'GENERIC_FORMAL_REQUEST':
      case 'UNDERSTAND_WHICH_OFFICE_TO_CONTACT':
      case 'MISSING_DOCUMENTS_INTEGRATION_GENERAL':
      case 'REFUND_REQUEST':
      case 'COMPLAINT_REQUEST':
      case 'FOLLOWUP_UNANSWERED_REQUEST':
      case 'STATUS_UPDATE_WITH_PROTOCOL':
      case 'ASK_DOCUMENT_CLARIFICATION':
      case 'SEND_PEC_WITH_ATTACHMENTS':
      case 'WRITE_SHORT_POLITE_EMAIL':
      case 'WRITE_STRONG_FORMAL_COMPLAINT':
      case 'PREPARE_DOCUMENTS_BEFORE_OFFICE':
      case 'CONVERT_INFORMAL_TO_FORMAL_ITALIAN':
      default:
        return _general(procedure);
    }
  }

  static ServiceIntelligence _health(
    AdminProcedure procedure, {
    required String destinationGuidance,
    required List<String> officialLinks,
    required List<OnlineOption> onlineOptions,
    required _DocumentSets requiredDocuments,
    required List<String> warnings,
  }) {
    return _base(
      procedure,
      responsibleAuthorityType: 'ASL / regional health authority',
      destinationGuidance: destinationGuidance,
      officialLinks: officialLinks,
      onlineOptions: onlineOptions,
      inPersonOptions: [
        const InPersonOption(
          id: 'asl_counter',
          title: 'ASL / district office in person',
          description:
              'If you prefer to go in person, check the official ASL or district office for your address.',
          officeFinderLink: '',
          documentsToBring: [
            'ID',
            'Codice fiscale',
            'Tessera sanitaria if available',
            'Previous receipt or protocol if available',
          ],
          verificationStatus: ServiceVerificationStatus.needsReview,
          warning:
              'Verify the exact office, booking rules, and opening hours on the official regional or ASL website.',
        ),
      ],
      pecRequiredLevel: PecRequiredLevel.recommended,
      spidCieRequiredLevel: SpidCieRequiredLevel.oftenRequiredOnline,
      requiredDocuments: requiredDocuments.required,
      recommendedDocuments: requiredDocuments.recommended,
      conditionalDocuments: requiredDocuments.conditional,
      citySpecificNotes: const [
        'If your city or region has a dedicated health portal, use that official portal or office-finder first.',
      ],
      warnings: warnings,
      followUpGuidance:
          'If there is no answer after several working days, use the follow-up message and include any protocol or previous request reference.',
      rejectionGuidance:
          'If the office rejects the request for missing documents, open the rejected request reply flow and attach the missing items.',
    );
  }

  static ServiceIntelligence _housing(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'Landlord / agency / Agenzia Entrate',
    destinationGuidance:
        'This usually goes first to the landlord or agency. Some rental contract changes may also require official tax-registration steps through Agenzia Entrate.',
    officialLinks: const ['agenzia_entrate'],
    onlineOptions: const [
      OnlineOption(
        id: 'agenzia_entrate_rentals',
        title: 'Agenzia Entrate information pages',
        description:
            'Check official registration guidance if the contract change requires fiscal/registration follow-up.',
        url: 'https://www.agenziaentrate.gov.it/',
        requiresSpid: false,
        requiresCie: false,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.verified,
        warning: 'Verify the exact page for your contract scenario.',
      ),
    ],
    inPersonOptions: const [
      InPersonOption(
        id: 'landlord_agency',
        title: 'Meeting with landlord or agency',
        description:
            'For contract updates, handover, or deposit issues, an in-person meeting may be useful after formal written notice.',
        documentsToBring: [
          'Rental contract',
          'ID',
          'Previous emails/messages',
          'Photos or proof if the issue is about damage or maintenance',
        ],
        verificationStatus: ServiceVerificationStatus.unverified,
        warning: 'Do not rely only on verbal agreements for important changes.',
      ),
    ],
    pecRequiredLevel: PecRequiredLevel.recommended,
    spidCieRequiredLevel: SpidCieRequiredLevel.useful,
    requiredDocuments: const ['Rental contract', 'ID'],
    recommendedDocuments: const [
      'Previous communications',
      'Proof of payment or deposit where relevant',
    ],
    conditionalDocuments: const [
      'Photos, invoices, witness note, or handover evidence depending on the issue',
    ],
    providerSpecificNotes: const [
      'If an agency manages the property, verify whether communications should go first to the agency instead of the owner.',
    ],
    warnings: const [
      'Contract registration and legal effects depend on the actual contract and official rules.',
    ],
    followUpGuidance:
        'If no answer arrives, send a polite follow-up and keep proof of sending.',
    rejectionGuidance:
        'If the landlord or agency refuses, keep all written proof and prepare a stronger follow-up or complaint pack.',
  );

  static ServiceIntelligence _utility(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'Utility supplier / distributor / ARERA',
    destinationGuidance:
        'Commercial and billing issues usually go first to the supplier shown on the bill. Technical faults, gas smell, dangerous meters, or emergency network issues go to the distributor/pronto intervento number printed on the bill. ARERA and conciliation are escalation paths after the supplier complaint step.',
    officialLinks: const ['arera_portale_offerte'],
    onlineOptions: const [
      OnlineOption(
        id: 'provider_customer_area',
        title: 'Provider customer area or official website',
        description:
            'Utility requests often depend on the provider customer area, contract section, or complaint form.',
        requiresSpid: false,
        requiresCie: false,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.needsReview,
        warning:
            'Verify the exact provider channel in your bill, contract, or official website.',
      ),
    ],
    inPersonOptions: const [
      InPersonOption(
        id: 'utility_shop',
        title: 'Provider desk or authorized point',
        description:
            'Some providers or authorized desks may accept in-person support for contract changes or documentation review.',
        documentsToBring: [
          'ID',
          'Codice fiscale',
          'Recent bill',
          'Meter information or reading if relevant',
        ],
        verificationStatus: ServiceVerificationStatus.unverified,
        warning: 'Verify whether the desk is official and what it can handle.',
      ),
    ],
    pecRequiredLevel: PecRequiredLevel.recommended,
    spidCieRequiredLevel: SpidCieRequiredLevel.notNeeded,
    requiredDocuments: const ['Recent bill or contract reference'],
    recommendedDocuments: const [
      'Previous bill',
      'Screenshots of customer area or messages',
      'Payment proof if relevant',
    ],
    conditionalDocuments: const [
      'Meter photo, activation data, switch terms, or payment-plan evidence depending on the case',
    ],
    providerSpecificNotes: const [
      'Do not assume one supplier or distributor in Torino. Read both names from the bill before sending requests.',
      'Do not assume one provider channel works for every request. Switch, complaint, refund, and cancellation paths can differ.',
    ],
    warnings: const [
      'This app does not identify the guaranteed cheapest provider.',
      'Supplier handles billing, contracts, refunds, and payment plans. Distributor handles technical faults and emergencies.',
      'Check the official provider site, contract, and Portale Offerte before switching or complaining.',
    ],
    followUpGuidance:
        'If the provider does not answer, send a follow-up and keep screenshots, protocol numbers, and proof of sending.',
    rejectionGuidance:
        'If the provider rejects the request, prepare a stronger complaint or correction request with all supporting proof.',
  );

  static ServiceIntelligence _canoneRai(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'Agenzia Entrate / bill-line clarification only',
    destinationGuidance:
        'Canone RAI declarations, exemptions, refunds, and form choices are handled through Agenzia Entrate official channels or an intermediary. The electricity supplier can help explain the bill line, but it cannot decide exemption or refund eligibility.',
    officialLinks: const ['agenzia_entrate'],
    onlineOptions: const [
      OnlineOption(
        id: 'agenzia_entrate_portal',
        title: 'Agenzia Entrate official instructions',
        description:
            'Check official instructions, declaration channels, and truthful filing requirements before submitting.',
        url: 'https://www.agenziaentrate.gov.it/',
        requiresSpid: true,
        requiresCie: true,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.verified,
        warning: 'Verify the exact official path before sending personal data.',
      ),
    ],
    inPersonOptions: const [],
    pecRequiredLevel: PecRequiredLevel.unknown,
    spidCieRequiredLevel: SpidCieRequiredLevel.oftenRequiredOnline,
    requiredDocuments: const ['Bill holder data', 'Codice fiscale'],
    recommendedDocuments: const [
      'Electricity bill showing the charge',
      'Previous declaration/refund proof if available',
    ],
    conditionalDocuments: const [
      'Eligibility evidence depends on the official case and year involved',
    ],
    warnings: const [
      'Submit only truthful declarations.',
      'Do not assume eligibility without checking official instructions.',
      'Use the supplier only for bill-line clarification, not to decide exemption or refund eligibility.',
    ],
    followUpGuidance:
        'If there is no answer, use a follow-up referencing the year, bill period, and any previous submission details.',
    rejectionGuidance:
        'If rejected, review the official reason and prepare a correction or clarification request instead of repeating an unsupported declaration.',
  );

  static ServiceIntelligence _telecom(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'Telecom operator / ConciliaWeb escalation',
    destinationGuidance:
        'Use the operator first for cancellation, complaints, tickets, refunds, and service issues. If the operator does not answer or gives an unsatisfactory response after a written complaint, prepare escalation through ConciliaWeb/Corecom guidance.',
    officialLinks: const [],
    onlineOptions: const [
      OnlineOption(
        id: 'provider_support_area',
        title: 'Provider support / customer area',
        description:
            'Telecom complaints and cancellations are usually handled through official support channels and contract-specific forms.',
        requiresSpid: false,
        requiresCie: false,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.needsReview,
        warning:
            'Check your contract, bill, or official provider site for the correct channel.',
      ),
    ],
    inPersonOptions: const [],
    pecRequiredLevel: PecRequiredLevel.recommended,
    spidCieRequiredLevel: SpidCieRequiredLevel.notNeeded,
    requiredDocuments: const ['Contract number or customer code'],
    recommendedDocuments: const [
      'Invoice disputed',
      'Cancellation proof',
      'Provider replies or screenshots',
    ],
    conditionalDocuments: const [
      'Modem return receipt, portability reference, or payment proof when relevant',
    ],
    providerSpecificNotes: const [
      'Customer support, complaints, and cancellation channels may differ.',
      'Do not guess operator PEC addresses. Use the official operator website, contract, bill, or customer area.',
    ],
    warnings: const [
      'Verify the provider’s official complaint or cancellation path before sending.',
      'Written operator complaint usually comes before ConciliaWeb escalation.',
    ],
    followUpGuidance:
        'If there is no answer, send a follow-up and keep contract, invoice, cancellation, and modem return proof together.',
    rejectionGuidance:
        'If the provider rejects the request, prepare a stronger complaint pack with all proof items.',
  );

  static ServiceIntelligence _publicOffice(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'Comune / Anagrafe',
    destinationGuidance:
        'Use the specific Comune or ANPR path that matches the case: residence change, address update, temporary residence, certificates, appointment, or formal PEC. For Italian public offices, autocertificazione may be enough before you request a paid certificate.',
    officialLinks: const ['generic_comune_search'],
    onlineOptions: const [
      OnlineOption(
        id: 'comune_portal',
        title: 'Comune portal or appointment page',
        description:
            'Some Comuni allow appointments, certificate requests, or status checks online.',
        requiresSpid: true,
        requiresCie: true,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.needsReview,
        warning: 'Verify the exact city page and access requirements.',
      ),
    ],
    inPersonOptions: const [
      InPersonOption(
        id: 'anagrafe_desk',
        title: 'Comune / Anagrafe desk in person',
        description:
            'For many residence and certificate issues, in-person support may be available depending on the Comune.',
        documentsToBring: [
          'ID',
          'Codice fiscale',
          'Residence proof if relevant',
        ],
        verificationStatus: ServiceVerificationStatus.needsReview,
        warning:
            'Check appointment rules and office finder on the official Comune website.',
      ),
    ],
    pecRequiredLevel: PecRequiredLevel.recommended,
    spidCieRequiredLevel: SpidCieRequiredLevel.oftenRequiredOnline,
    requiredDocuments: const ['ID'],
    recommendedDocuments: const ['Protocol number or previous receipt if any'],
    conditionalDocuments: const [
      'Residence or family documentation depending on the certificate or request',
    ],
    warnings: const [
      'Comune procedures are often city-specific.',
      'Use normal email for information and PEC for formal or protocol-level follow-up when the case requires it.',
    ],
    followUpGuidance:
        'If the office does not answer, reference your protocol number or appointment request in the follow-up.',
    rejectionGuidance:
        'If rejected, verify which document was missing and reply with the correction or additional attachment.',
  );

  static ServiceIntelligence _work(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'Patronato / INPS / employer support context',
    destinationGuidance:
        'Choose the channel that matches the problem: patronato for NASpI and many INPS benefit applications, CAF for ISEE-linked documentation, Centro per l’Impiego for DID or patto di servizio, employer contact for missing end-of-contract documents, and union support for salary, TFR, dismissal, or contract disputes.',
    officialLinks: const [],
    onlineOptions: const [
      OnlineOption(
        id: 'inps_portal',
        title: 'INPS portal',
        description:
            'Some employment or benefit steps may require official portal access depending on the case.',
        url: 'https://www.inps.it/',
        requiresSpid: true,
        requiresCie: true,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.verified,
        warning: 'Verify the exact INPS path or patronato support option.',
      ),
    ],
    inPersonOptions: const [
      InPersonOption(
        id: 'patronato_office',
        title: 'Patronato / CAF appointment',
        description:
            'A patronato or similar office can help review your paperwork in person.',
        documentsToBring: [
          'ID',
          'Codice fiscale',
          'Employment documents relevant to the case',
        ],
        verificationStatus: ServiceVerificationStatus.unverified,
        warning:
            'Verify the specific office, appointment method, and document list first.',
      ),
    ],
    pecRequiredLevel: PecRequiredLevel.recommended,
    spidCieRequiredLevel: SpidCieRequiredLevel.oftenRequiredOnline,
    requiredDocuments: const ['ID', 'Codice fiscale'],
    recommendedDocuments: const [
      'Employer documents or previous communications',
    ],
    conditionalDocuments: const [
      'Termination, payslip, or benefit documents depending on the issue',
    ],
    warnings: const [
      'Eligibility and deadlines must be verified on official channels.',
      'If a patronato submitted the request, contact that patronato first with the protocol or receipt before escalating.',
      'Use written employer or INPS follow-up before assuming the issue is solved informally.',
    ],
    followUpGuidance:
        'If you are waiting for a reply or appointment, keep the request date, protocol, patronato receipt, or employer message together and follow up in writing.',
    rejectionGuidance:
        'If rejected, check whether the issue is document-related or eligibility-related before replying.',
  );

  static ServiceIntelligence _university(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: 'University office',
    destinationGuidance:
        'The correct office depends on the university and the issue: student office, international office, fees office, scholarship office, or department administration.',
    officialLinks: const [],
    onlineOptions: const [
      OnlineOption(
        id: 'university_portal',
        title: 'University portal or student area',
        description:
            'Some student requests are handled through the official portal or ticketing system.',
        requiresSpid: false,
        requiresCie: false,
        requiresPec: false,
        verificationStatus: ServiceVerificationStatus.needsReview,
        warning:
            'Verify the exact office and official portal for your university.',
      ),
    ],
    inPersonOptions: const [
      InPersonOption(
        id: 'student_office',
        title: 'Student office in person',
        description:
            'Some universities handle corrections, document checks, or international support in person.',
        documentsToBring: [
          'ID',
          'Student number if available',
          'Relevant supporting documents',
        ],
        verificationStatus: ServiceVerificationStatus.unverified,
        warning: 'Verify office hours and booking requirements first.',
      ),
    ],
    pecRequiredLevel: PecRequiredLevel.notUsuallyNeeded,
    spidCieRequiredLevel: SpidCieRequiredLevel.useful,
    requiredDocuments: const ['ID or student identification details'],
    recommendedDocuments: const [
      'Enrollment, fee, or scholarship evidence depending on the request',
    ],
    conditionalDocuments: const [
      'Permesso or residence documents if relevant to the student case',
    ],
    warnings: const ['University rules and channels vary by institution.'],
    followUpGuidance:
        'If there is no reply, follow up with the office name, student number, and original message date.',
    rejectionGuidance:
        'If rejected, clarify what document or office path was missing before sending a second request.',
  );

  static ServiceIntelligence _general(AdminProcedure procedure) => _base(
    procedure,
    responsibleAuthorityType: procedure.authorityType,
    destinationGuidance:
        'Use the official office or provider channel that matches your case. If the correct destination depends on city, region, or provider, verify it before sending.',
    officialLinks: const [],
    onlineOptions: const [],
    inPersonOptions: const [],
    pecRequiredLevel: PecRequiredLevel.recommended,
    spidCieRequiredLevel: SpidCieRequiredLevel.unknown,
    requiredDocuments: const ['Basic case details and sender information'],
    recommendedDocuments: const [
      'Any previous communication or supporting proof',
    ],
    conditionalDocuments: const [
      'Situation-specific attachments depending on the office or provider',
    ],
    warnings: const [
      'Verify the correct office/provider before submitting personal data.',
    ],
    followUpGuidance:
        'If there is no answer, use a short follow-up and restate the original request reference.',
    rejectionGuidance:
        'If rejected, ask which information or document is missing and reply with a corrected request.',
  );

  static ServiceIntelligence _base(
    AdminProcedure procedure, {
    required String responsibleAuthorityType,
    required String destinationGuidance,
    required List<String> officialLinks,
    required List<OnlineOption> onlineOptions,
    required List<InPersonOption> inPersonOptions,
    required PecRequiredLevel pecRequiredLevel,
    required SpidCieRequiredLevel spidCieRequiredLevel,
    required List<String> requiredDocuments,
    required List<String> recommendedDocuments,
    required List<String> conditionalDocuments,
    required List<String> warnings,
    required String followUpGuidance,
    required String rejectionGuidance,
    List<String> citySpecificNotes = const [],
    List<String> regionSpecificNotes = const [],
    List<String> providerSpecificNotes = const [],
  }) {
    return ServiceIntelligence(
      procedureId: procedure.id,
      title: procedure.title,
      category: procedure.category.label,
      responsibleAuthorityType: responsibleAuthorityType,
      destinationGuidance: destinationGuidance,
      recipientRules: const [
        'Verify the correct office/provider before sending.',
        'Do not assume one city, region, or provider contact works for every case.',
      ],
      officialContactOptions: const [],
      officialLinks: officialLinks,
      inPersonOptions: inPersonOptions,
      onlineOptions: onlineOptions,
      pecRequiredLevel: pecRequiredLevel,
      spidCieRequiredLevel: spidCieRequiredLevel,
      requiredDocumentsDetailed: requiredDocuments
          .map(
            (item) => DocumentRequirementDetailed(
              id: '${procedure.id}_req_$item',
              name: item,
              requiredLevel: DocumentRequiredLevel.required,
              description:
                  'Usually required to identify the sender or support the request.',
              whenNeeded: 'Before sending or at the office if requested.',
              examples: [item],
              canUseCopy: true,
            ),
          )
          .toList(),
      recommendedDocumentsDetailed: recommendedDocuments
          .map(
            (item) => DocumentRequirementDetailed(
              id: '${procedure.id}_rec_$item',
              name: item,
              requiredLevel: DocumentRequiredLevel.recommended,
              description: 'Useful for context and proof.',
              whenNeeded: 'Recommended when available.',
              examples: [item],
              canUseCopy: true,
            ),
          )
          .toList(),
      situationSpecificDocuments: conditionalDocuments
          .map(
            (item) => DocumentRequirementDetailed(
              id: '${procedure.id}_cond_$item',
              name: item,
              requiredLevel: DocumentRequiredLevel.conditional,
              description: 'Needed only for some situations.',
              whenNeeded:
                  'Only if the office/provider asks for it or the case requires it.',
              examples: [item],
              canUseCopy: true,
            ),
          )
          .toList(),
      beforeSendingChecklist: const [
        'Verify the recipient email, PEC, portal, or office on an official source.',
        'Check personal data, protocol numbers, and references.',
        'Attach the relevant documents.',
        'Replace sample details with your real information and review the final text.',
        'Submit only truthful statements.',
        'Save proof of sending.',
      ],
      inPersonChecklist: const [
        'Bring ID and any document listed as required.',
        'Check whether an appointment is required.',
        'Keep a copy or photo of anything you deliver.',
      ],
      followUpGuidance: followUpGuidance,
      rejectionGuidance: rejectionGuidance,
      escalationGuidance:
          'If the issue remains unresolved after follow-up, organize your proof and prepare a stronger complaint or escalation pack.',
      citySpecificNotes: citySpecificNotes,
      regionSpecificNotes: regionSpecificNotes,
      providerSpecificNotes: providerSpecificNotes,
      warnings: warnings,
      verificationStatus: ServiceVerificationStatus.needsReview,
      lastReviewedAt: DateTime(2026, 5, 6),
    );
  }

  static OnlineOption _portal(
    String id,
    String title,
    String description, {
    required bool requiresSpid,
    required bool requiresCie,
  }) {
    return OnlineOption(
      id: id,
      title: title,
      description: description,
      requiresSpid: requiresSpid,
      requiresCie: requiresCie,
      requiresPec: false,
      verificationStatus: ServiceVerificationStatus.needsReview,
      warning:
          'Verify the exact portal, login method, and office competence first.',
    );
  }

  static _DocumentSets _docs({
    required List<String> required,
    required List<String> recommended,
    required List<String> conditional,
  }) => _DocumentSets(
    required: required,
    recommended: recommended,
    conditional: conditional,
  );
}

class _DocumentSets {
  const _DocumentSets({
    required this.required,
    required this.recommended,
    required this.conditional,
  });

  final List<String> required;
  final List<String> recommended;
  final List<String> conditional;
}
