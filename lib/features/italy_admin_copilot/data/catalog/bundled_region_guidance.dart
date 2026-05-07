import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'bundled_official_links.dart';

final bundledRegionGuidance = <RegionGuidance>[
  RegionGuidance(
    id: 'piemonte-health',
    region: 'Piemonte',
    category: 'health',
    title: 'Piemonte health services',
    description: const {
      'en':
          'Use Salute Piemonte and verify the correct ASL or local office before sending.',
      'it':
          'Usa Salute Piemonte e verifica la ASL o l’ufficio locale corretto prima dell’invio.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    procedureIds: const [
      'TESSERA_SANITARIA_RENEWAL',
      'CHANGE_DOCTOR',
      'ASL_APPOINTMENT_REQUEST',
    ],
    portalLinks: bundledOfficialLinks
        .where((item) => item.id.startsWith('salute-piemonte'))
        .toList(),
    contactGuidance: const {
      'en':
          'The exact ASL office depends on residence. Check the official regional portal and then the local ASL page.',
      'it':
          'L’ufficio ASL esatto dipende dalla residenza. Controlla il portale regionale ufficiale e poi la pagina della ASL locale.',
    },
    inPersonGuidance: const {
      'en':
          'Bring ID, codice fiscale, tessera sanitaria if available, and any previous receipt or protocol.',
      'it':
          'Porta documento, codice fiscale, tessera sanitaria se disponibile e qualsiasi ricevuta o protocollo precedente.',
    },
    sourceUrl: 'https://www.salutepiemonte.it/',
    sourceLabel: 'Salute Piemonte',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    warning: kCatalogWarning,
  ),
  RegionGuidance(
    id: 'lombardia-health',
    region: 'Lombardia',
    category: 'health',
    title: 'Lombardia health services',
    description: const {
      'en':
          'Use the official Lombardia health portal and verify the local ATS/ASST or office by residence.',
      'it':
          'Usa il portale sanitario ufficiale della Lombardia e verifica ATS/ASST o ufficio locale in base alla residenza.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const ['TESSERA_SANITARIA_RENEWAL', 'CHANGE_DOCTOR'],
    sourceUrl: 'https://www.regione.lombardia.it/',
    sourceLabel: 'Regione Lombardia',
    warning: kNeedsReviewWarning,
  ),
  RegionGuidance(
    id: 'lazio-health',
    region: 'Lazio',
    category: 'health',
    title: 'Lazio health services',
    description: const {
      'en':
          'Use the official Lazio health portal and verify the local ASL page by residence.',
      'it':
          'Usa il portale sanitario ufficiale del Lazio e verifica la pagina ASL locale in base alla residenza.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const ['TESSERA_SANITARIA_RENEWAL', 'CHANGE_DOCTOR'],
    sourceUrl: 'https://www.salutelazio.it/',
    sourceLabel: 'Salute Lazio',
    warning: kNeedsReviewWarning,
  ),
];
