import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'bundled_provider_forms.dart';
import 'verified_catalog_import_v1.dart';

ServiceProvider _provider({
  required String id,
  required String name,
  required String category,
  String? websiteUrl,
  String? customerAreaUrl,
  String? cancellationPageUrl,
  String? complaintPageUrl,
  CatalogVerificationStatus verificationStatus =
      CatalogVerificationStatus.verified,
}) {
  return ServiceProvider(
    id: id,
    name: name,
    category: category,
    websiteUrl: websiteUrl,
    customerAreaUrl: customerAreaUrl,
    cancellationPageUrl: cancellationPageUrl,
    complaintPageUrl: complaintPageUrl,
    verificationStatus: verificationStatus,
    lastVerifiedAt: verificationStatus == CatalogVerificationStatus.verified
        ? verifiedOn(2026, 5, 6)
        : null,
    cancellationGuidance: const {
      'en':
          'Check the official provider site, customer area, or contract for the current cancellation process, notice period, and return duties.',
      'it':
          'Controlla il sito ufficiale del provider, l’area clienti o il contratto per la procedura attuale di disdetta, il preavviso e gli obblighi di restituzione.',
    },
    complaintGuidance: const {
      'en':
          'Keep bill numbers, dates, screenshots, and previous contacts before sending a complaint.',
      'it':
          'Tieni pronti numeri di bolletta, date, screenshot e contatti precedenti prima di inviare un reclamo.',
    },
    paymentPlanGuidance: const {
      'en':
          'Check whether the provider offers an official instalment or payment-plan route in the customer area.',
      'it':
          'Verifica se il provider offre un percorso ufficiale di rateizzazione o piano di pagamento nell’area clienti.',
    },
    modemReturnGuidance: const {
      'en':
          'If equipment is involved, verify exact return rules, deadlines, and proof requirements on the official provider site.',
      'it':
          'Se sono coinvolti apparati, verifica sul sito ufficiale del provider regole, scadenze e prove richieste per la restituzione.',
    },
    warnings: kCatalogWarning,
  );
}

