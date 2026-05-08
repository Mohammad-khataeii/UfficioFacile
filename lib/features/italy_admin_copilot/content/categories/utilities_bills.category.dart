import '../../data/utilities_electricity_gas_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final utilitiesBillsCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: utilitiesElectricityGasTorino,
  sortOrder: 3,
  localizedTitle: localeMapFromPrimary(
    'Bills & utilities',
    it: 'Bollette e utenze',
    fr: 'Factures et services',
    es: 'Facturas y suministros',
    fa: 'قبض‌ها و خدمات',
    ar: 'الفواتير والخدمات',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Need help with electricity, gas, water, provider changes, refunds, or a bill that looks wrong?',
    it: 'Ti serve aiuto con luce, gas, acqua, cambio gestore, rimborsi o una bolletta che sembra sbagliata?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Use this area for utility bills, contracts, provider complaints, switching, and the practical steps that help you fix service or cost problems.',
    it: 'Usa questa sezione per bollette, contratti, reclami verso il gestore, cambio fornitore e passaggi pratici per risolvere problemi di servizio o di costo.',
  ),
  isPremium: true,
  monetizationType: 'premium_money_value',
  icon: 'bolt',
  color: '#0EA5E9',
  tags: const ['utilities', 'bills', 'electricity', 'gas', 'water'],
  searchableKeywords: const [
    'bollette',
    'utility',
    'electricity',
    'gas',
    'refund',
  ],
  premiumReason: localeMapFromPrimary(
    'This category includes money-saving guidance, bill disputes, switching strategy, and public discount workflows.',
    it: 'Questa categoria include guide per risparmiare, contestare bollette, cambiare gestore e usare agevolazioni pubbliche.',
  ),
);
