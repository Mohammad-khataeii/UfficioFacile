import '../../data/health_asl_guidance_definitions.dart';
import '../models/cms_seed_models.dart';

final healthAslCategorySeed = CmsCategorySeed.fromRichGuidance(
  guidance: healthAslGuidanceToRichCategory(healthAslGetTesseraSanitariaTorino),
  sortOrder: 1,
  localizedTitle: localeMapFromPrimary(
    'Health / ASL',
    it: 'Salute / ASL',
    fr: 'Santé / ASL',
    es: 'Salud / ASL',
    fa: 'سلامت / ASL',
    ar: 'الصحة / ASL',
  ),
  localizedSubtitle: localeMapFromPrimary(
    'Do you need help with the health card, SSN registration, your family doctor, or an ASL request?',
    it: 'Hai bisogno di aiuto con tessera sanitaria, iscrizione al SSN, medico di base o una pratica ASL?',
    fr: 'Avez-vous besoin d’aide pour la carte sanitaire, l’inscription au SSN, le médecin traitant ou une démarche ASL ?',
    es: '¿Necesitas ayuda con la tarjeta sanitaria, la inscripción al SSN, el médico de cabecera o un trámite ASL?',
    fa: 'برای کارت سلامت، ثبت‌نام SSN، پزشک خانواده یا یک درخواست ASL به کمک نیاز داری؟',
    ar: 'هل تحتاج إلى مساعدة بخصوص البطاقة الصحية أو التسجيل في SSN أو طبيب الأسرة أو إجراء لدى ASL؟',
  ),
  localizedDescription: localeMapFromPrimary(
    'Use this area for public healthcare access in Italy: health card, SSN registration, doctor choice, ASL documents, and essential health administration.',
    it: 'Usa questa sezione per l’accesso alla sanità pubblica in Italia: tessera sanitaria, iscrizione SSN, scelta del medico, documenti ASL e pratiche sanitarie essenziali.',
    fr: 'Utilisez cette section pour l’accès à la santé publique en Italie : carte sanitaire, inscription au SSN, choix du médecin, documents ASL et démarches sanitaires essentielles.',
    es: 'Usa esta sección para el acceso a la sanidad pública en Italia: tarjeta sanitaria, inscripción al SSN, elección de médico, documentos ASL y trámites sanitarios esenciales.',
    fa: 'از این بخش برای دسترسی به خدمات درمانی عمومی در ایتالیا استفاده کن: کارت سلامت، ثبت‌نام SSN، انتخاب پزشک، مدارک ASL و کارهای ضروری درمانی.',
    ar: 'استخدم هذا القسم للوصول إلى الرعاية الصحية العامة في إيطاليا: البطاقة الصحية، التسجيل في SSN، اختيار الطبيب، مستندات ASL والإجراءات الصحية الأساسية.',
  ),
  isPremium: false,
  monetizationType: 'free',
  icon: 'health_and_safety',
  color: '#0F766E',
  tags: const ['health', 'asl', 'ssn', 'doctor', 'tessera sanitaria'],
  searchableKeywords: const ['health card', 'ssn', 'family doctor', 'asl'],
  isProcedurePremium: (slug) =>
      slug.contains('insurance') ||
      slug.contains('refund') ||
      slug.contains('reimbursement'),
  procedureMonetizationType: (slug) =>
      slug.contains('insurance') ||
          slug.contains('refund') ||
          slug.contains('reimbursement')
      ? 'premium_money_value'
      : 'free',
);
