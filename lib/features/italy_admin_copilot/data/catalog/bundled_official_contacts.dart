import '../../domain/catalog_models.dart';
import 'bundled_catalog_helpers.dart';
import 'verified_catalog_import_v1.dart';

final _baseBundledOfficialContacts = <OfficialContact>[
  OfficialContact(
    id: 'asl-local-finder',
    label: 'Local ASL contact finder',
    contactType: 'officeFinder',
    category: 'health',
    displayValue:
        'Verify the correct ASL office through your region or city health portal.',
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'TESSERA_SANITARIA_RENEWAL',
      'CHANGE_DOCTOR',
      'ASL_REJECTED_REQUEST_REPLY',
      'ASL_APPOINTMENT_REQUEST',
    ],
    jurisdiction: 'regional',
    warning: kNeedsReviewWarning,
  ),
  OfficialContact(
    id: 'provider-contact-placeholder',
    label: 'Provider official customer area or complaints channel',
    contactType: 'customerArea',
    category: 'provider',
    displayValue:
        'Check the official provider website, contract, or customer area for the correct cancellation or complaint channel.',
    verificationStatus: CatalogVerificationStatus.needsReview,
    procedureIds: const [
      'INTERNET_PHONE_CANCELLATION',
      'TELECOM_WRONG_BILL_COMPLAINT',
      'SERVICE_NOT_WORKING_COMPLAINT',
      'MODEM_RETURN_OR_CHARGE_DISPUTE',
      'HIGH_BILL_COMPLAINT',
      'METER_READING_CORRECTION',
      'PAYMENT_PLAN_REQUEST',
    ],
    jurisdiction: 'provider',
    warning: kNeedsReviewWarning,
  ),
];

final bundledOfficialContacts = <OfficialContact>[
  ...{
    for (final item in [
      ..._baseBundledOfficialContacts,
      ...verifiedCatalogOfficialContacts,
    ])
      item.id: item,
  }.values,
];
