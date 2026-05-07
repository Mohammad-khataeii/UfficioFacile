import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'verified_catalog_import_v1.dart';

final _baseBundledProviderForms = <ProviderForm>[
  ProviderForm(
    id: 'tim-cancellation-page',
    providerId: 'tim',
    providerName: 'TIM',
    formType: 'cancellation',
    title: 'TIM cancellation information',
    description: const {
      'en':
          'Use the official TIM website or customer area to verify the current cancellation process and required form.',
      'it':
          'Usa il sito ufficiale TIM o l’area clienti per verificare la procedura attuale di disdetta e l’eventuale modulo richiesto.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    warning: kNeedsReviewWarning,
    procedureIds: const ['INTERNET_PHONE_CANCELLATION'],
    requiredFields: const ['Contract number', 'Customer code', 'Line number'],
    requiredDocuments: const ['ID', 'Codice fiscale', 'Any modem return proof'],
    submissionChannels: const ['online-portal', 'pec', 'raccomandata-ar'],
  ),
  ProviderForm(
    id: 'vodafone-cancellation-page',
    providerId: 'vodafone',
    providerName: 'Vodafone',
    formType: 'cancellation',
    title: 'Vodafone cancellation information',
    description: const {
      'en':
          'Check the official Vodafone website or customer area for the current disdetta channel.',
      'it':
          'Controlla il sito ufficiale Vodafone o l’area clienti per il canale di disdetta attuale.',
    },
    verificationStatus: CatalogVerificationStatus.needsReview,
    warning: kNeedsReviewWarning,
    procedureIds: const ['INTERNET_PHONE_CANCELLATION'],
    requiredFields: const ['Contract number', 'Customer code', 'Line number'],
    requiredDocuments: const ['ID', 'Codice fiscale', 'Any modem return proof'],
    submissionChannels: const ['online-portal', 'pec', 'raccomandata-ar'],
  ),
];

final bundledProviderForms = <ProviderForm>[
  ...{
    for (final item in [
      ..._baseBundledProviderForms,
      ...verifiedCatalogProviderForms,
    ])
      item.id: item,
  }.values,
];
