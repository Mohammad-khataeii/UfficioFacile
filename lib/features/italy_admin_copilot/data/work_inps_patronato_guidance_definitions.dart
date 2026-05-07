import '../domain/rich_category_models.dart';

class WorkInpsPatronatoGuidanceDefinitions {
  static final RichCategoryGuidance category = RichCategoryGuidance.fromMap({
    'id': 'work_inps_patronato',
    'title': 'Work / INPS / Patronato',
    'titleIt': 'Lavoro / INPS / Patronato',
    'region': 'piemonte',
    'city': 'torino',
    'shortDescription':
        'Help users handle job-loss, NASpI, DID, Centro per l’Impiego, patronato appointments, INPS follow-up, rejected INPS requests, missing documents, employer end-of-contract documents, payslip/TFR problems, sick leave, family benefits, ISEE/CAF, and work-dispute support.',
    'mainUserQuestion':
        'What work, unemployment, INPS, patronato, or employer problem do I have, and should I contact INPS, patronato, Centro per l’Impiego, CAF, union, employer, or send PEC?',
    'routingLogicSummary':
        'First understand the user’s work situation: job loss, NASpI, DID/CPI, INPS request, rejected application, missing documents, employer documents, unpaid salary/TFR, sick leave, family benefits, ISEE/CAF, or work dispute. Then route to the correct flow and show only relevant documents, contacts, warnings, and generator buttons.',
    'topWarning':
        'Do not show all INPS, patronato, CPI, CAF, union contacts and all templates on one page. Ask the user what work/INPS problem they have, then show only the relevant flow.',
    'officialReferences': {
      'inpsTorino': {
        'label': 'INPS Torino - Direzione Provinciale',
        'url':
            'https://www.inps.it/it/it/sedi-e-contatti/sedi/ricerca-sede/dettaglio-sedi.it.sezione-sedi.sedi-inps.810000.810000-elencoStruttureInps.html',
      },
      'inpsTorinoSanPaolo': {
        'label': 'INPS Torino San Paolo',
        'url':
            'https://www.inps.it/it/it/sedi-e-contatti/sedi/ricerca-sede/dettaglio-sedi.it.sezione-sedi.sedi-inps.810009.810009-elencoStruttureInps.html',
      },
      'cpiTorinoNord': {
        'label': 'Centro per l’Impiego Torino Nord',
        'url':
            'https://agenziapiemontelavoro.it/centro-per-limpiego/centro-per-limpiego-di-torino-nord/',
      },
      'incaCgilTorino': {
        'label': 'INCA CGIL Torino',
        'url': 'https://inca.it/dove-siamo/sedi-in-italia.html',
      },
      'cgilTorino': {
        'label': 'CGIL Torino',
        'url': 'https://www.cgiltorino.it/servizi/inca.html',
      },
    },
    'contacts': {
      'inpsTorinoDirezioneProvinciale': {
        'id': 'inps_torino_direzione_provinciale',
        'name': 'INPS Torino - Direzione Provinciale',
        'address': 'Corso Vittorio Emanuele II 3, 10125 Torino',
        'phoneFixedLine': '803164',
        'phoneMobileOrAbroad': '06 164 164',
        'pec': 'direzione.provinciale.torino@postacert.inps.gov.it',
        'useFor': [
          'NASpI',
          'INPS benefit applications',
          'formal INPS follow-up',
          'rejected INPS requests',
          'missing document integration',
          'payment delay',
          'INPS appointment/contact request',
          'general INPS formal communication',
        ],
        'warning':
            'Use PEC for formal/protocol communication. For normal support, use INPS online services, contact center, appointment service, or patronato.',
      },
      'inpsTorinoSanPaolo': {
        'id': 'inps_torino_san_paolo',
        'name': 'INPS Torino San Paolo',
        'address': 'Via Francesco Millio 41, 10141 Torino',
        'phoneFixedLine': '803164',
        'phoneMobileOrAbroad': '06 164 164',
        'pec': 'direzione.agenzia.torinosanpaolo@postacert.inps.gov.it',
        'useFor': [
          'INPS practices if this agency is competent',
          'NASpI/local INPS support',
          'formal agency communication',
        ],
        'warning':
            'Do not assume this is the competent INPS office for every Torino user.',
      },
      'cpiTorinoNord': {
        'id': 'cpi_torino_nord',
        'name': 'Centro per l’Impiego Torino Nord',
        'address': 'Via Bologna 153, Torino',
        'phone': '011 0876180',
        'email': 'info.cpi.torinonord@agenziapiemontelavoro.it',
        'pec': 'cpi.torino.nord@pec.agenziapiemontelavoro.it',
        'openingHours':
            'Receives by appointment. Use the official page to verify hours and competence area.',
        'useFor': [
          'DID',
          'employment status',
          'job seeker declaration',
          'CPI appointment',
          'NASpI-related employment obligations',
          'patto di servizio',
          'employment-service support',
        ],
        'warning':
            'Torino has more than one CPI competence area. Do not assume Torino Nord is correct for every user; ask user address or let them verify competent CPI.',
      },
      'incaCgilTorino': {
        'id': 'inca_cgil_torino',
        'name': 'Patronato INCA CGIL Torino',
        'address': 'Via Carlo Pedrotti 5, 10152 Torino',
        'phone': '011 2442381',
        'email': 'torinocentro@inca.it',
        'useFor': [
          'NASpI',
          'INPS applications',
          'pension/benefit practices',
          'checking INPS status',
          'rejected INPS request support',
          'foreign-citizen patronato support',
        ],
      },
      'cgilTorino': {
        'id': 'cgil_torino',
        'name': 'CGIL Torino',
        'address': 'Via Pedrotti 5, 10152 Torino',
        'phone': '011 2442376',
        'email': 'torino@cgiltorino.it',
        'pec': 'cgiltorino@pec.it',
        'useFor': [
          'worker support',
          'work dispute direction',
          'union/vertenza support',
          'unpaid salary/TFR',
          'contract abuse',
          'wrong dismissal',
          'payslip problems',
        ],
        'warning':
            'Use union/legal-work dispute support for employer problems. Use patronato for INPS/benefit applications.',
      },
      'inasCislGeneric': {
        'id': 'inas_cisl_generic',
        'name': 'Patronato INAS CISL',
        'email': 'info@inas.it',
        'pec': 'protocollo@pec.inas.it',
        'useFor': [
          'NASpI',
          'INPS practices',
          'pensions',
          'maternity/family benefits',
          'invalidity',
          'immigration-related patronato support',
        ],
        'warning':
            'For a local Torino appointment, use the official INAS/CISL Torino local office list. Do not hardcode a local office unless verified.',
      },
      'cafGeneric': {
        'id': 'caf_generic',
        'name': 'CAF',
        'useFor': [
          'ISEE ordinario',
          'ISEE corrente',
          'bonus applications',
          'university benefits',
          'family benefits that require ISEE',
          'income/asset documentation',
        ],
        'warning':
            'CAF is for ISEE/tax-assistance style procedures. Patronato is usually for INPS benefit applications.',
      },
    },
    'channelRules': [
      {'id': 'patronato', 'label': 'Contact patronato', 'labelIt': 'Contatta un patronato', 'priority': 'recommended_for_benefits', 'useWhen': ['NASpI preparation', 'NASpI follow-up', 'INPS rejected request', 'missing documents for INPS', 'maternity/family benefits', 'user is unsure about INPS procedure', 'foreign citizen needs help'], 'warning': 'Patronato is usually safer for users who are unsure about eligibility, documents, or INPS online forms.'},
      {'id': 'inps_online', 'label': 'Use INPS online service', 'labelIt': 'Usa servizio online INPS', 'priority': 'if_user_confident', 'useWhen': ['NASpI application', 'checking application status', 'uploading documents if service allows', 'checking INPS messages', 'payment status'], 'warning': 'Requires SPID/CIE/CNS and confidence with the INPS portal.'},
      {'id': 'inps_pec', 'label': 'Send PEC to INPS', 'labelIt': 'Invia PEC a INPS', 'priority': 'formal', 'pec': 'direzione.provinciale.torino@postacert.inps.gov.it', 'useWhen': ['formal follow-up', 'missing document integration', 'rejected request reply', 'payment delay formal request', 'protocol update', 'official written communication'], 'warning': 'Use PEC for formal/protocol communication. Include protocol number and attachments.'},
      {'id': 'centro_impiego', 'label': 'Contact Centro per l’Impiego', 'labelIt': 'Contatta Centro per l’Impiego', 'priority': 'did_cpi', 'useWhen': ['DID', 'patto di servizio', 'employment status', 'NASpI active policy obligations', 'CPI appointment'], 'warning': 'Use the competent CPI based on user address. Torino Nord is not always the correct CPI.'},
      {'id': 'employer_formal_request', 'label': 'Send formal request to employer', 'labelIt': 'Invia richiesta formale al datore di lavoro', 'priority': 'employer_documents_or_payments', 'useWhen': ['termination documents missing', 'UNILAV missing', 'last payslips missing', 'TFR/final payment problem', 'CU missing', 'employer ignores documents request'], 'warning': 'If employer refuses or money is owed, suggest union/vertence support.'},
      {'id': 'union_support', 'label': 'Contact union / work dispute support', 'labelIt': 'Contatta sindacato / vertenza lavoro', 'priority': 'work_dispute', 'useWhen': ['unpaid salary', 'TFR missing', 'wrong dismissal', 'contract abuse', 'fake resignation', 'payslip irregularity', 'serious employer dispute'], 'warning': 'UfficioFacile can help prepare documents and messages, but does not replace a lawyer or union/legal representative.'},
      {'id': 'caf', 'label': 'Contact CAF', 'labelIt': 'Contatta CAF', 'priority': 'isee_tax_documents', 'useWhen': ['ISEE', 'ISEE corrente', 'bonus that require ISEE', 'university benefits', 'family benefits with ISEE requirement']},
    ],
    'commonDocuments': [
      {'id': 'identity_document', 'label': 'Identity document', 'labelIt': 'Documento d’identità'},
      {'id': 'codice_fiscale', 'label': 'Codice fiscale', 'labelIt': 'Codice fiscale'},
      {'id': 'iban', 'label': 'IBAN', 'labelIt': 'IBAN'},
      {'id': 'spid_cie_cns', 'label': 'SPID / CIE / CNS', 'labelIt': 'SPID / CIE / CNS'},
      {'id': 'employment_contract', 'label': 'Employment contract', 'labelIt': 'Contratto di lavoro'},
      {'id': 'termination_letter', 'label': 'Termination letter / contract-end proof', 'labelIt': 'Lettera licenziamento / fine contratto'},
      {'id': 'payslips', 'label': 'Payslips', 'labelIt': 'Buste paga'},
      {'id': 'unilav', 'label': 'UNILAV / employment communication', 'labelIt': 'UNILAV / comunicazione rapporto lavoro'},
      {'id': 'cu', 'label': 'CU / Certificazione Unica', 'labelIt': 'CU / Certificazione Unica'},
      {'id': 'permesso_soggiorno', 'label': 'Permesso di soggiorno if non-EU', 'labelIt': 'Permesso di soggiorno se extra-UE'},
      {'id': 'inps_protocol', 'label': 'INPS protocol number', 'labelIt': 'Numero protocollo INPS'},
      {'id': 'inps_receipt', 'label': 'INPS receipt/application PDF', 'labelIt': 'Ricevuta/domanda INPS'},
      {'id': 'inps_messages', 'label': 'INPS messages', 'labelIt': 'Messaggi INPS'},
      {'id': 'patronato_receipt', 'label': 'Patronato receipt', 'labelIt': 'Ricevuta patronato'},
      {'id': 'employer_messages', 'label': 'Employer messages', 'labelIt': 'Messaggi datore di lavoro'},
      {'id': 'bank_payments', 'label': 'Bank payments', 'labelIt': 'Pagamenti bancari'},
      {'id': 'medical_certificate_protocol', 'label': 'Medical certificate protocol', 'labelIt': 'Protocollo certificato medico'},
      {'id': 'isee_documents', 'label': 'ISEE documents', 'labelIt': 'Documenti ISEE'},
    ],
    'firstScreenQuestions': [
      {'id': 'problem_type', 'question': 'What work / INPS problem do you have?', 'questionIt': 'Qual è il tuo problema lavoro / INPS?', 'type': 'single_choice', 'options': [{'id': 'not_sure_job_loss', 'label': 'I lost my job and need to understand what to do'}, {'id': 'naspi_prepare', 'label': 'I need NASpI'}, {'id': 'naspi_followup', 'label': 'I already applied for NASpI and need follow-up'}, {'id': 'did_cpi', 'label': 'I need DID / Centro per l’Impiego'}, {'id': 'patronato_appointment', 'label': 'I need a patronato appointment'}, {'id': 'inps_contact', 'label': 'I need to contact INPS'}, {'id': 'inps_rejected', 'label': 'My INPS request was rejected'}, {'id': 'missing_documents', 'label': 'INPS asked for missing documents'}, {'id': 'employer_documents', 'label': 'I need documents from employer after contract ended'}, {'id': 'salary_tfr_problem', 'label': 'Employer did not pay salary/TFR'}, {'id': 'sick_leave', 'label': 'I need sick leave / malattia information'}, {'id': 'family_benefits', 'label': 'I need maternity/family benefit help'}, {'id': 'isee_caf', 'label': 'I need ISEE/CAF'}, {'id': 'work_dispute', 'label': 'I have a work dispute'}, {'id': 'inps_formal_pec', 'label': 'I need to send INPS PEC/formal request'}]},
      {'id': 'job_end_reason', 'question': 'Why did the job end?', 'questionIt': 'Perché è finito il lavoro?', 'type': 'single_choice', 'options': [{'id': 'dismissal', 'label': 'Dismissal / licenziamento'}, {'id': 'fixed_term_end', 'label': 'Fixed-term contract ended'}, {'id': 'apprenticeship_end_by_employer', 'label': 'Apprenticeship ended by employer'}, {'id': 'resignation', 'label': 'Voluntary resignation'}, {'id': 'mutual_agreement', 'label': 'Mutual agreement'}, {'id': 'probation', 'label': 'Probation ended'}, {'id': 'not_sure', 'label': 'Not sure'}]},
      {'id': 'contract_type', 'question': 'What contract type did you have?', 'questionIt': 'Che tipo di contratto avevi?', 'type': 'single_choice', 'options': [{'id': 'permanent', 'label': 'Permanent'}, {'id': 'fixed_term', 'label': 'Fixed-term'}, {'id': 'apprenticeship', 'label': 'Apprenticeship'}, {'id': 'part_time', 'label': 'Part-time'}, {'id': 'seasonal', 'label': 'Seasonal'}, {'id': 'domestic_work', 'label': 'Domestic work'}, {'id': 'not_sure', 'label': 'Not sure'}]},
      {'id': 'last_working_day', 'question': 'What was your last working day?', 'questionIt': 'Qual è stato l’ultimo giorno di lavoro?', 'type': 'text'},
      {'id': 'has_termination_letter', 'question': 'Do you have a termination/contract-end letter?', 'questionIt': 'Hai una lettera di licenziamento/fine contratto?', 'type': 'single_choice', 'options': [{'id': 'yes', 'label': 'Yes'}, {'id': 'no', 'label': 'No'}, {'id': 'not_sure', 'label': 'Not sure'}]},
      {'id': 'already_applied_inps', 'question': 'Did you already apply to INPS?', 'questionIt': 'Hai già fatto domanda a INPS?', 'type': 'single_choice', 'options': [{'id': 'yes', 'label': 'Yes'}, {'id': 'no', 'label': 'No'}, {'id': 'through_patronato', 'label': 'Yes, through patronato'}]},
      {'id': 'has_protocol', 'question': 'Do you have an INPS protocol number?', 'questionIt': 'Hai un numero di protocollo INPS?', 'type': 'single_choice', 'options': [{'id': 'yes', 'label': 'Yes'}, {'id': 'no', 'label': 'No'}]},
      {'id': 'has_spid', 'question': 'Do you have SPID/CIE/CNS?', 'questionIt': 'Hai SPID/CIE/CNS?', 'type': 'single_choice', 'options': [{'id': 'yes', 'label': 'Yes'}, {'id': 'no', 'label': 'No'}]},
      {'id': 'citizenship_status', 'question': 'Are you Italian, EU, or non-EU?', 'questionIt': 'Sei cittadino italiano, UE o extra-UE?', 'type': 'single_choice', 'options': [{'id': 'italian', 'label': 'Italian'}, {'id': 'eu', 'label': 'EU'}, {'id': 'non_eu', 'label': 'Non-EU'}]},
      {'id': 'has_permesso', 'question': 'Do you have permesso di soggiorno?', 'questionIt': 'Hai il permesso di soggiorno?', 'type': 'single_choice', 'showWhen': {'citizenship_status': 'non_eu'}, 'options': [{'id': 'yes', 'label': 'Yes'}, {'id': 'renewal_receipt', 'label': 'Renewal/application receipt'}, {'id': 'no', 'label': 'No'}, {'id': 'not_applicable', 'label': 'Not applicable'}]},
      {'id': 'preferred_channel', 'question': 'Do you want to apply alone or through patronato?', 'questionIt': 'Vuoi fare da solo o tramite patronato?', 'type': 'single_choice', 'options': [{'id': 'alone_online', 'label': 'Alone online'}, {'id': 'patronato', 'label': 'Through patronato'}, {'id': 'not_sure', 'label': 'Not sure'}]},
    ],
    'subcategories': [
      {'id': 'understand_job_loss_benefit_situation', 'title': 'Understand job-loss and benefit situation', 'titleIt': 'Capire situazione lavoro / disoccupazione / benefici', 'priority': 'high', 'whatIsIt': 'This page helps the user understand which path applies after job loss, contract end, resignation, dismissal, apprenticeship end, or other work interruption.', 'whyDoYouNeedIt': ['User asks for NASpI but may need first to understand eligibility route', 'Job ended for different possible reasons', 'User may need employer documents first', 'User may need DID/CPI obligations', 'User may need patronato instead of doing INPS alone', 'Employer problem may be a union/legal-work dispute, not only INPS'], 'recommendedChannels': ['patronato'], 'recommendedContacts': ['incaCgilTorino', 'inasCislGeneric'], 'documents': ['identity_document', 'codice_fiscale', 'iban', 'employment_contract', 'termination_letter', 'payslips', 'unilav', 'cu', 'permesso_soggiorno'], 'extraDocuments': ['Employer communications', 'Previous NASpI or INPS documents', 'SPID/CIE/CNS if applying online', 'Last working day', 'Reason job ended'], 'warnings': ['Do not promise NASpI eligibility without checking job-end reason and contribution requirements.', 'If the user resigned voluntarily, NASpI may not apply except specific cases.', 'If employer did not pay or dismissal is disputed, route to union/legal-work support.'], 'outputs': ['correct_work_benefit_route', 'naspi_readiness_checklist', 'patronato_appointment_email', 'did_cpi_reminder', 'work_document_checklist']},
      {'id': 'naspi_preparation', 'title': 'NASpI preparation', 'titleIt': 'Preparazione domanda NASpI', 'priority': 'high', 'whatIsIt': 'This page helps users prepare for the NASpI unemployment benefit application.', 'whyDoYouNeedIt': ['Job ended involuntarily', 'Fixed-term contract ended', 'Apprenticeship ended by employer', 'Worker was dismissed', 'User needs documents before patronato', 'User wants to apply online through INPS', 'User needs DID/CPI guidance'], 'recommendedChannels': ['patronato', 'inps_online', 'centro_impiego'], 'recommendedContacts': ['incaCgilTorino', 'inasCislGeneric', 'inpsTorinoDirezioneProvinciale', 'cpiTorinoNord'], 'documents': ['identity_document', 'codice_fiscale', 'iban', 'employment_contract', 'termination_letter', 'payslips', 'unilav', 'cu', 'spid_cie_cns', 'permesso_soggiorno'], 'extraDocuments': ['Employer PEC/email communications', 'Previous NASpI or INPS documents if any', 'Last working day', 'Reason job ended'], 'warnings': ['For most users, patronato is safer than doing the application alone.', 'If the user resigned voluntarily, check carefully before NASpI.', 'If the employer ended an apprenticeship at the end of training period, verify with patronato/INPS.'], 'outputs': ['naspi_checklist', 'patronato_appointment_email', 'inps_contact_request', 'employer_document_request', 'did_cpi_reminder']},
      {'id': 'naspi_application_followup', 'title': 'NASpI application follow-up', 'titleIt': 'Controllo stato domanda NASpI', 'priority': 'high', 'whatIsIt': 'This page helps the user check or follow up on a NASpI application already submitted.', 'whyDoYouNeedIt': ['NASpI still pending', 'INPS asks for documents', 'Application rejected', 'Payment not arrived', 'IBAN problem', 'DID/CPI obligation problem', 'Employer data missing', 'Wrong last working day', 'Patronato submitted but user has no update'], 'recommendedChannels': ['inps_online', 'patronato', 'inps_pec'], 'recommendedContacts': ['inpsTorinoDirezioneProvinciale', 'incaCgilTorino', 'inasCislGeneric'], 'documents': ['inps_protocol', 'inps_receipt', 'identity_document', 'codice_fiscale', 'iban', 'inps_messages', 'employment_contract', 'termination_letter', 'patronato_receipt'], 'extraDocuments': ['Employer documents', 'Screenshot of INPS status', 'Any INPS request for integration', 'DID/CPI proof if relevant'], 'warnings': ['If a patronato submitted the request, first contact that patronato with protocol/receipt.', 'For formal INPS communication, include protocol number.'], 'outputs': ['naspi_status_checklist', 'message_to_patronato_followup', 'inps_formal_followup', 'pec_inps_document_integration', 'naspi_payment_delay_request']},
      {'id': 'did_and_centro_impiego', 'title': 'DID and Centro per l’Impiego', 'titleIt': 'DID e Centro per l’Impiego', 'priority': 'high', 'whatIsIt': 'This page helps users understand DID, employment availability declaration, and Centro per l’Impiego obligations.', 'whyDoYouNeedIt': ['NASpI requires availability to work and employment-service obligations', 'User may need DID', 'User needs CPI appointment', 'User must sign patto di servizio', 'User needs employment status update', 'User needs to reply to CPI message'], 'recommendedChannels': ['centro_impiego'], 'recommendedContacts': ['cpiTorinoNord'], 'documents': ['identity_document', 'codice_fiscale', 'spid_cie_cns', 'employment_contract', 'termination_letter', 'inps_receipt', 'permesso_soggiorno'], 'extraDocuments': ['CV', 'Residence/domicile address', 'NASpI protocol if available', 'Previous CPI messages'], 'warnings': ['Use correct CPI based on the user’s address, not automatically Torino Nord.', 'If the user has NASpI, do not ignore CPI/patto di servizio obligations.'], 'outputs': ['did_cpi_checklist', 'email_to_cpi_appointment', 'pec_to_cpi', 'patto_servizio_document_checklist']},
      {'id': 'patronato_appointment_request', 'title': 'Patronato appointment request', 'titleIt': 'Richiesta appuntamento Patronato', 'priority': 'high', 'whatIsIt': 'This page helps users write to a patronato for an appointment.', 'whyDoYouNeedIt': ['NASpI', 'INPS benefits', 'maternity/family benefits', 'pension', 'invalidity', 'checking INPS rejection', 'submitting documents', 'foreign-citizen support'], 'recommendedChannels': ['patronato'], 'recommendedContacts': ['incaCgilTorino', 'inasCislGeneric'], 'documents': ['identity_document', 'codice_fiscale', 'employment_contract', 'termination_letter', 'payslips', 'iban', 'spid_cie_cns', 'inps_protocol', 'permesso_soggiorno', 'inps_messages'], 'extraDocuments': ['Any rejection/message from INPS', 'CU/UNILAV if available', 'Patronato receipt if existing practice'], 'outputs': ['patronato_appointment_email', 'short_patronato_call_script', 'naspi_specific_appointment_request', 'patronato_document_checklist']},
      {'id': 'inps_appointment_contact_request', 'title': 'INPS appointment / contact request', 'titleIt': 'Appuntamento o contatto INPS', 'priority': 'medium', 'whatIsIt': 'This page helps users contact INPS or prepare an appointment request.', 'whyDoYouNeedIt': ['Check application', 'Ask information', 'Submit integration', 'Resolve payment issue', 'Ask why request is rejected', 'Need official response', 'Cannot access online service'], 'recommendedChannels': ['inps_online', 'inps_pec', 'patronato'], 'recommendedContacts': ['inpsTorinoDirezioneProvinciale', 'inpsTorinoSanPaolo', 'incaCgilTorino'], 'documents': ['identity_document', 'codice_fiscale', 'inps_protocol', 'inps_receipt', 'inps_messages', 'spid_cie_cns'], 'extraDocuments': ['Relevant attachments', 'Screenshots/messages', 'IBAN if payment issue', 'Patronato receipt if relevant'], 'outputs': ['inps_appointment_checklist', 'inps_contact_request_message', 'inps_pec_template', 'inps_online_service_problem_report']},
      {'id': 'reply_rejected_inps_request', 'title': 'Reply to rejected INPS request', 'titleIt': 'Risposta a domanda INPS respinta', 'priority': 'high', 'whatIsIt': 'This page helps users respond when INPS rejects or suspends a request.', 'whyDoYouNeedIt': ['NASpI rejected', 'Benefit rejected', 'Missing documents', 'Wrong data', 'IBAN issue', 'Contribution issue', 'Employer communication missing', 'Residence/permesso problem', 'Deadline issue'], 'recommendedChannels': ['patronato', 'inps_pec', 'inps_online'], 'recommendedContacts': ['incaCgilTorino', 'inasCislGeneric', 'inpsTorinoDirezioneProvinciale'], 'documents': ['inps_messages', 'inps_protocol', 'inps_receipt', 'identity_document', 'codice_fiscale', 'employment_contract', 'termination_letter', 'payslips', 'iban', 'permesso_soggiorno', 'patronato_receipt'], 'extraDocuments': ['All missing documents requested by INPS', 'Proof of IBAN ownership if needed', 'Employer communications', 'DID/CPI proof if relevant'], 'warnings': ['If user is unsure, patronato first.', 'Use PEC/formal request only with protocol and clear attachments.', 'Do not promise reconsideration outcome.'], 'outputs': ['rejected_inps_reply_pec', 'message_to_patronato_rejected_request', 'missing_document_integration_checklist', 'formal_reconsideration_request']},
      {'id': 'missing_documents_integration', 'title': 'Missing documents integration', 'titleIt': 'Integrazione documenti INPS', 'priority': 'medium', 'whatIsIt': 'This page helps users send missing documents to INPS or patronato.', 'whyDoYouNeedIt': ['INPS asked for documents', 'Patronato needs attachments', 'NASpI pending because document missing', 'Employer document missing', 'User uploaded wrong file', 'Deadline for integration'], 'recommendedChannels': ['inps_online', 'patronato', 'inps_pec'], 'recommendedContacts': ['inpsTorinoDirezioneProvinciale', 'incaCgilTorino', 'inasCislGeneric'], 'documents': ['inps_protocol', 'inps_messages', 'identity_document', 'codice_fiscale', 'inps_receipt'], 'extraDocuments': ['All missing documents requested by INPS', 'Proof of upload/submission', 'Patronato receipt if applicable'], 'outputs': ['integration_checklist', 'pec_inps_document_integration', 'message_to_patronato_attachments', 'upload_checklist']},
      {'id': 'employer_termination_contract_end_documents', 'title': 'Employer termination / contract-end document checklist', 'titleIt': 'Documenti fine rapporto di lavoro', 'priority': 'high', 'whatIsIt': 'This page helps users ask the employer for documents after the job ends.', 'whyDoYouNeedIt': ['To apply for NASpI', 'To verify final salary', 'To check TFR', 'To prove job end', 'To show patronato/INPS', 'To contest missing payment'], 'recommendedChannels': ['employer_formal_request', 'union_support'], 'recommendedContacts': ['cgilTorino', 'incaCgilTorino'], 'documents': ['employment_contract', 'termination_letter', 'payslips', 'unilav', 'cu', 'employer_messages'], 'extraDocuments': ['TFR calculation', 'Ferie/permessi records', 'Final settlement/prospetto competenze', 'Employer PEC/email'], 'warnings': ['If employer refuses or payment is missing, route to union/work dispute support.', 'For NASpI, patronato may tell the user which employer documents are really needed.'], 'outputs': ['employer_document_request', 'end_of_contract_document_checklist', 'formal_employer_reminder', 'union_appointment_recommendation']},
      {'id': 'payslip_tfr_final_payment_problem', 'title': 'Payslip / TFR / final payment problem', 'titleIt': 'Problema busta paga / TFR / ultimo stipendio', 'priority': 'high', 'whatIsIt': 'This page helps users when employer does not pay salary, TFR, ferie, permessi, or final settlement.', 'whyDoYouNeedIt': ['Missing final salary', 'TFR not paid', 'Payslip wrong', 'Ferie/permessi not paid', 'Employer ignores messages', 'Contract ended but no final settlement', 'Need union/vertence support'], 'recommendedChannels': ['employer_formal_request', 'union_support'], 'recommendedContacts': ['cgilTorino'], 'documents': ['employment_contract', 'payslips', 'bank_payments', 'termination_letter', 'employer_messages', 'cu'], 'extraDocuments': ['Timesheets', 'TFR/ferie/permessi records', 'Final settlement document if available', 'Employer details'], 'warnings': ['This is a work-dispute/payment issue, not only INPS.', 'If unresolved, recommend union/legal-work support.'], 'outputs': ['employer_payment_request', 'final_payment_checklist', 'union_appointment_email', 'work_dispute_evidence_checklist']},
      {'id': 'sick_leave_malattia_inps_basics', 'title': 'Sick leave / malattia INPS basics', 'titleIt': 'Malattia INPS / certificato medico', 'priority': 'medium', 'whatIsIt': 'This page explains basic steps for sick leave connected to work and INPS.', 'whyDoYouNeedIt': ['Worker is sick', 'Need certificate', 'Need protocol number', 'Employer asks for certificate', 'INPS visit/controllo medico fiscale', 'Wrong address during illness', 'Certificate missing'], 'recommendedChannels': ['inps_online', 'patronato'], 'recommendedContacts': ['inpsTorinoDirezioneProvinciale', 'incaCgilTorino'], 'documents': ['medical_certificate_protocol', 'employment_contract', 'employer_messages', 'inps_messages'], 'extraDocuments': ['Address during illness', 'Doctor certificate details', 'Employer communication', 'INPS visit/control notice if any'], 'warnings': ['The doctor normally sends the certificate electronically.', 'The user should provide protocol to employer if needed.', 'Address availability during illness matters for controllo medico fiscale.'], 'outputs': ['sick_leave_checklist', 'message_to_employer_with_protocol', 'inps_certificate_problem_request', 'illness_address_availability_warning']},
      {'id': 'maternity_family_benefit_help', 'title': 'Maternity / family benefit help', 'titleIt': 'Maternità / assegni familiari / benefici famiglia', 'priority': 'medium', 'whatIsIt': 'This page routes users to patronato/INPS help for family-related benefits.', 'whyDoYouNeedIt': ['Maternity', 'Parental leave', 'Assegno unico', 'Family benefits', 'Child-related INPS requests', 'Benefit rejected', 'Missing documents'], 'recommendedChannels': ['patronato', 'inps_online', 'caf'], 'recommendedContacts': ['incaCgilTorino', 'inasCislGeneric', 'cafGeneric', 'inpsTorinoDirezioneProvinciale'], 'documents': ['identity_document', 'codice_fiscale', 'iban', 'employment_contract', 'payslips', 'inps_messages', 'permesso_soggiorno', 'isee_documents'], 'extraDocuments': ['Child/family documents', 'ISEE if relevant', 'Benefit-specific INPS documents', 'Previous application/protocol if any'], 'outputs': ['family_benefit_patronato_email', 'family_benefit_checklist', 'inps_family_benefit_followup']},
      {'id': 'isee_caf_connection', 'title': 'ISEE / CAF connection', 'titleIt': 'ISEE / appuntamento CAF', 'priority': 'medium', 'whatIsIt': 'This page helps users understand when they need CAF instead of patronato.', 'whyDoYouNeedIt': ['ISEE ordinario', 'ISEE corrente', 'University benefits', 'Bonus', 'Housing support', 'Family benefits', 'Social support'], 'recommendedChannels': ['caf'], 'recommendedContacts': ['cafGeneric'], 'documents': ['identity_document', 'codice_fiscale', 'isee_documents', 'rental_contract', 'permesso_soggiorno'], 'extraDocuments': ['Tessera sanitaria', 'Family status', 'Income documents', 'Bank balance/giacenza media', 'Disability documents if relevant', 'University documents if relevant'], 'warnings': ['ISEE is usually handled by CAF, not patronato.', 'If user needs an INPS benefit application after ISEE, route back to patronato/INPS.'], 'outputs': ['caf_appointment_email', 'isee_checklist', 'isee_corrente_warning', 'benefit_to_isee_routing']},
      {'id': 'union_legal_work_dispute_support', 'title': 'Union or legal-work dispute support', 'titleIt': 'Sindacato / vertenza lavoro', 'priority': 'high', 'whatIsIt': 'This page helps users when the issue is not just INPS, but a work dispute.', 'whyDoYouNeedIt': ['Employer did not pay', 'Wrong dismissal', 'TFR missing', 'Contract abuse', 'Fake resignation', 'Harassment or pressure', 'Payslip irregularities', 'Missing contract', 'Need vertenza'], 'recommendedChannels': ['union_support', 'employer_formal_request'], 'recommendedContacts': ['cgilTorino'], 'documents': ['employment_contract', 'payslips', 'employer_messages', 'bank_payments', 'termination_letter'], 'extraDocuments': ['Timesheets', 'Employer details', 'Witness/proof if any', 'Any written threats/pressure', 'Final settlement documents'], 'warnings': ['This may require union/legal assistance.', 'UfficioFacile can help organize evidence and draft first messages, but does not replace legal representation.'], 'outputs': ['union_appointment_email', 'work_dispute_evidence_checklist', 'employer_formal_request', 'legal_help_warning']},
      {'id': 'general_inps_formal_request_pec', 'title': 'General INPS formal request / PEC', 'titleIt': 'Richiesta formale INPS / PEC', 'priority': 'medium', 'whatIsIt': 'This page helps users write a formal request to INPS.', 'whyDoYouNeedIt': ['Follow-up', 'Missing documents', 'Request explanation', 'Blocked application', 'Payment delay', 'Rejected request', 'Protocol update', 'Wrong personal data'], 'recommendedChannels': ['inps_pec', 'inps_online', 'patronato'], 'recommendedContacts': ['inpsTorinoDirezioneProvinciale', 'incaCgilTorino'], 'documents': ['inps_protocol', 'inps_receipt', 'identity_document', 'codice_fiscale', 'inps_messages', 'iban'], 'extraDocuments': ['Relevant attachments', 'Patronato receipt if relevant', 'Screenshots from INPS area if useful'], 'outputs': ['inps_pec_template', 'inps_followup_template', 'inps_payment_delay_request', 'pec_inps_document_integration']},
    ],
    'outputGenerators': [
      {'id': 'correct_work_benefit_route', 'title': 'Correct work/benefit route', 'titleIt': 'Percorso corretto lavoro/benefici', 'outputType': 'guided_summary', 'templateBehavior': 'Based on job-end reason, contract type, last working day, documents available, and whether the user already applied to INPS, recommend NASpI preparation, NASpI follow-up, patronato, CPI/DID, employer document request, union support, or CAF.'},
      {'id': 'naspi_checklist', 'title': 'NASpI checklist', 'titleIt': 'Checklist NASpI', 'outputType': 'checklist', 'items': ['Identity document', 'Codice fiscale', 'IBAN', 'Employment contract', 'Termination letter / contract-end proof', 'Last payslips', 'UNILAV if available', 'CU if available', 'SPID/CIE/CNS if applying online', 'Permesso di soggiorno if non-EU', 'Employer communications', 'Last working day', 'Reason job ended'], 'warning': 'Eligibility must be checked with INPS/patronato. Do not rely only on this checklist.'},
      {'id': 'patronato_appointment_email', 'title': 'Patronato appointment email', 'titleIt': 'Email appuntamento Patronato', 'outputType': 'email', 'sendToOptions': ['torinocentro@inca.it', 'info@inas.it'], 'templateIt': 'Oggetto: Richiesta appuntamento Patronato per [NASpI / pratica INPS]\n\nBuongiorno,\n\nvorrei prendere appuntamento per ricevere assistenza su [NASpI / pratica INPS / altro].\n\nLa mia situazione è la seguente:\n- Nome e cognome: [nome]\n- Codice fiscale: [codice fiscale]\n- Tipo contratto: [tipo contratto]\n- Ultimo giorno di lavoro: [data]\n- Motivo fine rapporto: [licenziamento / fine contratto / apprendistato / altro]\n- Domanda INPS già presentata: [sì/no]\n- Protocollo INPS, se presente: [numero]\n\nDocumenti disponibili:\n[elenco documenti]\n\nChiedo cortesemente di sapere quando è possibile fissare un appuntamento e quali documenti devo portare.\n\nCordiali saluti,\n[Nome Cognome]\nTelefono: [telefono]'},
      {'id': 'naspi_specific_appointment_request', 'title': 'NASpI-specific appointment request', 'titleIt': 'Richiesta appuntamento specifica NASpI', 'outputType': 'email', 'sendToOptions': ['torinocentro@inca.it', 'info@inas.it'], 'templateIt': 'Oggetto: Richiesta appuntamento per domanda NASpI\n\nBuongiorno,\n\nvorrei prendere appuntamento per presentare domanda NASpI.\n\nIl mio rapporto di lavoro è terminato / terminerà in data [data] per [motivo]. Il contratto era di tipo [tipo contratto].\n\nHo disponibili i seguenti documenti:\n- Documento d’identità\n- Codice fiscale\n- IBAN\n- Contratto di lavoro\n- Lettera di fine rapporto/licenziamento\n- Buste paga\n- [altri documenti]\n\nChiedo cortesemente conferma dei documenti necessari e disponibilità per un appuntamento.\n\nCordiali saluti,\n[Nome Cognome]\nTelefono: [telefono]'},
      {'id': 'employer_document_request', 'title': 'Employer document request', 'titleIt': 'Richiesta documenti al datore di lavoro', 'outputType': 'email_or_pec', 'recipient': 'employer', 'templateIt': 'Oggetto: Richiesta documenti di fine rapporto\n\nBuongiorno,\n\nin seguito alla cessazione del rapporto di lavoro in data [data], chiedo cortesemente l’invio della documentazione relativa alla fine del rapporto, in particolare:\n- lettera/comunicazione di cessazione;\n- UNILAV/comunicazione obbligatoria, se disponibile;\n- ultime buste paga;\n- prospetto finale competenze;\n- calcolo TFR, ferie e permessi residui;\n- CU, quando disponibile.\n\nLa documentazione mi serve per verifiche personali e per eventuali pratiche INPS/patronato.\n\nCordiali saluti,\n[Nome Cognome]'},
      {'id': 'did_cpi_reminder', 'title': 'DID/CPI reminder', 'titleIt': 'Promemoria DID/CPI', 'outputType': 'info_card', 'contentIt': 'Per NASpI e stato di disoccupazione possono essere necessari DID, contatto con il Centro per l’Impiego e patto di servizio. Verifica la tua posizione tramite servizi online o con il CPI competente per il tuo indirizzo.'},
      {'id': 'email_to_cpi_appointment', 'title': 'Email to CPI asking appointment', 'titleIt': 'Email appuntamento CPI', 'outputType': 'email', 'sendTo': 'info.cpi.torinonord@agenziapiemontelavoro.it', 'templateIt': 'Oggetto: Richiesta informazioni/appuntamento DID - Centro per l’Impiego\n\nBuongiorno,\n\nvorrei ricevere informazioni / fissare un appuntamento per [DID / patto di servizio / stato occupazionale / altro].\n\nLa mia situazione è la seguente:\n- Nome e cognome: [nome]\n- Codice fiscale: [codice fiscale]\n- Indirizzo di domicilio/residenza: [indirizzo]\n- Ultimo rapporto di lavoro terminato in data: [data]\n- Domanda NASpI presentata: [sì/no]\n\nChiedo cortesemente conferma se questo è il CPI competente per il mio indirizzo e quali documenti devo preparare.\n\nCordiali saluti,\n[Nome Cognome]\nTelefono: [telefono]'},
      {'id': 'message_to_patronato_followup', 'title': 'Message to patronato follow-up', 'titleIt': 'Messaggio al Patronato per controllo pratica', 'outputType': 'email_or_message', 'recipient': 'patronato', 'templateIt': 'Buongiorno,\n\nvorrei chiedere un aggiornamento sulla pratica [NASpI / INPS] presentata tramite il vostro patronato.\n\nDati pratica:\n- Nome e cognome: [nome]\n- Codice fiscale: [codice fiscale]\n- Protocollo INPS, se disponibile: [numero]\n- Data presentazione: [data]\n\nRisulta attualmente [in attesa / respinta / richiesta integrazione / pagamento non arrivato].\n\nChiedo cortesemente indicazioni sui prossimi passi.\n\nGrazie,\n[Nome Cognome]'},
      {'id': 'inps_formal_followup', 'title': 'INPS formal follow-up', 'titleIt': 'Follow-up formale INPS', 'outputType': 'pec', 'sendTo': 'direzione.provinciale.torino@postacert.inps.gov.it', 'templateIt': 'Oggetto: Richiesta aggiornamento pratica INPS - Protocollo [numero]\n\nBuongiorno,\n\ncon la presente chiedo un aggiornamento in merito alla pratica [tipo pratica], protocollo [numero], presentata in data [data].\n\nLa pratica risulta attualmente [stato pratica] e avrei necessità di conoscere eventuali documenti mancanti o ulteriori passaggi richiesti.\n\nAllego copia della ricevuta/domanda e documentazione utile.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]'},
      {'id': 'pec_inps_document_integration', 'title': 'PEC INPS document integration', 'titleIt': 'PEC integrazione documenti INPS', 'outputType': 'pec', 'sendTo': 'direzione.provinciale.torino@postacert.inps.gov.it', 'templateIt': 'Oggetto: Integrazione documenti pratica INPS - Protocollo [numero]\n\nBuongiorno,\n\nin riferimento alla pratica [tipo pratica], protocollo [numero], invio in allegato la documentazione integrativa richiesta / mancante.\n\nDocumenti allegati:\n[elenco documenti]\n\nChiedo cortesemente conferma della ricezione e aggiornamento sullo stato della pratica.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]'},
      {'id': 'naspi_payment_delay_request', 'title': 'NASpI payment delay request', 'titleIt': 'Richiesta ritardo pagamento NASpI', 'outputType': 'pec_or_email', 'sendTo': 'direzione.provinciale.torino@postacert.inps.gov.it', 'templateIt': 'Oggetto: Richiesta verifica pagamento NASpI - Protocollo [numero]\n\nBuongiorno,\n\nchiedo cortesemente una verifica sul pagamento della domanda NASpI protocollo [numero], presentata in data [data].\n\nAd oggi il pagamento risulta [non ricevuto / bloccato / parziale] e vorrei sapere se sono presenti problemi relativi a IBAN, documentazione, DID/CPI o altri controlli.\n\nAllego ricevuta della domanda e documentazione disponibile.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]'},
      {'id': 'rejected_inps_reply_pec', 'title': 'Rejected INPS reply PEC', 'titleIt': 'PEC risposta domanda INPS respinta', 'outputType': 'pec', 'sendTo': 'direzione.provinciale.torino@postacert.inps.gov.it', 'templateIt': 'Oggetto: Richiesta riesame pratica INPS respinta - Protocollo [numero]\n\nBuongiorno,\n\ncon riferimento alla pratica [tipo pratica], protocollo [numero], ho ricevuto comunicazione di rigetto/sospensione per il seguente motivo: [motivo indicato da INPS].\n\nCon la presente chiedo cortesemente il riesame della pratica e allego la documentazione integrativa a supporto:\n[elenco documenti]\n\nResto disponibile per eventuali ulteriori chiarimenti o integrazioni.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]'},
      {'id': 'message_to_patronato_rejected_request', 'title': 'Message to patronato for rejected request', 'titleIt': 'Messaggio Patronato per domanda respinta', 'outputType': 'email_or_message', 'recipient': 'patronato', 'templateIt': 'Buongiorno,\n\nla mia pratica INPS [tipo pratica], protocollo [numero], risulta respinta/sospesa per il seguente motivo: [motivo].\n\nVorrei chiedere supporto per capire se è possibile integrare documenti o richiedere riesame.\n\nDocumenti disponibili:\n[elenco]\n\nPotete indicarmi come procedere e se è necessario fissare un appuntamento?\n\nGrazie,\n[Nome Cognome]\nTelefono: [telefono]'},
      {'id': 'employer_payment_request', 'title': 'Employer payment request', 'titleIt': 'Richiesta pagamento datore di lavoro', 'outputType': 'email_or_pec', 'recipient': 'employer', 'templateIt': 'Oggetto: Richiesta pagamento competenze di fine rapporto\n\nBuongiorno,\n\nin riferimento al rapporto di lavoro terminato in data [data], chiedo cortesemente la verifica e il pagamento delle competenze ancora dovute, in particolare:\n- stipendio/mensilità di [mese];\n- TFR;\n- ferie/permessi residui;\n- eventuali altre competenze di fine rapporto.\n\nChiedo inoltre l’invio del relativo prospetto di calcolo e delle buste paga/documenti mancanti.\n\nResto in attesa di riscontro scritto.\n\nCordiali saluti,\n[Nome Cognome]'},
      {'id': 'union_appointment_email', 'title': 'Union appointment email', 'titleIt': 'Email appuntamento sindacato', 'outputType': 'email', 'sendTo': 'torino@cgiltorino.it', 'templateIt': 'Oggetto: Richiesta appuntamento per problema di lavoro\n\nBuongiorno,\n\nvorrei chiedere un appuntamento per ricevere supporto su un problema relativo al rapporto di lavoro.\n\nLa situazione è la seguente:\n- Tipo problema: [stipendio non pagato / TFR / licenziamento / busta paga / contratto / altro]\n- Datore di lavoro: [nome azienda]\n- Periodo di lavoro: [date]\n- Rapporto terminato: [sì/no]\n- Documenti disponibili: [contratto, buste paga, messaggi, bonifici, lettera, ecc.]\n\nChiedo cortesemente di sapere quando posso fissare un appuntamento e quali documenti devo portare.\n\nCordiali saluti,\n[Nome Cognome]\nTelefono: [telefono]'},
      {'id': 'work_dispute_evidence_checklist', 'title': 'Work dispute evidence checklist', 'titleIt': 'Checklist prove vertenza lavoro', 'outputType': 'checklist', 'items': ['Employment contract', 'Payslips', 'Bank transfers/payments', 'Termination letter', 'Employer messages', 'Timesheets', 'TFR/ferie/permessi records', 'CU if available', 'Company details', 'Any witnesses/proof']},
      {'id': 'sick_leave_checklist', 'title': 'Sick leave checklist', 'titleIt': 'Checklist malattia', 'outputType': 'checklist', 'items': ['Contact doctor', 'Doctor sends certificate electronically', 'Save medical certificate protocol number', 'Send protocol to employer if required', 'Check address during illness', 'Be available for possible medical control visit', 'Check INPS messages if problems appear']},
      {'id': 'message_to_employer_with_protocol', 'title': 'Message to employer with sick leave protocol', 'titleIt': 'Messaggio datore con protocollo malattia', 'outputType': 'message', 'recipient': 'employer', 'templateIt': 'Buongiorno,\n\ncomunico che sono in malattia dal [data] al [data].\n\nIl numero di protocollo del certificato medico è: [protocollo].\n\nResto a disposizione per eventuali comunicazioni.\n\nCordiali saluti,\n[Nome]'},
      {'id': 'caf_appointment_email', 'title': 'CAF appointment email', 'titleIt': 'Email appuntamento CAF', 'outputType': 'email', 'recipient': 'CAF', 'templateIt': 'Oggetto: Richiesta appuntamento CAF per ISEE\n\nBuongiorno,\n\nvorrei prendere appuntamento per la preparazione dell’ISEE [ordinario/corrente].\n\nLa mia situazione è la seguente:\n- Nome e cognome: [nome]\n- Motivo ISEE: [università / bonus / affitto / famiglia / altro]\n- Nucleo familiare: [numero persone]\n\nVorrei sapere quali documenti devo portare e quando è possibile fissare un appuntamento.\n\nCordiali saluti,\n[Nome Cognome]\nTelefono: [telefono]'},
      {'id': 'isee_checklist', 'title': 'ISEE checklist', 'titleIt': 'Checklist ISEE', 'outputType': 'checklist', 'items': ['Identity document', 'Codice fiscale/tessera sanitaria', 'Family status information', 'Income documents', 'Bank balance and giacenza media', 'Rental contract if applicable', 'Property/vehicle information if applicable', 'Disability documents if relevant', 'University documents if relevant']},
      {'id': 'inps_pec_template', 'title': 'INPS PEC template', 'titleIt': 'Modello PEC INPS', 'outputType': 'pec', 'sendTo': 'direzione.provinciale.torino@postacert.inps.gov.it', 'templateIt': 'Oggetto: Richiesta formale INPS - [tipo pratica]\n\nBuongiorno,\n\ncon la presente chiedo verifica / aggiornamento / chiarimenti in merito alla pratica [tipo pratica], protocollo [numero], relativa a [descrizione breve].\n\nDati richiedente:\n- Nome e cognome: [nome]\n- Codice fiscale: [codice fiscale]\n- Recapito telefonico: [telefono]\n- Email: [email]\n\nDescrizione richiesta:\n[spiegare chiaramente il problema]\n\nAllego la documentazione disponibile:\n[elenco allegati]\n\nResto in attesa di riscontro.\n\nCordiali saluti,\n[Nome Cognome]'},
    ],
    'routingRules': [
      {'if': {'problem_type': 'not_sure_job_loss'}, 'routeTo': 'understand_job_loss_benefit_situation'},
      {'if': {'problem_type': 'naspi_prepare'}, 'routeTo': 'naspi_preparation'},
      {'if': {'problem_type': 'naspi_followup'}, 'routeTo': 'naspi_application_followup'},
      {'if': {'problem_type': 'did_cpi'}, 'routeTo': 'did_and_centro_impiego'},
      {'if': {'problem_type': 'patronato_appointment'}, 'routeTo': 'patronato_appointment_request'},
      {'if': {'problem_type': 'inps_contact'}, 'routeTo': 'inps_appointment_contact_request'},
      {'if': {'problem_type': 'inps_rejected'}, 'routeTo': 'reply_rejected_inps_request'},
      {'if': {'problem_type': 'missing_documents'}, 'routeTo': 'missing_documents_integration'},
      {'if': {'problem_type': 'employer_documents'}, 'routeTo': 'employer_termination_contract_end_documents'},
      {'if': {'problem_type': 'salary_tfr_problem'}, 'routeTo': 'payslip_tfr_final_payment_problem'},
      {'if': {'problem_type': 'sick_leave'}, 'routeTo': 'sick_leave_malattia_inps_basics'},
      {'if': {'problem_type': 'family_benefits'}, 'routeTo': 'maternity_family_benefit_help'},
      {'if': {'problem_type': 'isee_caf'}, 'routeTo': 'isee_caf_connection'},
      {'if': {'problem_type': 'work_dispute'}, 'routeTo': 'union_legal_work_dispute_support'},
      {'if': {'problem_type': 'inps_formal_pec'}, 'routeTo': 'general_inps_formal_request_pec'},
      {'if': {'already_applied_inps': 'through_patronato'}, 'routeTo': 'naspi_application_followup', 'note': 'If patronato submitted the request, first contact patronato with receipt/protocol.'},
      {'if': {'job_end_reason': 'resignation', 'problem_type': 'naspi_prepare'}, 'routeTo': 'understand_job_loss_benefit_situation', 'note': 'Voluntary resignation needs careful eligibility check before NASpI.'},
      {'if': {'problem_type': 'naspi_prepare', 'preferred_channel': 'patronato'}, 'routeTo': 'patronato_appointment_request'},
    ],
  });

