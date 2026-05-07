import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'verified_catalog_import_v1.dart';

final _baseBundledSourceReferences = <SourceReference>[
  SourceReference(
    id: 'agentrate-canone-rai',
    title: 'Agenzia Entrate - Canone RAI guidance',
    sourceType: 'taxAuthorityGuidance',
    referenceLabel: 'Agenzia Entrate',
    url: 'https://www.agenziaentrate.gov.it/portale/',
    explanation: const {
      'en':
          'Use Agenzia Entrate as the first official reference for Canone RAI declaration, exemption, and refund topics.',
      'it':
          'Usa Agenzia Entrate come primo riferimento ufficiale per dichiarazione, esenzione e rimborso Canone RAI.',
    },
    relevance: const {
      'en':
          'Relevant for official submission paths and truthful declaration warnings.',
      'it':
          'Rilevante per percorsi di invio ufficiali e avvisi sulla dichiarazione veritiera.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    procedureIds: const [
      'CANONE_RAI_NO_TV_DECLARATION_CHECKLIST',
      'CANONE_RAI_EXEMPTION_OVER_75_CHECKLIST',
      'CANONE_RAI_REFUND_OR_WRONG_CHARGE',
    ],
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    warning: kNoLegalAdviceWarning,
  ),
  SourceReference(
    id: 'arera-portale-offerte',
    title: 'ARERA / Portale Offerte',
    sourceType: 'energyAuthorityGuidance',
    referenceLabel: 'ARERA / Portale Offerte',
    url: 'https://www.ilportaleofferte.it/',
    explanation: const {
      'en':
          'Use the public comparison portal and ARERA-linked consumer guidance for energy offer comparisons and complaint context.',
      'it':
          'Usa il portale pubblico di confronto e la guida collegata ad ARERA per confronti offerte e contesto reclami energia.',
    },
    relevance: const {
      'en':
          'Relevant for high bill checks, offer comparison, and consumer orientation.',
      'it':
          'Rilevante per controlli su bollette alte, confronto offerte e orientamento consumatori.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    procedureIds: const [
      'ENERGY_SUPPLIER_COMPARISON',
      'HIGH_BILL_COMPLAINT',
      'METER_READING_CORRECTION',
      'PAYMENT_PLAN_REQUEST',
      'WRONG_CHARGE_REFUND_REQUEST',
    ],
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    warning: kNoLegalAdviceWarning,
  ),
  SourceReference(
    id: 'agcom-conciliaweb',
    title: 'AGCOM / ConciliaWeb',
    sourceType: 'telecomAuthorityGuidance',
    referenceLabel: 'AGCOM',
    url: 'https://www.agcom.it/servizi/cittadino',
    explanation: const {
      'en':
          'AGCOM and ConciliaWeb are relevant official references for telecom disputes and complaint escalation.',
      'it':
          'AGCOM e ConciliaWeb sono riferimenti ufficiali rilevanti per controversie telecom ed escalation reclami.',
    },
    relevance: const {
      'en':
          'Useful for internet cancellation disputes, wrong bills, and service problems.',
      'it':
          'Utile per controversie su disdetta internet, bollette errate e problemi di servizio.',
    },
    verificationStatus: CatalogVerificationStatus.verified,
    procedureIds: const [
      'INTERNET_PHONE_CANCELLATION',
      'TELECOM_WRONG_BILL_COMPLAINT',
      'SERVICE_NOT_WORKING_COMPLAINT',
      'MODEM_RETURN_OR_CHARGE_DISPUTE',
    ],
    lastVerifiedAt: verifiedOn(2026, 5, 6),
    warning: kNoLegalAdviceWarning,
  ),
  SourceReference(
    id: 'rental-civil-code-placeholder',
    title: 'Rental and contract obligations',
    sourceType: 'civilCodeReference',
    explanation: const {
      'en':
          'Rental and maintenance disputes may depend on your contract and applicable civil-law rules. Verify the exact legal basis if needed.',
      'it':
          'Le controversie su affitto e manutenzione possono dipendere dal contratto e da norme civilistiche applicabili. Verifica la base legale esatta se necessario.',
    },
    relevance: const {
      'en':
          'Useful for maintenance, deposit return, and formal notice wording.',
      'it':
          'Utile per manutenzione, restituzione deposito e formulazione di solleciti formali.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'LANDLORD_MAINTENANCE_OR_CONTRACT',
      'DEPOSIT_RETURN_REQUEST',
      'RENT_CONTRACT_TERMINATION_NOTICE',
      'RENTAL_CONTRACT_CHANGE',
    ],
    warning: kNoLegalAdviceWarning,
  ),
];

final bundledSourceReferences = <SourceReference>[
  ...{
    for (final item in [
      ..._baseBundledSourceReferences,
      ...verifiedCatalogSourceReferences,
    ])
      item.id: item,
  }.values,
];
