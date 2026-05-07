import '../domain/health_asl_guidance.dart';

const healthAslGetTesseraSanitariaTorino = HealthAslGuidance(
  id: 'get_tessera_sanitaria',
  categoryId: 'health_asl',
  region: 'piemonte',
  city: 'torino',
  asl: 'ASL Città di Torino',
  title: 'Get Tessera Sanitaria / Register with SSN',
  titleIt: 'Ottenere la Tessera Sanitaria / Iscrizione al SSN',
  shortDescription:
      'Understand how to register with the Italian public healthcare system in Torino, receive or use the Tessera Sanitaria, and know whether to go in person, use PEC, send email, or contact Centro ISI.',
  whatIsIt:
      'This page helps users understand how to access the Italian Servizio Sanitario Nazionale in Torino. In most cases, the first step is not simply asking for the plastic Tessera Sanitaria, but registering or updating the user’s position with the SSN/ASL. Once the user is correctly registered, they can choose a family doctor, use public healthcare services, receive prescriptions, book exams, and receive or renew the Tessera Sanitaria.',
  mainUserQuestion:
      'How do I get the Tessera Sanitaria in Torino? Should I go in person, send PEC, send normal email, use an online service, or contact another office?',
  topAnswer: HealthAslTopAnswer(
    title: 'How to get it in Torino',
    body:
        'For most first-time SSN / Tessera Sanitaria procedures in Torino, especially foreign citizens, students, workers, unemployed people, voluntary registration, domiciliation, STP, ENI, or complex cases, the safest method is to go in person to the ASL administrative office of the district where you live or have domicile. PEC is mainly for formal follow-up, rejected requests, missing documents, or complaints. Normal email is mainly for information and URP support.',
    defaultRecommendedChannel: 'in_person_asl_administrative_office',
  ),
  sourceNotes: [
    HealthAslSourceNote(
      label: 'ASL Città di Torino administrative offices',
      note:
          'ASL Torino lists sportelli amministrativi for administrative health procedures and provides general PEC and URP email contacts.',
    ),
    HealthAslSourceNote(
      label: 'Voluntary SSN registration',
      note:
          'ASL Torino says voluntary SSN registration requests must be presented at the ASL Città di Torino administrative offices for choice/revocation.',
    ),
    HealthAslSourceNote(
      label: 'Centro ISI',
      note:
          'ASL Torino lists Centro ISI at Via Bazzi 19, corner with Lungo Dora Savona 24, with phone 011.240.3625 and email centro.isi@aslcittaditorino.it.',
    ),
  ],
  contacts: {
    'aslTorinoGeneral': HealthAslContact(
      name: 'ASL Città di Torino',
      address: 'Via San Secondo 29, 10128 Torino',
      pec: 'protocollo@pec.aslcittaditorino.it',
      email: 'urp@aslcittaditorino.it',
      phones: ['011.5661566', '011.4393111', '011.7095.1', '240.1111'],
      cupRegionale: '800 000 500',
      useFor: [
        'general information',
        'URP support',
        'formal follow-up',
        'rejected requests',
        'complaints',
        'asking which office is competent',
      ],
    ),
    'centroIsi': HealthAslContact(
      name: 'Centro ISI ASL Città di Torino',
      fullName: 'Centro ISI - Informazione Salute Immigrati',
      address: 'Via Bazzi 19, angolo Lungo Dora Savona 24, Torino',
      phone: '011.240.3625',
      email: 'centro.isi@aslcittaditorino.it',
      openingHours: 'Monday to Friday, 08:30-12:00 and 13:00-15:00',
      accessMode:
          'direct counter / telephone; ambulatory services may require booking',
      useFor: [
        'foreign citizens needing health access support',
        'STP guidance',
        'people without valid permesso di soggiorno',
        'vulnerable users without normal SSN coverage',
        'immigrant health information',
      ],
    ),
    'edisuStudentSupport': HealthAslContact(
      name: 'EDISU Piemonte healthcare support',
      email: 'info.healthcare@edisu-piemonte.it',
      phone: '+39 334 1006710',
      useFor: [
        'student healthcare information',
        'students who do not know their competent ASL',
        'students who need help understanding doctor lists or healthcare access',
      ],
      warning:
          'EDISU is useful for guidance, but it is not the final ASL registration office.',
    ),
  },
  channelRules: [
    HealthAslChannelRule(
      id: 'in_person_asl_administrative_office',
      label: 'Go in person to ASL administrative office',
      labelIt: 'Vai di persona allo sportello amministrativo ASL',
      priority: 'primary',
      useWhen: [
        'first SSN registration',
        'voluntary SSN registration',
        'non-EU student registration',
        'non-EU worker registration',
        'EU or non-EU domiciliation in Torino',
        'choosing doctor as non-resident',
        'STP or ENI evaluation',
        'documents must be checked',
        'complex eligibility case',
        'user does not know which online flow applies',
      ],
      userFacingText:
          'For this case, the safest channel in Torino is to go in person to the ASL administrative office of your district with all documents.',
    ),
    HealthAslChannelRule(
      id: 'pec',
      label: 'Send PEC',
      labelIt: 'Invia PEC',
      priority: 'formal_follow_up',
      address: 'protocollo@pec.aslcittaditorino.it',
      useWhen: [
        'formal follow-up',
        'request already rejected',
        'sending missing documents after rejection',
        'asking for official reconsideration',
        'complaint with attachments',
        'user has protocol number or receipt',
      ],
      userFacingText:
          'Use PEC mainly for formal follow-up, rejected requests, missing documents, or complaints. Do not rely only on PEC for first SSN registration unless ASL specifically accepts it for your exact case.',
    ),
    HealthAslChannelRule(
      id: 'normal_email',
      label: 'Send normal email',
      labelIt: 'Invia email normale',
      priority: 'information',
      address: 'urp@aslcittaditorino.it',
      useWhen: [
        'asking for information',
        'asking which office is competent',
        'asking what documents are missing',
        'URP clarification',
        'accessibility or appointment support',
        'user is confused and needs direction',
      ],
      userFacingText:
          'Use normal email for information and URP support. For formal/protocol communication, PEC is stronger.',
    ),
    HealthAslChannelRule(
      id: 'online',
      label: 'Use online service',
      labelIt: 'Usa il servizio online',
      priority: 'specific_cases_only',
      useWhen: [
        'change or revoke family doctor with SPID',
        'some Salute Piemonte services',
        'CUP bookings',
        'some national duplicate Tessera Sanitaria procedures',
      ],
      warning:
          'Do not use online as the default answer for first SSN registration, foreign registration, voluntary registration, STP, ENI, or complex cases.',
    ),
    HealthAslChannelRule(
      id: 'centro_isi',
      label: 'Contact Centro ISI',
      labelIt: 'Contatta il Centro ISI',
      priority: 'foreign_vulnerable_users',
      useWhen: [
        'person without valid permesso di soggiorno',
        'STP case',
        'vulnerable foreign citizen',
        'immigrant health access question',
        'EU citizen without usable coverage and vulnerable condition',
      ],
      userFacingText:
          'If you cannot access normal SSN registration or you need STP/immigrant health support, contact or go to Centro ISI.',
    ),
    HealthAslChannelRule(
      id: 'edisu',
      label: 'Contact EDISU healthcare support',
      labelIt: 'Contatta supporto sanitario EDISU',
      priority: 'student_guidance',
      useWhen: [
        'student does not know competent ASL',
        'international student needs healthcare guidance',
        'EU student needs guidance on TEAM usage',
        'non-EU student needs guidance before ASL visit',
      ],
      userFacingText:
          'Use EDISU for student guidance. For actual SSN registration, the final step is normally with ASL.',
    ),
  ],
  aslAdministrativeOffices: HealthAslAdministrativeOffices(
    generalOpeningHours:
        'Usually Monday to Friday, 08:00-14:00. Queue numbers usually stop at 13:30. Some offices may have different hours, so the app should show a warning to verify before going.',
    verifyBeforeGoing: true,
    offices: [
      HealthAslOffice(
        id: 'via_juvarra_19',
        district: 'Sud Est',
        circoscrizione: '1',
        areas: ['Centro', 'Crocetta'],
        address: 'Via Juvarra 19, Torino',
        notes:
            'Presidio Oftalmico. ASL page lists Monday to Friday 08:00-15:00, queue numbers until 14:00 for this specific office.',
      ),
      HealthAslOffice(
        id: 'corso_corsica_55',
        district: 'Sud Est',
        circoscrizione: '8',
        areas: [
          'San Salvario',
          'Cavoretto',
          'Borgo Po',
          'Nizza Millefonti',
          'Lingotto',
          'Filadelfia',
        ],
        address: 'Corso Corsica 55, Torino',
      ),
      HealthAslOffice(
        id: 'via_farinelli_25',
        district: 'Sud-Ovest',
        circoscrizione: '2',
        areas: ['Santa Rita', 'Mirafiori Nord', 'Mirafiori Sud'],
        address: 'Via Farinelli 25, Torino',
      ),
      HealthAslOffice(
        id: 'via_gorizia_114',
        district: 'Sud-Ovest',
        circoscrizione: '2',
        areas: ['Santa Rita', 'Mirafiori Nord', 'Mirafiori Sud'],
        address: 'Via Gorizia 114, Torino',
      ),
      HealthAslOffice(
        id: 'via_monginevro_130',
        district: 'Sud-Ovest',
        circoscrizione: '3',
        areas: [
          'Borgo San Paolo',
          'Cenisia',
          'Pozzo Strada',
          'Cit Turin',
          'Borgata Lesna',
        ],
        address: 'Via Monginevro 130, Torino',
      ),
      HealthAslOffice(
        id: 'via_pacchiotti_4',
        district: 'Nord-Ovest',
        circoscrizione: '4',
        areas: ['San Donato', 'Campidoglio', 'Parella'],
        address: 'Via Pacchiotti 4, Torino',
      ),
      HealthAslOffice(
        id: 'via_luzzatti_50',
        district: 'Nord-Ovest',
        circoscrizione: '5',
        areas: [
          'Borgo Vittoria',
          'Madonna di Campagna',
          'Barriera di Lanzo',
          'Lucento',
          'Vallette',
        ],
        address: 'Via Luzzatti 50, Torino',
        notes: 'Casa di Comunità Marco Antonetto.',
      ),
      HealthAslOffice(
        id: 'via_cigna_74',
        district: 'Nord-Ovest',
        circoscrizione: '5',
        areas: [
          'Borgo Vittoria',
          'Madonna di Campagna',
          'Barriera di Lanzo',
          'Lucento',
          'Vallette',
        ],
        address: 'Via Cigna 74, Torino',
        notes: 'Casa di Comunità.',
      ),
      HealthAslOffice(
        id: 'via_montanaro_60',
        district: 'Nord Est',
        circoscrizione: '6',
        areas: [
          'Barriera di Milano',
          'Barca',
          'Bertolla',
          'Falchera',
          'Rebaudengo',
          'Villaretto',
          'Regio Parco',
        ],
        address: 'Via Montanaro 60, Torino',
      ),
      HealthAslOffice(
        id: 'via_cavezzale_6',
        district: 'Nord Est',
        circoscrizione: '7',
        areas: ['Aurora', 'Vanchiglia', 'Borgata Sassi', 'Madonna del Pilone'],
        address: 'Via Cavezzale 6, Torino',
      ),
    ],
  ),
  commonDocuments: [
    HealthAslCommonDocument(
      id: 'identity_document',
      label: 'Identity document',
      labelIt: 'Documento d’identità',
      examples: ['Carta d’identità', 'Passport', 'Permesso card if applicable'],
    ),
    HealthAslCommonDocument(
      id: 'codice_fiscale',
      label: 'Codice fiscale',
      labelIt: 'Codice fiscale',
    ),
    HealthAslCommonDocument(
      id: 'tessera_sanitaria_if_available',
      label: 'Existing Tessera Sanitaria, if available',
      labelIt: 'Tessera Sanitaria precedente, se disponibile',
    ),
    HealthAslCommonDocument(
      id: 'torino_address_proof',
      label: 'Proof of residence or domicile in Torino',
      labelIt: 'Prova di residenza o domicilio a Torino',
      examples: [
        'residenza',
        'rental contract',
        'hospitality declaration',
        'domicile declaration',
      ],
    ),
  ],
  userSituationQuestions: [
    HealthAslSituationQuestion(
      id: 'citizenship_status',
      question: 'Are you Italian, EU, or non-EU?',
      questionIt: 'Sei cittadino italiano, UE o extra-UE?',
      type: 'single_choice',
      options: [
        HealthAslQuestionOption(id: 'italian', label: 'Italian citizen'),
        HealthAslQuestionOption(id: 'eu', label: 'EU citizen'),
        HealthAslQuestionOption(id: 'non_eu', label: 'Non-EU citizen'),
      ],
    ),
    HealthAslSituationQuestion(
      id: 'torino_status',
      question: 'Are you resident in Torino or only domiciled here?',
      questionIt: 'Sei residente a Torino o solo domiciliato qui?',
      type: 'single_choice',
      options: [
        HealthAslQuestionOption(id: 'resident', label: 'Resident in Torino'),
        HealthAslQuestionOption(
          id: 'domiciled',
          label: 'Domiciled in Torino but resident elsewhere',
        ),
        HealthAslQuestionOption(id: 'not_sure', label: 'Not sure'),
      ],
    ),
    HealthAslSituationQuestion(
      id: 'main_role',
      question: 'What is your situation?',
      questionIt: 'Qual è la tua situazione?',
      type: 'single_choice',
      options: [
        HealthAslQuestionOption(id: 'worker', label: 'Worker'),
        HealthAslQuestionOption(id: 'student', label: 'Student'),
        HealthAslQuestionOption(id: 'unemployed', label: 'Unemployed'),
        HealthAslQuestionOption(
          id: 'no_valid_permit',
          label: 'No valid residence permit',
        ),
        HealthAslQuestionOption(
          id: 'duplicate_only',
          label: 'I only need duplicate/renewal',
        ),
        HealthAslQuestionOption(
          id: 'rejected_request',
          label: 'My ASL request was rejected',
        ),
      ],
    ),
    HealthAslSituationQuestion(
      id: 'has_permesso',
      question: 'Do you have a valid permesso di soggiorno?',
      questionIt: 'Hai un permesso di soggiorno valido?',
      type: 'single_choice',
      options: [
        HealthAslQuestionOption(id: 'yes', label: 'Yes'),
        HealthAslQuestionOption(
          id: 'renewal_receipt',
          label: 'I have renewal/application receipt',
        ),
        HealthAslQuestionOption(id: 'no', label: 'No'),
        HealthAslQuestionOption(id: 'not_applicable', label: 'Not applicable'),
      ],
      showWhen: {'citizenship_status': 'non_eu'},
    ),
    HealthAslSituationQuestion(
      id: 'already_has_card',
      question: 'Do you already have a Tessera Sanitaria?',
      questionIt: 'Hai già una Tessera Sanitaria?',
      type: 'single_choice',
      options: [
        HealthAslQuestionOption(id: 'yes_valid', label: 'Yes, valid'),
        HealthAslQuestionOption(id: 'yes_expired', label: 'Yes, expired'),
        HealthAslQuestionOption(
          id: 'lost_or_damaged',
          label: 'Lost or damaged',
        ),
        HealthAslQuestionOption(id: 'never_received', label: 'Never received'),
        HealthAslQuestionOption(id: 'no', label: 'No'),
      ],
    ),
  ],
  userFlows: [
    HealthAslUserFlow(
      id: 'italian_resident_torino',
      label: 'Italian citizen resident in Torino',
      labelIt: 'Cittadino italiano residente a Torino',
      summary:
          'For an Italian citizen resident in Torino, the practical need is usually to update the ASL position and choose a family doctor. If the user already has SSN coverage, they may only need doctor choice/revocation.',
      recommendedChannel: 'online_or_in_person',
      channelExplanation:
          'Use online services with SPID for doctor choice/revocation when possible. Otherwise go in person to the ASL administrative office of the district.',
      whereToGo:
          'ASL administrative office of the Torino district where the user lives.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'tessera_sanitaria_if_available',
        'torino_address_proof',
      ],
      extraDocuments: ['SPID/CIE/CNS if using online services'],
      warnings: [
        'This flow is usually not about first receiving a codice fiscale card; it is about local ASL position and doctor choice.',
        'If the user only needs duplicate/renewal, route to duplicate_or_renew_tessera_sanitaria.',
      ],
      outputs: ['in_person_checklist', 'normal_email_information_request'],
    ),
    HealthAslUserFlow(
      id: 'italian_student_domiciled_torino',
      label: 'Italian student living in Torino but resident elsewhere',
      labelIt: 'Studente italiano domiciliato a Torino ma residente altrove',
      summary:
          'For an Italian student who studies in Torino but is resident in another city or region, the practical need is usually temporary healthcare domiciliation and choosing a doctor in Torino.',
      recommendedChannel: 'in_person_asl_administrative_office',
      channelExplanation:
          'Go in person to the ASL administrative office of the Torino district where the student lives.',
      whereToGo:
          'ASL administrative office of the district where the student has domicile in Torino.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'tessera_sanitaria_if_available',
        'torino_address_proof',
      ],
      extraDocuments: [
        'University enrollment certificate',
        'Proof of domicile in Torino',
        'Previous doctor revocation/cancellation if required',
        'Domiciliazione sanitaria form',
      ],
      warnings: [
        'This is not simply duplicate Tessera Sanitaria. It is usually domiciliazione sanitaria.',
        'The user may need to renounce the doctor in the residence area before choosing a doctor in Torino.',
      ],
      usefulContacts: ['edisuStudentSupport'],
      outputs: [
        'in_person_checklist',
        'student_email_to_edisu',
        'normal_email_information_request',
      ],
    ),
    HealthAslUserFlow(
      id: 'eu_student_torino',
      label: 'EU student in Torino',
      labelIt: 'Studente UE a Torino',
      summary:
          'EU students often use the European Health Insurance Card / TEAM from their home country for necessary healthcare. Full Italian SSN registration depends on eligibility and should be evaluated case by case.',
      recommendedChannel: 'edisu_or_in_person_asl',
      channelExplanation:
          'For guidance, contact EDISU healthcare support. For ASL administrative evaluation, go to the ASL administrative office of the district where the student lives.',
      whereToGo:
          'ASL administrative office of the student’s Torino district, if full local registration or domiciliation is needed.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'torino_address_proof',
      ],
      extraDocuments: [
        'European Health Insurance Card / TEAM',
        'Readable copy of TEAM',
        'University enrollment certificate',
      ],
      warnings: [
        'EU student does not automatically mean full Italian SSN registration.',
        'The app must distinguish between using TEAM, private insurance, and possible SSN registration.',
      ],
      usefulContacts: ['edisuStudentSupport'],
      outputs: [
        'student_email_to_edisu',
        'in_person_checklist',
        'normal_email_information_request',
      ],
    ),
    HealthAslUserFlow(
      id: 'non_eu_student_torino',
      label: 'Non-EU student in Torino',
      labelIt: 'Studente extra-UE a Torino',
      summary:
          'A non-EU student in Torino usually needs either private health insurance or voluntary SSN registration. If they want SSN access and a family doctor, they normally need to pay the annual contribution and present the request at ASL administrative offices.',
      recommendedChannel: 'in_person_asl_administrative_office',
      channelExplanation:
          'Go in person to the ASL administrative office with the voluntary SSN registration forms and payment proof. Use PEC only for follow-up or rejected requests.',
      whereToGo:
          'ASL administrative office of the Torino district where the student lives.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'torino_address_proof',
      ],
      extraDocuments: [
        'Passport',
        'Valid permesso di soggiorno, or ask ASL if receipt is acceptable in the specific case',
        'University enrollment certificate',
        'F24 payment receipt for voluntary SSN registration',
        'Voluntary SSN registration form',
        'Dichiarazione sostitutiva di atto notorio',
        'Previous health insurance documents if relevant',
      ],
      warnings: [
        'Do not tell the user to only send PEC for first voluntary SSN registration.',
        'Voluntary SSN registration is usually annual and expires on 31 December.',
        'The payment is usually not divisible monthly and is not retroactive.',
        'A valid residence permit may be required; if the user only has a receipt, ASL must evaluate the specific case.',
      ],
      usefulContacts: ['edisuStudentSupport', 'aslTorinoGeneral'],
      outputs: [
        'voluntary_ssn_registration_checklist',
        'in_person_checklist',
        'student_email_to_edisu',
        'pec_rejected_request_followup',
      ],
    ),
    HealthAslUserFlow(
      id: 'non_eu_worker_torino',
      label: 'Non-EU worker in Torino',
      labelIt: 'Lavoratore extra-UE a Torino',
      summary:
          'A non-EU worker with the correct stay/work status often falls under mandatory SSN registration, not voluntary paid student-style registration.',
      recommendedChannel: 'in_person_asl_administrative_office',
      channelExplanation:
          'Go in person to the ASL administrative office of the district where the worker lives or has effective domicile.',
      whereToGo: 'ASL administrative office of the worker’s Torino district.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'torino_address_proof',
      ],
      extraDocuments: [
        'Passport',
        'Permesso di soggiorno',
        'Permesso renewal receipt if under renewal',
        'Work contract',
        'Recent payslip if available',
        'Previous ASL documents if any',
        'Doctor choice form if choosing doctor at the same time',
      ],
      warnings: [
        'Do not route this user to voluntary SSN payment unless ASL says they are not eligible for mandatory registration.',
        'If the ASL rejected the request for missing work proof, generate a PEC follow-up with the work contract attached.',
      ],
      outputs: [
        'in_person_checklist',
        'pec_missing_documents_followup',
        'normal_email_information_request',
      ],
    ),
    HealthAslUserFlow(
      id: 'unemployed_torino',
      label: 'Unemployed person in Torino',
      labelIt: 'Persona disoccupata a Torino',
      summary:
          'For unemployed users, eligibility depends on citizenship, previous work, DID/NASpI/Centro per l’Impiego registration, residence/domicile, and permit type.',
      recommendedChannel: 'in_person_asl_administrative_office',
      channelExplanation:
          'Go in person to ASL with unemployment and previous-work documents. Use PEC if a previous request was rejected.',
      whereToGo:
          'ASL administrative office of the Torino district where the user lives or has domicile.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'torino_address_proof',
      ],
      extraDocuments: [
        'Permesso di soggiorno if non-EU',
        'DID or Centro per l’Impiego registration if available',
        'NASpI application or acceptance if available',
        'Previous employment contract',
        'Previous payslip if available',
        'Previous Tessera Sanitaria if available',
      ],
      warnings: [
        'Do not give one generic answer for unemployed people.',
        'The app must first distinguish Italian, EU, and non-EU users.',
        'For non-EU users, permit type and previous work are critical.',
      ],
      outputs: [
        'in_person_checklist',
        'pec_missing_documents_followup',
        'normal_email_information_request',
      ],
    ),
    HealthAslUserFlow(
      id: 'non_resident_worker_or_student_torino',
      label: 'Non-resident worker or student living in Torino',
      labelIt: 'Lavoratore o studente non residente ma domiciliato a Torino',
      summary:
          'For users resident elsewhere but living in Torino for work, study, or health reasons, the practical flow is usually domiciliazione sanitaria.',
      recommendedChannel: 'in_person_asl_administrative_office',
      channelExplanation:
          'Go in person to the ASL administrative office of the district where the user has domicile in Torino.',
      whereToGo:
          'ASL administrative office of the domicile district in Torino.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'tessera_sanitaria_if_available',
        'torino_address_proof',
      ],
      extraDocuments: [
        'Work contract or university enrollment certificate',
        'Previous doctor revocation/cancellation if required',
        'Domiciliazione sanitaria form',
      ],
      warnings: [
        'This is not a simple card duplicate flow.',
        'If domiciliation is requested for health reasons, the case may require medical-director evaluation and may not be immediate.',
        'Temporary registration may depend on duration of work/study/health reason.',
      ],
      outputs: [
        'domiciliazione_sanitaria_checklist',
        'in_person_checklist',
        'normal_email_information_request',
      ],
    ),
    HealthAslUserFlow(
      id: 'no_valid_permesso_stp',
      label: 'Person without valid permesso di soggiorno',
      labelIt: 'Persona senza permesso di soggiorno valido',
      summary:
          'A non-EU person without normal SSN eligibility should not be routed to ordinary Tessera Sanitaria registration. They may need STP support through Centro ISI.',
      recommendedChannel: 'centro_isi',
      channelExplanation: 'Go to or contact Centro ISI ASL Città di Torino.',
      whereToGo:
          'Centro ISI, Via Bazzi 19, corner with Lungo Dora Savona 24, Torino.',
      documents: ['identity_document'],
      extraDocuments: [
        'Any identity document if available',
        'Personal data',
        'Medical documents if available',
        'Address or contact if available',
        'Declaration of indigence if requested',
      ],
      warnings: [
        'STP is not the same as normal Tessera Sanitaria.',
        'STP is a temporary healthcare code for necessary healthcare access.',
        'Do not route this user to normal voluntary SSN registration unless their legal status changes or ASL says so.',
      ],
      usefulContacts: ['centroIsi'],
      outputs: ['centro_isi_contact_message', 'stp_checklist'],
    ),
    HealthAslUserFlow(
      id: 'eu_without_team_or_coverage',
      label: 'EU citizen without Italian SSN or usable TEAM coverage',
      labelIt: 'Cittadino UE senza SSN italiano o TEAM utilizzabile',
      summary:
          'An EU citizen without Italian SSN registration and without usable TEAM coverage needs case-by-case ASL or Centro ISI evaluation, especially if vulnerable.',
      recommendedChannel: 'in_person_asl_or_centro_isi',
      channelExplanation:
          'If the user has stable work/residence conditions, go to the ASL administrative office. If vulnerable or without coverage, contact Centro ISI for guidance.',
      whereToGo:
          'ASL administrative office of the Torino district, or Centro ISI if vulnerable/without coverage.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'torino_address_proof',
      ],
      extraDocuments: [
        'Any proof of no healthcare coverage',
        'Any TEAM/EHIC document if expired or unusable',
        'Work/study/unemployment documents if available',
        'Declaration of social fragility/indigence if requested',
      ],
      warnings: [
        'Do not automatically promise ENI.',
        'The case must be evaluated by ASL/Centro ISI.',
      ],
      usefulContacts: ['centroIsi', 'aslTorinoGeneral'],
      outputs: [
        'in_person_checklist',
        'centro_isi_contact_message',
        'normal_email_information_request',
      ],
    ),
    HealthAslUserFlow(
      id: 'duplicate_or_renew_tessera_sanitaria',
      label: 'Duplicate, lost, expired, or damaged Tessera Sanitaria',
      labelIt:
          'Duplicato, smarrimento, scadenza o danneggiamento Tessera Sanitaria',
      summary:
          'This is a separate later page for users who already have an SSN/codice fiscale position and only need a duplicate, renewal, or replacement card.',
      recommendedChannel: 'online_or_in_person',
      channelExplanation:
          'Use the national online services first when possible. If you cannot complete it online or there is a local issue, go to the ASL administrative office.',
      whereToGo:
          'ASL administrative office of the user’s Torino district if online duplicate/renewal is not enough.',
      documents: [
        'identity_document',
        'codice_fiscale',
        'tessera_sanitaria_if_available',
      ],
      extraDocuments: [
        'Old card if damaged or expired',
        'Loss/theft report if available',
        'Delegation form if another person goes',
      ],
      warnings: [
        'This flow must not be the first Tessera Sanitaria page.',
        'Only route here if the user already has a healthcare/tax position and needs card duplicate or renewal.',
      ],
      outputs: [
        'duplicate_card_checklist',
        'in_person_checklist',
        'normal_email_information_request',
      ],
    ),
  ],
  outputGenerators: [
    HealthAslOutputGenerator(
      id: 'in_person_checklist',
      title: 'Checklist for going in person',
      titleIt: 'Checklist per andare allo sportello',
      outputType: 'checklist',
      fieldsNeeded: [
        'user full name',
        'citizenship status',
        'Torino district or address',
        'work/study/unemployment status',
        'permesso status if non-EU',
        'whether user already has Tessera Sanitaria',
      ],
      templateBehavior:
          'Generate a clear checklist of documents, the recommended ASL office based on the user’s area, opening-hour warning, and a short sentence explaining why in-person is recommended.',
    ),
    HealthAslOutputGenerator(
      id: 'normal_email_information_request',
      title: 'Email asking ASL/URP for information',
      titleIt: 'Email per chiedere informazioni all’URP ASL',
      outputType: 'email',
      sendTo: 'urp@aslcittaditorino.it',
      tone: 'formal',
      templateIt:
          'Buongiorno,\n\nvorrei chiedere informazioni sulla procedura corretta per [tipo richiesta] presso l’ASL Città di Torino.\n\nLa mia situazione è la seguente:\n- Cittadinanza: [italiana/UE/extra-UE]\n- Residenza/domicilio: [indirizzo o zona Torino]\n- Situazione: [studente/lavoratore/disoccupato/altro]\n- Tessera Sanitaria: [mai ricevuta/scaduta/smarrita/già presente]\n- Permesso di soggiorno, se applicabile: [valido/in rinnovo/non disponibile]\n\nVorrei sapere quale sportello è competente e quali documenti devo portare.\n\nCordiali saluti,\n[Nome Cognome]\n[Codice fiscale]\n[Telefono]',
    ),
    HealthAslOutputGenerator(
      id: 'pec_rejected_request_followup',
      title: 'PEC for rejected ASL request',
      titleIt: 'PEC per richiesta ASL respinta',
      outputType: 'pec',
      sendTo: 'protocollo@pec.aslcittaditorino.it',
      tone: 'formal',
      templateIt:
          'Oggetto: Richiesta di riesame pratica ASL respinta - [tipo pratica]\n\nBuongiorno,\n\ncon la presente chiedo cortesemente il riesame della mia pratica relativa a [tipo pratica], presentata in data [data], con eventuale numero di protocollo [numero protocollo].\n\nLa richiesta risulta respinta / non completata per il seguente motivo: [motivo indicato dall’ASL].\n\nAllego alla presente la documentazione aggiornata e completa, in particolare:\n[elenco documenti allegati]\n\nChiedo gentilmente di verificare nuovamente la pratica e di indicarmi se siano necessari ulteriori documenti o passaggi.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]',
    ),
    HealthAslOutputGenerator(
      id: 'pec_missing_documents_followup',
      title: 'PEC sending missing documents',
      titleIt: 'PEC per inviare documenti mancanti',
      outputType: 'pec',
      sendTo: 'protocollo@pec.aslcittaditorino.it',
      tone: 'formal',
      templateIt:
          'Oggetto: Integrazione documenti pratica ASL - [tipo pratica]\n\nBuongiorno,\n\nin riferimento alla mia richiesta relativa a [tipo pratica], presentata in data [data] con numero di protocollo [numero protocollo, se disponibile], invio in allegato i documenti richiesti / mancanti.\n\nDocumenti allegati:\n[elenco documenti]\n\nChiedo cortesemente di confermare la ricezione e di procedere con la valutazione della pratica.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]',
    ),
    HealthAslOutputGenerator(
      id: 'student_email_to_edisu',
      title: 'Email to EDISU healthcare support',
      titleIt: 'Email a EDISU per supporto sanitario studenti',
      outputType: 'email',
      sendTo: 'info.healthcare@edisu-piemonte.it',
      tone: 'formal',
      templateIt:
          'Buongiorno,\n\nsono uno studente a Torino e vorrei ricevere informazioni sulla procedura corretta per l’assistenza sanitaria / iscrizione al SSN / scelta del medico.\n\nLa mia situazione è la seguente:\n- Università: [nome università]\n- Cittadinanza: [italiana/UE/extra-UE]\n- Indirizzo a Torino: [indirizzo completo]\n- Residenza ufficiale: [città/paese]\n- Tessera sanitaria o TEAM: [presente/non presente/scaduta]\n- Permesso di soggiorno, se applicabile: [valido/in rinnovo/non disponibile]\n\nVorrei sapere qual è l’ASL competente e quali documenti devo preparare.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
    ),
    HealthAslOutputGenerator(
      id: 'centro_isi_contact_message',
      title: 'Message to Centro ISI',
      titleIt: 'Messaggio al Centro ISI',
      outputType: 'email_or_call_script',
      sendTo: 'centro.isi@aslcittaditorino.it',
      tone: 'formal_simple',
      templateIt:
          'Buongiorno,\n\nvorrei chiedere informazioni per l’accesso all’assistenza sanitaria tramite Centro ISI.\n\nLa mia situazione è la seguente:\n- Nome e cognome: [nome]\n- Cittadinanza: [paese]\n- Situazione del permesso di soggiorno: [descrizione]\n- Indirizzo o zona a Torino: [indirizzo/zona]\n- Necessità sanitaria: [breve descrizione]\n\nVorrei sapere se devo presentarmi direttamente allo sportello e quali documenti devo portare.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
    ),
    HealthAslOutputGenerator(
      id: 'voluntary_ssn_registration_checklist',
      title: 'Voluntary SSN registration checklist',
      titleIt: 'Checklist iscrizione volontaria SSN',
      outputType: 'checklist',
      appliesTo: ['non_eu_student_torino'],
      items: [
        'Passport',
        'Codice fiscale',
        'Valid permesso di soggiorno or ASL-evaluable receipt',
        'University enrollment certificate',
        'Proof of Torino address/domicile',
        'F24 payment receipt',
        'Modulo Iscrizione volontaria',
        'Dichiarazione sostitutiva atto notorio',
        'Previous health insurance documents if relevant',
      ],
      warning:
          'The request should be presented at ASL Città di Torino administrative offices. Do not tell the user to rely only on PEC for first registration.',
    ),
    HealthAslOutputGenerator(
      id: 'domiciliazione_sanitaria_checklist',
      title: 'Domiciliazione sanitaria checklist',
      titleIt: 'Checklist domiciliazione sanitaria',
      outputType: 'checklist',
      appliesTo: [
        'italian_student_domiciled_torino',
        'non_resident_worker_or_student_torino',
      ],
      items: [
        'Identity document',
        'Codice fiscale',
        'Existing Tessera Sanitaria',
        'Proof of domicile in Torino',
        'Work contract or university enrollment certificate',
        'Previous doctor revocation/cancellation if required',
        'Scelta medico/pediatra domiciliati - Domiciliazione Sanitaria form',
      ],
    ),
    HealthAslOutputGenerator(
      id: 'stp_checklist',
      title: 'STP checklist',
      titleIt: 'Checklist STP',
      outputType: 'checklist',
      appliesTo: ['no_valid_permesso_stp'],
      items: [
        'Identity document if available',
        'Personal data',
        'Any medical documents if available',
        'Address/contact if available',
        'Declaration of indigence if requested',
      ],
      warning:
          'STP is not normal SSN registration and does not mean ordinary Tessera Sanitaria.',
    ),
    HealthAslOutputGenerator(
      id: 'duplicate_card_checklist',
      title: 'Duplicate or renewal Tessera Sanitaria checklist',
      titleIt: 'Checklist duplicato o rinnovo Tessera Sanitaria',
      outputType: 'checklist',
      appliesTo: ['duplicate_or_renew_tessera_sanitaria'],
      items: [
        'Identity document',
        'Codice fiscale',
        'Old Tessera Sanitaria if damaged or expired',
        'Loss/theft report if available',
        'Delegation form if another person goes',
      ],
      warning:
          'This belongs to a separate subpage. It must not replace the first page about getting SSN registration.',
    ),
  ],
  routingRules: [
    HealthAslRoutingRule(
      conditions: {'main_role': 'duplicate_only'},
      routeTo: 'duplicate_or_renew_tessera_sanitaria',
      note:
          'This user does not need the first registration page unless their ASL/SSN position is missing or blocked.',
    ),
    HealthAslRoutingRule(
      conditions: {'citizenship_status': 'non_eu', 'main_role': 'student'},
      routeTo: 'non_eu_student_torino',
      recommendedChannel: 'in_person_asl_administrative_office',
    ),
    HealthAslRoutingRule(
      conditions: {'citizenship_status': 'non_eu', 'main_role': 'worker'},
      routeTo: 'non_eu_worker_torino',
      recommendedChannel: 'in_person_asl_administrative_office',
    ),
    HealthAslRoutingRule(
      conditions: {
        'citizenship_status': 'non_eu',
        'main_role': 'no_valid_permit',
      },
      routeTo: 'no_valid_permesso_stp',
      recommendedChannel: 'centro_isi',
    ),
    HealthAslRoutingRule(
      conditions: {'citizenship_status': 'eu', 'main_role': 'student'},
      routeTo: 'eu_student_torino',
      recommendedChannel: 'edisu_or_in_person_asl',
    ),
    HealthAslRoutingRule(
      conditions: {'torino_status': 'domiciled'},
      routeTo: 'non_resident_worker_or_student_torino',
      recommendedChannel: 'in_person_asl_administrative_office',
    ),
    HealthAslRoutingRule(
      conditions: {'main_role': 'unemployed'},
      routeTo: 'unemployed_torino',
      recommendedChannel: 'in_person_asl_administrative_office',
    ),
    HealthAslRoutingRule(
      conditions: {'main_role': 'rejected_request'},
      routeTo: 'rejected_asl_request',
      recommendedOutput: 'pec_rejected_request_followup',
    ),
  ],
  implementationNotesForCodex: [
    'Do not hardcode this content inside React components. Store it in the same data layer used by the rest of UfficioFacile categories.',
    'This subcategory must be first inside Health / ASL.',
    "Rename the old generic 'Health card / Tessera Sanitaria' page to 'Get Tessera Sanitaria / Register with SSN'.",
    "Create a separate later subpage for 'Duplicate or renew Tessera Sanitaria'.",
    'The UI should first ask the user’s situation, then show the recommended channel, office/address, documents, warnings, and generated action.',
    'For Torino, default first-registration and complex cases to in-person ASL administrative offices.',
    'Use PEC mainly for formal follow-up, rejected requests, and sending missing documents.',
    'Use normal email mainly for information and URP support.',
    'Use Centro ISI for STP/foreign vulnerable healthcare access flows.',
    'Use EDISU only as student guidance, not as the final ASL registration authority.',
    'Add a warning near all addresses: opening hours can change, verify before going.',
  ],
);

class HealthAslGuidanceDefinitions {
  static const List<HealthAslGuidance> all = [
    healthAslGetTesseraSanitariaTorino,
  ];

  static HealthAslGuidance? forProcedureId(String procedureId) {
    switch (procedureId) {
      case 'TESSERA_SANITARIA_RENEWAL':
        return healthAslGetTesseraSanitariaTorino;
      default:
        return null;
    }
  }
}
