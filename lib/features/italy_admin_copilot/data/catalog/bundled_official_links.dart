import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'verified_catalog_import_v1.dart';

final _baseBundledOfficialLinks = <OfficialLink>[
  OfficialLink(
    id: 'agenzia-entrate-home',
    title: 'Agenzia Entrate',
    category: 'authority',
    descriptionLocalized: const {
      'en':
          'Official tax authority website and reference point for Canone RAI and rental contract tax procedures.',
      'it':
          'Sito ufficiale dell’autorità fiscale e riferimento per Canone RAI e procedure fiscali sui contratti di affitto.',
    },
    url: 'https://www.agenziaentrate.gov.it/portale/',
    country: 'IT',
    relatedProcedureIds: const [
      'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
      'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
      'RENTAL_CONTRACT_CHANGE',
    ],
    sourceUrl: 'https://www.agenziaentrate.gov.it/portale/',
    sourceLabel: 'Agenzia Entrate',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'inps-disoccupazione',
    title: 'INPS - Disoccupazione',
    category: 'authority',
    descriptionLocalized: const {
      'en': 'Official INPS area for unemployment and NASpI services.',
      'it': 'Area ufficiale INPS per disoccupazione e servizi NASpI.',
    },
    url: 'https://www.inps.it/it/it/lavoro/disoccupazione.html',
    country: 'IT',
    relatedProcedureIds: const ['NASPI_PREPARATION'],
    sourceUrl: 'https://www.inps.it/it/it/lavoro/disoccupazione.html',
    sourceLabel: 'INPS',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'portale-offerte-home',
    title: 'Portale Offerte luce e gas',
    category: 'utilities',
    descriptionLocalized: const {
      'en': 'Official public comparison portal for electricity and gas offers.',
      'it': 'Portale pubblico ufficiale per confrontare offerte luce e gas.',
    },
    url: 'https://www.ilportaleofferte.it/',
    country: 'IT',
    relatedProcedureIds: const [
      'ENERGY_SUPPLIER_COMPARISON',
      'HIGH_BILL_COMPLAINT',
    ],
    sourceUrl: 'https://www.ilportaleofferte.it/',
    sourceLabel: 'Portale Offerte',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'agcom-servizi-cittadino',
    title: 'AGCOM - Servizi per il cittadino',
    category: 'telecom',
    descriptionLocalized: const {
      'en':
          'Official AGCOM citizen services area, including ConciliaWeb access.',
      'it':
          'Area ufficiale AGCOM per i servizi al cittadino, incluso l’accesso a ConciliaWeb.',
    },
    url: 'https://www.agcom.it/servizi/cittadino',
    country: 'IT',
    relatedProcedureIds: const [
      'INTERNET_PHONE_CANCELLATION',
      'TELECOM_WRONG_BILL_COMPLAINT',
      'SERVICE_NOT_WORKING_COMPLAINT',
      'MODEM_RETURN_OR_CHARGE_DISPUTE',
    ],
    sourceUrl: 'https://www.agcom.it/servizi/cittadino',
    sourceLabel: 'AGCOM',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'conciliaweb-login',
    title: 'ConciliaWeb',
    category: 'telecom',
    descriptionLocalized: const {
      'en': 'Official AGCOM dispute platform for telecom and pay-TV disputes.',
      'it': 'Piattaforma ufficiale AGCOM per controversie telecom e pay TV.',
    },
    url: 'https://conciliaweb.agcom.it/conciliaweb/login.htm?lang=en',
    country: 'IT',
    relatedProcedureIds: const [
      'TELECOM_WRONG_BILL_COMPLAINT',
      'SERVICE_NOT_WORKING_COMPLAINT',
    ],
    sourceUrl: 'https://conciliaweb.agcom.it/conciliaweb/login.htm?lang=en',
    sourceLabel: 'AGCOM - ConciliaWeb',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'poste-raccomandata',
    title: 'Poste Italiane - Posta Raccomandata',
    category: 'postal',
    descriptionLocalized: const {
      'en':
          'Official Poste Italiane page for Raccomandata and Avviso di Ricevimento guidance.',
      'it':
          'Pagina ufficiale Poste Italiane per Raccomandata e Avviso di Ricevimento.',
    },
    url: 'https://www.poste.it/posta-raccomandata',
    country: 'IT',
    relatedProcedureIds: const [
      'LANDLORD_MAINTENANCE_OR_CONTRACT',
      'DEPOSIT_RETURN_REQUEST',
      'RENT_CONTRACT_TERMINATION_NOTICE',
      'INTERNET_PHONE_CANCELLATION',
    ],
    sourceUrl: 'https://www.poste.it/posta-raccomandata',
    sourceLabel: 'Poste Italiane',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'salute-piemonte-home',
    title: 'Salute Piemonte',
    category: 'health',
    descriptionLocalized: const {
      'en':
          'Regional health portal for Piemonte. Verify local ASL contacts before sending.',
      'it':
          'Portale sanitario regionale del Piemonte. Verifica i contatti ASL locali prima dell’invio.',
    },
    url: 'https://www.salutepiemonte.it/',
    country: 'IT',
    region: 'Piemonte',
    relatedProcedureIds: const [
      'TESSERA_SANITARIA_RENEWAL',
      'CHANGE_DOCTOR',
      'ASL_APPOINTMENT_REQUEST',
    ],
    sourceUrl: 'https://www.salutepiemonte.it/',
    sourceLabel: 'Salute Piemonte',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'salute-piemonte-fse',
    title: 'Salute Piemonte - Fascicolo Sanitario Elettronico FAQ',
    category: 'health',
    descriptionLocalized: const {
      'en':
          'Official Piemonte health FAQ showing SPID/CIE access for FSE services.',
      'it':
          'FAQ ufficiale Piemonte che mostra l’accesso SPID/CIE ai servizi FSE.',
    },
    url:
        'https://www.salutepiemonte.it/cms/faq/come-accedo-e-consulto-il-fascicolo-sanitario-elettronico',
    country: 'IT',
    region: 'Piemonte',
    relatedProcedureIds: const ['TESSERA_SANITARIA_RENEWAL'],
    sourceUrl:
        'https://www.salutepiemonte.it/cms/faq/come-accedo-e-consulto-il-fascicolo-sanitario-elettronico',
    sourceLabel: 'Salute Piemonte',
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    verificationStatus: OfficialLinkVerificationStatus.verified,
    warningLocalized: kCatalogWarning,
  ),
  OfficialLink(
    id: 'comune-search-placeholder',
    title: 'Comune official website search',
    category: 'comune',
    descriptionLocalized: const {
      'en':
          'Use the official Comune site for your city to verify the correct anagrafe or residence office.',
      'it':
          'Usa il sito ufficiale del tuo Comune per verificare l’ufficio anagrafe o residenza corretto.',
    },
    url: '',
    country: 'IT',
    relatedProcedureIds: const [
      'COMUNE_RESIDENCE_REQUEST',
      'ANAGRAFE_CERTIFICATE_REQUEST',
    ],
    verificationStatus: OfficialLinkVerificationStatus.needsReview,
    warningLocalized: kNeedsReviewWarning,
    notes: const {'placeholder': true},
  ),
];

final bundledOfficialLinks = <OfficialLink>[
  ...{
    for (final item in [
      ..._baseBundledOfficialLinks,
      ...verifiedCatalogOfficialLinks,
    ])
      item.id: item,
  }.values,
];
