import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'bundled_official_links.dart';

final bundledAuthorityGuidance = <AuthorityGuidance>[
  AuthorityGuidance(
    id: 'authority-agenzia-entrate',
    authorityName: 'Agenzia Entrate',
    authorityType: 'taxAuthority',
    category: 'tax',
    title: 'Agenzia Entrate guidance',
    description: const {
      'en':
          'Use Agenzia Entrate for official tax-facing procedures such as Canone RAI and rental registration changes.',
      'it':
          'Usa Agenzia Entrate per procedure ufficiali fiscali come Canone RAI e variazioni di registrazione del contratto di affitto.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    procedureIds: const [
      'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
      'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      'RENTAL_CONTRACT_CHANGE',
    ],
    officialLinks: bundledOfficialLinks
        .where((item) => item.id == 'agenzia-entrate-home')
        .toList(),
    contactGuidance: const {
      'en':
          'Verify the exact page, form, and office finder path on the official website before sending personal data.',
      'it':
          'Verifica sul sito ufficiale pagina, modulo e percorso corretto per cercare l’ufficio prima di inviare dati personali.',
    },
    sourceUrl: 'https://www.agenziaentrate.gov.it/portale/',
    sourceLabel: 'Agenzia Entrate',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    warning: kCatalogWarning,
  ),
];
