import '../../data/housing_rent_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final housingRentCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: housingGuidanceToRichCategory(
    HousingRentGuidanceDefinitions.category,
  ),
  sortOrder: 2,
  localizedTitle: localeMapFromPrimary(
    'Housing / Rent',
    it: 'Casa / Affitto',
    fr: 'Logement / Loyer',
    es: 'Vivienda / Alquiler',
    fa: 'خانه / اجاره',
    ar: 'السكن / الإيجار',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Do you need help with rent contracts, registration, residence, roommates, deposits, or landlord issues?',
    it: 'Hai bisogno di aiuto con contratto di affitto, registrazione, residenza, coinquilini, cauzione o problemi con il proprietario?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Start here for rent contracts, tenant documents, residence changes, utilities linked to a home, and practical housing steps in Italy.',
    it: 'Parti da qui per contratto di affitto, documenti da inquilino, cambio residenza, utenze collegate alla casa e pratiche abitative in Italia.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'home',
  color: '#B45309',
  tags: const ['housing', 'rent', 'lease', 'residence', 'landlord'],
  searchableKeywords: const [
    'rent',
    'deposit',
    'lease',
    'residence',
    'affitto',
  ],
  isProcedurePremium: (slug) =>
      slug.contains('deposit') ||
      slug.contains('support') ||
      slug.contains('optimization') ||
      slug.contains('dispute') ||
      slug.contains('termination'),
  procedureMonetizationType: (slug) =>
      slug.contains('deposit') ||
          slug.contains('support') ||
          slug.contains('optimization') ||
          slug.contains('dispute') ||
          slug.contains('termination')
      ? 'premium_money_value'
      : 'free',
);
