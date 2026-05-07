import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';

final bundledSubmissionChannels = <SubmissionChannel>[
  SubmissionChannel(
    id: 'whatsapp',
    type: 'whatsapp',
    title: const {'en': 'WhatsApp first', 'it': 'WhatsApp prima'},
    description: const {
      'en':
          'Useful for a first informal contact when you want a quick response.',
      'it':
          'Utile per un primo contatto informale quando vuoi una risposta rapida.',
    },
    whenToUse: const {
      'en':
          'Best for simple issues or first contact before escalating to formal channels.',
      'it':
          'Meglio per problemi semplici o primo contatto prima di passare a canali formali.',
    },
    steps: const [
      'State the issue briefly.',
      'Ask for confirmation or intervention.',
      'Save screenshots and delivery status.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    proofToKeep: const ['Screenshots', 'Date/time', 'Any reply received'],
    warnings: kCatalogWarning,
    priority: 10,
  ),
  SubmissionChannel(
    id: 'normal-email',
    type: 'normalEmail',
    title: const {'en': 'Normal email', 'it': 'Email normale'},
    description: const {
      'en': 'Good for standard communication when PEC is not required.',
      'it': 'Buona per comunicazioni standard quando la PEC non è richiesta.',
    },
    whenToUse: const {
      'en':
          'Use when the office or provider accepts ordinary email and you have a verified address.',
      'it':
          'Usala quando l’ufficio o il provider accetta email ordinaria e hai un indirizzo verificato.',
    },
    steps: const [
      'Verify the email address on the official source.',
      'Attach only necessary documents.',
      'Save the sent email and attachments.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    proofToKeep: const ['Sent email copy', 'Attachment list'],
    warnings: kCatalogWarning,
    priority: 20,
  ),
  SubmissionChannel(
    id: 'pec',
    type: 'pec',
    title: const {'en': 'PEC', 'it': 'PEC'},
    description: const {
      'en': 'Formal certified email channel used in Italy.',
      'it': 'Canale di posta elettronica certificata usato in Italia.',
    },
    whenToUse: const {
      'en':
          'Use when the office publishes a PEC and formal traceability matters.',
      'it':
          'Usala quando l’ufficio pubblica una PEC e la tracciabilità formale conta.',
    },
    steps: const [
      'Verify the recipient PEC on an official source.',
      'Send from your own PEC account when formal PEC value matters.',
      'Save acceptance and delivery receipts.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    relatedTerms: const ['pec'],
    proofToKeep: const ['PEC acceptance receipt', 'PEC delivery receipt'],
    warnings: kCatalogWarning,
    priority: 30,
  ),
  SubmissionChannel(
    id: 'raccomandata-ar',
    type: 'raccomandataAR',
    title: const {'en': 'Raccomandata A/R', 'it': 'Raccomandata A/R'},
    description: const {
      'en': 'Formal postal channel with proof of sending and return receipt.',
      'it':
          'Canale postale formale con prova di spedizione e avviso di ricevimento.',
    },
    whenToUse: const {
      'en':
          'Use when you need strong postal proof or when postal notice is recommended.',
      'it':
          'Usala quando ti serve una forte prova postale o quando la comunicazione postale è consigliata.',
    },
    steps: const [
      'Print and sign the letter if needed.',
      'Verify sender and recipient addresses carefully.',
      'Keep the shipping receipt and return receipt.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    officialLinks: const ['poste-raccomandata'],
    relatedTerms: const ['raccomandata-ar', 'pec'],
    proofToKeep: const [
      'Shipping receipt',
      'Return receipt',
      'Copy of the letter',
    ],
    warnings: kCatalogWarning,
    priority: 40,
  ),
  SubmissionChannel(
    id: 'online-portal',
    type: 'onlinePortal',
    title: const {'en': 'Online portal', 'it': 'Portale online'},
    description: const {
      'en':
          'Official portal or online service published by the authority or provider.',
      'it':
          'Portale ufficiale o servizio online pubblicato dall’autorità o dal provider.',
    },
    whenToUse: const {
      'en':
          'Use when the authority or provider offers a dedicated service or form.',
      'it':
          'Usalo quando l’autorità o il provider offre un servizio o un modulo dedicato.',
    },
    steps: const [
      'Verify that the portal is official.',
      'Check whether SPID or CIE is required.',
      'Save protocol number, screenshots, or confirmation emails.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    relatedTerms: const ['spid', 'cie', 'protocollo'],
    warnings: kCatalogWarning,
    priority: 50,
  ),
  SubmissionChannel(
    id: 'provider-customer-area',
    type: 'providerCustomerArea',
    title: const {
      'en': 'Provider customer area',
      'it': 'Area clienti provider',
    },
    description: const {
      'en':
          'Official customer area or authenticated support route published by the provider.',
      'it':
          'Area clienti ufficiale o percorso di assistenza autenticato pubblicato dal provider.',
    },
    whenToUse: const {
      'en':
          'Use when your provider offers cancellation, complaint, or equipment-return steps in the customer area.',
      'it':
          'Usala quando il provider offre passaggi di disdetta, reclamo o restituzione apparati nell’area clienti.',
    },
    steps: const [
      'Open the official provider customer area.',
      'Check whether a dedicated cancellation or complaint section exists.',
      'Save protocol numbers, receipts, and screenshots.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    warnings: kCatalogWarning,
    priority: 55,
  ),
  SubmissionChannel(
    id: 'official-form',
    type: 'officialForm',
    title: const {'en': 'Official form', 'it': 'Modulo ufficiale'},
    description: const {
      'en': 'Dedicated official form published by the authority or provider.',
      'it':
          'Modulo dedicato ufficiale pubblicato dall’autorità o dal provider.',
    },
    whenToUse: const {
      'en':
          'Use when the official page requires a specific PDF or online form.',
      'it':
          'Usalo quando la pagina ufficiale richiede un PDF specifico o un modulo online.',
    },
    steps: const [
      'Download the current official form.',
      'Fill all required fields carefully.',
      'Keep the submitted copy and receipt.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    warnings: kCatalogWarning,
    priority: 57,
  ),
  SubmissionChannel(
    id: 'in-person',
    type: 'inPerson',
    title: const {'en': 'In person', 'it': 'Di persona'},
    description: const {
      'en': 'Visit the office or store if official guidance allows it.',
      'it':
          'Vai in ufficio o punto vendita se le indicazioni ufficiali lo consentono.',
    },
    whenToUse: const {
      'en':
          'Use when you need direct support, document review, or a receipt/protocol in person.',
      'it':
          'Usalo quando ti serve supporto diretto, controllo documenti o una ricevuta/protocollo di persona.',
    },
    steps: const [
      'Verify office hours and appointment rules.',
      'Bring ID, codes, and supporting documents.',
      'Ask for a receipt, protocol, or written confirmation.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    warnings: kCatalogWarning,
    priority: 60,
  ),
  SubmissionChannel(
    id: 'in-person-store',
    type: 'inPerson',
    title: const {'en': 'Store or desk visit', 'it': 'Negozio o sportello'},
    description: const {
      'en':
          'Visit an official store or front desk if the provider accepts in-person support.',
      'it':
          'Vai in un negozio ufficiale o sportello se il provider accetta assistenza di persona.',
    },
    whenToUse: const {
      'en':
          'Use only if the provider or office confirms in-person handling and you can obtain a receipt.',
      'it':
          'Usalo solo se il provider o ufficio conferma la gestione di persona e puoi ottenere una ricevuta.',
    },
    steps: const [
      'Verify the official store or office first.',
      'Bring ID, contract data, and supporting documents.',
      'Ask for a written receipt or protocol.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    warnings: kCatalogWarning,
    priority: 65,
  ),
  SubmissionChannel(
    id: 'phone-support',
    type: 'phone',
    title: const {'en': 'Phone support', 'it': 'Assistenza telefonica'},
    description: const {
      'en':
          'Useful for information, ticket opening, or first support, but weaker as final proof.',
      'it':
          'Utile per informazioni, apertura ticket o primo supporto, ma più debole come prova finale.',
    },
    whenToUse: const {
      'en':
          'Use as a secondary channel before or after sending the formal request.',
      'it':
          'Usalo come canale secondario prima o dopo l’invio della richiesta formale.',
    },
    steps: const [
      'Note the date, time, and operator if available.',
      'Ask for a ticket or protocol number.',
      'Follow up in writing if the issue is important.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    warnings: kCatalogWarning,
    priority: 70,
  ),
  SubmissionChannel(
    id: 'patronato',
    type: 'cafPatronato',
    title: const {
      'en': 'Patronato / support desk',
      'it': 'Patronato / sportello di supporto',
    },
    description: const {
      'en':
          'Useful when a patronato or support desk can help you prepare and submit the request.',
      'it':
          'Utile quando un patronato o sportello di supporto può aiutarti a preparare e inviare la richiesta.',
    },
    whenToUse: const {
      'en':
          'Use for complex INPS, work, or document procedures when guided support is helpful.',
      'it':
          'Usalo per procedure INPS, lavoro o documenti complesse quando è utile un supporto guidato.',
    },
    steps: const [
      'Book an appointment if needed.',
      'Bring identity, tax, and case-specific documents.',
      'Keep any submission receipt or protocol.',
    ],
    verificationStatus: CatalogVerificationStatus.verified,
    warnings: kCatalogWarning,
    priority: 75,
  ),
];
