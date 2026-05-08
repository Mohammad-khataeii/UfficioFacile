import '../../data/work_inps_patronato_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final workInpsCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: WorkInpsPatronatoGuidanceDefinitions.category,
  sortOrder: 7,
  localizedTitle: localeMapFromPrimary(
    'Work / INPS / Patronato',
    it: 'Lavoro / INPS / Patronato',
    fr: 'Travail / INPS / Patronato',
    es: 'Trabajo / INPS / Patronato',
    fa: 'کار / INPS / Patronato',
    ar: 'العمل / INPS / Patronato',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Need help with work documents, INPS, patronato, ISEE, NASpI, or family support requests?',
    it: 'Ti serve aiuto con documenti di lavoro, INPS, patronato, ISEE, NASpI o richieste di sostegno familiare?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Use this area for INPS and patronato flows, work paperwork, unemployment support, ISEE-related steps, and formal follow-up.',
    it: 'Usa questa sezione per pratiche INPS e patronato, documenti di lavoro, sostegni alla disoccupazione, passaggi legati all’ISEE e follow-up formali.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'work',
  color: '#059669',
  tags: const ['work', 'inps', 'patronato', 'isee', 'naspi'],
  searchableKeywords: const ['inps', 'naspi', 'patronato', 'isee', 'caf'],
  isProcedurePremium: (slug) =>
      slug.contains('naspi') ||
      slug.contains('isee') ||
      slug.contains('benefit') ||
      slug.contains('bonus') ||
      slug.contains('support'),
  procedureMonetizationType: (slug) =>
      slug.contains('naspi') ||
          slug.contains('isee') ||
          slug.contains('benefit') ||
          slug.contains('bonus') ||
          slug.contains('support')
      ? 'premium_money_value'
      : 'free',
);
