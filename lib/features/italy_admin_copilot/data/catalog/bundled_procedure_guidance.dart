import '../../domain/catalog_models.dart';
import '../procedure_definitions.dart';
import 'bundled_catalog_helpers.dart';
import 'verified_catalog_import_v1.dart';

final _baseBundledProcedureGuidance =
    <ProcedureGuidance>[
          ProcedureGuidance(
            id: 'pg-tessera',
            procedureId: 'TESSERA_SANITARIA_RENEWAL',
            category: 'health',
            title: 'Tessera Sanitaria Renewal / Health Card Problem',
            verificationStatus: CatalogVerificationStatus.needsReview,
            summary: const {
              'en':
                  'Start from the regional health portal or local ASL path, then verify whether online, in-person, email, or PEC support exists for your area.',
              'it':
                  'Parti dal portale sanitario regionale o dal percorso ASL locale, poi verifica se nella tua zona esistono canali online, di persona, email o PEC.',
            },
            destinationGuidance: const {
              'en':
                  'This request is usually handled by your local ASL or regional health authority. The exact office depends on your residence.',
              'it':
                  'Questa richiesta è di solito gestita dalla tua ASL locale o dall’autorità sanitaria regionale. L’ufficio esatto dipende dalla residenza.',
            },
            submissionChannelIds: const [
              'online-portal',
              'in-person',
              'normal-email',
              'pec',
            ],
            officialLinkIds: const [
              'salute-piemonte-home',
              'salute-piemonte-fse',
            ],
            officialContactIds: const ['asl-local-finder'],
            requiredDocuments: const [
              'ID',
              'Codice fiscale',
              'Tessera sanitaria if available',
            ],
            recommendedDocuments: const [
              'Previous request receipt or protocol',
              'Permesso / study / work document if your case requires it',
            ],
            proofItems: const [
              'Screenshots of portal steps',
              'Email/PEC receipt',
              'Office receipt or protocol',
            ],
            beforeSendingChecklist: const [
              'Verify the exact ASL office or portal for your residence.',
              'Verify the contact or office finder on the official regional/ASL site.',
              'Keep any protocol or previous request receipt.',
            ],
            warnings: kCatalogWarning,
            sourceReferenceIds: const [],
            regionIds: const [
              'piemonte-health',
              'lombardia-health',
              'lazio-health',
            ],
            cityIds: const [],
          ),
          ProcedureGuidance(
            id: 'pg-landlord',
            procedureId: 'LANDLORD_MAINTENANCE_OR_CONTRACT',
            category: 'housing',
            title: 'Landlord Maintenance / Contract Problem Letter',
            verificationStatus: CatalogVerificationStatus.needsReview,
            summary: const {
              'en':
                  'Start with documented WhatsApp or email for simple issues. Escalate to PEC or raccomandata A/R when proof matters.',
              'it':
                  'Inizia con WhatsApp o email documentata per problemi semplici. Passa a PEC o raccomandata A/R quando la prova conta.',
            },
            destinationGuidance: const {
              'en':
                  'Send first to the landlord or agency. Use Agenzia Entrate only for registration or contract-change tax steps, not normal maintenance messages.',
              'it':
                  'Invia prima al proprietario o all’agenzia. Usa Agenzia Entrate solo per passaggi fiscali di registrazione o variazione contratto, non per normali messaggi di manutenzione.',
            },
            submissionChannelIds: const [
              'whatsapp',
              'normal-email',
              'pec',
              'raccomandata-ar',
              'in-person',
            ],
            officialLinkIds: const [
              'agenzia-entrate-home',
              'poste-raccomandata',
            ],
            requiredDocuments: const ['Rental contract copy'],
            recommendedDocuments: const [
              'Photos',
              'Previous messages',
              'Dates of the problem',
            ],
            proofItems: const [
              'Photos',
              'Screenshots',
              'Mail receipts',
              'Raccomandata receipt',
            ],
            beforeSendingChecklist: const [
              'Describe the issue clearly and truthfully.',
              'Do not make legal claims you cannot support.',
              'Keep photos, messages, and contract proof together.',
              'For urgent safety issues, consider competent authority or professional support.',
            ],
            warnings: const {
              'en':
                  'Do not claim facts or damages without proof. Verify the correct recipient address before sending raccomandata A/R.',
              'it':
                  'Non dichiarare fatti o danni senza prove. Verifica l’indirizzo corretto del destinatario prima di inviare una raccomandata A/R.',
            },
            sourceReferenceIds: const ['rental-civil-code-placeholder'],
          ),
          ProcedureGuidance(
            id: 'pg-telecom-cancel',
            procedureId: 'INTERNET_PHONE_CANCELLATION',
            category: 'telecom',
            title: 'Internet / Phone Cancellation',
            verificationStatus: CatalogVerificationStatus.needsReview,
            summary: const {
              'en':
                  'Select your provider first, then verify the official cancellation channel, return duties, and notice period.',
              'it':
                  'Seleziona prima il provider, poi verifica il canale ufficiale di disdetta, gli obblighi di restituzione e il preavviso.',
            },
            destinationGuidance: const {
              'en':
                  'Use the official provider website, customer area, contract, or published complaint/cancellation page. Do not rely on unofficial contact lists.',
              'it':
                  'Usa il sito ufficiale del provider, l’area clienti, il contratto o la pagina ufficiale reclami/disdetta pubblicata. Non fare affidamento su elenchi contatti non ufficiali.',
            },
            submissionChannelIds: const [
              'online-portal',
              'pec',
              'raccomandata-ar',
              'in-person',
            ],
            officialLinkIds: const [
              'agcom-servizi-cittadino',
              'conciliaweb-login',
            ],
            officialContactIds: const ['provider-contact-placeholder'],
            requiredDocuments: const [
              'ID',
              'Codice fiscale',
              'Customer code',
              'Contract number',
              'Line number',
            ],
            recommendedDocuments: const [
              'Any provider form',
              'Last invoice',
              'Modem/router details',
            ],
            proofItems: const [
              'Cancellation receipt',
              'Email/PEC proof',
              'Modem return proof',
              'Screenshots',
            ],
            beforeSendingChecklist: const [
              'Check contract conditions and notice period.',
              'Verify modem or router return rules.',
              'If portability matters, avoid sending a cancellation that conflicts with your transfer process.',
            ],
            warnings: const {
              'en':
                  'Check contract conditions, cancellation costs, modem return rules, and notice period before sending.',
              'it':
                  'Controlla condizioni contrattuali, costi di disdetta, regole di restituzione modem e preavviso prima dell’invio.',
            },
            sourceReferenceIds: const ['agcom-conciliaweb'],
            providerIds: const [
              'tim',
              'vodafone',
              'windtre',
              'fastweb',
              'iliad',
              'sky-wifi',
              'postemobile-postecasa',
              'tiscali',
              'aruba',
              'opnet',
              'other-telecom',
            ],
          ),
          ProcedureGuidance(
            id: 'pg-high-bill',
            procedureId: 'HIGH_BILL_COMPLAINT',
            category: 'utilities',
            title: 'High Bill Complaint',
            verificationStatus: CatalogVerificationStatus.needsReview,
            summary: const {
              'en':
                  'Collect the bill, meter reading proof, and contract data before complaining. Verify whether the issue concerns estimated reading, conguaglio, or a disputed charge.',
              'it':
                  'Raccogli bolletta, prove delle letture e dati contrattuali prima di reclamare. Verifica se il problema riguarda lettura stimata, conguaglio o addebito contestato.',
            },
            destinationGuidance: const {
              'en':
                  'Start from the official provider contact or customer area. Use public energy references such as Portale Offerte for comparison context and consumer orientation.',
              'it':
                  'Parti dal contatto ufficiale del provider o dall’area clienti. Usa riferimenti pubblici come Portale Offerte per confronto e orientamento al consumatore.',
            },
            submissionChannelIds: const [
              'online-portal',
              'normal-email',
              'pec',
              'raccomandata-ar',
            ],
            officialLinkIds: const ['portale-offerte-home'],
            officialContactIds: const ['provider-contact-placeholder'],
            requiredDocuments: const [
              'Bill number',
              'Bill period',
              'Customer code',
            ],
            recommendedDocuments: const [
              'POD/PDR',
              'Actual meter reading photo',
              'Previous bills',
            ],
            proofItems: const [
              'Meter photos',
              'Bill copy',
              'Complaint receipt',
            ],
            beforeSendingChecklist: const [
              'Check whether the bill uses estimated or actual readings.',
              'Check whether the amount includes conguaglio.',
              'Keep photos of the meter and the bill pages you contest.',
            ],
            warnings: kCatalogWarning,
            sourceReferenceIds: const ['arera-portale-offerte'],
            providerIds: const [
              'enel-energia',
              'servizio-elettrico-nazionale',
              'plenitude',
              'edison-energia',
              'a2a-energia',
              'hera-comm',
              'iren',
              'sorgenia',
              'nen',
              'octopus-energy',
              'engie',
              'wekiwi',
              'acea-energia',
              'dolomiti-energia',
              'other-energy',
            ],
          ),
          ProcedureGuidance(
            id: 'pg-canone-rai',
            procedureId: 'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
            category: 'canoneRai',
            title: 'Canone RAI No-TV Declaration Checklist',
            verificationStatus: CatalogVerificationStatus.needsReview,
            summary: const {
              'en':
                  'Use only official Agenzia Entrate channels and submit only truthful declarations.',
              'it':
                  'Usa solo canali ufficiali Agenzia Entrate e invia solo dichiarazioni veritiere.',
            },
            destinationGuidance: const {
              'en':
                  'Check the official Agenzia Entrate site for the correct declaration path, form, and deadlines.',
              'it':
                  'Controlla il sito ufficiale dell’Agenzia Entrate per percorso, modulo e scadenze corretti.',
            },
            submissionChannelIds: const [
              'online-portal',
              'officialForm',
              'raccomandata-ar',
            ],
            officialLinkIds: const ['agenzia-entrate-home'],
            requiredDocuments: const [
              'Identity details',
              'Tax data if requested',
            ],
            proofItems: const ['Submission receipt', 'Copy of declaration'],
            beforeSendingChecklist: const [
              'Read the official instructions carefully.',
              'Submit only truthful declarations.',
              'Keep the submission receipt.',
            ],
            warnings: const {
              'en':
                  'False declarations can have consequences. Verify official instructions and deadlines before submitting.',
              'it':
                  'Le dichiarazioni false possono avere conseguenze. Verifica istruzioni ufficiali e scadenze prima di inviare.',
            },
            sourceReferenceIds: const ['agentrate-canone-rai'],
          ),
        ]
        .followedBy(
          ItalyAdminProcedureDefinitions.all()
              .where(
                (procedure) => ![
                  'TESSERA_SANITARIA_RENEWAL',
                  'LANDLORD_MAINTENANCE_OR_CONTRACT',
                  'INTERNET_PHONE_CANCELLATION',
                  'HIGH_BILL_COMPLAINT',
                  'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
                ].contains(procedure.id),
              )
              .map(
                (procedure) => ProcedureGuidance(
                  id: 'pg-${procedure.id.toLowerCase()}',
                  procedureId: procedure.id,
                  category: procedure.category.name,
                  title: procedure.title,
                  verificationStatus: CatalogVerificationStatus.needsReview,
                  summary: {
                    'en':
                        'Review the official channel, gather the suggested documents, and verify the destination before sending.',
                    'it':
                        'Controlla il canale ufficiale, raccogli i documenti suggeriti e verifica il destinatario prima dell’invio.',
                  },
                  destinationGuidance: {
                    'en':
                        'Use the official office, provider, or authority website to verify the correct destination for this procedure.',
                    'it':
                        'Usa il sito ufficiale dell’ufficio, provider o autorità per verificare il destinatario corretto di questa procedura.',
                  },
                  submissionChannelIds: const [
                    'normal-email',
                    'online-portal',
                    'in-person',
                  ],
                  officialLinkIds: const [],
                  requiredDocuments: procedure.attachmentSuggestions
                      .where((item) => item.required)
                      .map((item) => item.name)
                      .toList(),
                  recommendedDocuments: procedure.attachmentSuggestions
                      .where((item) => !item.required)
                      .map((item) => item.name)
                      .toList(),
                  proofItems: const [
                    'Copy of what you sent',
                    'Any receipt or protocol',
                  ],
                  beforeSendingChecklist: const [
                    'Verify the destination on an official source.',
                    'Remove placeholders from the generated text.',
                    'Keep proof of sending.',
                  ],
                  warnings: kCatalogWarning,
                ),
              ),
        )
        .toList();

final bundledProcedureGuidance = <ProcedureGuidance>[
  ...{
    for (final item in [
      ..._baseBundledProcedureGuidance,
      ...verifiedCatalogProcedureGuidance,
    ])
      item.procedureId: item,
  }.values,
];
