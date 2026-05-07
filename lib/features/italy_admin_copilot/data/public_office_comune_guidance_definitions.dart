import '../domain/rich_category_models.dart';

class PublicOfficeComuneGuidanceDefinitions {
  static final RichCategoryGuidance category = RichCategoryGuidance.fromMap({
    'id': 'public_office_comune',
    'title': 'Public Office / Comune',
    'titleIt': 'Comune / Uffici pubblici',
    'region': 'piemonte',
    'city': 'torino',
    'shortDescription':
        'Help users handle Comune and Anagrafe procedures in Torino: residenza, cambio indirizzo, temporary residence, rejected residence requests, anagrafe certificates, stato di famiglia, residence certificate, autocertificazione, appointments, PEC requests, and online service problems.',
    'mainUserQuestion':
        'What do I need from Comune or Anagrafe, and should I use ANPR, Comune di Torino online services, email, PEC, appointment, or in-person office?',
    'routingLogicSummary':
        'First identify whether the user needs residenza, cambio indirizzo inside Torino, temporary residence, a certificate, self-certification, an appointment, a formal PEC, or help with a rejected/blocked request. Then show only the relevant flow, documents, contacts, warnings, and generator buttons.',
    'topWarning':
        'Start from what you need so you can see the right Comune or Anagrafe office, document, and contact channel.',
    'officialReferences': {
      'comuneTorinoAnagrafe': {
        'label': 'Comune di Torino - Sedi anagrafiche e orari',
        'url':
            'https://www.comune.torino.it/schede-informative/sedi-anagrafiche-orari',
      },
      'comuneTorinoAppointment': {
        'label': 'Comune di Torino - Prenota un appuntamento',
        'url': 'https://www.comune.torino.it/servizi/prenota-un-appuntamento',
      },
      'temporaryResidence': {
        'label': 'Comune di Torino - Registro popolazione temporanea',
        'url':
            'https://www.comune.torino.it/servizi/richiedere-liscrizione-nel-registro-della-popolazione-temporanea',
      },
      'certificates': {
        'label': 'Comune di Torino - Richiedere un certificato',
        'url': 'https://www.comune.torino.it/servizi/richiedere-un-certificato',
      },
      'anprCertificates': {
        'label': 'ANPR - Certificati ed estratti',
        'url':
            'https://www.anagrafenazionale.interno.it/area-cittadino/certificati/',
      },
    },
    'contacts': {
      'anagrafeTorinoGeneral': {
        'id': 'anagrafe_torino_general',
        'name': 'Comune di Torino - Anagrafe',
        'address': 'Anagrafe Centrale, Via della Consolata 23, Torino',
        'phone': '011 011 25380',
        'openingHours': 'Monday to Friday, 08:00-18:00',
        'email': 'info.anagrafe@comune.torino.it',
        'pec': 'Servizi.Civici@cert.comune.torino.it',
        'access':
            'Generally Monday to Thursday 08:15-15:00, Friday 08:15-13:50. Verify before going.',
        'useFor': [
          'residenza information',
          'cambio indirizzo',
          'anagrafe appointments',
          'general anagrafe information',
          'formal PEC to Comune/Anagrafe',
          'rejected or blocked anagrafe requests',
        ],
        'warning':
            'Use normal email for information. Use PEC for formal/protocol communication, missing-document integration, or rejected-request replies.',
      },
      'residenzaTemporaneaTorino': {
        'id': 'residenza_temporanea_torino',
        'name': 'Comune di Torino - Residenza temporanea',
        'address': 'Anagrafe Centrale, Via della Consolata 23, Torino',
        'email': 'residenzatemporanea@comune.torino.it',
        'pec': 'Servizi.Civici@cert.comune.torino.it',
        'useFor': [
          'temporary residence',
          'registro popolazione temporanea',
          'appointment request for temporary residence',
          'documents for temporary stay in Torino',
        ],
        'warning':
            'Temporary residence is different from ordinary residenza. It is for people temporarily living in Torino without transferring habitual residence.',
      },
      'anpr': {
        'id': 'anpr',
        'name': 'ANPR - Anagrafe Nazionale Popolazione Residente',
        'url': 'https://www.anagrafenazionale.interno.it/',
        'useFor': [
          'online anagrafe certificates',
          'residence certificate',
          'family status certificate',
          'civil status certificates/extracts when available',
          'online residence transfer services where available',
        ],
        'warning':
            'Use SPID/CIE/CNS. Not every historical or special certificate may be available online.',
      },
      'comuneAppointmentService': {
        'id': 'comune_torino_appointment_service',
        'name': 'Comune di Torino - Prenota un appuntamento',
        'url': 'https://www.comune.torino.it/servizi/prenota-un-appuntamento',
        'phone': '800 450 900',
        'useFor': [
          'booking appointment at enabled offices',
          'checking available counters',
          'remote/online appointment where available',
        ],
        'warning':
            'Use the current Comune appointment page first. The legacy Sportello Facile page references 800 450 900 for assistance.',
      },
      'historicCertificatesTorino': {
        'id': 'historic_certificates_torino',
        'name': 'Comune di Torino - Certificati storici',
        'email': 'cert.storici@comune.torino.it',
        'useFor': [
          'historical residence certificate before 1 November 1989',
          'historical citizenship certificate before 1 November 1989',
          'historical family status certificate before 1 November 1989',
        ],
        'warning':
            'Use only for historical certificates that match the Comune instructions.',
      },
    },
    'channelRules': [
      {
        'id': 'anpr_online',
        'label': 'Use ANPR online',
        'labelIt': 'Usa ANPR online',
        'priority': 'primary_for_certificates',
        'useWhen': [
          'current anagrafe certificate',
          'residence certificate',
          'family status certificate',
          'civil status certificate/extract when available',
          'user has SPID/CIE/CNS',
        ],
        'warning':
            'For many certificates, ANPR is faster than going to Comune. Historical or special certificates may require Comune channels.',
      },
      {
        'id': 'comune_online_service',
        'label': 'Use Comune online service',
        'labelIt': 'Usa servizio online Comune',
        'priority': 'primary_when_available',
        'useWhen': [
          'change residence',
          'change address inside Torino',
          'appointment booking',
          'online Comune procedure',
        ],
        'warning':
            'If the online service fails, route to online service problem report or Anagrafe email.',
      },
      {
        'id': 'normal_email',
        'label': 'Send normal email to Anagrafe',
        'labelIt': 'Invia email normale all’Anagrafe',
        'priority': 'information',
        'email': 'info.anagrafe@comune.torino.it',
        'useWhen': [
          'asking for information',
          'asking which procedure applies',
          'asking which documents are needed',
          'asking appointment help',
          'unclear case',
        ],
        'warning':
            'Normal email is for information. For formal protocol-level communication, use PEC.',
      },
      {
        'id': 'pec_formal',
        'label': 'Send PEC to Comune',
        'labelIt': 'Invia PEC al Comune',
        'priority': 'formal',
        'pec': 'Servizi.Civici@cert.comune.torino.it',
        'useWhen': [
          'formal request',
          'missing document integration',
          'reply to rejected or suspended request',
          'follow-up with protocol number',
          'official complaint',
          'formal appointment request',
        ],
        'warning':
            'Use PEC when the user has PEC and needs formal proof/protocol communication.',
      },
      {
        'id': 'in_person_anagrafe',
        'label': 'Go in person to Anagrafe',
        'labelIt': 'Vai allo sportello Anagrafe',
        'priority': 'when_needed',
        'useWhen': [
          'appointment required',
          'online service unavailable',
          'complex case',
          'documents must be checked',
          'temporary residence by appointment',
          'user cannot use SPID/CIE/CNS',
        ],
        'warning':
            'Verify office hours and appointment requirement before going.',
      },
      {
        'id': 'appointment',
        'label': 'Book appointment',
        'labelIt': 'Prenota appuntamento',
        'priority': 'when_counter_needed',
        'useWhen': [
          'in-person service required',
          'temporary residence appointment',
          'complex anagrafe procedure',
          'user needs office support',
        ],
      },
    ],
    'commonDocuments': [
      {
        'id': 'identity_document',
        'label': 'Identity document',
        'labelIt': 'Documento d’identità',
      },
      {
        'id': 'codice_fiscale',
        'label': 'Codice fiscale',
        'labelIt': 'Codice fiscale',
      },
      {
        'id': 'rental_contract',
        'label': 'Rental contract',
        'labelIt': 'Contratto di affitto',
      },
      {
        'id': 'hospitality_declaration',
        'label': 'Hospitality declaration',
        'labelIt': 'Dichiarazione di ospitalità',
      },
      {
        'id': 'property_deed',
        'label': 'Property deed / ownership proof',
        'labelIt': 'Atto di proprietà / prova proprietà',
      },
      {
        'id': 'permesso_soggiorno',
        'label': 'Permesso di soggiorno if non-EU',
        'labelIt': 'Permesso di soggiorno se extra-UE',
      },
      {
        'id': 'passport_or_eu_id',
        'label': 'Passport or EU ID card if foreign citizen',
        'labelIt': 'Passaporto o documento UE se cittadino straniero',
      },
      {
        'id': 'protocol_number',
        'label': 'Protocol number',
        'labelIt': 'Numero di protocollo',
      },
      {
        'id': 'rejection_message',
        'label': 'Rejection/suspension message',
        'labelIt': 'Messaggio di rigetto/sospensione',
      },
      {
        'id': 'spid_cie_cns',
        'label': 'SPID / CIE / CNS',
        'labelIt': 'SPID / CIE / CNS',
      },
      {
        'id': 'proof_of_address',
        'label': 'Proof of address',
        'labelIt': 'Prova dell’indirizzo',
      },
      {
        'id': 'doorbell_mailbox_photo',
        'label': 'Doorbell/mailbox photo',
        'labelIt': 'Foto citofono/cassetta postale',
      },
      {
        'id': 'marca_da_bollo',
        'label': 'Marca da bollo if required',
        'labelIt': 'Marca da bollo se richiesta',
      },
      {
        'id': 'delegation',
        'label': 'Delegation if requesting for another person',
        'labelIt': 'Delega se richiedi per un’altra persona',
      },
    ],
    'firstScreenQuestions': [
      {
        'id': 'need_type',
        'question': 'What do you need from Comune / Anagrafe?',
        'questionIt': 'Cosa ti serve dal Comune / Anagrafe?',
        'type': 'single_choice',
        'options': [
          {'id': 'not_sure', 'label': 'I am not sure'},
          {
            'id': 'move_to_torino',
            'label': 'I moved to Torino from another Comune or abroad',
          },
          {
            'id': 'move_inside_torino',
            'label': 'I changed address inside Torino',
          },
          {
            'id': 'temporary_stay',
            'label': 'I am only temporarily living in Torino',
          },
          {
            'id': 'residenza_rejected',
            'label': 'My residenza request was rejected/suspended',
          },
          {
            'id': 'certificate_general',
            'label': 'I need an Anagrafe certificate',
          },
          {'id': 'stato_famiglia', 'label': 'I need stato di famiglia'},
          {
            'id': 'residence_certificate',
            'label': 'I need certificato di residenza',
          },
          {'id': 'self_certification', 'label': 'I need self-certification'},
          {'id': 'appointment', 'label': 'I need an appointment'},
          {'id': 'formal_pec', 'label': 'I need to send PEC/formal request'},
          {'id': 'online_problem', 'label': 'The online service does not work'},
          {
            'id': 'doorbell_address_proof',
            'label': 'I need doorbell/mailbox/address proof help',
          },
          {'id': 'general_information', 'label': 'I need general information'},
        ],
      },
      {
        'id': 'already_resident_torino',
        'question': 'Are you already resident in Torino?',
        'questionIt': 'Sei già residente a Torino?',
        'type': 'single_choice',
        'options': [
          {'id': 'yes', 'label': 'Yes'},
          {'id': 'no', 'label': 'No'},
          {'id': 'not_sure', 'label': 'Not sure'},
        ],
      },
      {
        'id': 'origin',
        'question': 'Where are you moving from?',
        'questionIt': 'Da dove ti stai trasferendo?',
        'type': 'single_choice',
        'options': [
          {'id': 'another_italian_comune', 'label': 'Another Italian Comune'},
          {'id': 'abroad', 'label': 'From abroad'},
          {'id': 'inside_torino', 'label': 'Inside Torino'},
          {'id': 'not_moving', 'label': 'Not moving'},
        ],
      },
      {
        'id': 'has_housing_proof',
        'question':
            'Do you have rental contract, ownership proof, or hospitality declaration?',
        'questionIt':
            'Hai contratto di affitto, proprietà o dichiarazione di ospitalità?',
        'type': 'single_choice',
        'options': [
          {'id': 'rental_contract', 'label': 'Rental contract'},
          {'id': 'ownership', 'label': 'Ownership proof'},
          {'id': 'hospitality', 'label': 'Hospitality declaration'},
          {'id': 'no', 'label': 'No'},
          {'id': 'not_sure', 'label': 'Not sure'},
        ],
      },
      {
        'id': 'citizenship_status',
        'question': 'Are you Italian, EU, or non-EU?',
        'questionIt': 'Sei cittadino italiano, UE o extra-UE?',
        'type': 'single_choice',
        'options': [
          {'id': 'italian', 'label': 'Italian'},
          {'id': 'eu', 'label': 'EU'},
          {'id': 'non_eu', 'label': 'Non-EU'},
        ],
      },
      {
        'id': 'has_permesso',
        'question': 'Do you have permesso di soggiorno?',
        'questionIt': 'Hai il permesso di soggiorno?',
        'type': 'single_choice',
        'showWhen': {'citizenship_status': 'non_eu'},
        'options': [
          {'id': 'yes', 'label': 'Yes'},
          {'id': 'renewal_receipt', 'label': 'Renewal/application receipt'},
          {'id': 'no', 'label': 'No'},
          {'id': 'not_applicable', 'label': 'Not applicable'},
        ],
      },
      {
        'id': 'has_spid',
        'question': 'Do you have SPID/CIE/CNS?',
        'questionIt': 'Hai SPID/CIE/CNS?',
        'type': 'single_choice',
        'options': [
          {'id': 'yes', 'label': 'Yes'},
          {'id': 'no', 'label': 'No'},
        ],
      },
      {
        'id': 'has_protocol',
        'question': 'Do you have a protocol number?',
        'questionIt': 'Hai un numero di protocollo?',
        'type': 'single_choice',
        'options': [
          {'id': 'yes', 'label': 'Yes'},
          {'id': 'no', 'label': 'No'},
        ],
      },
      {
        'id': 'certificate_recipient',
        'question': 'Who is asking for the certificate?',
        'questionIt': 'Chi ti chiede il certificato?',
        'type': 'single_choice',
        'options': [
          {'id': 'public_office', 'label': 'Italian public office'},
          {'id': 'private_company', 'label': 'Private company'},
          {'id': 'foreign_authority', 'label': 'Foreign authority'},
          {'id': 'not_sure', 'label': 'Not sure'},
        ],
      },
    ],
    'subcategories': [
      {
        'id': 'understand_residenza_domicilio_temporary',
        'title': 'Understand residenza, domicilio, and temporary residence',
        'titleIt': 'Capire residenza, domicilio e residenza temporanea',
        'priority': 'high',
        'whatIsIt':
            'This page helps users understand which Comune procedure they actually need: residenza, cambio indirizzo, domicilio, temporary residence, certificate, or self-certification.',
        'whyDoYouNeedIt': [
          'User says they need residenza but may only need a certificate',
          'User is temporarily living in Torino',
          'User is moving inside Torino',
          'User moved from another Comune or abroad',
          'User needs proof for ASL, EDISU, permesso, employer, bank, or another office',
          'User does not know whether autocertificazione is enough',
        ],
        'recommendedChannels': ['normal_email'],
        'recommendedContacts': ['anagrafeTorinoGeneral'],
        'documents': [
          'identity_document',
          'codice_fiscale',
          'rental_contract',
          'hospitality_declaration',
          'permesso_soggiorno',
        ],
        'extraDocuments': [
          'Previous Comune/residence details',
          'Family members moving with user',
          'Address details',
          'Reason/use of document',
        ],
        'warnings': [
          'Do not route everyone directly to residenza.',
          'If you only need proof for an Italian public office, autocertificazione may be enough.',
          'If you are temporarily living in Torino without transferring habitual residence, temporary residence may be more appropriate.',
        ],
        'outputs': [
          'correct_procedure_recommendation',
          'comune_document_checklist',
          'certificate_vs_self_certification_explanation',
          'general_anagrafe_information_email',
        ],
      },
      {
        'id': 'change_residence_from_another_comune_or_abroad',
        'title': 'Change residence from another Comune or from abroad',
        'titleIt': 'Cambio residenza da altro Comune o dall’estero',
        'priority': 'high',
        'whatIsIt':
            'This is for users who move to Torino from another Italian municipality or from abroad and want to register their residence in Torino.',
        'whyDoYouNeedIt': [
          'Moving to Torino',
          'Starting work or study in Torino',
          'Need residenza for documents',
          'Need access to local services',
          'Need family doctor/ASL support',
          'Need permesso/immigration paperwork',
          'Need ISEE/benefits',
        ],
        'recommendedChannels': [
          'comune_online_service',
          'normal_email',
          'pec_formal',
          'appointment',
        ],
        'recommendedContacts': [
          'anagrafeTorinoGeneral',
          'comuneAppointmentService',
        ],
        'documents': [
          'identity_document',
          'codice_fiscale',
          'rental_contract',
          'hospitality_declaration',
          'property_deed',
          'permesso_soggiorno',
          'passport_or_eu_id',
        ],
        'extraDocuments': [
          'Declaration form',
          'Address details: street, number, apartment or unit, floor, staircase',
          'Data of all people moving',
          'Vehicle plate if applicable',
          'Driving licence details if requested',
          'Previous Comune or foreign address',
        ],
        'warnings': [
          'Submit the declaration after actually moving into the home.',
          'Comune di Torino states residence change after moving must be declared within 20 days.',
          'Name on doorbell/mailbox matters because checks may fail if the person cannot be found.',
          'False residence declarations can create legal problems.',
        ],
        'outputs': [
          'residence_change_checklist',
          'email_to_anagrafe_procedure_documents',
          'pec_missing_documents_integration',
          'doorbell_mailbox_checklist',
          'rejected_residenza_reply',
        ],
      },
      {
        'id': 'change_address_inside_torino',
        'title': 'Change address inside Torino',
        'titleIt': 'Cambio indirizzo dentro Torino',
        'priority': 'high',
        'whatIsIt':
            'This is for someone already resident in Torino who moves to another address inside Torino.',
        'whyDoYouNeedIt': [
          'New apartment in Torino',
          'Changed room or house',
          'Need updated address for Comune',
          'Need updated address for documents, ASL, bank, employer',
          'Need correct address for public-office communications',
        ],
        'recommendedChannels': [
          'comune_online_service',
          'normal_email',
          'pec_formal',
          'appointment',
        ],
        'recommendedContacts': [
          'anagrafeTorinoGeneral',
          'comuneAppointmentService',
        ],
        'documents': [
          'identity_document',
          'codice_fiscale',
          'rental_contract',
          'hospitality_declaration',
          'property_deed',
          'permesso_soggiorno',
        ],
        'extraDocuments': [
          'Current Torino residence address',
          'New address',
          'Family members moving with user',
          'Vehicle/driving information if requested',
        ],
        'warnings': [
          'Use this only if the user is already resident in Torino.',
          'If moving from another Comune or abroad, route to change_residence_from_another_comune_or_abroad.',
        ],
        'outputs': [
          'change_address_checklist',
          'comune_online_service_guide',
          'email_to_anagrafe_procedure_documents',
          'pec_missing_documents_integration',
        ],
      },
      {
        'id': 'temporary_residence_popolazione_temporanea',
        'title': 'Temporary residence / popolazione temporanea',
        'titleIt': 'Residenza temporanea / popolazione temporanea',
        'priority': 'medium',
        'whatIsIt':
            'This is for people temporarily living in Torino who do not want or cannot transfer permanent residence.',
        'whyDoYouNeedIt': [
          'Student temporarily in Torino',
          'Worker temporarily in Torino',
          'Person staying for medium-term reasons',
          'Need administrative recognition without full residenza transfer',
          'User is not transferring habitual residence',
        ],
        'recommendedChannels': [
          'normal_email',
          'pec_formal',
          'appointment',
          'in_person_anagrafe',
        ],
        'recommendedContacts': [
          'residenzaTemporaneaTorino',
          'anagrafeTorinoGeneral',
        ],
        'documents': [
          'identity_document',
          'codice_fiscale',
          'rental_contract',
          'hospitality_declaration',
          'permesso_soggiorno',
          'passport_or_eu_id',
        ],
        'extraDocuments': [
          'Proof of temporary stay',
          'Reason for temporary stay',
          'Permanent residence address elsewhere',
          'Any form required by Comune',
        ],
        'warnings': [
          'Temporary residence is not ordinary residenza.',
          'Comune di Torino accepts request by email, PEC, or in person at Anagrafe Centrale by appointment requested by email.',
          'Temporary population registration may not give the same certificates/rights as ordinary residence.',
        ],
        'outputs': [
          'temporary_residence_checklist',
          'temporary_residence_email',
          'temporary_residence_pec_checklist',
          'temporary_residence_appointment_request',
        ],
      },
      {
        'id': 'doorbell_mailbox_address_proof',
        'title': 'Add name to doorbell / mailbox / address proof',
        'titleIt': 'Nome su citofono / cassetta postale / prova abitazione',
        'priority': 'medium',
        'whatIsIt':
            'This page helps users prepare for residence checks and proof of address.',
        'whyDoYouNeedIt': [
          'Name is not on doorbell',
          'Name is not on mailbox',
          'Address details are incomplete',
          'Internal/floor/staircase not clear',
          'Landlord/host did not provide documents',
          'User cannot prove they actually live there',
          'Comune or police check may fail',
        ],
        'documents': [
          'rental_contract',
          'hospitality_declaration',
          'identity_document',
          'doorbell_mailbox_photo',
          'proof_of_address',
        ],
        'extraDocuments': [
          'Landlord/host ID if relevant',
          'Address details',
          'Messages with landlord/host',
          'Condominium/administrator confirmation if available',
        ],
        'warnings': [
          'This is preparation support, not a Comune submission by itself.',
          'If residence request was already rejected/suspended, route to rejected_residenza_request_reply.',
        ],
        'outputs': [
          'doorbell_mailbox_checklist',
          'message_to_landlord_host',
          'address_proof_checklist',
          'residence_check_preparation',
        ],
      },
      {
        'id': 'rejected_residenza_request_reply',
        'title': 'Reply to rejected residenza request',
        'titleIt': 'Risposta a richiesta residenza respinta',
        'priority': 'high',
        'whatIsIt':
            'This page helps users reply when Comune rejects, suspends, or asks for integration on a residenza/cambio indirizzo request.',
        'whyDoYouNeedIt': [
          'Missing rental contract',
          'Missing hospitality declaration',
          'Missing ID',
          'Missing permesso di soggiorno',
          'Address not found',
          'Name not on doorbell',
          'Police/Comune check failed',
          'Landlord/host documents missing',
          'Incomplete form',
          'Wrong procedure used',
        ],
        'recommendedChannels': ['pec_formal', 'normal_email'],
        'recommendedContacts': ['anagrafeTorinoGeneral'],
        'documents': [
          'rejection_message',
          'protocol_number',
          'identity_document',
          'codice_fiscale',
          'rental_contract',
          'hospitality_declaration',
          'permesso_soggiorno',
          'doorbell_mailbox_photo',
        ],
        'extraDocuments': [
          'Any missing documents requested by Comune',
          'Proof of address',
          'Messages with landlord/host',
          'Updated form if required',
        ],
        'warnings': [
          'Use PEC for formal integration/reply when possible.',
          'If you do not understand what is missing, start with a normal email asking for clarification.',
        ],
        'outputs': [
          'pec_residenza_integration',
          'email_ask_missing_documents',
          'rejected_residenza_reply',
          'residenza_rejection_document_checklist',
        ],
      },
      {
        'id': 'anagrafe_certificate_request',
        'title': 'Anagrafe certificate request',
        'titleIt': 'Richiedere certificato anagrafico',
        'priority': 'high',
        'whatIsIt':
            'This page helps users request official demographic/anagrafe certificates.',
        'whyDoYouNeedIt': [
          'Need residence certificate',
          'Need family status',
          'Need citizenship certificate',
          'Need civil status certificate',
          'Need historical certificate',
          'Need certificate for private company or foreign authority',
        ],
        'recommendedChannels': [
          'anpr_online',
          'in_person_anagrafe',
          'appointment',
        ],
        'recommendedContacts': [
          'anpr',
          'anagrafeTorinoGeneral',
          'historicCertificatesTorino',
        ],
        'documents': [
          'identity_document',
          'codice_fiscale',
          'spid_cie_cns',
          'marca_da_bollo',
          'delegation',
        ],
        'extraDocuments': [
          'Reason/use of certificate',
          'Recipient office/company/authority',
          'Data of person certificate refers to',
          'Historical period if historical certificate',
        ],
        'warnings': [
          'For many current certificates, ANPR is the fastest channel.',
          'For many Italian public offices, autocertificazione may be enough.',
          'Historical certificates may require specific Comune email/channel.',
        ],
        'outputs': [
          'certificate_request_checklist',
          'anpr_guide',
          'in_person_certificate_checklist',
          'appointment_checklist',
          'email_which_certificate_needed',
        ],
      },
      {
        'id': 'family_status_certificate',
        'title': 'Family status / stato di famiglia certificate',
        'titleIt': 'Certificato stato di famiglia',
        'priority': 'medium',
        'whatIsIt':
            'This is a specific certificate showing the people registered in the same family household.',
        'whyDoYouNeedIt': [
          'ISEE',
          'benefits',
          'school or university procedures',
          'housing',
          'bank or insurance',
          'foreign documents',
          'public-office request',
        ],
        'recommendedChannels': [
          'anpr_online',
          'in_person_anagrafe',
          'appointment',
        ],
        'recommendedContacts': ['anpr', 'anagrafeTorinoGeneral'],
        'documents': [
          'spid_cie_cns',
          'identity_document',
          'codice_fiscale',
          'marca_da_bollo',
        ],
        'extraDocuments': [
          'Reason/use',
          'Recipient office/company/authority',
          'Delegation if requesting for another person',
        ],
        'warnings': [
          'If the recipient is an Italian public office, autocertificazione may be enough.',
          'Roommates are not automatically the same family household.',
        ],
        'outputs': [
          'stato_famiglia_checklist',
          'anpr_download_guide',
          'autocertificazione_alternative_warning',
        ],
      },
      {
        'id': 'residence_certificate',
        'title': 'Residence certificate / certificato di residenza',
        'titleIt': 'Certificato di residenza',
        'priority': 'medium',
        'whatIsIt':
            'This certificate proves where a person is officially resident.',
        'whyDoYouNeedIt': [
          'Bank',
          'employer',
          'foreign authority',
          'school/university',
          'housing procedure',
          'private company',
          'some public-office cases',
        ],
        'recommendedChannels': [
          'anpr_online',
          'in_person_anagrafe',
          'appointment',
        ],
        'recommendedContacts': ['anpr', 'anagrafeTorinoGeneral'],
        'documents': [
          'spid_cie_cns',
          'identity_document',
          'codice_fiscale',
          'marca_da_bollo',
        ],
        'extraDocuments': [
          'Reason/use',
          'Recipient office/company/authority',
          'Delegation if requesting for another person',
        ],
        'warnings': [
          'For many Italian public offices, an autocertificazione may be enough instead of paying for a certificate.',
          'If you are not officially resident at that address yet, the certificate will not solve the issue. Use the residenza or cambio indirizzo flow first.',
        ],
        'outputs': [
          'residence_certificate_checklist',
          'anpr_download_guide',
          'autocertificazione_alternative',
          'appointment_checklist',
        ],
      },
      {
        'id': 'self_certification_autocertificazione',
        'title': 'Self-certification / autocertificazione',
        'titleIt': 'Autocertificazione',
        'priority': 'medium',
        'whatIsIt':
            'This page helps users understand when they can use self-certification instead of requesting an official certificate.',
        'whyDoYouNeedIt': [
          'User wants to avoid paying for unnecessary certificate',
          'Italian public office asks for information user can self-certify',
          'User needs declaration of residence, family status, birth, citizenship, or similar data',
          'User is unsure whether a certificate is required',
        ],
        'documents': ['identity_document', 'codice_fiscale'],
        'extraDocuments': [
          'Correct personal data to declare',
          'Recipient office',
          'Reason/use',
        ],
        'warnings': [
          'Do not use autocertificazione for every private or foreign authority.',
          'Some private companies or foreign authorities may require official certificates.',
          'False declarations can create legal problems.',
        ],
        'outputs': [
          'autocertificazione_template',
          'when_not_to_use_autocertificazione',
          'certificate_vs_self_certification_explanation',
        ],
      },
      {
        'id': 'book_anagrafe_appointment',
        'title': 'Book an Anagrafe appointment',
        'titleIt': 'Prenotare appuntamento Anagrafe',
        'priority': 'medium',
        'whatIsIt':
            'This page helps users book an appointment with Comune/Anagrafe.',
        'whyDoYouNeedIt': [
          'User needs counter support',
          'User cannot complete online service',
          'Complex procedure',
          'Temporary residence appointment',
          'Need help with an existing practice',
          'Need to bring documents in person',
        ],
        'recommendedChannels': ['appointment', 'normal_email'],
        'recommendedContacts': [
          'comuneAppointmentService',
          'anagrafeTorinoGeneral',
        ],
        'documents': ['identity_document', 'codice_fiscale', 'protocol_number'],
        'extraDocuments': [
          'Type of service needed',
          'Relevant documents for appointment',
          'Existing protocol number if any',
          'Screenshot/error if online problem',
        ],
        'warnings': [
          'Some offices may offer remote/online appointments.',
          'Verify the service and office before going.',
        ],
        'outputs': [
          'appointment_checklist',
          'email_appointment_help',
          'what_to_bring_checklist',
        ],
      },
      {
        'id': 'pec_formal_request_comune',
        'title': 'PEC or formal request to Comune',
        'titleIt': 'PEC o richiesta formale al Comune',
        'priority': 'medium',
        'whatIsIt':
            'This page helps users write a formal request to Comune/Anagrafe.',
        'whyDoYouNeedIt': [
          'Missing document integration',
          'Follow-up on protocol',
          'Request clarification',
          'Complaint about blocked practice',
          'Formal appointment request',
          'Rejected request reply',
        ],
        'recommendedChannels': ['pec_formal', 'normal_email'],
        'recommendedContacts': ['anagrafeTorinoGeneral'],
        'documents': [
          'protocol_number',
          'identity_document',
          'codice_fiscale',
          'rejection_message',
        ],
        'extraDocuments': [
          'Relevant attachments',
          'Previous Comune message',
          'Proof of submission',
          'Clear description of request',
        ],
        'warnings': [
          'Use PEC for formal/protocol communication.',
          'Use normal email for simple information requests.',
        ],
        'outputs': [
          'comune_pec_template',
          'normal_email_template',
          'followup_protocol_template',
          'missing_document_integration_template',
        ],
      },
      {
        'id': 'online_comune_service_problem',
        'title': 'Report problem with online Comune service',
        'titleIt': 'Problema con servizio online Comune',
        'priority': 'medium',
        'whatIsIt':
            'This page helps users report problems with Torino online Comune/Anagrafe services.',
        'whyDoYouNeedIt': [
          'SPID login problem',
          'service error',
          'upload not working',
          'appointment booking error',
          'form blocked',
          'payment problem',
          'cannot download certificate',
          'residenza request stuck',
        ],
        'recommendedChannels': ['normal_email', 'appointment'],
        'recommendedContacts': [
          'anagrafeTorinoGeneral',
          'comuneAppointmentService',
        ],
        'documents': [
          'screenshots',
          'protocol_number',
          'identity_document',
          'codice_fiscale',
        ],
        'extraDocuments': [
          'Screenshot of error',
          'Date/time',
          'SPID/CIE method used',
          'Service name',
          'Browser/device information',
        ],
        'warnings': [
          'Do not send sensitive passwords or SPID credentials.',
          'Include screenshots and exact service name.',
        ],
        'outputs': [
          'technical_issue_report',
          'screenshot_checklist',
          'email_to_anagrafe_support',
        ],
      },
      {
        'id': 'general_comune_information_request',
        'title': 'General Comune information request',
        'titleIt': 'Richiesta informazioni generica al Comune',
        'priority': 'low',
        'whatIsIt':
            'This page helps users ask Comune/Anagrafe what to do when they are unsure.',
        'whyDoYouNeedIt': [
          'User is unsure which procedure applies',
          'User has mixed residence/certificate/document problem',
          'User needs to ask which documents to prepare',
          'User needs office/contact direction',
        ],
        'recommendedChannels': ['normal_email', 'pec_formal'],
        'recommendedContacts': ['anagrafeTorinoGeneral'],
        'documents': ['identity_document', 'codice_fiscale', 'protocol_number'],
        'extraDocuments': [
          'Short description of case',
          'Address',
          'Relevant attachments',
          'Previous protocol if any',
        ],
        'warnings': [
          'Use normal email for information.',
          'Use PEC only if formal/protocol communication is needed.',
        ],
        'outputs': [
          'short_information_request_email',
          'formal_pec_if_needed',
          'appointment_request',
        ],
      },
    ],
    'outputGenerators': [
      {
        'id': 'correct_procedure_recommendation',
        'title': 'Correct procedure recommendation',
        'titleIt': 'Consiglio sulla procedura corretta',
        'outputType': 'guided_summary',
        'templateBehavior':
            'Based on the user’s answers, explain whether they need ordinary residenza, change address inside Torino, temporary residence, certificate, self-certification, appointment, or PEC/formal request.',
      },
      {
        'id': 'comune_document_checklist',
        'title': 'Comune document checklist',
        'titleIt': 'Checklist documenti Comune',
        'outputType': 'checklist',
        'items': [
          'Identity document',
          'Codice fiscale',
          'Rental contract / property proof / hospitality declaration',
          'Address details',
          'Permesso di soggiorno if non-EU',
          'Passport or EU ID if foreign citizen',
          'Protocol number if existing practice',
          'Any Comune message if request is blocked/rejected',
        ],
      },
      {
        'id': 'residence_change_checklist',
        'title': 'Residence change checklist',
        'titleIt': 'Checklist cambio residenza',
        'outputType': 'checklist',
        'items': [
          'Identity document',
          'Codice fiscale',
          'Rental contract, ownership proof, or hospitality declaration',
          'Complete address: street, number, apartment or unit, floor, staircase',
          'Data of all people moving',
          'Permesso di soggiorno if non-EU',
          'Passport/EU ID if foreign citizen',
          'Doorbell/mailbox name visible',
          'Vehicle plate/driving details if requested',
          'Submit after actually moving into the home',
        ],
        'warning':
            'Comune di Torino states residence change after moving must be declared within 20 days.',
      },
      {
        'id': 'email_to_anagrafe_procedure_documents',
        'title': 'Email asking Anagrafe procedure/documents',
        'titleIt': 'Email per chiedere procedura/documenti all’Anagrafe',
        'outputType': 'email',
        'sendTo': 'info.anagrafe@comune.torino.it',
        'templateIt':
            'Oggetto: Richiesta informazioni su pratica anagrafica\n\nBuongiorno,\n\nvorrei chiedere informazioni sulla procedura corretta per [cambio residenza / cambio indirizzo / certificato / altro].\n\nLa mia situazione è la seguente:\n- Nome e cognome: [nome]\n- Cittadinanza: [italiana/UE/extra-UE]\n- Indirizzo attuale: [indirizzo]\n- Nuovo indirizzo, se applicabile: [indirizzo]\n- Sono già residente a Torino: [sì/no]\n- Documenti disponibili: [contratto affitto / ospitalità / permesso / altro]\n\nVorrei sapere quale procedura devo seguire e quali documenti devo preparare.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
      },
      {
        'id': 'pec_missing_documents_integration',
        'title': 'PEC missing documents integration',
        'titleIt': 'PEC integrazione documenti mancanti',
        'outputType': 'pec',
        'sendTo': 'Servizi.Civici@cert.comune.torino.it',
        'templateIt':
            'Oggetto: Integrazione documenti pratica anagrafica - Protocollo [numero]\n\nBuongiorno,\n\nin riferimento alla pratica anagrafica relativa a [tipo pratica], presentata in data [data], protocollo [numero protocollo], invio in allegato la documentazione integrativa richiesta.\n\nDocumenti allegati:\n[elenco documenti]\n\nChiedo cortesemente di confermare la ricezione e di procedere con la valutazione della pratica.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]',
      },
      {
        'id': 'doorbell_mailbox_checklist',
        'title': 'Doorbell/mailbox checklist',
        'titleIt': 'Checklist citofono/cassetta postale',
        'outputType': 'checklist',
        'items': [
          'Name visible on doorbell',
          'Name visible on mailbox',
          'Correct street number',
          'Correct apartment or unit, floor, and staircase details',
          'Landlord/host aware of possible residence check',
          'Photo of doorbell/mailbox',
          'Rental contract or hospitality declaration ready',
        ],
        'warning':
            'Residence checks may fail if Comune/police cannot find the person at the declared address.',
      },
      {
        'id': 'message_to_landlord_host',
        'title': 'Message to landlord/host',
        'titleIt': 'Messaggio a proprietario/ospitante',
        'outputType': 'message',
        'recipient': 'landlord_or_host',
        'templateIt':
            'Buongiorno,\n\nper completare la pratica di residenza/cambio indirizzo ho bisogno che il mio nome sia visibile sul citofono e sulla cassetta postale dell’abitazione in [indirizzo].\n\nPuò aiutarmi ad aggiungerlo o indicarmi come procedere con il condominio/amministratore?\n\nGrazie,\n[Nome]',
      },
      {
        'id': 'temporary_residence_checklist',
        'title': 'Temporary residence checklist',
        'titleIt': 'Checklist residenza temporanea',
        'outputType': 'checklist',
        'items': [
          'Identity document',
          'Codice fiscale',
          'Proof of temporary stay in Torino',
          'Rental contract or hospitality declaration',
          'Reason for temporary stay',
          'Permanent residence address elsewhere',
          'Permesso di soggiorno if non-EU',
          'Passport/ID if foreign citizen',
          'Send to residenzatemporanea@comune.torino.it or PEC, or request appointment',
        ],
      },
      {
        'id': 'temporary_residence_email',
        'title': 'Temporary residence email',
        'titleIt': 'Email residenza temporanea',
        'outputType': 'email',
        'sendTo': 'residenzatemporanea@comune.torino.it',
        'templateIt':
            'Oggetto: Richiesta iscrizione registro popolazione temporanea\n\nBuongiorno,\n\nvorrei richiedere informazioni / presentare richiesta di iscrizione nel registro della popolazione temporanea del Comune di Torino.\n\nLa mia situazione è la seguente:\n- Nome e cognome: [nome]\n- Codice fiscale: [codice fiscale]\n- Cittadinanza: [italiana/UE/extra-UE]\n- Residenza permanente: [Comune/Paese]\n- Domicilio temporaneo a Torino: [indirizzo]\n- Motivo della permanenza temporanea: [studio/lavoro/altro]\n- Periodo previsto: [date]\n\nAllego / posso allegare: [documenti].\n\nChiedo cortesemente indicazioni sulla documentazione necessaria e sulla modalità di presentazione.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
      },
      {
        'id': 'rejected_residenza_reply',
        'title': 'Rejected residenza reply',
        'titleIt': 'Risposta a residenza respinta/sospesa',
        'outputType': 'pec_or_email',
        'sendTo': 'Servizi.Civici@cert.comune.torino.it',
        'templateIt':
            'Oggetto: Richiesta riesame / integrazione pratica residenza - Protocollo [numero]\n\nBuongiorno,\n\ncon riferimento alla mia pratica di [residenza / cambio indirizzo], protocollo [numero], ho ricevuto comunicazione di [rigetto / sospensione / richiesta integrazione] per il seguente motivo: [motivo indicato].\n\nCon la presente invio la documentazione aggiornata/integrativa:\n[elenco documenti]\n\nChiedo cortesemente il riesame della pratica e resto disponibile per eventuali ulteriori chiarimenti.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]',
      },
      {
        'id': 'certificate_request_checklist',
        'title': 'Certificate request checklist',
        'titleIt': 'Checklist richiesta certificato',
        'outputType': 'checklist',
        'items': [
          'Identify exact certificate needed',
          'Check if ANPR can issue it online',
          'SPID/CIE/CNS for online request',
          'Identity document and codice fiscale',
          'Check if marca da bollo is required',
          'Check if autocertificazione is enough for Italian public office',
          'For historical certificates, use specific Comune channel if needed',
        ],
      },
      {
        'id': 'anpr_guide',
        'title': 'ANPR guide',
        'titleIt': 'Guida ANPR',
        'outputType': 'info_card',
        'contentIt':
            'Per molti certificati anagrafici attuali puoi usare ANPR con SPID/CIE/CNS. Accedi al portale ANPR, scegli il certificato, verifica eventuale bollo, scarica il PDF e conserva il file. Se il certificato è storico o non disponibile online, usa i canali del Comune.',
      },
      {
        'id': 'autocertificazione_template',
        'title': 'Autocertificazione template',
        'titleIt': 'Modello autocertificazione',
        'outputType': 'document_template',
        'templateIt':
            'DICHIARAZIONE SOSTITUTIVA DI CERTIFICAZIONE\n\nIo sottoscritto/a [Nome Cognome], nato/a a [luogo] il [data], codice fiscale [codice fiscale], residente in [indirizzo], consapevole delle responsabilità previste in caso di dichiarazioni false,\n\nDICHIARO\n\n[contenuto della dichiarazione: residenza / stato di famiglia / altro]\n\nLa presente dichiarazione è resa per uso [indicare uso/destinatario].\n\nLuogo e data: [luogo, data]\nFirma: [firma]\n\nAllego copia del documento d’identità se richiesto.',
      },
      {
        'id': 'when_not_to_use_autocertificazione',
        'title': 'When not to use autocertificazione',
        'titleIt': 'Quando non usare autocertificazione',
        'outputType': 'warning_card',
        'contentIt':
            'L’autocertificazione non è sempre accettata da soggetti privati o autorità estere. Se il destinatario richiede espressamente un certificato ufficiale, apostille, traduzione o legalizzazione, verifica prima di usare l’autocertificazione.',
      },
      {
        'id': 'appointment_checklist',
        'title': 'Appointment checklist',
        'titleIt': 'Checklist appuntamento Anagrafe',
        'outputType': 'checklist',
        'items': [
          'Choose correct service',
          'Book through Comune appointment service if required',
          'Bring identity document',
          'Bring codice fiscale',
          'Bring protocol number if existing practice',
          'Bring all procedure-specific documents',
          'Verify address, office, date and time',
          'Check whether appointment is in person or remote',
        ],
      },
      {
        'id': 'email_appointment_help',
        'title': 'Email asking appointment help',
        'titleIt': 'Email richiesta aiuto appuntamento',
        'outputType': 'email',
        'sendTo': 'info.anagrafe@comune.torino.it',
        'templateIt':
            'Oggetto: Richiesta informazioni per appuntamento Anagrafe\n\nBuongiorno,\n\nvorrei prenotare un appuntamento per [tipo servizio], ma ho bisogno di capire quale sportello/procedura scegliere.\n\nLa mia situazione è la seguente:\n[descrivere brevemente]\n\nHo disponibili i seguenti documenti:\n[elenco]\n\nChiedo cortesemente indicazioni su come prenotare correttamente e cosa portare.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
      },
      {
        'id': 'comune_pec_template',
        'title': 'Comune PEC template',
        'titleIt': 'Modello PEC Comune',
        'outputType': 'pec',
        'sendTo': 'Servizi.Civici@cert.comune.torino.it',
        'templateIt':
            'Oggetto: Richiesta formale - [tipo pratica]\n\nBuongiorno,\n\ncon la presente chiedo informazioni / intervento / verifica in merito a [tipo pratica], relativa a [descrizione breve].\n\nDati pratica, se disponibili:\n- Protocollo: [numero]\n- Data presentazione: [data]\n- Servizio interessato: [Anagrafe / altro]\n\nDescrizione richiesta:\n[spiegare chiaramente]\n\nAllego la documentazione disponibile:\n[elenco allegati]\n\nResto in attesa di riscontro.\n\nCordiali saluti,\n[Nome Cognome]\nCodice fiscale: [codice fiscale]\nTelefono: [telefono]\nEmail: [email]',
      },
      {
        'id': 'technical_issue_report',
        'title': 'Technical issue report',
        'titleIt': 'Segnalazione problema servizio online',
        'outputType': 'email',
        'sendTo': 'info.anagrafe@comune.torino.it',
        'templateIt':
            'Oggetto: Segnalazione problema servizio online Comune/Anagrafe\n\nBuongiorno,\n\nsegnalo un problema con il servizio online [nome servizio].\n\nDettagli:\n- Data e ora del problema: [data/ora]\n- Metodo di accesso: [SPID/CIE/CNS]\n- Browser/dispositivo: [browser/dispositivo]\n- Messaggio di errore: [testo errore]\n- Protocollo, se presente: [numero]\n\nAllego screenshot del problema.\n\nChiedo cortesemente indicazioni su come procedere.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
      },
      {
        'id': 'short_information_request_email',
        'title': 'Short information request email',
        'titleIt': 'Email breve richiesta informazioni',
        'outputType': 'email',
        'sendTo': 'info.anagrafe@comune.torino.it',
        'templateIt':
            'Oggetto: Richiesta informazioni Anagrafe\n\nBuongiorno,\n\nvorrei chiedere informazioni sulla procedura corretta per il mio caso.\n\nDescrizione breve:\n[spiegare situazione]\n\nVorrei sapere quale servizio devo usare, se è necessario appuntamento e quali documenti devo preparare.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
      },
    ],
    'routingRules': [
      {
        'if': {'need_type': 'not_sure'},
        'routeTo': 'understand_residenza_domicilio_temporary',
      },
      {
        'if': {'need_type': 'move_to_torino'},
        'routeTo': 'change_residence_from_another_comune_or_abroad',
      },
      {
        'if': {'need_type': 'move_inside_torino'},
        'routeTo': 'change_address_inside_torino',
      },
      {
        'if': {'need_type': 'temporary_stay'},
        'routeTo': 'temporary_residence_popolazione_temporanea',
      },
      {
        'if': {'need_type': 'residenza_rejected'},
        'routeTo': 'rejected_residenza_request_reply',
      },
      {
        'if': {'need_type': 'certificate_general'},
        'routeTo': 'anagrafe_certificate_request',
      },
      {
        'if': {'need_type': 'stato_famiglia'},
        'routeTo': 'family_status_certificate',
      },
      {
        'if': {'need_type': 'residence_certificate'},
        'routeTo': 'residence_certificate',
      },
      {
        'if': {'need_type': 'self_certification'},
        'routeTo': 'self_certification_autocertificazione',
      },
      {
        'if': {'need_type': 'appointment'},
        'routeTo': 'book_anagrafe_appointment',
      },
      {
        'if': {'need_type': 'formal_pec'},
        'routeTo': 'pec_formal_request_comune',
      },
      {
        'if': {'need_type': 'online_problem'},
        'routeTo': 'online_comune_service_problem',
      },
      {
        'if': {'need_type': 'doorbell_address_proof'},
        'routeTo': 'doorbell_mailbox_address_proof',
      },
      {
        'if': {'need_type': 'general_information'},
        'routeTo': 'general_comune_information_request',
      },
      {
        'if': {'origin': 'inside_torino', 'already_resident_torino': 'yes'},
        'routeTo': 'change_address_inside_torino',
      },
      {
        'if': {'origin': 'another_italian_comune'},
        'routeTo': 'change_residence_from_another_comune_or_abroad',
      },
      {
        'if': {'origin': 'abroad'},
        'routeTo': 'change_residence_from_another_comune_or_abroad',
      },
      {
        'if': {'certificate_recipient': 'public_office'},
        'routeTo': 'self_certification_autocertificazione',
        'note':
            'For many Italian public offices, autocertificazione may be enough; show warning and allow user to continue to certificate if needed.',
      },
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
  'UNDERSTAND_RESIDENZA_DOMICILIO_TEMPORARY':
      'understand_residenza_domicilio_temporary',
  'CHANGE_RESIDENCE_FROM_ANOTHER_COMUNE_OR_ABROAD':
      'change_residence_from_another_comune_or_abroad',
  'CHANGE_ADDRESS_INSIDE_TORINO': 'change_address_inside_torino',
  'TEMPORARY_RESIDENCE_POPOLAZIONE_TEMPORANEA':
      'temporary_residence_popolazione_temporanea',
  'DOORBELL_MAILBOX_ADDRESS_PROOF': 'doorbell_mailbox_address_proof',
  'REJECTED_RESIDENZA_REQUEST_REPLY': 'rejected_residenza_request_reply',
  'ANAGRAFE_CERTIFICATE_REQUEST': 'anagrafe_certificate_request',
  'FAMILY_STATUS_CERTIFICATE': 'family_status_certificate',
  'RESIDENCE_CERTIFICATE': 'residence_certificate',
  'SELF_CERTIFICATION_AUTOCERTIFICAZIONE':
      'self_certification_autocertificazione',
  'BOOK_ANAGRAFE_APPOINTMENT': 'book_anagrafe_appointment',
  'PEC_FORMAL_REQUEST_COMUNE': 'pec_formal_request_comune',
  'ONLINE_COMUNE_SERVICE_PROBLEM': 'online_comune_service_problem',
  'GENERAL_COMUNE_INFORMATION_REQUEST': 'general_comune_information_request',
  'COMUNE_RESIDENCE_REQUEST': 'understand_residenza_domicilio_temporary',
};
