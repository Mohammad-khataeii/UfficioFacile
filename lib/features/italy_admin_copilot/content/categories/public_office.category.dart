import '../../data/public_office_comune_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final publicOfficeCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: PublicOfficeComuneGuidanceDefinitions.category,
  sortOrder: 6,
  localizedTitle: localeMapFromPrimary(
    'Public office / Comune',
    it: 'Uffici pubblici / Comune',
    fr: 'Bureau public / Commune',
    es: 'Oficina pública / Comune',
    fa: 'ادارات عمومی / Comune',
    ar: 'المكاتب العامة / البلدية',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Do you need help with residence, certificates, identity documents, or another Comune request?',
    it: 'Hai bisogno di aiuto con residenza, certificati, documenti di identità o un’altra pratica del Comune?',
  ),
  localizedDescription: localeMapFromPrimary(
    'Start here for anagrafe, residence changes, certificates, appointments, and the practical steps for Comune paperwork.',
    it: 'Parti da qui per anagrafe, cambio residenza, certificati, appuntamenti e passaggi pratici per le pratiche del Comune.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'account_balance',
  color: '#475569',
  tags: const ['comune', 'anagrafe', 'residence', 'certificate'],
  searchableKeywords: const ['comune', 'residenza', 'anagrafe', 'certificato'],
);
