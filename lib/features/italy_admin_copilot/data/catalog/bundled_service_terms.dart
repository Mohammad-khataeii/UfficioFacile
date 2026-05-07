import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';

final bundledServiceTerms = <ServiceTerm>[
  ServiceTerm(
    id: 'pec',
    term: 'PEC',
    shortDefinition: const {
      'en': 'Certified email used in Italy for formal delivery.',
      'it': 'Posta elettronica certificata usata in Italia per invii formali.',
    },
    longExplanation: const {
      'en':
          'PEC is a certified email system used in Italy. When an office requires PEC, the legal or formal value usually depends on using a PEC sender account and a verified PEC recipient.',
      'it':
          'La PEC è un sistema di posta elettronica certificata usato in Italia. Quando un ufficio richiede la PEC, il valore formale dipende in genere dall’uso di una casella PEC del mittente e di una PEC del destinatario verificata.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    relatedLinks: const ['spid-what-is'],
    providerExamples: const [
      'Aruba PEC',
      'Postecert',
      'Legalmail',
      'Register.it',
      'InfoCert',
      'Namirial',
    ],
    warnings: kCatalogWarning,
  ),
  ServiceTerm(
    id: 'spid',
    term: 'SPID',
    shortDefinition: const {
      'en': 'Italian public digital identity for online services.',
      'it': 'Identità digitale pubblica italiana per servizi online.',
    },
    longExplanation: const {
      'en':
          'SPID lets you access many Italian public services online. Some portals may require SPID before you can submit a request or view your case.',
      'it':
          'SPID ti permette di accedere a molti servizi pubblici italiani online. Alcuni portali possono richiedere SPID prima di inviare una richiesta o consultare la pratica.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    relatedLinks: const ['spid-what-is'],
    warnings: kCatalogWarning,
  ),
  ServiceTerm(
    id: 'cie',
    term: 'CIE',
    shortDefinition: const {
      'en':
          'Electronic identity card that can also be used for digital access.',
      'it':
          'Carta d’identità elettronica utilizzabile anche per l’accesso digitale.',
    },
    longExplanation: const {
      'en':
          'CIE can be used to access many public online services in Italy. Some portals allow access with SPID or CIE.',
      'it':
          'La CIE può essere usata per accedere a molti servizi pubblici online in Italia. Alcuni portali consentono l’accesso con SPID o CIE.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    relatedLinks: const ['cie-digital-id'],
    warnings: kCatalogWarning,
  ),
  ServiceTerm(
    id: 'raccomandata-ar',
    term: 'Raccomandata A/R',
    shortDefinition: const {
      'en': 'Registered mail with return receipt.',
      'it': 'Raccomandata con avviso di ricevimento.',
    },
    longExplanation: const {
      'en':
          'Raccomandata A/R is a postal method that gives proof of sending and return receipt. It is often useful when you need strong postal proof.',
      'it':
          'La raccomandata A/R è un metodo postale che fornisce prova di spedizione e avviso di ricevimento. È spesso utile quando serve una forte prova postale.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    relatedLinks: const ['poste-raccomandata'],
    warnings: kCatalogWarning,
  ),
  ServiceTerm(
    id: 'conguaglio',
    term: 'Conguaglio',
    shortDefinition: const {
      'en': 'Adjustment bill based on updated consumption data.',
      'it': 'Bolletta di conguaglio basata su dati di consumo aggiornati.',
    },
    longExplanation: const {
      'en':
          'A conguaglio usually adjusts previous estimated billing after the provider receives more complete meter data.',
      'it':
          'Il conguaglio di solito corregge bollette precedenti stimate dopo che il fornitore riceve dati del contatore più completi.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    warnings: kNoLegalAdviceWarning,
  ),
  ServiceTerm(
    id: 'lettura-stimata',
    term: 'Lettura stimata',
    shortDefinition: const {
      'en': 'Estimated meter reading.',
      'it': 'Lettura stimata del contatore.',
    },
    longExplanation: const {
      'en':
          'An estimated reading is not based on a recent direct reading from the meter. It can later be corrected.',
      'it':
          'Una lettura stimata non si basa su una recente lettura diretta del contatore. Può essere corretta successivamente.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    warnings: kNoLegalAdviceWarning,
  ),
  ServiceTerm(
    id: 'lettura-effettiva',
    term: 'Lettura effettiva',
    shortDefinition: const {
      'en': 'Actual meter reading.',
      'it': 'Lettura effettiva del contatore.',
    },
    longExplanation: const {
      'en':
          'An actual reading is based on meter data that has been read directly or transmitted through an official channel.',
      'it':
          'Una lettura effettiva si basa su dati del contatore letti direttamente o trasmessi tramite un canale ufficiale.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    warnings: kNoLegalAdviceWarning,
  ),
];