final _baseBundledServiceProviders = <ServiceProvider>[
  _provider(
    id: 'tim',
    name: 'TIM',
    category: 'telecom',
    websiteUrl: 'https://www.tim.it/',
    customerAreaUrl: 'https://www.tim.it/mytim',
  ).copyWith(
    forms: [
      bundledProviderForms.firstWhere((item) => item.providerId == 'tim'),
    ],
  ),
  _provider(
    id: 'vodafone',
    name: 'Vodafone',
    category: 'telecom',
    websiteUrl: 'https://www.vodafone.it/',
  ).copyWith(
    forms: [
      bundledProviderForms.firstWhere((item) => item.providerId == 'vodafone'),
    ],
  ),
  _provider(
    id: 'windtre',
    name: 'WINDTRE',
    category: 'telecom',
    websiteUrl: 'https://www.windtre.it/',
  ),
  _provider(
    id: 'fastweb',
    name: 'Fastweb',
    category: 'telecom',
    websiteUrl: 'https://www.fastweb.it/',
  ),
  _provider(
    id: 'iliad',
    name: 'Iliad',
    category: 'telecom',
    websiteUrl: 'https://www.iliad.it/',
  ),
  _provider(
    id: 'sky-wifi',
    name: 'Sky Wifi',
    category: 'telecom',
    websiteUrl: 'https://www.sky.it/sky-wifi',
  ),
  _provider(
    id: 'postemobile-postecasa',
    name: 'PosteMobile / PosteCasa',
    category: 'telecom',
    websiteUrl: 'https://www.postemobile.it/',
  ),
  _provider(
    id: 'tiscali',
    name: 'Tiscali',
    category: 'telecom',
    websiteUrl: 'https://www.tiscali.it/',
  ),
  _provider(
    id: 'aruba',
    name: 'Aruba',
    category: 'telecom',
    websiteUrl: 'https://www.aruba.it/',
  ),
  _provider(
    id: 'opnet',
    name: 'Linkem / OpNet',
    category: 'telecom',
    websiteUrl: 'https://www.opnet.it/',
    verificationStatus: CatalogVerificationStatus.needsReview,
  ),
  _provider(
    id: 'other-telecom',
    name: 'Other provider',
    category: 'telecom',
    verificationStatus: CatalogVerificationStatus.unverified,
  ),
  _provider(
    id: 'enel-energia',
    name: 'Enel Energia',
    category: 'electricity',
    websiteUrl: 'https://www.enelenergia.it/',
  ),
  _provider(
    id: 'servizio-elettrico-nazionale',
    name: 'Servizio Elettrico Nazionale',
    category: 'electricity',
    websiteUrl: 'https://www.servizioelettriconazionale.it/',
    verificationStatus: CatalogVerificationStatus.needsReview,
  ),
  _provider(
    id: 'plenitude',
    name: 'Plenitude / Eni',
    category: 'dualEnergy',
    websiteUrl: 'https://eniplenitude.com/',
    verificationStatus: CatalogVerificationStatus.needsReview,
  ),
  _provider(
    id: 'edison-energia',
    name: 'Edison',
    category: 'dualEnergy',
    websiteUrl: 'https://www.edisonenergia.it/',
  ),
  _provider(
    id: 'a2a-energia',
    name: 'A2A Energia',
    category: 'dualEnergy',
    websiteUrl: 'https://www.a2aenergia.eu/',
  ),
  _provider(
    id: 'hera-comm',
    name: 'Hera Comm',
    category: 'dualEnergy',
    websiteUrl: 'https://heracomm.gruppohera.it/',
  ),
  _provider(
    id: 'iren',
    name: 'Iren',
    category: 'dualEnergy',
    websiteUrl: 'https://www.irenlucegas.it/',
  ),
  _provider(
    id: 'sorgenia',
    name: 'Sorgenia',
    category: 'dualEnergy',
    websiteUrl: 'https://www.sorgenia.it/',
  ),
  _provider(
    id: 'nen',
    name: 'NeN',
    category: 'dualEnergy',
    websiteUrl: 'https://nen.it/',
  ),
  _provider(
    id: 'octopus-energy',
    name: 'Octopus Energy',
    category: 'dualEnergy',
    websiteUrl: 'https://octopusenergy.it/',
  ),
  _provider(
    id: 'engie',
    name: 'Engie',
    category: 'dualEnergy',
    websiteUrl: 'https://www.engie.it/',
  ),
  _provider(
    id: 'wekiwi',
    name: 'Wekiwi',
    category: 'dualEnergy',
    websiteUrl: 'https://www.wekiwi.it/',
  ),
  _provider(
    id: 'acea-energia',
    name: 'Acea Energia',
    category: 'dualEnergy',
    websiteUrl: 'https://www.acea.it/acea-energia',
  ),
  _provider(
    id: 'dolomiti-energia',
    name: 'Dolomiti Energia',
    category: 'dualEnergy',
    websiteUrl: 'https://www.dolomitienergia.it/',
  ),
  _provider(
    id: 'other-energy',
    name: 'Other provider',
    category: 'dualEnergy',
    verificationStatus: CatalogVerificationStatus.unverified,
  ),
];

final bundledServiceProviders = <ServiceProvider>[
  ...{
    for (final item in [
      ..._baseBundledServiceProviders,
      ...verifiedCatalogServiceProviders,
    ])
      item.id: item,
  }.values,
];

extension on ServiceProvider {
  ServiceProvider copyWith({
    List<ProviderForm>? forms,
    List<ProviderContactOption>? contactOptions,
  }) {
    return ServiceProvider(
      id: id,
      name: name,
      category: category,
      verificationStatus: verificationStatus,
      websiteUrl: websiteUrl,
      customerAreaUrl: customerAreaUrl,
      cancellationPageUrl: cancellationPageUrl,
      complaintPageUrl: complaintPageUrl,
      forms: forms ?? this.forms,
      contactOptions: contactOptions ?? this.contactOptions,
      modemReturnGuidance: modemReturnGuidance,
      cancellationGuidance: cancellationGuidance,
      complaintGuidance: complaintGuidance,
      paymentPlanGuidance: paymentPlanGuidance,
      sourceReferences: sourceReferences,
      lastVerifiedAt: lastVerifiedAt,
      warnings: warnings,
    );
  }
}
