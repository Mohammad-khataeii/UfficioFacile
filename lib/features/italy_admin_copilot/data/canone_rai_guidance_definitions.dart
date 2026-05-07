import '../domain/canone_rai_guidance.dart';

final RichCategoryGuidance canoneRaiTorino = RichCategoryGuidance.fromMap({
  'id': 'canone_rai',
  'title': 'Canone RAI',
  'titleIt': 'Canone RAI',
  'region': 'italy',
  'city': 'torino',
  'shortDescription':
      'Help users understand whether they must pay Canone RAI, submit a no-TV declaration, request over-75 exemption, ask for refund, handle wrong charges, and choose the correct Agenzia Entrate form and submission channel.',
  'mainUserQuestion':
      'Do I have to pay Canone RAI, and if not, which declaration, exemption, refund request, or form should I use?',
  'routingLogicSummary':
      'Canone RAI flows are handled through Agenzia delle Entrate. The app should first identify the user’s situation: no TV, over 75, wrong charge, duplicate charge, someone in the same family household already pays, diplomatic/military exemption, new home/electricity contract change, or general form help. Then show only the relevant flow, deadlines, documents, submission channels, and generator buttons.',
  'topWarning':
      'Do not show all forms, all deadlines, and all contacts together. First ask the user’s situation, then show only the relevant Canone RAI flow.',
  'officialReferences': {
    'mainPage': {
      'label': 'Agenzia Entrate - Canone TV',
      'url':
          'https://www.agenziaentrate.gov.it/portale/schede/agevolazioni/canone-tv',
    },
    'noTvDeclaration': {
      'label': 'Dichiarazione sostitutiva Canone TV',
      'url':
          'https://www.agenziaentrate.gov.it/portale/schede/agevolazioni/canone-tv/dichiarazione-sostitutiva-canone-tv',
    },
    'noTvOnlineSubmission': {
      'label': 'Dichiarazione sostitutiva - invio online',
      'url':
          'https://www.agenziaentrate.gov.it/portale/schede/agevolazioni/canone-tv/dichiarazione-sostitutiva-invio-online',
    },
    'formsAndInstructions': {
      'label': 'Canone TV - Modelli e istruzioni',
      'url':
          'https://www.agenziaentrate.gov.it/portale/schede/agevolazioni/canone-tv/modelli-e-istruzioni-canone-tv',
    },
    'refundWrongCharge': {
      'label': 'Rimborso Canone TV addebitato nelle fatture elettriche',
      'url':
          'https://www.agenziaentrate.gov.it/portale/schede/agevolazioni/canone-tv/richiesta-di-rimborso-del-canone-tv-bolletta',
    },
  },
  'contacts': {
    'agenziaEntrateCanoneTvTorino': {
      'id': 'agenzia_entrate_canone_tv_torino',
      'name':
          'Agenzia delle Entrate - Direzione Provinciale I di Torino - Ufficio Canone TV',
      'postalAddress':
          'Agenzia delle Entrate - Direzione Provinciale I di Torino - Ufficio Canone TV - Casella postale 22 - 10121 Torino',
      'physicalOfficeAddress': 'Via Giovanni Carlo Cavalli 6, 10138 Torino',
      'email': 'dp.itorino.ufficiocanonetv@agenziaentrate.it',
      'pec': 'DP.1TORINO@PCE.AGENZIAENTRATE.IT',
      'useFor': [
        'Canone TV office information',
        'questions about Canone RAI procedures',
        'Torino Canone TV office reference',
      ],
      'warning':
          'For official no-TV declaration by post, use the Casella postale 22 address. For digitally signed no-TV declarations by PEC, use the specific Canone TV PEC channel if applicable.',
    },
    'noTvDeclarationPec': {
      'id': 'no_tv_declaration_pec',
      'name': 'PEC for digitally signed no-TV declaration',
      'pec': 'cp22.canonetv@postacertificata.rai.it',
      'useFor': [
        'no-TV declaration sent by PEC',
        'only when the declaration is digitally signed',
        'same deadline rules as other submission channels',
      ],
      'warning':
          'Use this PEC only if the form is digitally signed and the current official instructions confirm this channel for the chosen model.',
    },
    'cafOrIntermediary': {
      'id': 'caf_or_intermediary',
      'name': 'CAF / authorized intermediary',
      'useFor': [
        'online submission by intermediary',
        'elderly users',
        'users unsure which form to use',
        'refund/wrong charge cases',
        'over-75 exemption',
        'complex household cases',
      ],
      'warning':
          'Useful when the user is not comfortable with Agenzia Entrate online services or when the household/payment situation is unclear.',
    },
    'electricitySupplierGeneric': {
      'id': 'electricity_supplier_generic',
      'name': 'Electricity supplier',
      'nameIt': 'Fornitore luce',
      'useFor': [
        'understanding where the Canone was charged on the bill',
        'asking for bill clarification',
        'checking bill line items',
      ],
      'warning':
          'The supplier cannot decide Canone eligibility. Exemption/refund procedures are handled through Agenzia Entrate.',
    },
  },
  'channelRules': [
    {
      'id': 'agenzia_entrate_online',
      'label': 'Submit online through Agenzia Entrate',
      'labelIt': 'Invio online tramite Agenzia Entrate',
      'priority': 'primary_if_user_has_access',
      'useWhen': [
        'no-TV declaration',
        'refund request if online service available',
        'user has SPID/CIE/CNS or Agenzia Entrate access',
        'user is confident using official online services',
      ],
      'warning':
          'Use the official Agenzia Entrate service for the specific Canone TV model.',
    },
    {
      'id': 'intermediary_caf',
      'label': 'Submit through CAF/intermediary',
      'labelIt': 'Invio tramite CAF/intermediario',
      'priority': 'recommended_for_complex_or_elderly_users',
      'useWhen': [
        'over-75 exemption',
        'elderly user',
        'refund/wrong charge',
        'complex family household case',
        'user does not understand which form to use',
        'user cannot use online services',
      ],
    },
    {
      'id': 'registered_mail',
      'label': 'Send by registered mail',
      'labelIt': 'Invio con raccomandata',
      'priority': 'official_paper_channel',
      'address':
          'Agenzia delle Entrate - Direzione Provinciale I di Torino - Ufficio Canone TV - Casella postale 22 - 10121 Torino',
      'useWhen': [
        'no-TV declaration',
        'paper form submission',
        'user cannot submit online',
        'user wants a paper channel',
      ],
      'warning':
          'Send the signed form with a copy of a valid identity document. Follow the official instructions for the selected form.',
    },
    {
      'id': 'pec_digitally_signed',
      'label': 'Send by PEC with digital signature',
      'labelIt': 'Invio via PEC con firma digitale',
      'priority': 'only_if_digitally_signed',
      'pec': 'cp22.canonetv@postacertificata.rai.it',
      'useWhen': [
        'no-TV declaration digitally signed',
        'user has PEC',
        'user has digital signature',
      ],
      'warning':
          'Do not suggest PEC if the user cannot digitally sign the form, unless the official instructions for that exact model allow it.',
    },
    {
      'id': 'electricity_supplier_clarification',
      'label': 'Ask electricity supplier for bill clarification',
      'labelIt': 'Chiedi chiarimenti al fornitore luce',
      'priority': 'bill_clarification_only',
      'useWhen': [
        'user does not understand the Canone line on the electricity bill',
        'bill line item unclear',
        'user needs bill copy or payment proof',
      ],
      'warning':
          'The supplier can explain the bill, but Canone exemption/refund eligibility is handled through Agenzia Entrate.',
    },
  ],
  'commonDocuments': [
    {
      'id': 'identity_document',
      'label': 'Identity document',
      'labelIt': 'Documento d’identita',
    },
    {
      'id': 'codice_fiscale',
      'label': 'Codice fiscale',
      'labelIt': 'Codice fiscale',
    },
    {
      'id': 'electricity_bill',
      'label': 'Residential electricity bill',
      'labelIt': 'Bolletta elettrica residenziale',
    },
    {
      'id': 'customer_code',
      'label': 'Electricity customer code',
      'labelIt': 'Codice cliente utenza elettrica',
    },
    {
      'id': 'proof_of_payment',
      'label': 'Proof of payment',
      'labelIt': 'Prova di pagamento',
    },
    {
      'id': 'family_household_info',
      'label': 'Family registry household information',
      'labelIt': 'Informazioni sul nucleo familiare anagrafico',
    },
    {
      'id': 'official_form',
      'label': 'Official Agenzia Entrate form',
      'labelIt': 'Modulo ufficiale Agenzia Entrate',
    },
    {
      'id': 'digital_signature',
      'label': 'Digital signature if sending by PEC',
      'labelIt': 'Firma digitale se invii via PEC',
    },
  ],
  'firstScreenQuestions': [
    {
      'id': 'situation',
      'question': 'What is your situation?',
      'questionIt': 'Qual e la tua situazione?',
      'type': 'single_choice',
      'options': [
        {'id': 'not_sure_if_must_pay', 'label': 'I do not know if I must pay'},
        {'id': 'no_tv', 'label': 'I do not have a TV'},
        {'id': 'over_75', 'label': 'I am over 75'},
        {'id': 'wrong_charge', 'label': 'I was charged but should not pay'},
        {
          'id': 'someone_else_pays',
          'label': 'Someone in my household already pays',
        },
        {
          'id': 'moved_home',
          'label': 'I moved home or changed electricity contract',
        },
        {'id': 'refund_needed', 'label': 'I need a refund'},
        {
          'id': 'diplomatic_military',
          'label': 'I am diplomat / military / international staff',
        },
        {'id': 'form_help', 'label': 'I need help choosing/filling the form'},
      ],
    },
    {
      'id': 'has_tv',
      'question': 'Do you have a TV in the home?',
      'questionIt': 'Hai una TV in casa?',
      'type': 'single_choice',
      'options': [
        {'id': 'yes', 'label': 'Yes'},
        {'id': 'no', 'label': 'No'},
        {'id': 'not_sure', 'label': 'Not sure what counts as TV'},
      ],
    },
    {
      'id': 'electricity_contract_holder',
      'question': 'Is the residential electricity contract in your name?',
      'questionIt': 'Il contratto elettrico residenziale e intestato a te?',
      'type': 'single_choice',
      'options': [
        {'id': 'yes', 'label': 'Yes'},
        {'id': 'no', 'label': 'No'},
        {'id': 'not_sure', 'label': 'Not sure'},
      ],
    },
    {
      'id': 'already_charged',
      'question': 'Was Canone RAI already charged on the electricity bill?',
      'questionIt': 'Il Canone RAI e gia stato addebitato in bolletta?',
      'type': 'single_choice',
      'options': [
        {'id': 'yes', 'label': 'Yes'},
        {'id': 'no', 'label': 'No'},
        {'id': 'not_sure', 'label': 'Not sure'},
      ],
    },
    {
      'id': 'preferred_channel',
      'question': 'How do you want to submit it?',
      'questionIt': 'Come vuoi inviarlo?',
      'type': 'single_choice',
      'options': [
        {'id': 'online', 'label': 'Online'},
        {'id': 'caf', 'label': 'CAF / intermediary'},
        {'id': 'registered_mail', 'label': 'Registered mail'},
        {'id': 'pec', 'label': 'PEC'},
        {'id': 'not_sure', 'label': 'Not sure'},
      ],
    },
  ],
  'subcategories': [
    {
      'id': 'understand_if_must_pay_canone_rai',
      'title': 'Understand if you must pay Canone RAI',
      'titleIt': 'Capire se devi pagare il Canone RAI',
      'priority': 'high',
      'whatIsIt':
          'This page helps the user understand whether they are required to pay Canone RAI or should use an exemption/refund flow.',
      'whyDoYouNeedIt': [
        'User rents a room',
        'Electricity bill is not in user\'s name',
        'User does not own a TV',
        'User only uses laptop, phone, or tablet',
        'User moved home',
        'User shares an apartment',
        'User is over 75',
        'Someone in the same household already pays',
        'User received a wrong charge',
        'Foreign student or worker does not understand the tax',
      ],
      'recommendedContacts': ['cafOrIntermediary'],
      'documents': [
        'electricity_bill',
        'identity_document',
        'codice_fiscale',
        'family_household_info',
      ],
      'extraDocuments': [
        'Income information if over 75',
        'Proof of previous Canone payment if refund is needed',
        'Any Agenzia Entrate form already started',
      ],
      'userQuestions': [
        'Do you have a TV in the house?',
        'Is the electricity contract in your name?',
        'Is it a residential domestic electricity contract?',
        'Are you part of the same family registry household as someone who already pays?',
        'Are you over 75?',
        'Was the Canone already charged?',
        'Do you need exemption or refund?',
      ],
      'warnings': [
        'Do not route everyone directly to no-TV declaration.',
        'If the user has a TV, no-TV declaration is not the correct flow.',
        'If already charged, refund may be needed in addition to exemption/declaration.',
      ],
      'outputs': [
        'eligibility_explanation',
        'correct_subflow_recommendation',
        'canone_document_checklist',
        'deadline_warning_card',
      ],
    },
    {
      'id': 'no_tv_declaration',
      'title': 'No-TV declaration',
      'titleIt': 'Dichiarazione di non detenzione TV',
      'priority': 'high',
      'whatIsIt':
          'This page is for people who have a residential electricity contract in their name but do not own or possess any television in any home connected to their family registry household.',
      'whyDoYouNeedIt': [
        'No TV at home',
        'Only laptop, phone, or tablet',
        'Foreign student or worker renting an apartment',
        'Electricity contract holder but no television',
        'Previous no-TV declaration must be renewed',
      ],
      'recommendedChannels': [
        'agenzia_entrate_online',
        'intermediary_caf',
        'registered_mail',
        'pec_digitally_signed',
      ],
      'recommendedContacts': [
        'agenziaEntrateCanoneTvTorino',
        'noTvDeclarationPec',
        'cafOrIntermediary',
      ],
      'documents': [
        'official_form',
        'identity_document',
        'codice_fiscale',
        'electricity_bill',
        'customer_code',
      ],
      'extraDocuments': [
        'Digital signature if sending by PEC',
        'Proof of registered mail if sending by post',
        'SPID/CIE/CNS or online access if submitting online',
      ],
      'deadlines': [
        {
          'id': 'full_year_exemption',
          'label': 'Full-year exemption',
          'rule':
              'Submit from 1 July of the previous year to 31 January of the reference year for exemption for the whole reference year.',
        },
        {
          'id': 'second_semester_exemption',
          'label': 'Second-semester exemption',
          'rule':
              'Submit from 1 February to 30 June of the reference year for exemption only for the second semester, July to December.',
        },
      ],
      'warnings': [
        'Do not use this form if you have a TV.',
        'Do not use this form just because you do not watch RAI.',
        'The no-TV declaration is normally annual and must be renewed if the condition continues.',
        'For PEC, the form generally needs digital signature.',
      ],
      'outputs': [
        'no_tv_declaration_checklist',
        'deadline_explanation',
        'registered_mail_checklist',
        'pec_submission_warning',
        'caf_appointment_message',
      ],
    },
    {
      'id': 'over_75_exemption',
      'title': 'Over-75 exemption',
      'titleIt': 'Esenzione Canone RAI over 75',
      'priority': 'high',
      'whatIsIt':
          'This page is for people aged 75 or older who may be exempt from paying Canone RAI if they meet the income and household requirements.',
      'whyDoYouNeedIt': [
        'User is over 75',
        'User may have low income',
        'User has been charged Canone RAI but may be exempt',
        'User needs help with form or refund',
        'Family member is helping an elderly person',
      ],
      'recommendedChannels': [
        'intermediary_caf',
        'agenzia_entrate_online',
        'registered_mail',
      ],
      'recommendedContacts': [
        'cafOrIntermediary',
        'agenziaEntrateCanoneTvTorino',
      ],
      'documents': [
        'identity_document',
        'codice_fiscale',
        'electricity_bill',
        'official_form',
        'family_household_info',
      ],
      'extraDocuments': [
        'Income information',
        'Spouse/civil partner income if applicable',
        'Previous Canone payments if refund needed',
        'Any proof required by current official instructions',
      ],
      'configurableRules': {
        'incomeThreshold': {
          'label': 'Income threshold',
          'value': 'CHECK_CURRENT_OFFICIAL_VALUE',
          'warning':
              'Do not hardcode forever. The app should store this as configurable because income thresholds/deadlines can change.',
        },
        'ageRequirement': {
          'label': 'Age requirement',
          'value': '75+',
          'warning':
              'Check exact official timing rules for the reference year before showing final deadline.',
        },
      },
      'warnings': [
        'For elderly users, CAF/intermediary is often safer than self-submission.',
        'If Canone was already paid, user may need refund request in addition to exemption.',
        'Check current Agenzia Entrate instructions before showing exact deadline/date.',
      ],
      'outputs': [
        'over_75_eligibility_checklist',
        'over_75_document_checklist',
        'caf_appointment_message',
        'over_75_refund_recommendation',
      ],
    },
    {
      'id': 'diplomatic_military_exemption',
      'title': 'Diplomatic / military exemption',
      'titleIt': 'Esenzione diplomatici / militari stranieri',
      'priority': 'medium',
      'whatIsIt':
          'This page is for people exempt because of international conventions, such as diplomats, consular officers, certain international organization staff, and some non-Italian military personnel.',
      'whyDoYouNeedIt': [
        'User has diplomatic or consular status',
        'User is non-Italian military personnel covered by exemption',
        'Canone was charged despite exemption',
        'User needs correct official form',
      ],
      'recommendedChannels': [
        'intermediary_caf',
        'agenzia_entrate_online',
        'registered_mail',
      ],
      'recommendedContacts': [
        'agenziaEntrateCanoneTvTorino',
        'cafOrIntermediary',
      ],
      'documents': [
        'identity_document',
        'codice_fiscale',
        'electricity_bill',
        'official_form',
      ],
      'extraDocuments': [
        'Official diplomatic/consular/military status document',
        'Proof of charge if refund requested',
        'Any document required by the official exemption model',
      ],
      'warnings': [
        'The app should not decide diplomatic eligibility alone.',
        'Ask for the user’s official status and route to the official form or intermediary.',
      ],
      'outputs': [
        'diplomatic_exemption_checklist',
        'diplomatic_document_checklist',
        'agenzia_entrate_form_help',
        'refund_recommendation_if_already_charged',
      ],
    },
    {
      'id': 'refund_wrong_charge',
      'title': 'Refund / wrong charge',
      'titleIt': 'Rimborso Canone RAI / addebito non dovuto',
      'priority': 'high',
      'whatIsIt':
          'This page helps users request a refund when Canone RAI was charged but should not have been.',
      'whyDoYouNeedIt': [
        'No-TV declaration was valid but Canone was charged',
        'Over-75 exemption applies',
        'Canone paid twice',
        'Another member of same family registry household already paid',
        'Wrong electricity bill charge',
        'Charge after moving',
        'Diplomatic/military exemption applies',
        'Charge after contract change or closure',
      ],
      'recommendedChannels': [
        'agenzia_entrate_online',
        'intermediary_caf',
        'registered_mail',
      ],
      'recommendedContacts': [
        'agenziaEntrateCanoneTvTorino',
        'cafOrIntermediary',
        'electricitySupplierGeneric',
      ],
      'documents': [
        'electricity_bill',
        'identity_document',
        'codice_fiscale',
        'proof_of_payment',
        'official_form',
      ],
      'extraDocuments': [
        'IBAN if required',
        'Proof of exemption/declaration',
        'Family household information if another member already paid',
        'Contract closure/voltura proof if relevant',
        'Bills from other household member if relevant',
      ],
      'warnings': [
        'The electricity supplier can explain the bill line, but refund/exemption is handled through Agenzia Entrate.',
        'If the user was already charged, exemption alone may not be enough; route to refund.',
      ],
      'outputs': [
        'refund_eligibility_checklist',
        'refund_request_form_checklist',
        'supplier_bill_clarification_message',
        'caf_appointment_message',
      ],
    },
    {
      'id': 'wrong_electricity_bill_charge',
      'title': 'Canone charged on wrong electricity bill',
      'titleIt': 'Canone addebitato sulla bolletta sbagliata',
      'priority': 'medium',
      'whatIsIt':
          'This page is for users whose Canone was charged on the wrong electricity bill or charged when another family member in the same family registry household already pays.',
      'whyDoYouNeedIt': [
        'Two electricity contracts in same family household',
        'Tenant and landlord confusion',
        'User moved home',
        'Spouse already pays',
        'Canone charged in second home',
        'Canone charged after voltura',
        'Canone charged after contract closure',
      ],
      'recommendedChannels': [
        'agenzia_entrate_online',
        'intermediary_caf',
        'electricity_supplier_clarification',
      ],
      'recommendedContacts': [
        'agenziaEntrateCanoneTvTorino',
        'cafOrIntermediary',
        'electricitySupplierGeneric',
      ],
      'documents': [
        'electricity_bill',
        'identity_document',
        'codice_fiscale',
        'family_household_info',
      ],
      'extraDocuments': [
        'All electricity bills involved',
        'Proof another household member paid',
        'Contract closure or voltura proof if relevant',
        'Old and new address',
      ],
      'userQuestions': [
        'Who is the electricity contract holder?',
        'Is it a residential domestic contract?',
        'Who is in the same family registry household?',
        'Has someone in the same household already paid?',
        'Was Canone charged more than once?',
        'Which bill has the charge?',
      ],
      'warnings': [
        'Do not assume roommates are part of the same family registry household.',
        'If there was already a charge, route to refund/wrong charge.',
      ],
      'outputs': [
        'wrong_bill_checklist',
        'refund_flow_recommendation',
        'supplier_bill_clarification_message',
        'caf_appointment_message',
      ],
    },
    {
      'id': 'new_home_changed_electricity_contract',
      'title': 'New home / changed electricity contract',
      'titleIt': 'Nuova casa / cambio intestatario luce',
      'priority': 'medium',
      'whatIsIt':
          'This page helps users understand what happens to Canone RAI when they move, change electricity contract holder, do voltura, or open a new residential electricity contract.',
      'whyDoYouNeedIt': [
        'New apartment',
        'Voltura electricity',
        'Moved abroad',
        'Moved from shared house',
        'Electricity contract changed to tenant’s name',
        'Second home',
        'No TV in new home',
        'Already paying in family household',
      ],
      'recommendedChannels': [
        'agenzia_entrate_online',
        'intermediary_caf',
        'registered_mail',
      ],
      'recommendedContacts': [
        'agenziaEntrateCanoneTvTorino',
        'cafOrIntermediary',
      ],
      'documents': [
        'electricity_bill',
        'identity_document',
        'codice_fiscale',
        'family_household_info',
      ],
      'extraDocuments': [
        'Rental contract',
        'Old and new address',
        'Old and new electricity contract details',
        'Proof of voltura or contract closure if relevant',
      ],
      'userQuestions': [
        'Do you have a TV in the new home?',
        'Is the electricity contract in your name?',
        'Is it residential domestic?',
        'Are you already paying Canone in another household?',
        'Did you move residence or only domicile?',
      ],
      'warnings': [
        'If the user has no TV in the new home and electricity is in their name, route to no-TV declaration.',
        'If the user was already charged wrongly, route to refund/wrong charge.',
      ],
      'outputs': [
        'move_home_canone_checklist',
        'no_tv_declaration_recommendation',
        'refund_recommendation',
        'caf_appointment_message',
      ],
    },
    {
      'id': 'help_filling_agenzia_entrate_form',
      'title': 'Help filling Agenzia Entrate form',
      'titleIt': 'Aiuto compilazione modulo Agenzia Entrate',
      'priority': 'medium',
      'whatIsIt':
          'This page helps users choose and prepare the correct Agenzia Entrate Canone TV form.',
      'whyDoYouNeedIt': [
        'User does not know which form to use',
        'User is confused between exemption and refund',
        'User wants online, post, PEC, or CAF',
        'User has a complex household situation',
        'User needs help preparing documents',
      ],
      'recommendedChannels': [
        'intermediary_caf',
        'agenzia_entrate_online',
        'registered_mail',
        'pec_digitally_signed',
      ],
      'recommendedContacts': [
        'agenziaEntrateCanoneTvTorino',
        'noTvDeclarationPec',
        'cafOrIntermediary',
      ],
      'documents': [
        'identity_document',
        'codice_fiscale',
        'electricity_bill',
        'official_form',
      ],
      'extraDocuments': [
        'Proof of exemption',
        'Proof of charge/payment if refund',
        'Digital signature if PEC',
        'Family household information if relevant',
      ],
      'userQuestions': [
        'What are you trying to do?',
        'Do you have a TV?',
        'Was Canone already charged?',
        'Are you over 75?',
        'Is someone in your family household already paying?',
        'Do you need refund or exemption?',
        'Do you want online, registered mail, PEC, or CAF?',
      ],
      'warnings': [
        'PEC should not be recommended unless the user can digitally sign the form or the official instructions allow PEC for the exact model.',
        'If the user is unsure, CAF/intermediary is safer than choosing the wrong form.',
      ],
      'outputs': [
        'form_selection_wizard',
        'document_checklist',
        'registered_mail_checklist',
        'caf_appointment_message',
        'pec_submission_warning',
      ],
    },
  ],
  'outputGenerators': [
    {
      'id': 'eligibility_explanation',
      'title': 'Eligibility explanation',
      'titleIt': 'Spiegazione obbligo/esenzione',
      'outputType': 'guided_summary',
      'templateBehavior':
          'Generate a short explanation based on whether the user has a TV, whether the electricity contract is in their name, whether Canone was already charged, whether someone in the same family household already pays, and whether they qualify for a special exemption.',
    },
    {
      'id': 'no_tv_declaration_checklist',
      'title': 'No-TV declaration checklist',
      'titleIt': 'Checklist dichiarazione non detenzione TV',
      'outputType': 'checklist',
      'items': [
        'Official Agenzia Entrate no-TV declaration form',
        'Identity document',
        'Codice fiscale',
        'Residential electricity bill/customer code',
        'Choose submission channel: online, CAF/intermediary, registered mail, or digitally signed PEC',
        'Check deadline for full-year or second-semester exemption',
        'Keep proof of submission',
      ],
      'warning':
          'Use only if no TV is possessed by any member of the family registry household in any relevant home.',
    },
    {
      'id': 'deadline_explanation',
      'title': 'Deadline explanation',
      'titleIt': 'Spiegazione scadenze',
      'outputType': 'info_card',
      'contentIt':
          'Per la dichiarazione di non detenzione TV, l’invio dal 1 luglio dell’anno precedente al 31 gennaio dell’anno di riferimento vale normalmente per l’intero anno. L’invio dal 1 febbraio al 30 giugno vale normalmente solo per il secondo semestre, da luglio a dicembre. Verifica sempre la scadenza ufficiale dell’anno corrente.',
    },
    {
      'id': 'registered_mail_checklist',
      'title': 'Registered mail checklist',
      'titleIt': 'Checklist invio raccomandata',
      'outputType': 'checklist',
      'address':
          'Agenzia delle Entrate - Direzione Provinciale I di Torino - Ufficio Canone TV - Casella postale 22 - 10121 Torino',
      'items': [
        'Print official form',
        'Fill and sign form',
        'Attach copy of valid identity document',
        'Send by registered mail according to official instructions',
        'Keep postal receipt',
        'Keep copy of all documents sent',
      ],
    },
    {
      'id': 'pec_submission_warning',
      'title': 'PEC submission warning',
      'titleIt': 'Avviso invio PEC',
      'outputType': 'warning_card',
      'contentIt':
          'L’invio via PEC e da usare solo se il modulo e firmato digitalmente e se le istruzioni ufficiali del modello scelto confermano questo canale. Per la dichiarazione di non detenzione TV firmata digitalmente, il canale indicato e cp22.canonetv@postacertificata.rai.it.',
    },
    {
      'id': 'caf_appointment_message',
      'title': 'CAF appointment message',
      'titleIt': 'Messaggio appuntamento CAF',
      'outputType': 'message',
      'recipient': 'CAF/intermediary',
      'templateIt':
          'Buongiorno,\n\nvorrei prendere appuntamento per assistenza sulla pratica Canone RAI.\n\nLa mia situazione e la seguente:\n- Motivo: [non detenzione TV / over 75 / rimborso / addebito errato / altro]\n- Canone gia addebitato: [si/no]\n- Utenza elettrica intestata a me: [si/no]\n- Presenza TV in casa: [si/no]\n- Documenti disponibili: [bolletta, documento, codice fiscale, modulo, prova pagamento]\n\nVorrei sapere quali documenti devo portare e quando e possibile fissare un appuntamento.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]',
    },
    {
      'id': 'over_75_eligibility_checklist',
      'title': 'Over-75 eligibility checklist',
      'titleIt': 'Checklist esenzione over 75',
      'outputType': 'checklist',
      'items': [
        'Check age requirement',
        'Check current official income threshold',
        'Check household composition',
        'Collect electricity bill',
        'Collect identity document and codice fiscale',
        'Prepare official over-75 exemption form',
        'If Canone already paid, evaluate refund request',
      ],
      'warning':
          'Income thresholds and deadlines must be checked against current Agenzia Entrate instructions before final submission.',
    },
    {
      'id': 'refund_eligibility_checklist',
      'title': 'Refund eligibility checklist',
      'titleIt': 'Checklist rimborso Canone RAI',
      'outputType': 'checklist',
      'items': [
        'Electricity bill showing Canone charge',
        'Proof of payment if needed',
        'Identity document',
        'Codice fiscale',
        'Reason for refund',
        'Proof of exemption/declaration if applicable',
        'Family household/payment proof if another member already paid',
        'IBAN if required by the form',
        'Official refund form or online service',
      ],
    },
    {
      'id': 'supplier_bill_clarification_message',
      'title': 'Ask supplier to clarify Canone bill line',
      'titleIt': 'Chiedere chiarimenti al fornitore sulla bolletta',
      'outputType': 'email_or_message',
      'recipient': 'electricity supplier',
      'templateIt':
          'Oggetto: Richiesta chiarimenti addebito Canone RAI in bolletta\n\nBuongiorno,\n\nchiedo cortesemente chiarimenti sull’addebito Canone RAI presente nella bolletta elettrica n. [numero bolletta], relativa all’utenza in [indirizzo], codice cliente [codice cliente].\n\nVorrei capire a quale periodo si riferisce l’addebito e se risultano eventuali rettifiche, rimborsi o storni gia applicati.\n\nResto in attesa di riscontro.\n\nCordiali saluti,\n[Nome Cognome]\n[Telefono]\n[Email]',
    },
    {
      'id': 'wrong_bill_checklist',
      'title': 'Wrong bill charge checklist',
      'titleIt': 'Checklist Canone su bolletta sbagliata',
      'outputType': 'checklist',
      'items': [
        'Collect all electricity bills involved',
        'Identify who is the electricity contract holder',
        'Check whether the contract is residential domestic',
        'Check family registry household situation',
        'Check whether another household member already paid',
        'Collect proof of duplicate/wrong charge',
        'Route to refund request if already paid',
      ],
      'warning':
          'Roommates are not automatically part of the same family registry household.',
    },
    {
      'id': 'move_home_canone_checklist',
      'title': 'Move-home Canone checklist',
      'titleIt': 'Checklist cambio casa e Canone RAI',
      'outputType': 'checklist',
      'items': [
        'Old address',
        'New address',
        'Old electricity contract details',
        'New electricity contract details',
        'Check if residential electricity contract is in user’s name',
        'Check if TV is present in new home',
        'Check if user is already part of a household where Canone is paid',
        'If no TV, evaluate no-TV declaration',
        'If wrongly charged, evaluate refund',
      ],
    },
    {
      'id': 'form_selection_wizard',
      'title': 'Form selection wizard',
      'titleIt': 'Selezione modulo corretto',
      'outputType': 'wizard',
      'behavior':
          'Ask whether the user has a TV, was already charged, is over 75, has another household member paying, has diplomatic/military status, and wants exemption or refund. Then route to the correct subcategory and output.',
    },
  ],
  'routingRules': [
    {
      'if': {'situation': 'not_sure_if_must_pay'},
      'routeTo': 'understand_if_must_pay_canone_rai',
    },
    {
      'if': {'situation': 'no_tv'},
      'routeTo': 'no_tv_declaration',
    },
    {
      'if': {
        'has_tv': 'no',
        'electricity_contract_holder': 'yes',
        'already_charged': 'no',
      },
      'routeTo': 'no_tv_declaration',
    },
    {
      'if': {'situation': 'over_75'},
      'routeTo': 'over_75_exemption',
    },
    {
      'if': {'situation': 'wrong_charge'},
      'routeTo': 'refund_wrong_charge',
    },
    {
      'if': {'situation': 'refund_needed'},
      'routeTo': 'refund_wrong_charge',
    },
    {
      'if': {'situation': 'someone_else_pays'},
      'routeTo': 'wrong_electricity_bill_charge',
    },
    {
      'if': {'situation': 'moved_home'},
      'routeTo': 'new_home_changed_electricity_contract',
    },
    {
      'if': {'situation': 'diplomatic_military'},
      'routeTo': 'diplomatic_military_exemption',
    },
    {
      'if': {'situation': 'form_help'},
      'routeTo': 'help_filling_agenzia_entrate_form',
    },
    {
      'if': {'already_charged': 'yes', 'has_tv': 'no'},
      'routeTo': 'refund_wrong_charge',
      'note':
          'User may need refund because Canone was already charged, plus no-TV declaration for future periods.',
    },
  ],
  'implementationNotesForCodex': [
    'This object belongs in the UfficioFacile data layer, not inside React components.',
    'Replace or expand the existing Canone RAI category with this richer structure.',
    'Keep the category visible as Canone RAI.',
    'Do not render the entire object on one page.',
    'The first screen must ask the user’s situation using firstScreenQuestions.',
    'Use routingRules to show only the relevant subcategory after selection.',
    'Show forms, deadlines, channels, contacts, and templates only for the selected flow.',
    'Do not show all deadlines together.',
    'Do not show all contacts together.',
    'Do not show all output templates by default.',
    'Show output generator buttons and reveal only the selected template/checklist.',
    'PEC should show a warning about digital signature.',
    'Registered mail should show the postal address only inside the selected flow or submission details section.',
    'Supplier clarification should be presented only as bill-line clarification, not as the authority for exemption/refund.',
    'Keep Dart typing strict and extend generic rich category types only where needed.',
    'Do not modify unrelated categories.',
  ],
});

class CanoneRaiGuidanceDefinitions {
  static RichCategoryGuidance get category => canoneRaiTorino;

  static const Map<String, String> _procedureToSubcategory = {
    'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST': 'no_tv_declaration',
    'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST': 'over_75_exemption',
    'CANONE_RAI_REFUND_OR_WRONG_CHARGE': 'refund_wrong_charge',
    'UNDERSTAND_IF_MUST_PAY_CANONE_RAI': 'understand_if_must_pay_canone_rai',
    'DIPLOMATIC_MILITARY_EXEMPTION': 'diplomatic_military_exemption',
    'WRONG_ELECTRICITY_BILL_CHARGE': 'wrong_electricity_bill_charge',
    'NEW_HOME_CHANGED_ELECTRICITY_CONTRACT':
        'new_home_changed_electricity_contract',
    'HELP_FILLING_AGENZIA_ENTRATE_FORM': 'help_filling_agenzia_entrate_form',
  };

  static RichCategorySubcategory? forProcedureId(String procedureId) {
    final subcategoryId = _procedureToSubcategory[procedureId];
    if (subcategoryId == null) {
      return null;
    }
    for (final item in category.subcategories) {
      if (item.id == subcategoryId) {
        return item;
      }
    }
    return null;
  }
}
