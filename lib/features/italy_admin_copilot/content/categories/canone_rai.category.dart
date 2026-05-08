import '../../data/canone_rai_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final canoneRaiCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: canoneRaiTorino,
  sortOrder: 4,
  localizedTitle: localeMapFromPrimary(
    'Canone RAI',
    it: 'Canone RAI',
    fr: 'Canone RAI',
    es: 'Canone RAI',
    fa: 'عوارض RAI',
    ar: 'رسم RAI',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Do you need to understand the TV fee, request an exemption, or fix a wrong charge?',
    it: 'Vuoi capire il canone TV, chiedere un’esenzione o correggere un addebito errato?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Start here to understand how the RAI fee works, when an exemption may apply, and how to handle disputes or incorrect charges.',
    it: 'Parti da qui per capire come funziona il canone RAI, quando può spettare un’esenzione e come gestire contestazioni o addebiti errati.',
  ),
  isPremium: true,
  monetizationType: 'premium_money_value',
  icon: 'tv',
  color: '#2563EB',
  tags: const ['canone rai', 'tv fee', 'exemption', 'refund'],
  searchableKeywords: const ['canone rai', 'tv tax', 'exemption', 'refund'],
  premiumReason: localeMapFromPrimary(
    'This category can help you avoid unnecessary charges or recover money from a wrong RAI fee workflow.',
    it: 'Questa categoria può aiutarti a evitare addebiti non dovuti o recuperare denaro da una pratica RAI errata.',
  ),
);