  static RichCategorySubcategory? forProcedureId(String procedureId) {
    final subcategoryId = _procedureToSubcategory[procedureId];
    if (subcategoryId == null) return null;
    for (final item in category.subcategories) {
      if (item.id == subcategoryId) return item;
    }
    return null;
  }
}

const Map<String, String> _procedureToSubcategory = {
  'UNDERSTAND_JOB_LOSS_BENEFIT_SITUATION': 'understand_job_loss_benefit_situation',
  'NASPI_PREPARATION': 'naspi_preparation',
  'NASPI_APPLICATION_FOLLOWUP': 'naspi_application_followup',
  'DID_AND_CENTRO_IMPIEGO': 'did_and_centro_impiego',
  'PATRONATO_APPOINTMENT_REQUEST': 'patronato_appointment_request',
  'INPS_APPOINTMENT_CONTACT_REQUEST': 'inps_appointment_contact_request',
  'REPLY_REJECTED_INPS_REQUEST': 'reply_rejected_inps_request',
  'MISSING_DOCUMENTS_INTEGRATION': 'missing_documents_integration',
  'EMPLOYER_TERMINATION_CONTRACT_END_DOCUMENTS': 'employer_termination_contract_end_documents',
  'PAYSLIP_TFR_FINAL_PAYMENT_PROBLEM': 'payslip_tfr_final_payment_problem',
  'SICK_LEAVE_MALATTIA_INPS_BASICS': 'sick_leave_malattia_inps_basics',
  'MATERNITY_FAMILY_BENEFIT_HELP': 'maternity_family_benefit_help',
  'ISEE_CAF_CONNECTION': 'isee_caf_connection',
  'UNION_LEGAL_WORK_DISPUTE_SUPPORT': 'union_legal_work_dispute_support',
  'GENERAL_INPS_FORMAL_REQUEST_PEC': 'general_inps_formal_request_pec',
};
