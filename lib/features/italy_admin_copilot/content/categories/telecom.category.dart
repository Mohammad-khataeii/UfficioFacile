import '../../data/telecom_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final telecomCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: telecomInternetMobileTorino,
  sortOrder: 5,
  localizedTitle: localeMapFromPrimary(
    'Telecom & internet',
    it: 'Telefono e internet',
    fr: 'Télécom et internet',
    es: 'Telecom e internet',
    fa: 'تلفن و اینترنت',
    ar: 'الاتصالات والإنترنت',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Need help with a line activation, cancellation, modem return, migration, or provider complaint?',
    it: 'Ti serve aiuto con attivazione linea, disdetta, restituzione modem, migrazione o reclamo verso l’operatore?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Use this section for fixed line, mobile, modem, and internet provider issues, from setup to cancellation and formal complaints.',
    it: 'Usa questa sezione per problemi con linea fissa, mobile, modem e provider internet, dall’attivazione alla disdetta e ai reclami formali.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'wifi',
  color: '#7C3AED',
  tags: const ['telecom', 'internet', 'mobile', 'provider', 'complaint'],
  searchableKeywords: const ['tim', 'vodafone', 'fastweb', 'fibra', 'modem'],
);
