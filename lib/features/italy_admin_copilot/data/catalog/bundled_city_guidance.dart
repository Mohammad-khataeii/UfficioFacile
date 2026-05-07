import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';

final bundledCityGuidance = <CityGuidance>[
  CityGuidance(
    id: 'torino-comune',
    city: 'Torino',
    region: 'Piemonte',
    category: 'comune',
    title: 'Torino Comune guidance',
    description: const {
      'en':
          'Use the official Torino Comune website to verify the correct Anagrafe or Residenza office and any booking requirement.',
      'it':
          'Usa il sito ufficiale del Comune di Torino per verificare l’ufficio Anagrafe o Residenza corretto ed eventuali prenotazioni.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    sourceUrl: 'https://www.comune.torino.it/',
    sourceLabel: 'Comune di Torino',
    warning: kNeedsReviewWarning,
  ),
  CityGuidance(
    id: 'milano-comune',
    city: 'Milano',
    region: 'Lombardia',
    category: 'comune',
    title: 'Milano Comune guidance',
    description: const {
      'en':
          'Use the official Milano Comune website to verify appointments, online services, and the correct office.',
      'it':
          'Usa il sito ufficiale del Comune di Milano per verificare appuntamenti, servizi online e ufficio corretto.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    sourceUrl: 'https://www.comune.milano.it/',
    sourceLabel: 'Comune di Milano',
    warning: kNeedsReviewWarning,
  ),
  CityGuidance(
    id: 'roma-comune',
    city: 'Roma',
    region: 'Lazio',
    category: 'comune',
    title: 'Roma Comune guidance',
    description: const {
      'en':
          'Use the official Roma Capitale website to verify the correct office and booking process.',
      'it':
          'Usa il sito ufficiale di Roma Capitale per verificare l’ufficio corretto e il processo di prenotazione.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    sourceUrl: 'https://www.comune.roma.it/',
    sourceLabel: 'Roma Capitale',
    warning: kNeedsReviewWarning,
  ),
  CityGuidance(
    id: 'bologna-comune',
    city: 'Bologna',
    region: 'Emilia-Romagna',
    category: 'comune',
    title: 'Bologna Comune guidance',
    description: const {
      'en':
          'Use the official Bologna Comune website to verify anagrafe/residence service details.',
      'it':
          'Usa il sito ufficiale del Comune di Bologna per verificare i dettagli dei servizi anagrafe/residenza.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    sourceUrl: 'https://www.comune.bologna.it/',
    sourceLabel: 'Comune di Bologna',
    warning: kNeedsReviewWarning,
  ),
  CityGuidance(
    id: 'firenze-comune',
    city: 'Firenze',
    region: 'Toscana',
    category: 'comune',
    title: 'Firenze Comune guidance',
    description: const {
      'en':
          'Use the official Firenze Comune website to verify office addresses and booking rules.',
      'it':
          'Usa il sito ufficiale del Comune di Firenze per verificare indirizzi uffici e regole di prenotazione.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    sourceUrl: 'https://www.comune.fi.it/',
    sourceLabel: 'Comune di Firenze',
    warning: kNeedsReviewWarning,
  ),
  CityGuidance(
    id: 'napoli-comune',
    city: 'Napoli',
    region: 'Campania',
    category: 'comune',
    title: 'Napoli Comune guidance',
    description: const {
      'en':
          'Use the official Napoli Comune website to verify office details and appointment rules.',
      'it':
          'Usa il sito ufficiale del Comune di Napoli per verificare dettagli uffici e regole di appuntamento.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    sourceUrl: 'https://www.comune.napoli.it/',
    sourceLabel: 'Comune di Napoli',
    warning: kNeedsReviewWarning,
  ),
];
